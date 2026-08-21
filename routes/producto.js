const express = require('express');
const router = express.Router();
const productoController = require('../controller/producto');
const { verificarToken, verificarRol } = require('../middlewares/auth');
const upload = require('../config/cloudinary');

router.get('/', productoController.listar);
router.get('/disponibles', productoController.listarDisponibles);
router.get('/:id', productoController.obtenerPorId);
router.post('/', verificarToken, verificarRol('admin'), upload.single('imagen'), productoController.crear);
router.put('/:id', verificarToken, verificarRol('admin'), upload.single('imagen'), productoController.actualizar);
router.delete('/:id', verificarToken, verificarRol('admin'), productoController.eliminar);

module.exports = router;
