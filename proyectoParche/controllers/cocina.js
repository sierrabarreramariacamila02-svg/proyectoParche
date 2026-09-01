import { obtenerCocina, crearRegistroCocina, actualizarCocina } from '../models/cocina.js';

export const listar = async (req, res) => {
    try {
        const { data, error } = await obtenerCocina();
        if (error) return res.status(500).json({ error: 'Error al consultar cocina' });
        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const crear = async (req, res) => {
    try {
        const { data, error } = await crearRegistroCocina(req.body);
        if (error) return res.status(500).json({ error: 'Error al crear el registro de cocina' });
        return res.status(201).json({ message: 'Registro creado', cocina: data[0] });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const editar = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await actualizarCocina(id, { ...req.body, actualizado_en: new Date().toISOString() });
        if (error) return res.status(500).json({ error: 'Error al actualizar cocina' });
        return res.status(200).json({ message: 'Cocina actualizada', cocina: data[0] });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};