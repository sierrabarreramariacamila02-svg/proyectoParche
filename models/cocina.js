const supabase = require('../config/supabase');

// "Cocina" gestiona la cola de pedidos que debe preparar
const listarPedidosPendientes = async () => {
  const { data, error } = await supabase
    .from('pedido')
    .select('*, detallePedido(*, producto(*))')
    .in('estado', ['pendiente', 'en_preparacion'])
    .order('fecha_creacion', { ascending: true });
  if (error) throw error;
  return data;
};

const marcarEnPreparacion = async (pedido_id) => {
  const { data, error } = await supabase
    .from('pedido')
    .update({ estado: 'en_preparacion' })
    .eq('id', pedido_id)
    .select()
    .single();
  if (error) throw error;
  return data;
};

const marcarListo = async (pedido_id) => {
  const { data, error } = await supabase
    .from('pedido')
    .update({ estado: 'listo' })
    .eq('id', pedido_id)
    .select()
    .single();
  if (error) throw error;
  return data;
};

module.exports = { listarPedidosPendientes, marcarEnPreparacion, marcarListo };
