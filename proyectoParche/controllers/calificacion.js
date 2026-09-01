import { obtenerCalificaciones, obtenerCalificacionesPorPedido, crearCalificacion, actualizarCalificacion, eliminarCalificacion } from '../models/calificacion.js';

export const listar = async (req, res) => {
    try {
        const { data, error } = await obtenerCalificaciones();
        if (error) return res.status(500).json({ error: 'Error al listar calificaciones' });
        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const porPedido = async (req, res) => {
    try {
        const { pedidoId } = req.params;
        const { data, error } = await obtenerCalificacionesPorPedido(pedidoId);
        if (error) return res.status(500).json({ error: 'Error al consultar calificaciones' });
        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const crear = async (req, res) => {
    try {
        const { pedido_id, puntuacion, comentario } = req.body;

        if (!pedido_id || !puntuacion || puntuacion < 1 || puntuacion > 5) {
            return res.status(400).json({ error: 'pedido_id y puntuacion entre 1 y 5 son obligatorios' });
        }

        const { data, error } = await crearCalificacion({
            pedido_id,
            usuario_id: req.usuario.id,
            puntuacion,
            comentario: comentario || null
        });

        if (error) return res.status(500).json({ error: 'Error al crear la calificación' });
        return res.status(201).json({ message: 'Calificación creada', calificacion: data[0] });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const editar = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await actualizarCalificacion(id, req.body);
        if (error) return res.status(500).json({ error: 'Error al actualizar la calificación' });
        return res.status(200).json({ message: 'Calificación actualizada', calificacion: data[0] });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const eliminar = async (req, res) => {
    try {
        const { id } = req.params;
        const { error } = await eliminarCalificacion(id);
        if (error) return res.status(500).json({ error: 'Error al eliminar la calificación' });
        return res.status(200).json({ message: 'Calificación eliminada' });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};