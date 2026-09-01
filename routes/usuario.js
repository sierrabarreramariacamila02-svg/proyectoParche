const express = require('express');
const router = express.Router();
const usuarioController = require('../controller/usuario');
const { verificarToken, verificarRol } = require('../middlewares/auth');

router.post('/registro', usuarioController.registrar);
router.post('/login', usuarioController.login);
router.get('/perfil', verificarToken, usuarioController.perfil);
router.get('/', verificarToken, verificarRol('admin'), usuarioController.listar);
router.put('/:id', verificarToken, usuarioController.actualizar);
router.delete('/:id', verificarToken, verificarRol('admin'), usuarioController.eliminar);

module.exports = router;
