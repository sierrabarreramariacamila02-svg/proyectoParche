import express from 'express';
import { listarProductos, obtenerProducto, crear, editar, eliminar } from '../controllers/producto.js';
import { verificarToken, verificarAdmin } from '../middlewares/authmiddleware.js';

const router = express.Router();

router.get('/', listarProductos);
router.get('/:id', obtenerProducto);
router.post('/', verificarToken, verificarAdmin, crear);
router.put('/:id', verificarToken, verificarAdmin, editar);
router.delete('/:id', verificarToken, verificarAdmin, eliminar);

export default router;