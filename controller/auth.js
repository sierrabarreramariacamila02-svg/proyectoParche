import usuarioModel from '../models/usuario.js';
import { exito, error } from '../utils/respuestas.js';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // 1. Validar campos requeridos
    if (!email || !password) {
      return error(res, 'email y password son obligatorios', 400);
    }

    // 2. Buscar si el usuario existe en la base de datos (usando obtenerPorEmail)
    const usuario = await usuarioModel.obtenerPorEmail(email);
    if (!usuario) {
      return error(res, 'Credenciales inválidas', 401);
    }

    // 3. Validar contraseña
    const esPasswordValida = await bcrypt.compare(password, usuario.password);
    if (!esPasswordValida) {
      return error(res, 'Credenciales inválidas', 401);
    }

    // 4. Generar Token JWT
    const token = jwt.sign(
      {
        id: usuario.id,
        rol: usuario.rol,
        email: usuario.email
      },
      process.env.JWT_SECRET || 'secreto_super_seguro',
      { expiresIn: '8h' }
    );

    // 5. Excluir contraseña antes de responder
    delete usuario.password;

    return exito(res, { usuario, token }, 200);
  } catch (err) {
    return error(res, 'Error al iniciar sesión', 500, err.message);
  }
};

export default {
  login
};