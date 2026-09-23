import { supabase } from '../config/supabase.js';
import { logError } from '../utils/logger.js';
import bcrypt from 'bcrypt';

export const crearUsuarioModel = async (
  nombre,
  email,
  password,
  telefono,
  rol,
  codigoverificacion = null,
  codigoverificacionexpiracion = null
) => {
  const salt = await bcrypt.genSalt(10);
  const passwordHash = await bcrypt.hash(password, salt);

  const { data, error } = await supabase
    .from('usuario')
    .insert([
      {
        nombre,
        email,
        password: passwordHash,
        telefono,
        rol: rol || 'cliente',
        estaverificado: false,
        codigoverificacion,
        codigoverificacionexpiracion
      }
    ])
    .select()
    .single();

  if (error) {
    logError('crearUsuarioModel', error);
    throw new Error(error.message);
  }

  return data;
};

export const buscarUsuarioPorEmailModel = async (email) => {
  const { data, error } = await supabase
    .from('usuario')
    .select('*')
    .eq('email', email)
    .single();

  if (error) {
    logError('buscarUsuarioPorEmailModel', error);
    return null;
  }

  return data;
};

export const obtenerUsuariosModel = async () => {
  const { data, error } = await supabase
    .from('usuario')
    .select('id, nombre, email, telefono, direccion, rol, creado_en, estaverificado')
    .order('id', { ascending: false });

  if (error) {
    logError('obtenerUsuariosModel', error);
    throw new Error(error.message);
  }

  return data;
};

export const obtenerUsuarioPorIdModel = async (id) => {
  const { data, error } = await supabase
    .from('usuario')
    .select('id, nombre, email, telefono, direccion, rol, creado_en, estaverificado')
    .eq('id', id)
    .single();

  if (error) {
    logError('obtenerUsuarioPorIdModel', error);
    return null;
  }

  return data;
};

export const actualizarUsuario = async (id, cambios) => {
  const { data, error } = await supabase
    .from('usuario')
    .update(cambios)
    .eq('id', id)
    .select();

  if (error) {
    logError('actualizarUsuario', error);
  }

  return { data, error };
};