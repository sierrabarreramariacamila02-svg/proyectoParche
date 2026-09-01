import express from 'express';
import recuperarController from '../controller/recuperar.js';

const router = express.Router();

router.post('/solicitar', recuperarController.solicitarRecuperacion);
router.post('/restablecer', recuperarController.restablecerContrasena);

export default router;