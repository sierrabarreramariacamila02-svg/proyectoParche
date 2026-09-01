const supabase = require('../config/supabase');

const crearUsuario = async (usuario) => {
  const { data, error } = await supabase.from('usuario').insert([usuario]).select().single();
  if (error) throw error;
  return data;
};

const obtenerPorEmail = async (email) => {
  const { data, error } = await supabase.from('usuario').select('*').eq('email', email).single();
  if (error && error.code !== 'PGRST116') throw error; // PGRST116 = no rows
  return data;
};

const obtenerPorId = async (id) => {
  const { data, error } = await supabase
    .from('usuario')
    .select('id, nombre, email, telefono, direccion, rol')
    .eq('id', id)
    .single();
  if (error) throw error;
  return data;
};

const listarUsuarios = async () => {
  const { data, error } = await supabase
    .from('usuario')
    .select('id, nombre, email, telefono, direccion, rol');
  if (error) throw error;
  return data;
};

const actualizarUsuario = async (id, cambios) => {
  const { data, error } = await supabase.from('usuario').update(cambios).eq('id', id).select().single();
  if (error) throw error;
  return data;
};

const eliminarUsuario = async (id) => {
  const { error } = await supabase.from('usuario').delete().eq('id', id);
  if (error) throw error;
  return true;
};

module.exports = {
  crearUsuario,
  obtenerPorEmail,
  obtenerPorId,
  listarUsuarios,
  actualizarUsuario,
  eliminarUsuario
};
