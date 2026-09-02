import detalleModel from '../models/detallePedido.js';
import { exito, error } from '../utils/respuestas.js';

export const listarPorPedido = async (req, res) => {
  try {
    const items = await detalleModel.listarPorPedido(req.params.pedido_id);
    return exito(res, items);
  } catch (err) {
    return error(res, 'Error al listar detalle del pedido', 500, err.message);
  }
};

export const agregarItem = async (req, res) => {
  try {
    const item = await detalleModel.agregarItem(req.body);
    return exito(res, item, 201);
  } catch (err) {
    return error(res, 'Error al agregar ítem', 500, err.message);
  }
};

export const actualizarItem = async (req, res) => {
  try {
    const item = await detalleModel.actualizarItem(req.params.id, req.body);
    return exito(res, item);
  } catch (err) {
    return error(res, 'Error al actualizar ítem', 500, err.message);
  }
};

export const eliminarItem = async (req, res) => {
  try {
    await detalleModel.eliminarItem(req.params.id);
    return exito(res, { mensaje: 'Ítem eliminado' });
  } catch (err) {
    return error(res, 'Error al eliminar ítem', 500, err.message);
  }
};

export default {
  listarPorPedido,
  agregarItem,
  actualizarItem,
  eliminarItem
};