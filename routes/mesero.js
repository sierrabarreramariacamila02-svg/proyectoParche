import express from 'express';
import meseroController from '../controller/mesero.js';
import { verificarToken, verificarRol } from '../middlewares/auth.js';

const router = express.Router();

router.get('/', verificarToken, verificarRol('admin'), meseroController.listar);
router.get('/:id', verificarToken, meseroController.obtenerPorId);
router.post('/', verificarToken, verificarRol('admin'), meseroController.crear);
router.put('/:id', verificarToken, meseroController.actualizar);
router.delete('/:id', verificarToken, verificarRol('admin'), meseroController.eliminar);
router.post('/pedido-mesa', verificarToken, verificarRol('mesero', 'admin'), meseroController.crearPedidoEnMesa);

export default router;