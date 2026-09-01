import { supabase } from '../config/supabase.js';

export const crearDetallePedido = async (detalleData) => {
  const { data, error } = await supabase.from('detalle_pedido').insert(detalleData).select();
  return { data, error };
};

export const obtenerDetallesPorPedido = async (pedidoId) => {
  const { data, error } = await supabase
    .from('detalle_pedido')
    .select('*, producto:producto_id(*)')
    .eq('pedido_id', pedidoId)
    .order('id');
  return { data, error };
};

export const actualizarDetallePedido = async (id, cambios) => {
  const { data, error } = await supabase.from('detalle_pedido').update(cambios).eq('id', id).select();
  return { data, error };
};

export const eliminarDetallePedido = async (id) => {
  const { data, error } = await supabase.from('detalle_pedido').delete().eq('id', id);
  return { data, error };
};