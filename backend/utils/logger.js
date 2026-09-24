/**
 * Loguea un error de Supabase (o de cualquier función async) con todo su detalle
 * en la terminal, para que sea fácil buscar la causa real.
 * @param {string} contexto - Nombre de la función/operación donde ocurrió (ej. 'verificarCuenta').
 * @param {Object|Error} error - El error devuelto por Supabase o capturado en un catch.
 */
export const logError = (contexto, error) => {
  console.error(`\n🔴 [ERROR] ${contexto}`);
  console.error('-------------------------------------------');
  if (error?.code) console.error('code:', error.code);
  if (error?.details) console.error('details:', error.details);
  if (error?.hint) console.error('hint:', error.hint);
  console.error('message:', error?.message || error);
  console.error('-------------------------------------------\n');
};