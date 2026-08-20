const cocinaModel = require('../models/cocina');
const { exito, error } = require('../utils/respuestas');

const listarPendientes = async (req, res) => {
  try {
    const pedidos = await cocinaModel.listarPedidosPendientes();
    return exito(res, pedidos);
  } catch (err) {
    return error(res, 'Error al listar pedidos pendientes', 500, err.message);
  }
};

const iniciarPreparacion = async (req, res) => {
  try {
    const pedido = await cocinaModel.marcarEnPreparacion(req.params.pedido_id);
    return exito(res, pedido);
  } catch (err) {
    return error(res, 'Error al iniciar preparación', 500, err.message);
  }
};

const marcarListo = async (req, res) => {
  try {
    const pedido = await cocinaModel.marcarListo(req.params.pedido_id);
    return exito(res, pedido);
  } catch (err) {
    return error(res, 'Error al marcar pedido como listo', 500, err.message);
  }
};

module.exports = { listarPendientes, iniciarPreparacion, marcarListo };
