const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const usuarioModel = require('../models/usuario');
const { exito, error } = require('../utils/respuestas');

const registrar = async (req, res) => {
  try {
    const { nombre, email, password, telefono, direccion, rol } = req.body;

    if (!nombre || !email || !password) {
      return error(res, 'nombre, email y password son obligatorios', 400);
    }

    const existente = await usuarioModel.obtenerPorEmail(email);
    if (existente) return error(res, 'Ese email ya está registrado', 409);

    const passwordHash = await bcrypt.hash(password, 10);

    const nuevoUsuario = await usuarioModel.crearUsuario({
      nombre,
      email,
      password: passwordHash,
      telefono,
      direccion,
      rol: rol || 'cliente' // cliente, admin, cocina, domiciliario, mesero
    });

    delete nuevoUsuario.password;
    return exito(res, nuevoUsuario, 201);
  } catch (err) {
    return error(res, 'Error al registrar usuario', 500, err.message);
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return error(res, 'email y password son obligatorios', 400);

    const usuario = await usuarioModel.obtenerPorEmail(email);
    if (!usuario) return error(res, 'Credenciales inválidas', 401);

    const passwordValido = await bcrypt.compare(password, usuario.password);
    if (!passwordValido) return error(res, 'Credenciales inválidas', 401);

    const token = jwt.sign(
      { id: usuario.id, email: usuario.email, rol: usuario.rol },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    delete usuario.password;
    return exito(res, { usuario, token });
  } catch (err) {
    return error(res, 'Error al iniciar sesión', 500, err.message);
  }
};

const perfil = async (req, res) => {
  try {
    const usuario = await usuarioModel.obtenerPorId(req.usuario.id);
    return exito(res, usuario);
  } catch (err) {
    return error(res, 'No se pudo obtener el perfil', 404, err.message);
  }
};

const listar = async (req, res) => {
  try {
    const usuarios = await usuarioModel.listarUsuarios();
    return exito(res, usuarios);
  } catch (err) {
    return error(res, 'Error al listar usuarios', 500, err.message);
  }
};

const actualizar = async (req, res) => {
  try {
    const cambios = { ...req.body };
    if (cambios.password) {
      cambios.password = await bcrypt.hash(cambios.password, 10);
    }
    const usuario = await usuarioModel.actualizarUsuario(req.params.id, cambios);
    delete usuario.password;
    return exito(res, usuario);
  } catch (err) {
    return error(res, 'Error al actualizar usuario', 500, err.message);
  }
};

const eliminar = async (req, res) => {
  try {
    await usuarioModel.eliminarUsuario(req.params.id);
    return exito(res, { mensaje: 'Usuario eliminado' });
  } catch (err) {
    return error(res, 'Error al eliminar usuario', 500, err.message);
  }
};

module.exports = { registrar, login, perfil, listar, actualizar, eliminar };
