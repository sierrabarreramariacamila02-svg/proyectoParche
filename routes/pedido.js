const express = require('express');
const router = express.Router();
const pedidoController = require('../controller/pedido');
const { verificarToken } = require('../middlewares/auth');

router.post('/', verificarToken, pedidoController.crear);
router.get('/:id', verificarToken, pedidoController.obtenerPorId);
router.get('/usuario/:usuario_id', verificarToken, pedidoController.listarPorUsuario);
router.get('/estado/:estado', verificarToken, pedidoController.listarPorEstado);
router.patch('/:id/estado', verificarToken, pedidoController.cambiarEstado);
router.patch('/:id/domiciliario', verificarToken, pedidoController.asignarDomiciliario);

module.exports = router;
