import express from 'express';
import {
    getUsuariosController,
    getUsuarioPorIdController,
    actualizarUsuarioController,
    eliminarUsuarioController
} from '../controllers/usuario.js';
import { verificarToken, verificarAdmin } from '../middlewares/authmiddleware.js';

const router = express.Router();

router.get('/', verificarToken, verificarAdmin, getUsuariosController);
router.get('/:id', verificarToken, getUsuarioPorIdController);
router.put('/:id', verificarToken, actualizarUsuarioController);
router.delete('/:id', verificarToken, verificarAdmin, eliminarUsuarioController);

export default router;