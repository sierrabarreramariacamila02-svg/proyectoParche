import express from 'express';
import detalleController from '../controller/detallePedido.js';
import { verificarToken } from '../middlewares/auth.js';

const router = express.Router();

router.get('/pedido/:pedido_id', verificarToken, detalleController.listarPorPedido);
router.post('/', verificarToken, detalleController.agregarItem);
router.put('/:id', verificarToken, detalleController.actualizarItem);
router.delete('/:id', verificarToken, detalleController.eliminarItem);

export default router;