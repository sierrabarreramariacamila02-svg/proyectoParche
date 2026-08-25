import express from 'express';
import usuarioController from '../controller/usuario.js';
import { verificarToken, verificarRol } from '../middlewares/auth.js';

const router = express.Router();

router.post('/registro', usuarioController.registrar);
router.post('/login', usuarioController.login);
router.get('/perfil', verificarToken, usuarioController.perfil);
router.get('/', verificarToken, verificarRol('admin'), usuarioController.listar);
router.put('/:id', verificarToken, usuarioController.actualizar);
router.delete('/:id', verificarToken, verificarRol('admin'), usuarioController.eliminar);

export default router;