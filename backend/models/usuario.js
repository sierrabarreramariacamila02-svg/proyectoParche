import { supabase } from '../config/supabase.js';

// Obtener todos los usuarios
export const getUsuarios = async () => {
    try {
        const { data, error } = await supabase
            .from('usuario')
            .select('*');

        return { data, error };
    } catch (error) {
        return { data: null, error };
    }
};

// Obtener un usuario por su ID
export const obtenerUsuarioPorId = async (usuarioId) => {
    try {
        const { data, error } = await supabase
            .from('usuario')
            .select('*')
            .eq('id', usuarioId)
            .single();

        if (error && error.code !== 'PGRST116') {
            return { data: null, error };
        }

        return { data, error: null };
    } catch (error) {
        return { data: null, error };
    }
};

// Obtener un usuario por su correo electrónico
export const obtenerUsuarioPorEmail = async (email) => {
    try {
        const { data, error } = await supabase
            .from('usuario')
            .select('*')
            .eq('email', email) // Corregido de 'correo' a 'email' y variable correcta
            .single();

        if (error && error.code !== 'PGRST116') {
            return { data: null, error };
        }

        return { data, error: null };
    } catch (error) {
        return { data: null, error };
    }
};

// Crear un usuario mediante Google
export const crearUsuarioGoogle = async (userData) => {
    try {
        const { data, error } = await supabase
            .from('usuario')
            .insert([
                {
                    nombre: userData.nombre,
                    email: userData.email, // Corregido de 'correo' a 'email'
                    googleId: userData.googleId, // Coincide con tu SQL ('googleId')
                    avatar: userData.avatar,
                    rol: userData.rol,
                    isverified: true // Coincide con tu SQL ('isverified')
                }
            ])
            .select()
            .single();

        return { data, error };
    } catch (error) {
        return { data: null, error };
    }
};

// Crear un usuario tradicional (Controlador de registro estándar)
export const crearUsuariocontroller = async (userData) => {
  try {
    const { data, error } = await supabase
      .from('usuario')
      .insert([
        {
          nombre: userData.nombre,
          email: userData.email,
          password: userData.password,
          telefono: userData.telefono,
          direccion: userData.direccion,
          rol: userData.rol || 'cliente',
          codigoverificacion: userData.codigoverificacion,
          codigoverificacionexpiracion: userData.codigoverificacionexpiracion,
          isverified: false
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

// Actualizar datos del usuario
export const actualizarUsuario = async (usuarioId, camposActualizar) => {
    try {
        const { data, error } = await supabase
            .from('usuario')
            .update(camposActualizar)
            .eq('id', usuarioId) // Corregido a 'id'
            .select();

        return { data, error };
    } catch (error) {
        return { data: null, error };
    }
};

// Eliminar un usuario por su ID
export const eliminarUsuario = async (usuarioId) => {
    try {
        const { data, error } = await supabase
            .from('usuario')
            .delete()
            .eq('id', usuarioId) // Corregido a 'id'
            .select();

        return { data, error };
    } catch (error) {
        return { data: null, error };
    }
};