import usuarioModel from '../models/usuario.js';
import { exito, error } from '../utils/respuestas.js';
import bcrypt from 'bcrypt'; // o 'bcryptjs' según lo que uses en tu package.json
import jwt from 'jsonwebtoken';

export const login = async (req, res) => {
  try {
    const { correo, contrasena } = req.body;

    // 1. Validar campos requeridos
    if (!correo || !contrasena) {
      return error(res, 'Correo y contraseña son obligatorios', 400);
    }

    // 2. Buscar si el usuario existe en la base de datos
    const usuario = await usuarioModel.obtenerPorCorreo(correo);
    if (!usuario) {
      return error(res, 'Credenciales inválidas', 401);
    }

    // 3. Validar contraseña
    const esPasswordValida = await bcrypt.compare(contrasena, usuario.contrasena);
    if (!esPasswordValida) {
      return error(res, 'Credenciales inválidas', 401);
    }

    // 4. Generar Token JWT
    const token = jwt.sign(
      {
        id: usuario.id,
        rol: usuario.rol,
        correo: usuario.correo
      },
      process.env.JWT_SECRET || 'secreto_super_seguro',
      { expiresIn: '8h' }
    );

    // 5. Excluir contraseña antes de responder
    delete usuario.contrasena;

    return exito(res, { usuario, token }, 200, 'Inicio de sesión exitoso');
  } catch (err) {
    return error(res, 'Error al iniciar sesión', 500, err.message);
  }
};

export default {
  login
};