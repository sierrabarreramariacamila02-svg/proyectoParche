import express from 'express';
import { listarProductos, obtenerProducto, crear, editar, eliminar } from '../controllers/producto.js';
import { verificarToken, verificarAdmin } from '../middlewares/authmiddleware.js';
import upload from '../middlewares/multer.js';

const router = express.Router();

router.get('/', listarProductos);
router.get('/:id', obtenerProducto);


router.post('/', verificarToken, verificarAdmin, upload.single('imagen'), crear);

router.put('/:id', verificarToken, verificarAdmin, upload.single('imagen'), editar);

router.delete('/:id', verificarToken, verificarAdmin, eliminar);

export default router;