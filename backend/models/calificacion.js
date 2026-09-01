import { supabase } from '../config/supabase.js';

export const obtenerCalificaciones = async () => {
  const { data, error } = await supabase
    .from('calificacion')
    .select('*, usuario:usuario_id(id, nombre), pedido:pedido_id(*)')
    .order('id', { ascending: false });
  return { data, error };
};

export const obtenerCalificacionesPorPedido = async (pedidoId) => {
  const { data, error } = await supabase.from('calificacion').select('*').eq('pedido_id', pedidoId).order('id');
  return { data, error };
};

export const crearCalificacion = async (calificacionData) => {
  const { data, error } = await supabase.from('calificacion').insert(calificacionData).select();
  return { data, error };
};

export const actualizarCalificacion = async (id, cambios) => {
  const { data, error } = await supabase.from('calificacion').update(cambios).eq('id', id).select();
  return { data, error };
};

export const eliminarCalificacion = async (id) => {
  const { data, error } = await supabase.from('calificacion').delete().eq('id', id);
  return { data, error };
};