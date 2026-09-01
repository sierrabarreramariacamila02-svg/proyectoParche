import express from 'express';
import { listar, porPedido, crear, editar, eliminar } from '../controllers/calificacion.js';
import { verificarToken, verificarAdmin } from '../middlewares/authmiddleware.js';

const router = express.Router();

router.get('/', listar);
router.get('/pedido/:pedidoId', porPedido);
router.post('/', verificarToken, crear);
router.put('/:id', verificarToken, editar);
router.delete('/:id', verificarToken, verificarAdmin, eliminar);

export default router;