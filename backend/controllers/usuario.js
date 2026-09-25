
import {
  getUsuarios,
  obtenerUsuarioPorId,
  actualizarUsuario,
  eliminarUsuario
} from '../models/usuario.js';
import { logError } from '../utils/logger.js';

// 1. Obtener todos los usuarios
export const getUsuariosController = async (req, res) => {

  try {
    const { data, error } = await getUsuarios();
    if (error) {
      return res.status(500).json({ error: 'Error al obtener los usuarios' });
    }
    return res.status(200).json({ usuarios: data });
  } catch (error) {
    logError('getUsuariosController', error);
    return res.status(500).json({ error: 'Error al obtener los usuarios' });
  }
};

// 2. Obtener un usuario por ID
export const getUsuarioPorIdController = async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await obtenerUsuarioPorId(id);

    if (error) {
      return res.status(500).json({ error: 'Error al obtener el usuario' });
    }

    if (!data) {
      return res.status(404).json({ error: 'Usuario no encontrado.' });
    }

    return res.status(200).json(data);
  } catch (error) {
    logError('getUsuarioPorIdController', error);
    return res.status(500).json({ error: 'Error al obtener el usuario.' });
  }
};
export const obtenerUsuarioPorIdController = getUsuarioPorIdController;

// 4. Actualizar usuario
export const actualizarUsuarioController = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, telefono, direccion, rol } = req.body;

    // Antes cualquier usuario logueado podía editar los datos (incluido el rol)
    // de cualquier otro usuario con solo cambiar el :id en la URL.
    // Ahora solo puede editar el dueño de la cuenta o un admin.
    const esDueno = String(req.usuario.id) === String(id);
    const esAdmin = req.usuario.rol === 'admin';
    if (!esDueno && !esAdmin) {
      return res.status(403).json({ error: 'No tienes permiso para editar este usuario' });
    }

    const { data: usuarioExistente, error: errorBusqueda } = await obtenerUsuarioPorId(id);
    if (errorBusqueda || !usuarioExistente) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    const datosActualizados = { nombre, telefono, direccion, rol };

    // Si quien edita no es admin, evitamos que se auto-asigne otro rol
    if (!esAdmin) {
      delete datosActualizados.rol;
    }

    // Quitamos campos undefined para no sobrescribir con "undefined" en Supabase
    Object.keys(datosActualizados).forEach((key) => {
      if (datosActualizados[key] === undefined) delete datosActualizados[key];
    });

    const { data, error } = await actualizarUsuario(id, datosActualizados);
    if (error) {
      return res.status(500).json({ error: 'Error al actualizar el usuario' });
    }

    return res.status(200).json({
      mensaje: 'Usuario actualizado correctamente',
      usuario: data
    });
  } catch (error) {
    logError('actualizarUsuarioController', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
};
export const updateUsuarioController = actualizarUsuarioController;

// 4. Eliminar usuario
export const eliminarUsuarioController = async (req, res) => {
  try {
    const { id } = req.params;
    const { error } = await eliminarUsuario(id);

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    return res.status(200).json({ mensaje: 'Usuario eliminado exitosamente' });
  } catch (error) {
    logError('eliminarUsuarioController', error);
    return res.status(500).json({ error: 'Error interno del servidor al eliminar el usuario.' });
  }
};
export const deleteUsuarioController = eliminarUsuarioController;