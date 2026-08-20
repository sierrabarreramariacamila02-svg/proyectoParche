const express = require('express');
const router = express.Router();
const meseroController = require('../controller/mesero');
const { verificarToken, verificarRol } = require('../middlewares/auth');

router.get('/', verificarToken, verificarRol('admin'), meseroController.listar);
router.get('/:id', verificarToken, meseroController.obtenerPorId);
router.post('/', verificarToken, verificarRol('admin'), meseroController.crear);
router.put('/:id', verificarToken, meseroController.actualizar);
router.delete('/:id', verificarToken, verificarRol('admin'), meseroController.eliminar);
router.post('/pedido-mesa', verificarToken, verificarRol('mesero', 'admin'), meseroController.crearPedidoEnMesa);

module.exports = router;
