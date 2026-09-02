import express from 'express';
import { listarPorPedido, crear, editar, eliminar } from '../controllers/detallePedido.js';
import { verificarToken } from '../middlewares/authmiddleware.js';

const router = express.Router();

router.get('/pedido/:pedidoId', verificarToken, listarPorPedido);
router.post('/', verificarToken, crear);
router.put('/:id', verificarToken, editar);
router.delete('/:id', verificarToken, eliminar);

export default router;