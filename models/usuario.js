import supabase from '../config/supabase.js';

export const crearUsuario = async (usuario) => {
  const { data, error } = await supabase.from('usuario').insert([usuario]).select().single();
  if (error) throw error;
  return data;
};

export const obtenerPorEmail = async (email) => {
  const { data, error } = await supabase.from('usuario').select('*').eq('email', email).single();
  if (error && error.code !== 'PGRST116') throw error; // PGRST116 = no rows
  return data;
};

export const obtenerPorId = async (id) => {
  const { data, error } = await supabase
    .from('usuario')
    .select('id, nombre, email, telefono, direccion, rol')
    .eq('id', id)
    .single();
  if (error) throw error;
  return data;
};

export const listarUsuarios = async () => {
  const { data, error } = await supabase
    .from('usuario')
    .select('id, nombre, email, telefono, direccion, rol');
  if (error) throw error;
  return data;
};

export const actualizarUsuario = async (id, cambios) => {
  const { data, error } = await supabase.from('usuario').update(cambios).eq('id', id).select().single();
  if (error) throw error;
  return data;
};

export const eliminarUsuario = async (id) => {
  const { error } = await supabase.from('usuario').delete().eq('id', id);
  if (error) throw error;
  return true;
};

export default {
  crearUsuario,
  obtenerPorEmail,
  obtenerPorId,
  listarUsuarios,
  actualizarUsuario,
  eliminarUsuario
};