import { supabase } from '../config/supabase.js';
import { logError } from '../utils/logger.js';
import bcrypt from 'bcrypt';


// Crear un usuario tradicional (Controlador de registro estándar)
export const crearUsuariocontroller = async (nombre, email, password, telefono, direccion, rol, codigoverificacion, codigoverificacionexpiracion) => {
  try {
    const { data, error } = await supabase
      .from('usuario')
      .insert([
        {
          nombre: nombre,
          email: email,
          password: password,
          telefono: telefono,
          direccion: direccion,
          rol: rol || 'cliente',
          codigoverificacion: codigoverificacion,
          codigoverificacionexpiracion:codigoverificacionexpiracion,
          isverified: false,
          creado_por_admin: false
        }
      ])
      .select()
      .single();

    // Si Supabase devuelve un error, lo retornamos explícitamente
    if (error) return { data: null, error };

    return { data, error: null };
  } catch (err) {
    // Si ocurre una excepción inesperada, la retornamos en el objeto error
    return { data: null, error: err };
  }
};

export const crearUsuarioModel = async (
  nombre,
  email,
  password,
  telefono,
  rol,
  codigoverificacion = null,
  codigoverificacionexpiracion = null,
  direccion = null
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
        direccion,
        rol: rol || 'cliente',
        isverified: false,
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

// ---------- Usadas por controllers/usuario.js (CRUD de usuarios) ----------

export const getUsuarios = async () => {
  try {
    const { data, error } = await supabase
      .from('usuario')
      .select('id, nombre, email, telefono, direccion, rol, creado_en, isverified, creado_por_admin')
      .eq('creado_por_admin', true)
      .order('id', { ascending: false });

    if (error) logError('getUsuarios', error);
    return { data, error };
  } catch (error) {
    logError('getUsuarios', error);
    return { data: null, error };
  }
};

export const obtenerUsuarioPorId = async (usuarioId) => {
  try {
    const { data, error } = await supabase
      .from('usuario')
      .select('id, nombre, email, telefono, direccion, avatar, rol, creado_en, isverified, creado_por_admin')
      .eq('id', usuarioId)
      .single();

    // PGRST116 = "no se encontraron filas", no lo tratamos como error real
    if (error && error.code !== 'PGRST116') {
      logError('obtenerUsuarioPorId', error);
      return { data: null, error };
    }

    return { data, error: null };
  } catch (error) {
    logError('obtenerUsuarioPorId', error);
    return { data: null, error };
  }
};

export const crearUsuarioAdministrativo = async (usuario) => {
  try {
    const { data, error } = await supabase
      .from('usuario')
      .insert([{ ...usuario, creado_por_admin: true, isverified: false }])
      .select('id, nombre, email, telefono, direccion, rol, creado_en, isverified, creado_por_admin')
      .single();

    if (error) logError('crearUsuarioAdministrativo', error);
    return { data, error };
  } catch (error) {
    logError('crearUsuarioAdministrativo', error);
    return { data: null, error };
  }
};

export const eliminarUsuario = async (usuarioId) => {
  try {
    const { data, error } = await supabase
      .from('usuario')
      .delete()
      .eq('id', usuarioId)
      .select();

    if (error) logError('eliminarUsuario', error);
    return { data, error };
  } catch (error) {
    logError('eliminarUsuario', error);
    return { data: null, error };
  }
};

// ---------- Compartida por auth.js, usuario.js, recuperar.js y googleAuth.js ----------

export const actualizarUsuario = async (usuarioId, camposActualizar) => {
  try {
    const { data, error } = await supabase
      .from('usuario')
      .update(camposActualizar)
      .eq('id', usuarioId)
      .select();

    if (error) logError('actualizarUsuario', error);
    return { data, error };
  } catch (error) {
    logError('actualizarUsuario', error);
    return { data: null, error };
  }
};


// ---------- Usadas por controllers/googleAuth.js ----------

export const obtenerUsuarioPorEmail = async (email) => {
  try {
    const { data, error } = await supabase
      .from('usuario')
      .select('*')
      .eq('email', email)
      .single();

    if (error && error.code !== 'PGRST116') {
      logError('obtenerUsuarioPorEmail', error);
      return { data: null, error };
    }

    return { data, error: null };
  } catch (error) {
    logError('obtenerUsuarioPorEmail', error);
    return { data: null, error };
  }
};

export const crearUsuarioGoogle = async (userData) => {
  try {
    const { data, error } = await supabase
      .from('usuario')
      .insert([
        {
          nombre: userData.nombre,
          email: userData.email,
          googleId: userData.googleId,
          avatar: userData.avatar,
          rol: userData.rol,
          isverified: true // quien entra por Google ya viene con el correo confirmado
        }
      ])
      .select()
      .single();

    if (error) logError('crearUsuarioGoogle', error);
    return { data, error };
  } catch (error) {
    logError('crearUsuarioGoogle', error);
    return { data: null, error };
  }
};
