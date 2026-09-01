import { supabase } from '../config/supabase.js';

export const crearPedido = async (pedidoData) => {
  const { data, error } = await supabase.from('pedido').insert(pedidoData).select();
  return { data, error };
};

export const obtenerPedidoConDetalles = async (id) => {
  const { data, error } = await supabase
    .from('pedido')
    .select(`
      *,
      usuario:usuario_id(id, nombre, email),
      detalle_pedido(id, cantidad, precio_unitario, subtotal, producto:producto_id(id, nombre, precio))
    `)
    .eq('id', id)
    .single();
  return { data, error };
};

export const obtenerPedidos = async () => {
  const { data, error } = await supabase
    .from('pedido')
    .select('*, usuario:usuario_id(id, nombre, email)')
    .order('id', { ascending: false });
  return { data, error };
};

export const obtenerPedidosPorUsuario = async (usuarioId) => {
  const { data, error } = await supabase
    .from('pedido')
    .select('*')
    .eq('usuario_id', usuarioId)
    .order('id', { ascending: false });
  return { data, error };
};

export const actualizarPedido = async (id, cambios) => {
  const { data, error } = await supabase.from('pedido').update(cambios).eq('id', id).select();
  return { data, error };
};

export const eliminarPedido = async (id) => {
  const { data, error } = await supabase.from('pedido').delete().eq('id', id);
  return { data, error };
};