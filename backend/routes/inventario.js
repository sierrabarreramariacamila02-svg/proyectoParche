import { Router } from 'express';
import { verificarAdmin, verificarToken } from '../middlewares/authmiddleware.js';
import { actualizar, crear, eliminar, obtenerInventario } from '../controllers/inventario.js';

const router = Router();

router.use(verificarToken, verificarAdmin);
router.get('/', obtenerInventario);
router.post('/', crear);
router.put('/:id', actualizar);
router.delete('/:id', eliminar);

export default router;
