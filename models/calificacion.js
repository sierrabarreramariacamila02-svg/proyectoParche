const supabase = require('../config/supabase');

const crearCalificacion = async (calificacion) => {
  const { data, error } = await supabase.from('calificacion').insert([calificacion]).select().single();
  if (error) throw error;
  return data;
};

const obtenerPorPedido = async (pedido_id) => {
  const { data, error } = await supabase
    .from('calificacion')
    .select('*')
    .eq('pedido_id', pedido_id)
    .single();
  if (error && error.code !== 'PGRST116') throw error;
  return data;
};

const listarPorUsuario = async (usuario_id) => {
  const { data, error } = await supabase
    .from('calificacion')
    .select('*')
    .eq('usuario_id', usuario_id)
    .order('fecha', { ascending: false });
  if (error) throw error;
  return data;
};

const promedioGeneral = async () => {
  const { data, error } = await supabase.from('calificacion').select('puntuacion');
  if (error) throw error;
  if (!data.length) return 0;
  const suma = data.reduce((acc, c) => acc + c.puntuacion, 0);
  return Number((suma / data.length).toFixed(2));
};

module.exports = { crearCalificacion, obtenerPorPedido, listarPorUsuario, promedioGeneral };
