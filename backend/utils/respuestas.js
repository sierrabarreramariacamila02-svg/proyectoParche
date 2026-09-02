/**
 * Envía una respuesta HTTP estandarizada de éxito.
 * @param {Object} res - Objeto de respuesta de Express.
 * @param {number} statusCode - Código HTTP de estado (e.g., 200, 201).
 * @param {string} mensaje - Descripción del resultado.
 * @param {Object|Array|null} [data=null] - Información devuelta por el servidor.
 */
export const respuestaExito = (res, statusCode = 200, mensaje = 'Operación exitosa', data = null) => {
  const respuesta = {
    ok: true,
    message: mensaje
  };

  if (data !== null) {
    respuesta.data = data;
  }

  return res.status(statusCode).json(respuesta);
};

/**
 * Envía una respuesta HTTP estandarizada de error.
 * @param {Object} res - Objeto de respuesta de Express.
 * @param {number} statusCode - Código HTTP de error (e.g., 400, 401, 403, 404, 500).
 * @param {string} mensaje - Detalle del error ocurrido.
 * @param {any} [detalles=null] - Información adicional sobre el error.
 */
export const respuestaError = (res, statusCode = 500, mensaje = 'Error interno del servidor', detalles = null) => {
  const respuesta = {
    ok: false,
    error: mensaje
  };

  if (detalles !== null) {
    respuesta.detalles = detalles;
  }

  return res.status(statusCode).json(respuesta);
};