const express = require('express');
const router = express.Router();
const calificacionController = require('../controller/calificacion');
const { verificarToken } = require('../middlewares/auth');
// En routes/calificacion.js
router.post('/', verificarToken, calificacionController.crearCalificacion);
router.get('/pedido/:pedido_id', verificarToken, calificacionController.obtenerPorPedido);
router.get('/usuario/:usuario_id', verificarToken, calificacionController.listarPorUsuario);
router.get('/promedio', calificacionController.promedioGeneral);

module.exports = router;
