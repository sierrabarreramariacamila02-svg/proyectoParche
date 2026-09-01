const express = require('express');
const router = express.Router();
const detalleController = require('../controller/detallePedido');
const { verificarToken } = require('../middlewares/auth');

router.get('/pedido/:pedido_id', verificarToken, detalleController.listarPorPedido);
router.post('/', verificarToken, detalleController.agregarItem);
router.put('/:id', verificarToken, detalleController.actualizarItem);
router.delete('/:id', verificarToken, detalleController.eliminarItem);

module.exports = router;
