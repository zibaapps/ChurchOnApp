const functions = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');

try { admin.initializeApp(); } catch (_) {}
const db = admin.firestore();

function computeFee(amount) {
  const pct = amount * 0.05;
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

const processedRefs = new Set();

exports.mtnCallback = functions.https.onRequest(async (req, res) => {
  try {
    if (!verifySignature(req, process.env.MTN_SECRET)) return res.status(401).json({ error: 'invalid signature' });
    const payload = req.body || {};
    const providerRef = payload.reference || payload.transactionId || '';
    if (processedRefs.has(providerRef)) return res.json({ ok: true });
    processedRefs.add(providerRef);
    const status = (payload.status || '').toLowerCase(); // success|failed|pending
    if (!providerRef) return res.status(400).json({ error: 'missing reference' });

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
    if (processedRefs.has(providerRef)) return res.json({ ok: true });
    processedRefs.add(providerRef);
    const status = (payload.status || '').toLowerCase();
    if (!providerRef) return res.status(400).json({ error: 'missing reference' });

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