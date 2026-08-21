const productoModel = require('../models/producto');
const { exito, error } = require('../utils/respuestas');
const { upload } = require('../config/cloudinary');

const listar = async (req, res) => {
  try {
    const productos = await productoModel.listarProductos();
    return exito(res, productos);
  } catch (err) {
    return error(res, 'Error al obtener productos', 500, err.message);
  }
};

const listarDisponibles = async (req, res) => {
  try {
    const productos = await productoModel.listarDisponibles();
    return exito(res, productos);
  } catch (err) {
    return error(res, 'Error al obtener el menú', 500, err.message);
  }
};

const obtenerPorId = async (req, res) => {
  try {
    const producto = await productoModel.obtenerPorId(req.params.id);
    return exito(res, producto);
  } catch (err) {
    return error(res, 'Producto no encontrado', 404, err.message);
  }
};

const crear = async (req, res) => {
  try {
    const { nombre, precio, categoria } = req.body;
    if (!nombre || precio === undefined || !categoria || !imagen_url) {
      return error(res, 'nombre, precio, categoria e imagen_url son obligatorios', 400);
    }

   //cloudinary almacena la URL segura en req.file.path
        const imagen_url = req.file ? req.file.path : null;

    const producto = await productoModel.crearProducto(req.body);
    return exito(res, producto, 201);
  } catch (err) {
    return error(res, 'Error al crear producto', 500, err.message);
  }
};

const actualizar = async (req, res) => {
  try {
    const producto = await productoModel.actualizarProducto(req.params.id, req.body);
    return exito(res, producto);
  } catch (err) {
    return error(res, 'Error al actualizar producto', 500, err.message);
  }
};

const eliminar = async (req, res) => {
  try {
    await productoModel.eliminarProducto(req.params.id);
    return exito(res, { mensaje: 'Producto eliminado' });
  } catch (err) {
    return error(res, 'Error al eliminar producto', 500, err.message);
  }
};

module.exports = { listar, listarDisponibles, obtenerPorId, crear, actualizar, eliminar };
