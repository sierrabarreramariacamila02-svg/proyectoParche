import express from 'express';
import {
    getUsuariosController,
    crearUsuarioAdminController,
    getUsuarioPorIdController,
    actualizarRolUsuarioController,
    actualizarUsuarioController,
    eliminarUsuarioController
} from '../controllers/usuario.js';
import { verificarToken, verificarAdmin } from '../middlewares/authmiddleware.js';

const router = express.Router();

router.get('/', verificarToken, verificarAdmin, getUsuariosController);
router.post('/', verificarToken, verificarAdmin, crearUsuarioAdminController);
router.put('/:id/rol', verificarToken, verificarAdmin, actualizarRolUsuarioController);
router.get('/:id', verificarToken, getUsuarioPorIdController);
router.put('/:id', verificarToken, actualizarUsuarioController);
router.delete('/:id', verificarToken, verificarAdmin, eliminarUsuarioController);

export default router;