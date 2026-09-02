import meseroModel from '../models/mesero.js';
import { exito, error } from '../utils/respuestas.js';

export const listar = async (req, res) => {
  try {
    const meseros = await meseroModel.listarMeseros();
    return exito(res, meseros);
  } catch (err) {
    return error(res, 'Error al listar meseros', 500, err.message);
  }
};

export const obtenerPorId = async (req, res) => {
  try {
    const mesero = await meseroModel.obtenerPorId(req.params.id);
    return exito(res, mesero);
  } catch (err) {
    return error(res, 'Mesero no encontrado', 404, err.message);
  }
};

export const crear = async (req, res) => {
  try {
    const mesero = await meseroModel.crearMesero(req.body);
    return exito(res, mesero, 201);
  } catch (err) {
    return error(res, 'Error al crear mesero', 500, err.message);
  }
};

export const actualizar = async (req, res) => {
  try {
    const mesero = await meseroModel.actualizarMesero(req.params.id, req.body);
    return exito(res, mesero);
  } catch (err) {
    return error(res, 'Error al actualizar mesero', 500, err.message);
  }
};

export const eliminar = async (req, res) => {
  try {
    await meseroModel.eliminarMesero(req.params.id);
    return exito(res, { mensaje: 'Mesero eliminado' });
  } catch (err) {
    return error(res, 'Error al eliminar mesero', 500, err.message);
  }
};

export const crearPedidoEnMesa = async (req, res) => {
  try {
    const { mesero_id, mesa_numero, items } = req.body;
    if (!items || items.length === 0) {
      return error(res, 'El pedido debe tener al menos un producto', 400);
    }
    const pedido = await meseroModel.crearPedidoEnMesa(mesero_id, mesa_numero, items);
    return exito(res, pedido, 201);
  } catch (err) {
    return error(res, 'Error al crear pedido en mesa', 500, err.message);
  }
};

export default {
  listar,
  obtenerPorId,
  crear,
  actualizar,
  eliminar,
  crearPedidoEnMesa
};