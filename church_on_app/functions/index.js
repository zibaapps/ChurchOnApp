const functions = require('firebase-functions');
const admin = require('firebase-admin');

try { admin.initializeApp(); } catch (_) {}
const db = admin.firestore();

function computeFee(amount) {
  const pct = amount * 0.05;
  return pct < 0.5 ? 0.5 : pct;
}

exports.mtnCallback = functions.https.onRequest(async (req, res) => {
  try {
    const payload = req.body || {};
    const providerRef = payload.reference || payload.transactionId || '';
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
    const payload = req.body || {};
    const providerRef = payload.reference || payload.transactionId || '';
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