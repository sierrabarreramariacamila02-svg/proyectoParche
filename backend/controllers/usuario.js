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

// 3. Obtener usuario por ID
export const obtenerUsuarioPorIdController = async (req, res) => {
  try {
    const { id } = req.params;
    const usuario = await obtenerUsuarioPorIdModel(id);

    if (!usuario) {
      return res.status(404).json({ error: 'Usuario no encontrado.' });
    }

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

// 5. Eliminar usuario
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