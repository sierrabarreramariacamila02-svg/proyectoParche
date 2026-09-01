import { supabase } from '../config/supabase.js';

export const obtenerConversaciones = async () => {
  const { data, error } = await supabase
    .from('conversaciones')
    .select('*, usuario:usuario_id(id, nombre, email)')
    .order('id', { ascending: false });
  return { data, error };
};

export const crearConversacion = async (conversacionData) => {
  const { data, error } = await supabase.from('conversaciones').insert(conversacionData).select();
  return { data, error };
};

export const obtenerConversacionPorId = async (id) => {
  const { data, error } = await supabase
    .from('conversaciones')
    .select('*, usuario:usuario_id(id, nombre, email), mensajes(*)')
    .eq('id', id)
    .single();
  return { data, error };
};

export const obtenerMensajesDeConversacion = async (conversacionId) => {
  const { data, error } = await supabase
    .from('mensajes')
    .select('*, emisor:emisor_id(id, nombre, email, rol)')
    .eq('conversacion_id', conversacionId)
    .order('enviado_en');
  return { data, error };
};

export const crearMensaje = async (mensajeData) => {
  const { data, error } = await supabase.from('mensajes').insert(mensajeData).select();
  return { data, error };
};