import { obtenerConversaciones, crearConversacion, obtenerConversacionPorId, obtenerMensajesDeConversacion, crearMensaje } from '../models/mensajes.js';

export const listarConversaciones = async (req, res) => {
    try {
        const { data, error } = await obtenerConversaciones();
        if (error) return res.status(500).json({ error: 'Error al listar conversaciones' });
        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const nuevaConversacion = async (req, res) => {
    try {
        const { data, error } = await crearConversacion({ usuario_id: req.usuario.id });
        if (error) return res.status(500).json({ error: 'Error al crear la conversación' });
        return res.status(201).json({ message: 'Conversación creada', conversacion: data[0] });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const obtenerConversacion = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await obtenerConversacionPorId(id);
        if (error || !data) return res.status(404).json({ error: 'Conversación no encontrada' });
        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const listarMensajes = async (req, res) => {
    try {
        const { conversacionId } = req.params;
        const { data, error } = await obtenerMensajesDeConversacion(conversacionId);
        if (error) return res.status(500).json({ error: 'Error al listar mensajes' });
        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const enviarMensaje = async (req, res) => {
    try {
        const { conversacionId } = req.params;
        const { contenido } = req.body;

        if (!contenido) return res.status(400).json({ error: 'contenido es obligatorio' });

        const { data, error } = await crearMensaje({
            conversacion_id: conversacionId,
            emisor_id: req.usuario.id,
            contenido
        });

        if (error) return res.status(500).json({ error: 'Error al enviar el mensaje' });
        return res.status(201).json({ message: 'Mensaje enviado', mensaje: data[0] });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};