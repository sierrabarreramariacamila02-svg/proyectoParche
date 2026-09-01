import express from 'express';
import { listar, crear, editar } from '../controllers/domiciliario.js';
import { verificarToken, verificarRol, verificarAdmin } from '../middlewares/authmiddleware.js';

const router = express.Router();

router.get('/', verificarToken, verificarRol('admin', 'domiciliario'), listar);
router.post('/', verificarToken, verificarAdmin, crear);
router.put('/:id', verificarToken, verificarRol('admin', 'domiciliario'), editar);

export default router;