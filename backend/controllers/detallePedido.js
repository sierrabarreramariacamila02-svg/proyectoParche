import { crearDetallePedido, obtenerDetallesPorPedido, actualizarDetallePedido, eliminarDetallePedido } from '../models/detallePedido.js';
import { obtenerProductoPorId } from '../models/producto.js';
import { obtenerPedidoConDetalles, actualizarPedido } from '../models/pedido.js';

export const listarPorPedido = async (req, res) => {
    try {
        const { pedidoId } = req.params;
        const { data, error } = await obtenerDetallesPorPedido(pedidoId);
        if (error) return res.status(500).json({ error: 'Error al obtener los detalles' });
        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// Función auxiliar para no repetir la lógica de recalcular el total del pedido
const recalcularTotalPedido = async (pedidoId) => {
    const { data: pedido } = await obtenerPedidoConDetalles(pedidoId);
    if (pedido) {
        const total = (pedido.detalle_pedido || []).reduce((suma, d) => suma + Number(d.subtotal), 0);
        await actualizarPedido(pedidoId, { total });
    }
};

export const crear = async (req, res) => {
    try {
        const { pedido_id, producto_id, cantidad } = req.body;

        if (!pedido_id || !producto_id || !cantidad || cantidad < 1) {
            return res.status(400).json({ error: 'pedido_id, producto_id y cantidad son obligatorios' });
        }

        const { data: producto, error: errorProducto } = await obtenerProductoPorId(producto_id);
        if (errorProducto || !producto) {
            return res.status(404).json({ error: 'Producto no encontrado' });
        }

        const subtotal = Number(producto.precio) * Number(cantidad);

        const { data, error } = await crearDetallePedido({
            pedido_id,
            producto_id,
            cantidad,
            precio_unitario: producto.precio,
            subtotal
        });

        if (error) return res.status(500).json({ error: 'Error al crear el detalle' });

        await recalcularTotalPedido(pedido_id);

        return res.status(201).json({ message: 'Detalle creado', detalle: data[0] });

    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const editar = async (req, res) => {
    try {
        const { id } = req.params;
        const cambios = { ...req.body };
        if (cambios.cantidad && cambios.precio_unitario) {
            cambios.subtotal = Number(cambios.cantidad) * Number(cambios.precio_unitario);
        }
        const { data, error } = await actualizarDetallePedido(id, cambios);
        if (error) return res.status(500).json({ error: 'Error al actualizar el detalle' });

        // CORRECCIÓN: si cambió el subtotal, el total del pedido debe recalcularse también.
        if (data && data[0] && data[0].pedido_id) {
            await recalcularTotalPedido(data[0].pedido_id);
        }

        return res.status(200).json({ message: 'Detalle actualizado', detalle: data[0] });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const eliminar = async (req, res) => {
    try {
        const { id } = req.params;

        const { data, error } = await eliminarDetallePedido(id);
        if (error) return res.status(500).json({ error: 'Error al eliminar el detalle' });

        const pedidoId = data && data[0] && data[0].pedido_id;
        if (pedidoId) {
            await recalcularTotalPedido(pedidoId);
        }

        return res.status(200).json({ message: 'Detalle eliminado' });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};