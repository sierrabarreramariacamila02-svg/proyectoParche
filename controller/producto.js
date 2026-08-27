import productoModel from '../models/producto.js';
import { exito, error } from '../utils/respuestas.js';

export const listar = async (req, res) => {
  try {
    const productos = await productoModel.listarProductos();
    return exito(res, productos);
  } catch (err) {
    return error(res, 'Error al obtener productos', 500, err.message);
  }
};

export const listarDisponibles = async (req, res) => {
  try {
    const productos = await productoModel.listarDisponibles();
    return exito(res, productos);
  } catch (err) {
    return error(res, 'Error al obtener el menú', 500, err.message);
  }
};

export const obtenerPorId = async (req, res) => {
  try {
    const producto = await productoModel.obtenerPorId(req.params.id);
    return exito(res, producto);
  } catch (err) {
    return error(res, 'Producto no encontrado', 404, err.message);
  }
};

export const crear = async (req, res) => {
  try {
    // Cloudinary devuelve la URL pública en req.file.path
    const imagen_url = req.file ? req.file.path : null;
    const { nombre, precio, categoria } = req.body;

    if (!nombre || precio === undefined || !categoria || !imagen_url) {
      return error(res, 'nombre, precio, categoria e imagen son obligatorios', 400);
    }

    const producto = await productoModel.crearProducto({
      ...req.body,
      imagen_url
    });
    
    return exito(res, producto, 201);
  } catch (err) {
    return error(res, 'Error al crear producto', 500, err.message);
  }
};

export const actualizar = async (req, res) => {
  try {
    // Si viene un archivo nuevo en la actualización, actualizamos la imagen
    const datosActualizar = { ...req.body };
    if (req.file) {
      datosActualizar.imagen_url = req.file.path;
    }

    const producto = await productoModel.actualizarProducto(req.params.id, datosActualizar);
    return exito(res, producto);
  } catch (err) {
    return error(res, 'Error al actualizar producto', 500, err.message);
  }
};

export const eliminar = async (req, res) => {
  try {
    await productoModel.eliminarProducto(req.params.id);
    return exito(res, { mensaje: 'Producto eliminado' });
  } catch (err) {
    return error(res, 'Error al eliminar producto', 500, err.message);
  }
};

export default {
  listar,
  listarDisponibles,
  obtenerPorId,
  crear,
  actualizar,
  eliminar
};