const express = require('express');
const router = express.Router();
const mensajesController = require('../controller/mensajes');
const { verificarToken } = require('../middlewares/auth');

router.post('/', verificarToken, mensajesController.enviar);
router.get('/pedido/:pedido_id', verificarToken, mensajesController.listarPorPedido);
router.patch('/:id/leido', verificarToken, mensajesController.marcarLeido);

module.exports = router;
