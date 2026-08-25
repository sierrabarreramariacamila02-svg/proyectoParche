import express from 'express';
import domiciliarioController from '../controller/domiciliario.js';
import { verificarToken, verificarRol } from '../middlewares/auth.js';

const router = express.Router();

router.get('/', verificarToken, verificarRol('admin'), domiciliarioController.listar);
router.get('/disponibles', verificarToken, domiciliarioController.listarDisponibles);
router.get('/:id', verificarToken, domiciliarioController.obtenerPorId);
router.post('/', verificarToken, verificarRol('admin'), domiciliarioController.crear);
router.put('/:id', verificarToken, domiciliarioController.actualizar);
router.patch('/:id/disponibilidad', verificarToken, domiciliarioController.cambiarDisponibilidad);

export default router;