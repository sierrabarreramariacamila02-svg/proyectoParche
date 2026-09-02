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
};

// 2. Obtener un usuario por ID
export const getUsuarioPorIdController = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await obtenerUsuarioPorId(id);

        if (error || !data) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        return res.status(200).json({
            usuario: data
        });
    } catch (error) {
        console.error('Error al obtener al usuario:', error);
        return res.status(500).json({ error: 'Error interno del servidor' });
    }
};

// 3. Actualizar un usuario por ID
export const actualizarUsuarioController = async (req, res) => {
    try {
        const { id } = req.params;
        const datosActualizados = req.body;

        const { data: usuarioExistente, error: errorBusqueda } = await obtenerUsuarioPorId(id);

        if (errorBusqueda || !usuarioExistente) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
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
    }
};

// 4. Eliminar un usuario por ID
export const eliminarUsuarioController = async (req, res) => {
    try {
        const { id } = req.params;
        const { error } = await eliminarUsuario(id);

        if (error) {
            return res.status(500).json({ error: 'Error al eliminar el usuario' });
        }

        return res.status(200).json({ mensaje: 'Usuario eliminado correctamente' });
    } catch (error) {
        console.error('Error al eliminar usuario:', error);
        return res.status(500).json({ error: 'Error interno del servidor' });
    }
};