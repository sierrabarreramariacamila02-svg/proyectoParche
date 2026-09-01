import { obtenerAtenciones, crearAtencion, actualizarAtencion } from '../models/mesero.js';

export const listar = async (req, res) => {
    try {
        const { data, error } = await obtenerAtenciones();
        if (error) return res.status(500).json({ error: 'Error al consultar atenciones' });
        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const crear = async (req, res) => {
    try {
        const meseroId = req.body.mesero_id || req.usuario.id;
        const { data, error } = await crearAtencion({ ...req.body, mesero_id: meseroId });
        if (error) return res.status(500).json({ error: 'Error al registrar la atención' });
        return res.status(201).json({ message: 'Atención registrada', mesero: data[0] });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const editar = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await actualizarAtencion(id, req.body);
        if (error) return res.status(500).json({ error: 'Error al actualizar la atención' });
        return res.status(200).json({ message: 'Atención actualizada', mesero: data[0] });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};