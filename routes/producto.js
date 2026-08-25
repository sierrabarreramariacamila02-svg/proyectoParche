import express from 'express';
import productoController from '../controller/producto.js';
import { verificarToken, verificarRol } from '../middlewares/auth.js';
import { upload } from '../config/cloudinary.js';
const router = express.Router();

router.get('/', productoController.listar);
router.get('/disponibles', productoController.listarDisponibles);
router.get('/:id', productoController.obtenerPorId);
router.post('/', verificarToken, verificarRol('admin'), upload.single('imagen'), productoController.crear);
router.put('/:id', verificarToken, verificarRol('admin'), upload.single('imagen'), productoController.actualizar);
router.delete('/:id', verificarToken, verificarRol('admin'), productoController.eliminar);

export default router;