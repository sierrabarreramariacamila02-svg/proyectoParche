import express from 'express';
import { listarPedidos, misPedidos, obtenerPedido, crear, editar, eliminar, actualizarEstado } from '../controllers/pedido.js';
import { verificarToken, verificarRol, verificarAdmin } from '../middlewares/authmiddleware.js';

const router = express.Router();

router.get('/', verificarToken, verificarRol('admin', 'administrador', 'cocina', 'cocinero', 'mesero', 'domiciliario'), listarPedidos);
router.get('/mis-pedidos', verificarToken, verificarRol('usuario'), misPedidos);
router.get('/:id', verificarToken, obtenerPedido);
router.post('/', verificarToken, crear);
router.put('/:id', verificarToken, verificarRol('admin', 'cocina', 'cocinero', 'mesero'), editar);
router.delete('/:id', verificarToken, verificarAdmin, eliminar);
router.put('/:id/estado', verificarToken, verificarRol('admin', 'administrador', 'cocina', 'cocinero', 'mesero'), actualizarEstado);

export default router;