const express = require('express');
const router = express.Router();
const recuperarController = require('../controller/recuperar');

router.post('/solicitar', recuperarController.solicitarRecuperacion);
router.post('/restablecer', recuperarController.restablecerContrasena);

module.exports = router;