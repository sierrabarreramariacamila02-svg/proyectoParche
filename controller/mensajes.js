const mensajesModel = require('../models/mensajes');
const { exito, error } = require('../utils/respuestas');

const enviar = async (req, res) => {
  try {
    const { pedido_id, emisor_id, receptor_id, contenido } = req.body;
    if (!pedido_id || !emisor_id || !contenido) {
      return error(res, 'pedido_id, emisor_id y contenido son obligatorios', 400);
    }
    const mensaje = await mensajesModel.enviarMensaje({
      pedido_id,
      emisor_id,
      receptor_id,
      contenido,
      leido: false
    });
    return exito(res, mensaje, 201);
  } catch (err) {
    return error(res, 'Error al enviar mensaje', 500, err.message);
  }
};

const listarPorPedido = async (req, res) => {
  try {
    const mensajes = await mensajesModel.listarPorPedido(req.params.pedido_id);
    return exito(res, mensajes);
  } catch (err) {
    return error(res, 'Error al listar mensajes', 500, err.message);
  }
};

const marcarLeido = async (req, res) => {
  try {
    const mensaje = await mensajesModel.marcarLeido(req.params.id);
    return exito(res, mensaje);
  } catch (err) {
    return error(res, 'Error al marcar mensaje como leído', 500, err.message);
  }
};

module.exports = { enviar, listarPorPedido, marcarLeido };
