import express from 'express';
import calificacionController from '../controller/calificacion.js';
import { verificarToken } from '../middlewares/auth.js';

const router = express.Router();

// En routes/calificacion.js
router.post('/', verificarToken, calificacionController.crearCalificacion);
router.get('/pedido/:pedido_id', verificarToken, calificacionController.obtenerPorPedido);
router.get('/usuario/:usuario_id', verificarToken, calificacionController.listarPorUsuario);
router.get('/promedio', calificacionController.promedioGeneral);

export default router;