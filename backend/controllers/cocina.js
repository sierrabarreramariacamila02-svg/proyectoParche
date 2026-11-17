import { obtenerCocina, crearRegistroCocina, actualizarCocina } from '../models/cocina.js';
import { supabase } from '../config/supabase.js';
import { logError } from '../utils/logger.js';

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
        if (error) return res.status(500).json({ error: 'Error al crear el registro de cocina', detalle: error.message});
        return res.status(201).json({ message: 'Registro creado', cocina: data[0] || data });
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

export const notificarPedidoListo = async (req, res) => {
    const pedidoId = Number(req.body?.pedido_id);
    if (!Number.isSafeInteger(pedidoId) || pedidoId <= 0) {
        return res.status(400).json({ error: 'El identificador del pedido no es válido' });
    }

    try {
        const { data: pedido, error: errorPedido } = await supabase
            .from('pedido')
            .select('id, tipo_pedido, numero_mesa, estado')
            .eq('id', pedidoId)
            .maybeSingle();

        if (errorPedido) {
            logError('notificarPedidoListo: consultar pedido', errorPedido);
            return res.status(500).json({ error: 'No se pudo consultar el pedido' });
        }
        if (!pedido) {
            return res.status(404).json({ error: 'Pedido no encontrado' });
        }
        if (pedido.estado !== 'listo') {
            return res.status(409).json({ error: 'El pedido aún no está listo' });
        }

        const lugar = pedido.tipo_pedido === 'mesa'
            ? `Mesa ${pedido.numero_mesa ?? '—'}`
            : pedido.tipo_pedido === 'domicilio'
            ? 'Domicilio'
            : pedido.tipo_pedido === 'recoger'
            ? 'Para recoger'
            : 'Pedido';
        const { error } = await supabase.from('notificaciones').insert({
            titulo: `Pedido #${pedido.id} listo para entregar`,
            cuerpo: `El pedido de ${lugar} está listo.`,
            leida: false,
        });

        if (error) {
            logError('notificarPedidoListo: guardar notificación', error);
            return res.status(500).json({ error: 'No se pudo guardar el aviso' });
        }

        return res.status(201).json({ message: 'Mesero notificado' });
    } catch (error) {
        logError('notificarPedidoListo', error);
        return res.status(500).json({ error: 'No se pudo guardar el aviso' });
    }
};