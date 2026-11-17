import express from 'express';
import { listar, crear, editar, notificarPedidoMesa } from '../controllers/mesero.js';
import { verificarToken, verificarRol } from '../middlewares/authmiddleware.js';

const router = express.Router();

router.get('/', verificarToken, verificarRol('admin', 'mesero'), listar);
router.post(
    '/notificar-pedido',
    verificarToken,
    verificarRol('admin', 'mesero'),
    notificarPedidoMesa
);
router.post('/', verificarToken, verificarRol('admin', 'mesero'), crear);
router.put('/:id', verificarToken, verificarRol('admin', 'mesero'), editar);

export default router;