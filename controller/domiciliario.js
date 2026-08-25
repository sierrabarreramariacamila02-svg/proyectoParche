import domiciliarioModel from '../models/domiciliario.js';
import { exito, error } from '../utils/respuestas.js';

export const listar = async (req, res) => {
  try {
    const domiciliarios = await domiciliarioModel.listarDomiciliarios();
    return exito(res, domiciliarios);
  } catch (err) {
    return error(res, 'Error al listar domiciliarios', 500, err.message);
  }
};

export const listarDisponibles = async (req, res) => {
  try {
    const domiciliarios = await domiciliarioModel.listarDisponibles();
    return exito(res, domiciliarios);
  } catch (err) {
    return error(res, 'Error al listar domiciliarios disponibles', 500, err.message);
  }
};

export const obtenerPorId = async (req, res) => {
  try {
    const domiciliario = await domiciliarioModel.obtenerPorId(req.params.id);
    return exito(res, domiciliario);
  } catch (err) {
    return error(res, 'Domiciliario no encontrado', 404, err.message);
  }
};

export const crear = async (req, res) => {
  try {
    const domiciliario = await domiciliarioModel.crearDomiciliario(req.body);
    return exito(res, domiciliario, 201);
  } catch (err) {
    return error(res, 'Error al crear domiciliario', 500, err.message);
  }
};

export const actualizar = async (req, res) => {
  try {
    const domiciliario = await domiciliarioModel.actualizarDomiciliario(req.params.id, req.body);
    return exito(res, domiciliario);
  } catch (err) {
    return error(res, 'Error al actualizar domiciliario', 500, err.message);
  }
};

export const cambiarDisponibilidad = async (req, res) => {
  try {
    const { disponible } = req.body;
    const domiciliario = await domiciliarioModel.cambiarDisponibilidad(req.params.id, disponible);
    return exito(res, domiciliario);
  } catch (err) {
    return error(res, 'Error al cambiar disponibilidad', 500, err.message);
  }
};

export default {
  listar,
  listarDisponibles,
  obtenerPorId,
  crear,
  actualizar,
  cambiarDisponibilidad
};