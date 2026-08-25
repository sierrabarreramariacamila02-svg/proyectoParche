import express from 'express';
import pedidoController from '../controller/pedido.js';
import { verificarToken } from '../middlewares/auth.js';

const router = express.Router();

router.post('/', verificarToken, pedidoController.crear);
router.get('/:id', verificarToken, pedidoController.obtenerPorId);
router.get('/usuario/:usuario_id', verificarToken, pedidoController.listarPorUsuario);
router.get('/estado/:estado', verificarToken, pedidoController.listarPorEstado);
router.patch('/:id/estado', verificarToken, pedidoController.cambiarEstado);
router.patch('/:id/domiciliario', verificarToken, pedidoController.asignarDomiciliario);

export default router;