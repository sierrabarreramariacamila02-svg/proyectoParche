import express from 'express';
import { listar, crear, editar } from '../controllers/cocina.js';
import { verificarToken, verificarRol } from '../middlewares/authmiddleware.js';

const router = express.Router();

router.get('/', verificarToken, verificarRol('admin', 'cocina', 'cocinero'), listar);
router.post('/', verificarToken, verificarRol('admin', 'cocina', 'cocinero'), crear);
router.put('/:id', verificarToken, verificarRol('admin', 'cocina', 'cocinero'), editar);

export default router;