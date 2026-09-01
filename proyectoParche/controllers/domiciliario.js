import { obtenerDomiciliarios, crearDomiciliario, actualizarDomiciliario } from '../models/domiciliario.js';

export const listar = async (req, res) => {
    try {
        const { data, error } = await obtenerDomiciliarios();
        if (error) return res.status(500).json({ error: 'Error al consultar entregas' });
        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const crear = async (req, res) => {
    try {
        const { data, error } = await crearDomiciliario(req.body);
        if (error) return res.status(500).json({ error: 'Error al asignar domiciliario' });
        return res.status(201).json({ message: 'Domiciliario asignado', domiciliario: data[0] });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const editar = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await actualizarDomiciliario(id, { ...req.body, actualizado_en: new Date().toISOString() });
        if (error) return res.status(500).json({ error: 'Error al actualizar la entrega' });
        return res.status(200).json({ message: 'Entrega actualizada', domiciliario: data[0] });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};