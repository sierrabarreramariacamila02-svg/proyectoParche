import supabase from '../config/supabase.js';

export const enviarMensaje = async (mensaje) => {
  const { data, error } = await supabase.from('mensajes').insert([mensaje]).select().single();
  if (error) throw error;
  return data;
};

export const listarPorPedido = async (pedido_id) => {
  const { data, error } = await supabase
    .from('mensajes')
    .select('*')
    .eq('pedido_id', pedido_id)
    .order('fecha', { ascending: true });
  if (error) throw error;
  return data;
};

export const marcarLeido = async (id) => {
  const { data, error } = await supabase
    .from('mensajes')
    .update({ leido: true })
    .eq('id', id)
    .select()
    .single();
  if (error) throw error;
  return data;
};

export default {
  enviarMensaje,
  listarPorPedido,
  marcarLeido
};