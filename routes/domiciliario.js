const express = require('express');
const router = express.Router();
const domiciliarioController = require('../controller/domiciliario');
const { verificarToken, verificarRol } = require('../middlewares/auth');

router.get('/', verificarToken, verificarRol('admin'), domiciliarioController.listar);
router.get('/disponibles', verificarToken, domiciliarioController.listarDisponibles);
router.get('/:id', verificarToken, domiciliarioController.obtenerPorId);
router.post('/', verificarToken, verificarRol('admin'), domiciliarioController.crear);
router.put('/:id', verificarToken, domiciliarioController.actualizar);
router.patch('/:id/disponibilidad', verificarToken, domiciliarioController.cambiarDisponibilidad);

module.exports = router;
