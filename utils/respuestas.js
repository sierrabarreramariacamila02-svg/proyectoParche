// Helper para respuestas consistentes en toda la API
export const exito = (res, data, status = 200) => {
  return res.status(status).json({ ok: true, data });
};

export const error = (res, mensaje, status = 500, detalle = null) => {
  return res.status(status).json({ ok: false, mensaje, detalle });
};

export default {
  exito,
  error
};