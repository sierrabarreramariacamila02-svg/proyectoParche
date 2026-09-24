import { getUsuarios, obtenerUsuarioPorId, actualizarUsuario as actualizarUsuarioModelo, eliminarUsuario } from '../models/usuario.js';

// 1. Obtener todos los usuarios
export const getUsuariosController = async (req, res) => {
    try {
        const { data, error } = await getUsuarios();
        if (error) {
            return res.status(500).json({ error: 'Error al obtener los usuarios' });
        }
        return res.status(200).json({
            usuarios: data
        });
    } catch (error) {
        console.error('Error al obtener a los usuarios', error);
        return res.status(500).json({ error: 'Error al obtener los usuarios' });
    }

import { crearUsuarioModel, obtenerUsuariosModel, obtenerUsuarioPorIdModel } from '../models/usuario.js';
import { supabase } from '../config/supabase.js';

// 1. Crear usuario
export const crearUsuarioController = async (req, res) => {
  try {
    const { nombre, email, password, telefono, rol } = req.body;

    if (!nombre || !email || !password) {
      return res.status(400).json({ error: 'Nombre, email y password son obligatorios.' });
    }

    const nuevoUsuario = await crearUsuarioModel(nombre, email, password, telefono, rol);

    res.status(201).json({
      mensaje: 'Usuario creado exitosamente',
      usuario: nuevoUsuario
    });
  } catch (error) {
    console.error('Error en controlador crearUsuario:', error);
    res.status(500).json({ error: error.message || 'Error al crear el usuario.' });
  }
};
// Alias por si se llama con minúscula en la i
export const crearUsuariocontroller = crearUsuarioController; 
export const createUsuarioController = crearUsuarioController;

// 2. Obtener todos los usuarios
export const obtenerUsuariosController = async (req, res) => {
  try {
    const usuarios = await obtenerUsuariosModel();
    res.status(200).json(usuarios);
  } catch (error) {
    console.error('Error al obtener usuarios:', error);
    res.status(500).json({ error: 'Error al obtener los usuarios.' });
  }

};
export const getUsuariosController = obtenerUsuariosController;


// 2. Obtener un usuario por ID
export const getUsuarioPorIdController = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await obtenerUsuarioPorId(id);

// 3. Obtener usuario por ID
export const obtenerUsuarioPorIdController = async (req, res) => {
  try {
    const { id } = req.params;
    const usuario = await obtenerUsuarioPorIdModel(id);


    if (!usuario) {
      return res.status(404).json({ error: 'Usuario no encontrado.' });
    }


// 3. Actualizar un usuario por ID

    res.status(200).json(usuario);
  } catch (error) {
    console.error('Error al obtener usuario por ID:', error);
    res.status(500).json({ error: 'Error al obtener el usuario.' });
  }
};
export const getUsuarioPorIdController = obtenerUsuarioPorIdController;

// 4. Actualizar usuario
export const actualizarUsuarioController = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, telefono, rol } = req.body;


        // CORRECCIÓN: antes cualquier usuario logueado podía editar los datos
        // (incluido el rol) de cualquier otro usuario con solo cambiar el :id
        // en la URL. Ahora solo puede editar el dueño de la cuenta o un admin.
        const esDueno = String(req.usuario.id) === String(id);
        const esAdmin = req.usuario.rol === 'admin';
        if (!esDueno && !esAdmin) {
            return res.status(403).json({ error: 'No tienes permiso para editar este usuario' });
        }

        const { data: usuarioExistente, error: errorBusqueda } = await obtenerUsuarioPorId(id);

        if (errorBusqueda || !usuarioExistente) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        // Si quien edita no es admin, evitamos que se auto-asigne otro rol
        if (!esAdmin && datosActualizados.rol) {
            delete datosActualizados.rol;
        }

        const { data, error } = await actualizarUsuarioModelo(id, datosActualizados);

        if (error) {
            return res.status(500).json({ error: 'Error al actualizar el usuario' });
        }

        return res.status(200).json({
            mensaje: 'Usuario actualizado correctamente',
            usuario: data
        });
    } catch (error) {
        console.error('Error en el controlador al actualizar usuario:', error);
        return res.status(500).json({ error: 'Error interno del servidor' });

    const { data, error } = await supabase
      .from('usuario')
      .update({ nombre, telefono, rol })
      .eq('id', id)
      .select()
      .single();

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    if (!data) {
      return res.status(404).json({ error: 'Usuario no encontrado para actualizar.' });
    }

    res.status(200).json({
      mensaje: 'Usuario actualizado exitosamente',
      usuario: data
    });
  } catch (error) {
    console.error('Error al actualizar usuario:', error);
    res.status(500).json({ error: 'Error interno del servidor al actualizar el usuario.' });
  }
};
export const updateUsuarioController = actualizarUsuarioController;


// 4. Eliminar un usuario por ID

// 5. Eliminar usuario
paola
export const eliminarUsuarioController = async (req, res) => {
  try {
    const { id } = req.params;

    const { error } = await supabase
      .from('usuario')
      .delete()
      .eq('id', id);

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    res.status(200).json({ mensaje: 'Usuario eliminado exitosamente' });
  } catch (error) {
    console.error('Error al eliminar usuario:', error);
    res.status(500).json({ error: 'Error interno del servidor al eliminar el usuario.' });
  }
};
export const deleteUsuarioController = eliminarUsuarioController;