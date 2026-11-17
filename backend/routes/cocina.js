import express from 'express';
import {
    listar,
    crear,
    editar,
    notificarPedidoListo,
} from '../controllers/cocina.js';
import { verificarToken, verificarRol } from '../middlewares/authmiddleware.js';

const router = express.Router();

router.get('/', verificarToken, verificarRol('admin', 'administrador', 'cocina', 'cocinero'), listar);
router.post(
    '/notificar-pedido-listo',
    verificarToken,
    verificarRol('admin', 'administrador', 'cocina', 'cocinero'),
    notificarPedidoListo
);
router.post('/', verificarToken, verificarRol('admin', 'administrador', 'cocina', 'cocinero'), crear);
router.put('/:id', verificarToken, verificarRol('admin', 'administrador', 'cocina', 'cocinero'), editar);

export default router;