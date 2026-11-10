import { Router } from 'express';
import { verificarAdmin, verificarRol, verificarToken } from '../middlewares/authmiddleware.js';
import { actualizar, crear, eliminar, obtenerInventario } from '../controllers/inventario.js';

const router = Router();

router.get(
  '/',
  verificarToken,
  verificarRol('admin', 'administrador', 'cocina', 'cocinero'),
  obtenerInventario,
);
router.post('/', verificarToken, verificarAdmin, crear);
router.put('/:id', verificarToken, verificarAdmin, actualizar);
router.delete('/:id', verificarToken, verificarAdmin, eliminar);

export default router;
