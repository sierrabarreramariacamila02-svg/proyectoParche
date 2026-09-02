import { supabase } from '../config/supabase.js';

// 1. Obtener todos los usuarios
export const getUsuarios = async () => {
    const { data, error } = await supabase
        .from('usuario')
        .select('id, nombre, email, telefono, direccion, rol, creado_en')
        .order('id');
    return { data, error };
};

// 2. Obtener un usuario por ID
export const obtenerUsuarioPorId = async (id) => {
    const { data, error } = await supabase
        .from('usuario')
        .select('id, nombre, email, telefono, direccion, rol, creado_en')
        .eq('id', id)
        .single();
    return { data, error };
};

// 3. Crear un nuevo usuario
export const crearUsuariocontroller = async (
  nombre,
  email,
  password,
  telefono,
  direccion,
  rol = 'cliente',
  codigoverificacion,
  codigoverificacionexpiracion
) => {
  const { data, error } = await supabase
    .from('usuario')
    .insert({
      nombre,
      email,
      password,
      telefono,
      direccion,
      rol,
      isverified: false,
      codigoverificacion: codigoverificacion,
      codigoverificacionexpiracion: codigoverificacionexpiracion
    })
    .select('id, nombre, email, rol')
    .single();

  return { data, error };
};
// 4. Actualizar usuario
export const actualizarUsuario = async (id, campos) => {
    const { data, error } = await supabase
        .from('usuario')
        .update(campos)
        .eq('id', id)
        .select('id, nombre, email, telefono, direccion, rol, creado_en')
        .single();
    return { data, error };
};

// 5. Eliminar usuario
export const eliminarUsuario = async (id) => {
    const { data, error } = await supabase
        .from('usuario')
        .delete()
        .eq('id', id);
    return { data, error };
};

// 6. Obtener usuario por email (para registro/login, incluye password)
export const obtenerUsuarioPorEmail = async (email) => {
    const { data, error } = await supabase
        .from('usuario')
        .select('*')
        .eq('email', email)
        .single();
    return { data, error };
};

export const crearUsuario = async (nombre, email, password, telefono, direccion, rol ) => {}