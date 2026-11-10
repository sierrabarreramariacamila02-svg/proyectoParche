const admin = require('firebase-admin');
const path = require('path');

// Apunta al archivo firebase-admin.json que está en la raíz del backend
const serviceAccount = require(path.join(__dirname, '../firebase-admin.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

module.exports = admin;