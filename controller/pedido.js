const pedidoModel = require('../models/pedido');
const { exito, error } = require('../utils/respuestas');

const crear = async (req, res) => {
  try {
    const { usuario_id, direccion_entrega, items } = req.body;
    if (!items || items.length === 0) {
      return error(res, 'El pedido debe tener al menos un producto', 400);
    }
    const pedido = await pedidoModel.crearPedido(usuario_id, direccion_entrega, items);
    return exito(res, pedido, 201);
  } catch (err) {
    return error(res, 'Error al crear el pedido', 500, err.message);
  }
};

const obtenerPorId = async (req, res) => {
  try {
    const pedido = await pedidoModel.obtenerPedidoPorId(req.params.id);
    return exito(res, pedido);
  } catch (err) {
    return error(res, 'Pedido no encontrado', 404, err.message);
  }
};

const listarPorUsuario = async (req, res) => {
  try {
    const pedidos = await pedidoModel.listarPedidosPorUsuario(req.params.usuario_id);
    return exito(res, pedidos);
  } catch (err) {
    return error(res, 'Error al listar pedidos', 500, err.message);
  }
};

const listarPorEstado = async (req, res) => {
  try {
    const pedidos = await pedidoModel.listarPorEstado(req.params.estado);
    return exito(res, pedidos);
  } catch (err) {
    return error(res, 'Error al listar pedidos', 500, err.message);
  }
};

const cambiarEstado = async (req, res) => {
  try {
    const { estado } = req.body;
    const pedido = await pedidoModel.actualizarEstadoPedido(req.params.id, estado);
    return exito(res, pedido);
  } catch (err) {
    return error(res, 'Error al actualizar estado', 400, err.message);
  }
};

const asignarDomiciliario = async (req, res) => {
  try {
    const { domiciliario_id } = req.body;
    const pedido = await pedidoModel.asignarDomiciliario(req.params.id, domiciliario_id);
    return exito(res, pedido);
  } catch (err) {
    return error(res, 'Error al asignar domiciliario', 500, err.message);
  }
};

module.exports = { crear, obtenerPorId, listarPorUsuario, listarPorEstado, cambiarEstado, asignarDomiciliario };
