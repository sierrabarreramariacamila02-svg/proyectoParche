import { crearPedido, obtenerPedidoConDetalles, obtenerPedidos, obtenerPedidosPorUsuario, actualizarPedido, eliminarPedido } from '../models/pedido.js';
import { logError } from '../utils/logger.js';

export const listarPedidos = async (req, res) => {
    try {
        const { data, error } = await obtenerPedidos();
        if (error) {
            logError('listarPedidos', error);
            return res.status(500).json({ error: 'Error al obtener los pedidos' });
        }
        return res.status(200).json(data);
    } catch (error) {
        logError('listarPedidos', error);
        return res.status(500).json({ error: error.message });
    }
};

export const misPedidos = async (req, res) => {
    try {
        const { data, error } = await obtenerPedidosPorUsuario(req.usuario.id);
        if (error) {
            logError('misPedidos', error);
            return res.status(500).json({ error: 'Error al obtener tus pedidos' });
        }
        return res.status(200).json(data);
    } catch (error) {
        logError('misPedidos', error);
        return res.status(500).json({ error: error.message });
    }
};

export const obtenerPedido = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await obtenerPedidoConDetalles(id);
        if (error) {
            logError('obtenerPedido', error);
            return res.status(404).json({ error: 'Pedido no encontrado', detalle: error.message });
        }
        if (!data) {
            return res.status(404).json({ error: 'Pedido no encontrado' });
        }
        return res.status(200).json(data);
    } catch (error) {
        logError('obtenerPedido', error);
        return res.status(500).json({ error: error.message });
    }
};

export const crear = async (req, res) => {
    try {
        const { tipo_pedido, numero_mesa } = req.body;
        const tipo = tipo_pedido || 'domicilio';

        if (tipo === 'mesa' && !numero_mesa) {
            return res.status(400).json({ error: 'numero_mesa es obligatorio para pedidos de mesa' });
        }

        const { data, error } = await crearPedido({
            usuario_id: req.usuario.id,
            tipo_pedido: tipo,
            numero_mesa: numero_mesa || null,
            estado: 'pendiente',
            total: req.body.total || 0
        });

        if (error) {
            logError('crear pedido', error);
            return res.status(500).json({ error: 'Error al crear el pedido' });
        }

        return res.status(201).json({ message: 'Pedido creado', pedido: data[0] });

    } catch (error) {
        logError('crear pedido', error);
        return res.status(500).json({ error: error.message });
    }
};

export const editar = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await actualizarPedido(id, req.body);
        if (error) {
            logError('editar pedido', error);
            return res.status(500).json({ error: 'Error al actualizar el pedido' });
        }
        return res.status(200).json({ message: 'Pedido actualizado', pedido: data[0] });
    } catch (error) {
        logError('editar pedido', error);
        return res.status(500).json({ error: error.message });
    }
};

export const eliminar = async (req, res) => {
    try {
        const { id } = req.params;
        const { error } = await eliminarPedido(id);
        if (error) {
            logError('eliminar pedido', error);
            return res.status(500).json({ error: 'Error al eliminar el pedido' });
        }
        return res.status(200).json({ message: 'Pedido eliminado' });
    } catch (error) {
        logError('eliminar pedido', error);
        return res.status(500).json({ error: error.message });
    }
};