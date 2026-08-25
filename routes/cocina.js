import express from 'express';
import cocinaController from '../controller/cocina.js';
import { verificarToken, verificarRol } from '../middlewares/auth.js';

const router = express.Router();

router.get('/pendientes', verificarToken, verificarRol('cocina', 'admin'), cocinaController.listarPendientes);
router.patch('/:pedido_id/iniciar', verificarToken, verificarRol('cocina', 'admin'), cocinaController.iniciarPreparacion);
router.patch('/:pedido_id/listo', verificarToken, verificarRol('cocina', 'admin'), cocinaController.marcarListo);

export default router;