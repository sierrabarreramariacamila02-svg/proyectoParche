const usuarioModel = require('../models/usuario');
const { exito, error } = require('../utils/respuestas');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// Solicitar token/código para restablecer contraseña
const solicitarRecuperacion = async (req, res) => {
  try {
    const { correo } = req.body;

    if (!correo) {
      return error(res, 'El correo electrónico es obligatorio', 400);
    }

    const usuario = await usuarioModel.obtenerPorCorreo(correo);
    if (!usuario) {
      // Por seguridad suele responderse éxito aunque no exista el correo
      return exito(res, null, 200, 'Si el correo existe, se enviarán las instrucciones');
    }

    // Generar token de recuperación con expiración corta (ej. 15 minutos)
    const resetToken = jwt.sign(
      { id: usuario.id },
      process.env.JWT_SECRET || 'secreto_super_seguro',
      { expiresIn: '15m' }
    );

    // TODO: Aquí integras Nodemailer u otro servicio de correos para enviar 'resetToken'
    
    return exito(res, { token: resetToken }, 200, 'Instrucciones enviadas al correo');
  } catch (err) {
    return error(res, 'Error al solicitar recuperación', 500, err.message);
  }
};

// Cambiar la contraseña con el token validado
const restablecerContrasena = async (req, res) => {
  try {
    const { token, nuevaContrasena } = req.body;

    if (!token || !nuevaContrasena) {
      return error(res, 'El token y la nueva contraseña son obligatorios', 400);
    }

    // Validar token
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secreto_super_seguro');

    // Encriptar la nueva contraseña
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(nuevaContrasena, salt);

    // Actualizar en BD usando el ID decodificado del token
    await usuarioModel.actualizarContrasena(decoded.id, hashedPassword);

    return exito(res, null, 200, 'Contraseña actualizada correctamente');
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return error(res, 'El token ha expirado, solicita uno nuevo', 400);
    }
    return error(res, 'Error al restablecer la contraseña', 500, err.message);
  }
};

module.exports = {
  solicitarRecuperacion,
  restablecerContrasena
};