import { crearPedido, obtenerPedidoConDetalles, obtenerPedidos, obtenerPedidosPorUsuario, actualizarPedido, eliminarPedido } from '../models/pedido.js';
import { logError } from '../utils/logger.js';
import { crearDetallePedido } from '../models/detallePedido.js';
import { actualizarCocinaPorPedido, crearRegistroCocina } from '../models/cocina.js';
import { obtenerProductoPorId } from '../models/producto.js';

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
    const {
      tipo_pedido,
      numero_mesa,
      direccion_entrega,
      productos
    } = req.body || {};
    const tipo = tipo_pedido || 'domicilio';

    if (!['mesa', 'domicilio', 'recoger'].includes(tipo)) {
      return res.status(400).json({ error: 'Tipo de pedido no válido' });
    }

    if (tipo === 'mesa' && !String(numero_mesa || '').trim()) {
      return res.status(400).json({
        error: 'numero_mesa es obligatorio para pedidos de mesa'
      });
    }

    if (tipo === 'domicilio' && !String(direccion_entrega || '').trim()) {
      return res.status(400).json({
        error: 'La dirección de entrega es obligatoria para pedidos a domicilio'
      });
    }

    if (!Array.isArray(productos) || productos.length === 0) {
      return res.status(400).json({
        error: 'Debes agregar al menos un producto'
      });
    }

    // Validate product IDs and quantities before creating the order.
    for (const producto of productos) {
      if (
        !producto ||
        typeof producto !== 'object' ||
        !producto.producto_id ||
        !Number.isInteger(Number(producto.cantidad)) ||
        Number(producto.cantidad) <= 0
      ) {
        return res.status(400).json({
          error: 'Los datos de uno de los productos no son válidos'
        });
      }
    }

    const detalles = [];
    for (const producto of productos) {
      const { data: productoDB, error: errorProducto } =
        await obtenerProductoPorId(producto.producto_id);

      if (errorProducto || !productoDB) {
        return res.status(400).json({
          error: `No se encontró el producto ${producto.producto_id}`
        });
      }

      const precio = Number(productoDB.precio);
      const cantidad = Number(producto.cantidad);
      if (!Number.isFinite(precio) || precio < 0) {
        return res.status(400).json({
          error: `El precio del producto ${producto.producto_id} no es válido`
        });
      }
      detalles.push({
        producto_id: productoDB.id,
        cantidad,
        precio_unitario: precio,
        subtotal: cantidad * precio
      });
    }

    const subtotal = detalles.reduce(
      (suma, detalle) => suma + detalle.subtotal,
      0
    );
    const total = subtotal + (tipo === 'domicilio' ? 8000 : 0);

    // 1. Crear pedido principal
    const { data, error } = await crearPedido({
      usuario_id: req.usuario.id,
      tipo_pedido: tipo,
      numero_mesa: numero_mesa || null,
      direccion_entrega: tipo === 'domicilio'
        ? String(direccion_entrega).trim()
        : null,
      estado: 'pendiente',
      total
    });

    if (error || !data?.length) {
      logError('crear pedido', error);
      return res.status(500).json({
        error: 'No se pudo crear el pedido'
      });
    }

    const pedido = data[0];

    // 2. Guardar los productos relacionados
    const detallesConPedido = detalles.map((detalle) => ({
      ...detalle,
      pedido_id: pedido.id
    }));

    const { error: errorDetalles } =
      await crearDetallePedido(detallesConPedido);

    if (errorDetalles) {
      logError('guardar detalles del pedido', errorDetalles);
      return res.status(500).json({
        error: 'El pedido se creó, pero falló el guardado de sus productos',
        pedido_id: pedido.id
      });
    }

    // 3. Registrar el pedido en cocina
    const { error: errorCocina } = await crearRegistroCocina({
      pedido_id: pedido.id,
      estado: 'pendiente',
      actualizado_en: new Date().toISOString()
    });

    if (errorCocina) {
      logError('registrar pedido en cocina', errorCocina);
      return res.status(500).json({
        error: 'El pedido se guardó, pero falló su registro en cocina',
        pedido_id: pedido.id
      });
    }

    // 4. Responder al frontend
    return res.status(201).json({
      message: 'Pedido creado y enviado a cocina',
      pedido,
      detalles: detallesConPedido
    });

  } catch (error) {
    console.error('Error creando pedido:', error);
    return res.status(500).json({
      error: 'Error interno al crear el pedido'
    });
  }
};

export const actualizarEstado = async (req, res) => {
    try {
        const { id } = req.params;
        const estado = String(req.body?.estado || '').trim().toLowerCase();
        const estadosValidos = ['pendiente', 'en_preparacion', 'listo', 'entregado'];

        if (!estadosValidos.includes(estado)) {
            return res.status(400).json({ error: 'Estado de pedido no válido' });
        }

        const { data: pedidoActual, error: errorPedido } = await obtenerPedidoConDetalles(id);
        if (errorPedido) {
            logError('consultar pedido para cambiar estado', errorPedido);
            return res.status(500).json({ error: 'Error al consultar el pedido' });
        }
        if (!pedidoActual) {
            return res.status(404).json({ error: 'Pedido no encontrado' });
        }

        const rol = String(req.usuario.rol || '').toLowerCase();
        if (rol === 'mesero' && String(pedidoActual.usuario_id) !== String(req.usuario.id)) {
            return res.status(403).json({ error: 'No puedes actualizar un pedido de otro mesero' });
        }

        if ((rol === 'cocina' || rol === 'cocinero') && estado === 'entregado') {
            return res.status(403).json({ error: 'Solo el mesero puede marcar el pedido como entregado' });
        }

        if (rol === 'cocina' || rol === 'cocinero') {
            if (estado === 'en_preparacion' && pedidoActual.estado !== 'pendiente') {
                return res.status(409).json({ error: 'Solo se puede iniciar la preparación de un pedido pendiente' });
            }
            if (estado === 'listo' && pedidoActual.estado !== 'en_preparacion') {
                return res.status(409).json({ error: 'El pedido debe estar en preparación antes de marcarlo como listo' });
            }
        }

        if (rol === 'mesero' && estado !== 'entregado') {
            return res.status(403).json({ error: 'El mesero solo puede marcar el pedido como entregado' });
        }

        if (estado === 'entregado' && pedidoActual.estado !== 'listo' && pedidoActual.estado !== 'entregado') {
            return res.status(409).json({ error: 'El pedido debe estar listo antes de entregarlo' });
        }

        const cambiosCocina = {
            estado,
            actualizado_en: new Date().toISOString()
        };
        let { data: registrosCocina, error: errorCocina } =
            await actualizarCocinaPorPedido(id, cambiosCocina);
        if (errorCocina) {
            logError('sincronizar estado de cocina', errorCocina);
            return res.status(500).json({
                error: 'No se pudo actualizar el estado en cocina'
            });
        }

        if (!registrosCocina || registrosCocina.length === 0) {
            const resultadoCocina = await crearRegistroCocina({
                pedido_id: pedidoActual.id,
                ...cambiosCocina
            });
            registrosCocina = resultadoCocina.data;
            errorCocina = resultadoCocina.error;
            if (errorCocina) {
                logError('crear registro de cocina para pedido existente', errorCocina);
                return res.status(500).json({
                    error: 'No se pudo sincronizar el estado del pedido con cocina'
                });
            }
        }

        const { data, error } = await actualizarPedido(id, { estado });
        if (error || !data || data.length === 0) {
            if (error) {
                logError('actualizar estado del pedido', error);
            }
            await actualizarCocinaPorPedido(id, {
                estado: pedidoActual.estado,
                actualizado_en: new Date().toISOString()
            });
            return res.status(error ? 500 : 404).json({
                error: error
                    ? 'No se pudo actualizar el estado del pedido'
                    : 'Pedido no encontrado'
            });
        }

        return res.status(200).json({ message: 'Estado actualizado', pedido: data[0] });
    } catch (error) {
        logError('actualizar estado del pedido', error);
        return res.status(500).json({ error: 'Error interno al actualizar el estado del pedido' });
    }
};

export const editar = async (req, res) => {
    try {
        const { id } = req.params;
        if (Object.prototype.hasOwnProperty.call(req.body || {}, 'estado')) {
            return res.status(400).json({
                error: 'Actualiza el estado usando la ruta /pedidos/:id/estado'
            });
        }
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