import express from 'express';
import { listar, crear, editar, eliminar } from '../controllers/destacado.js';
import { verificarToken, verificarAdmin } from '../middlewares/authmiddleware.js';
import upload from '../middlewares/multer.js';

const router = express.Router();

// Pública: el home la usa para mostrar los destacados
router.get('/', listar);

// Solo administrador
router.post('/', verificarToken, verificarAdmin, upload.single('imagen'), crear);
router.put('/:id', verificarToken, verificarAdmin, upload.single('imagen'), editar);
router.delete('/:id', verificarToken, verificarAdmin, eliminar);

export default router;