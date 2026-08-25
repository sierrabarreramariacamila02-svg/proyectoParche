import jwt from 'jsonwebtoken';

export const verificarToken = (req, res, next) => {
  const header = req.headers['authorization'];
  const token = header && header.startsWith('Bearer ') ? header.split(' ')[1] : header;

  if (!token) {
    return res.status(401).json({ mensaje: 'Token requerido' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.usuario = decoded;
    next();
  } catch (error) {
    return res.status(403).json({ mensaje: 'Token inválido o expirado' });
  }
};

export const verificarRol = (...rolesPermitidos) => {
  return (req, res, next) => {
    if (!req.usuario) {
      return res.status(401).json({ mensaje: 'No autenticado' });
    }
    if (!rolesPermitidos.includes(req.usuario.rol)) {
      return res.status(403).json({ mensaje: 'No tienes permisos para esta acción' });
    }
    next();
  };
};

export default {
  verificarToken,
  verificarRol
};