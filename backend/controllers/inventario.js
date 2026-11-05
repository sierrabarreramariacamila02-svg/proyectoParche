import {
  actualizarIngrediente,
  crearIngrediente,
  eliminarIngrediente,
  listarInventario,
} from '../models/inventario.js';
import { logError } from '../utils/logger.js';

const responderError = (res, operation, error) => {
  logError(operation, error);
  if (error.code === 'INVENTORY_DB_CONFIG') {
    return res.status(503).json({ error: error.message });
  }
  return res.status(500).json({ error: 'No se pudo completar la operación de inventario.' });
};

const validarIngrediente = (body) => {
  const nombre = String(body?.nombre ?? '').trim();
  const unidadMedida = String(body?.unidad_medida ?? '').trim();
  const cantidad = Number(body?.cantidad);
  const stockMinimo = Number(body?.stock_minimo);

  if (!nombre || !unidadMedida) {
    return { error: 'El nombre y la unidad de medida son obligatorios.' };
  }
  if (
    body?.cantidad === '' ||
    body?.stock_minimo === '' ||
    !Number.isFinite(cantidad) ||
    !Number.isFinite(stockMinimo) ||
    cantidad < 0 ||
    stockMinimo < 0
  ) {
    return { error: 'La cantidad y el stock mínimo deben ser números no negativos.' };
  }

  return {
    ingrediente: {
      nombre,
      cantidad,
      unidad_medida: unidadMedida,
      stock_minimo: stockMinimo,
    },
  };
};

export const obtenerInventario = async (_req, res) => {
  try {
    const { data, error } = await listarInventario();
    if (error) {
      return responderError(res, 'obtenerInventario', error);
    }
    return res.status(200).json(data ?? []);
  } catch (error) {
    return responderError(res, 'obtenerInventario', error);
  }
};

export const crear = async (req, res) => {
  const resultado = validarIngrediente(req.body);
  if (resultado.error) {
    return res.status(400).json({ error: resultado.error });
  }

  try {
    const { data, error } = await crearIngrediente(resultado.ingrediente);
    if (error) {
      return responderError(res, 'crearIngrediente', error);
    }
    return res.status(201).json(data);
  } catch (error) {
    return responderError(res, 'crearIngrediente', error);
  }
};

export const actualizar = async (req, res) => {
  const resultado = validarIngrediente(req.body);
  if (resultado.error) {
    return res.status(400).json({ error: resultado.error });
  }

  try {
    const { data, error } = await actualizarIngrediente(
      req.params.id,
      resultado.ingrediente,
    );
    if (error) {
      return responderError(res, 'actualizarIngrediente', error);
    }
    if (!data) {
      return res.status(404).json({ error: 'Ingrediente no encontrado.' });
    }
    return res.status(200).json(data);
  } catch (error) {
    return responderError(res, 'actualizarIngrediente', error);
  }
};

export const eliminar = async (req, res) => {
  try {
    const { error } = await eliminarIngrediente(req.params.id);
    if (error) {
      return responderError(res, 'eliminarIngrediente', error);
    }
    return res.status(204).send();
  } catch (error) {
    return responderError(res, 'eliminarIngrediente', error);
  }
};
