const express = require('express');
const router = express.Router();
const cocinaController = require('../controller/cocina');
const { verificarToken, verificarRol } = require('../middlewares/auth');

router.get('/pendientes', verificarToken, verificarRol('cocina', 'admin'), cocinaController.listarPendientes);
router.patch('/:pedido_id/iniciar', verificarToken, verificarRol('cocina', 'admin'), cocinaController.iniciarPreparacion);
router.patch('/:pedido_id/listo', verificarToken, verificarRol('cocina', 'admin'), cocinaController.marcarListo);

module.exports = router;
