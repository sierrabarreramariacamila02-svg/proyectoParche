import express from 'express';
import { cambiarPassword } from '../controllers/recuperar.js';
import { verificarToken } from '../middlewares/authmiddleware.js';

const router = express.Router();

router.put('/password', verificarToken, cambiarPassword);

export default router;