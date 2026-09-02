import express from 'express';
import { listarPedidos, misPedidos, obtenerPedido, crear, editar, eliminar } from '../controllers/pedido.js';
import { verificarToken, verificarRol, verificarAdmin } from '../middlewares/authmiddleware.js';

const router = express.Router();

router.get('/', verificarToken, verificarRol('admin', 'cocina', 'mesero', 'domiciliario'), listarPedidos);
router.get('/mis-pedidos', verificarToken, misPedidos);
router.get('/:id', verificarToken, obtenerPedido);
router.post('/', verificarToken, crear);
router.put('/:id', verificarToken, verificarRol('admin', 'cocina', 'mesero'), editar);
router.delete('/:id', verificarToken, verificarAdmin, eliminar);

export default router;