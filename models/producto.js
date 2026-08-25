import supabase from '../config/supabase.js';

export const listarProductos = async () => {
  const { data, error } = await supabase.from('producto').select('*').order('nombre');
  if (error) throw error;
  return data;
};

export const listarDisponibles = async () => {
  const { data, error } = await supabase
    .from('producto')
    .select('*')
    .eq('disponible', true)
    .order('categoria');
  if (error) throw error;
  return data;
};

export const obtenerPorId = async (id) => {
  const { data, error } = await supabase.from('producto').select('*').eq('id', id).single();
  if (error) throw error;
  return data;
};

export const crearProducto = async (producto) => {
  const { data, error } = await supabase.from('producto').insert([producto]).select().single();
  if (error) throw error;
  return data;
};

export const actualizarProducto = async (id, cambios) => {
  const { data, error } = await supabase.from('producto').update(cambios).eq('id', id).select().single();
  if (error) throw error;
  return data;
};

export const eliminarProducto = async (id) => {
  const { error } = await supabase.from('producto').delete().eq('id', id);
  if (error) throw error;
  return true;
};

export default {
  listarProductos,
  listarDisponibles,
  obtenerPorId,
  crearProducto,
  actualizarProducto,
  eliminarProducto
};