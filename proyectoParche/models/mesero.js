import { supabase } from '../config/supabase.js';

export const obtenerAtenciones = async () => {
  const { data, error } = await supabase
    .from('mesero')
    .select('*, pedido:pedido_id(*), mesero:mesero_id(id, nombre, email)')
    .order('id', { ascending: false });
  return { data, error };
};

export const crearAtencion = async (meseroData) => {
  const { data, error } = await supabase.from('mesero').insert(meseroData).select();
  return { data, error };
};

export const actualizarAtencion = async (id, cambios) => {
  const { data, error } = await supabase.from('mesero').update(cambios).eq('id', id).select();
  return { data, error };
};