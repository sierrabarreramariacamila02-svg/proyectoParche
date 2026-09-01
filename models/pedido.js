const supabase = require('../config/supabase');

const ESTADOS = ['pendiente', 'en_preparacion', 'listo', 'en_camino', 'entregado', 'cancelado'];

const crearPedido = async (usuario_id, direccion_entrega, items) => {
  const total = items.reduce((sum, item) => sum + item.cantidad * item.precio_unitario, 0);

  const { data: pedido, error: errorPedido } = await supabase
    .from('pedido')
    .insert([{ usuario_id, direccion_entrega, total, estado: 'pendiente' }])
    .select()
    .single();

  if (errorPedido) throw errorPedido;

  const detalles = items.map((item) => ({ ...item, pedido_id: pedido.id }));

  const { error: errorDetalle } = await supabase.from('detallePedido').insert(detalles);
  if (errorDetalle) throw errorDetalle;

  return pedido;
};

const obtenerPedidoPorId = async (id) => {
  const { data, error } = await supabase
    .from('pedido')
    .select('*, detallePedido(*, producto(*))')
    .eq('id', id)
    .single();
  if (error) throw error;
  return data;
};

const listarPedidosPorUsuario = async (usuario_id) => {
  const { data, error } = await supabase
    .from('pedido')
    .select('*')
    .eq('usuario_id', usuario_id)
    .order('fecha_creacion', { ascending: false });
  if (error) throw error;
  return data;
};

const listarPorEstado = async (estado) => {
  const { data, error } = await supabase
    .from('pedido')
    .select('*, detallePedido(*, producto(*))')
    .eq('estado', estado)
    .order('fecha_creacion', { ascending: true });
  if (error) throw error;
  return data;
};

const actualizarEstadoPedido = async (id, estado) => {
  if (!ESTADOS.includes(estado)) {
    throw new Error(`Estado inválido. Debe ser uno de: ${ESTADOS.join(', ')}`);
  }
  const { data, error } = await supabase
    .from('pedido')
    .update({ estado })
    .eq('id', id)
    .select()
    .single();
  if (error) throw error;
  return data;
};

const asignarDomiciliario = async (id, domiciliario_id) => {
  const { data, error } = await supabase
    .from('pedido')
    .update({ domiciliario_id, estado: 'en_camino' })
    .eq('id', id)
    .select()
    .single();
  if (error) throw error;
  return data;
};

module.exports = {
  ESTADOS,
  crearPedido,
  obtenerPedidoPorId,
  listarPedidosPorUsuario,
  listarPorEstado,
  actualizarEstadoPedido,
  asignarDomiciliario
};
