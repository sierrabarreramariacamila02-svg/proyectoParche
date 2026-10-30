import express from 'express';
import {
    getUsuariosController,
    crearUsuarioAdminController,
    getUsuarioPorIdController,
    getMiPerfilController,
    actualizarMiPerfilController,
    actualizarRolUsuarioController,
    actualizarUsuarioController,
    eliminarUsuarioController
} from '../controllers/usuario.js';
import { verificarToken, verificarAdmin } from '../middlewares/authmiddleware.js';
import upload from '../middlewares/multer.js';

const router = express.Router();

router.get('/', verificarToken, verificarAdmin, getUsuariosController);
router.post('/', verificarToken, verificarAdmin, crearUsuarioAdminController);
router.put('/:id/rol', verificarToken, verificarAdmin, actualizarRolUsuarioController);
router.get('/perfil', verificarToken, getMiPerfilController);
router.put('/perfil', verificarToken, upload.single('avatar'), actualizarMiPerfilController);
router.get('/:id', verificarToken, getUsuarioPorIdController);
router.put('/:id', verificarToken, actualizarUsuarioController);
router.delete('/:id', verificarToken, verificarAdmin, eliminarUsuarioController);

export default router;