import { supabase } from '../config/supabase.js';

export const obtenerProductos = async () => {
  const { data, error } = await supabase.from('producto').select('*').order('id');
  return { data, error };
};

export const obtenerProductoPorId = async (id) => {
  const { data, error } = await supabase.from('producto').select('*').eq('id', id).single();
  return { data, error };
};

export const crearProducto = async (productoData) => {
  const { data, error } = await supabase.from('producto').insert(productoData).select();
  return { data, error };
};

export const actualizarProducto = async (id, productoData) => {
  const { data, error } = await supabase.from('producto').update(productoData).eq('id', id).select();
  return { data, error };
};

export const eliminarProducto = async (id) => {
  const { data, error } = await supabase.from('producto').delete().eq('id', id);
  return { data, error };
};