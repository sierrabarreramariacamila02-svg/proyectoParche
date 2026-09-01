import jwt from 'jsonwebtoken';

/**
 * Genera un JSON Web Token (JWT) para la sesión del usuario.
 * @param {Object} usuario - Datos del usuario (id, email, rol).
 * @param {string} [expiresIn='7d'] - Tiempo de expiración del token.
 * @returns {string} Token firmado.
 */
export const generarToken = (usuario, expiresIn = '7d') => {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET no está definida en las variables de entorno');
  }

  const payload = {
    id: usuario.id,
    email: usuario.email,
    rol: usuario.rol
  };

  return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn });
};