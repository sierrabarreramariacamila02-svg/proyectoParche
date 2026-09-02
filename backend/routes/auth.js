import express from 'express';
import { login, registro, verificarCuenta } from '../controllers/auth.js';

const router = express.Router();

router.post('/registro', registro);
router.post('/login', login);
router.post('/verificar', verificarCuenta);


export default router;