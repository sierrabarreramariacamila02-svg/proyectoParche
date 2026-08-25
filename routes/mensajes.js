import express from 'express';
import mensajesController from '../controller/mensajes.js';
import { verificarToken } from '../middlewares/auth.js';

const router = express.Router();

router.post('/', verificarToken, mensajesController.enviar);
router.get('/pedido/:pedido_id', verificarToken, mensajesController.listarPorPedido);
router.patch('/:id/leido', verificarToken, mensajesController.marcarLeido);

export default router;