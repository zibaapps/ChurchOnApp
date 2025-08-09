const functions = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');

try { admin.initializeApp(); } catch (_) {}
const db = admin.firestore();

function computeFee(amount) {
  const pct = amount * 0.005; // 0.5%
  return pct < 0.5 ? 0.5 : pct;
}

function verifySignature(req, secret) {
  // Example: HMAC of raw body with shared secret in header 'x-signature'
  try {
    const sig = req.headers['x-signature'] || req.headers['x-pay-signature'];
    if (!sig || !secret) return false;
    const h = crypto.createHmac('sha256', secret).update(req.rawBody || JSON.stringify(req.body || {})).digest('hex');
    return sig === h;
  } catch (e) {
    console.error('verifySignature error', e);
    return false;
  }
}

async function claimIdempotency(providerRef, ttlMinutes = 60) {
  if (!providerRef) return false;
  const ref = db.collection('webhook_dedup').doc(providerRef);
  try {
    await ref.create({ createdAt: admin.firestore.FieldValue.serverTimestamp(), ttlMinutes });
    return true;
  } catch (e) {
    // Already exists
    return false;
  }
}

exports.mtnCallback = functions.https.onRequest(async (req, res) => {
  try {
    if (!verifySignature(req, process.env.MTN_SECRET)) return res.status(401).json({ error: 'invalid signature' });
    const payload = req.body || {};
    const providerRef = payload.reference || payload.transactionId || '';
    if (!providerRef) return res.status(400).json({ error: 'missing reference' });

    const firstClaim = await claimIdempotency(providerRef);
    if (!firstClaim) return res.json({ ok: true, dedup: true });

    const status = (payload.status || '').toLowerCase(); // success|failed|pending

    const q = await db.collectionGroup('payments').where('providerRef', '==', providerRef).limit(1).get();
    if (q.empty) return res.status(404).json({ error: 'payment not found' });
    const doc = q.docs[0];
    const data = doc.data();

    let finalStatus = status === 'successful' ? 'success' : status;
    if (finalStatus !== 'success' && finalStatus !== 'failed') finalStatus = 'failed';

    await doc.ref.update({ status: finalStatus, updatedAt: new Date().toISOString() });

    if (finalStatus === 'success') {
      const fee = computeFee(data.amount);
      await db.collection('superadmin_ledger').add({
        churchId: data.churchId || doc.ref.parent.parent.id,
        fee,
        source: 'mtn',
        createdAt: new Date().toISOString(),
      });
    }
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

exports.airtelCallback = functions.https.onRequest(async (req, res) => {
  try {
    if (!verifySignature(req, process.env.AIRTEL_SECRET)) return res.status(401).json({ error: 'invalid signature' });
    const payload = req.body || {};
    const providerRef = payload.reference || payload.transactionId || '';
    if (!providerRef) return res.status(400).json({ error: 'missing reference' });

    const firstClaim = await claimIdempotency(providerRef);
    if (!firstClaim) return res.json({ ok: true, dedup: true });

    const status = (payload.status || '').toLowerCase();

    const q = await db.collectionGroup('payments').where('providerRef', '==', providerRef).limit(1).get();
    if (q.empty) return res.status(404).json({ error: 'payment not found' });
    const doc = q.docs[0];
    const data = doc.data();

    let finalStatus = status === 'successful' ? 'success' : status;
    if (finalStatus !== 'success' && finalStatus !== 'failed') finalStatus = 'failed';

    await doc.ref.update({ status: finalStatus, updatedAt: new Date().toISOString() });

    if (finalStatus === 'success') {
      const fee = computeFee(data.amount);
      await db.collection('superadmin_ledger').add({
        churchId: data.churchId || doc.ref.parent.parent.id,
        fee,
        source: 'airtel',
        createdAt: new Date().toISOString(),
      });
    }
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.message });
  }
});

// Reconciliation job: mark old pending payments as failed after timeout (placeholder until real provider checks)
exports.reconcilePendingPayments = functions.pubsub.schedule('every 30 minutes').onRun(async () => {
  const cutoff = Date.now() - 1000 * 60 * 60; // 1 hour
  const q = await db.collectionGroup('payments').where('status', '==', 'pending').limit(200).get();
  const batch = db.batch();
  q.forEach((doc) => {
    const d = doc.data();
    const created = new Date(d.createdAt || 0).getTime();
    if (created && created < cutoff) {
      batch.update(doc.ref, { status: 'failed', updatedAt: new Date().toISOString() });
    }
  });
  if (!q.empty) await batch.commit();
  return null;
});

// Privacy: user export and deletion requests (stubs)
exports.requestDataExport = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Sign in required');
  const uid = context.auth.uid;
  await db.collection('privacy_exports').doc(uid).set({
    requestedAt: new Date().toISOString(),
    status: 'queued',
  }, { merge: true });
  return { ok: true };
});

exports.requestAccountDeletion = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Sign in required');
  const uid = context.auth.uid;
  await db.collection('deletion_requests').doc(uid).set({
    requestedAt: new Date().toISOString(),
    status: 'queued',
  }, { merge: true });
  return { ok: true };
});

// Auto-generate thumbnails (placeholder: returns a generated URL based on title)
exports.generateThumbnail = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Sign in required');
  const { collection, churchId, docId, title } = data || {};
  if (!collection || !churchId || !docId) throw new functions.https.HttpsError('invalid-argument', 'Missing fields');

  const ref = db.collection('churches').doc(churchId).collection(collection).doc(docId);
  const snap = await ref.get();
  if (!snap.exists) throw new functions.https.HttpsError('not-found', 'Document not found');
  const d = snap.data() || {};

  // If already has a thumbnail or an image (news), or previously generated, return existing and do not overwrite
  if (d.thumbnailUrl || d.imageUrl || d.thumbnailGenerated) {
    return { url: d.thumbnailUrl || d.imageUrl || null, skipped: true };
  }

  // TODO: call real image generation provider; for now, create a placeholder URL using a service (e.g., dummyimage.com)
  const encoded = encodeURIComponent((title || d.title || 'Image').toString().slice(0, 30));
  const url = `https://dummyimage.com/600x338/6750A4/ffffff&text=${encoded}`;

  const update = { updatedAt: new Date().toISOString(), thumbnailGenerated: true };
  if (collection === 'sermons') update.thumbnailUrl = url;
  if (collection === 'news') update.imageUrl = url;

  await ref.update(update);
  return { url };
});