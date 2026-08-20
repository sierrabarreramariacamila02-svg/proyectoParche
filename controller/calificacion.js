const calificacionModel = require('../models/calificacion');
const {exito, error} = require('../utils/respuestas');

const crearCalificacion = async (req, res) => {
try {

const {pedido_id, usuario_id, puntuacion, comentario} = req.body;
if(!pedido_id || !usuario_id || !puntuacion || !comentario){
  return error(res, 'pedido, usuario y puntuacion son requeridos', 400);
}
if (puntuacion < 1 || puntuacion > 5) {
  return error(res, 'la puntuación debe estar entre 1 y 5', 400);
}
const calificacion = await calificacionModel.crearCalificacion({
  pedido_id,
  usuario_id,
  puntuacion,
  comentario
});
return exito(res, calificacion, 201);
  } catch (err) {
    return error(res, 'Error al crear calificación', 500, err.message);
  }
};

const obtenerPorPedido = async (req, res) => {
  try{
    const {pedido_id} = req.params;
    const calificaciones = await calificacionModel.obtenerPorPedido(pedido_id);
    return exito(res, calificaciones, 200);
  } catch (err) {
    return error(res, 'Error al obtener calificaciones', 500, err.message);
  }
};

const listarPorUsuario = async (req, res) => {
  try {
    const calificaciones = await calificacionModel.listarPorUsuario(req.params.usuario_id);
    return exito(res, calificaciones);
  } catch (err) {
    return error(res, 'Error al listar calificaciones', 500, err.message);
  }
};

const promedioGeneral = async (req, res) => {
  try {
    const promedio = await calificacionModel.promedioGeneral();
    return exito(res, { promedio });
  } catch (err) {
    return error(res, 'Error al calcular promedio', 500, err.message);
  }
};

module.exports = { crearCalificacion, obtenerPorPedido, listarPorUsuario, promedioGeneral };
