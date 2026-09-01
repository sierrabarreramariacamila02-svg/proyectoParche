import { supabase } from '../config/supabase.js';

export const obtenerCocina = async () => {
  const { data, error } = await supabase
    .from('cocina')
    .select('*, pedido:pedido_id(*)')
    .order('id', { ascending: false });
  return { data, error };
};

export const crearRegistroCocina = async (cocinaData) => {
  const { data, error } = await supabase.from('cocina').insert(cocinaData).select();
  return { data, error };
};

export const actualizarCocina = async (id, cambios) => {
  const { data, error } = await supabase.from('cocina').update(cambios).eq('id', id).select();
  return { data, error };
};