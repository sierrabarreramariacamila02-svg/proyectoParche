import jwt from 'jsonwebtoken';

// Verifica que exista un token válido (usuario autenticado)
export const verificarToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // formato: "Bearer TOKEN"

  if (!token) {
    return res.status(401).json({ error: 'Token no proporcionado, por favor inicie sesion' });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(403).json({ error: 'Token inválido o expirado' });
    }
    req.usuario = decoded;
    next();
  });
};

// Deja pasar solo si el usuario tiene uno de los roles permitidos
export const verificarRol = (...rolesPermitidos) => {
  return (req, res, next) => {
    if (!req.usuario) {
      return res.status(401).json({ error: 'No autenticado' });
    }
    if (!rolesPermitidos.includes(req.usuario.rol)) {
      return res.status(403).json({ error: 'No tienes permisos para esta operación' });
    }
    next();
  };
};

// Solo deja pasar si el usuario tiene rol admin (panel administrador)
export const verificarAdmin = verificarRol('admin');