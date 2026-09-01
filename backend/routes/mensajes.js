import express from 'express';
import { listarConversaciones, nuevaConversacion, obtenerConversacion, listarMensajes, enviarMensaje } from '../controllers/mensajes.js';
import { verificarToken } from '../middlewares/authmiddleware.js';

const router = express.Router();

router.get('/conversaciones', verificarToken, listarConversaciones);
router.post('/conversaciones', verificarToken, nuevaConversacion);
router.get('/conversaciones/:id', verificarToken, obtenerConversacion);
router.get('/conversaciones/:conversacionId/mensajes', verificarToken, listarMensajes);
router.post('/conversaciones/:conversacionId/mensajes', verificarToken, enviarMensaje);

export default router;