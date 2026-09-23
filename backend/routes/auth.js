import express from 'express';
import { login, registro, verificarCuenta, reenviarCodigo } from '../controllers/auth.js';

const router = express.Router();

router.post('/registro', registro);
router.post('/login', login);
router.post('/verificar', verificarCuenta);

//olvido de contrseña
router.post('/verificarCuenta', verificarCuenta);
router.post('/verify-code', verificarCuenta);

// Reenviar código cuando el anterior expiró
router.post('/reenviar-codigo', reenviarCodigo);

export default router;