import supabase from '../config/supabase.js';

export const listarMeseros = async () => {
  const { data, error } = await supabase.from('mesero').select('*');
  if (error) throw error;
  return data;
};

export const obtenerPorId = async (id) => {
  const { data, error } = await supabase.from('mesero').select('*').eq('id', id).single();
  if (error) throw error;
  return data;
};

export const crearMesero = async (mesero) => {
  const { data, error } = await supabase.from('mesero').insert([mesero]).select().single();
  if (error) throw error;
  return data;
};

export const actualizarMesero = async (id, cambios) => {
  const { data, error } = await supabase.from('mesero').update(cambios).eq('id', id).select().single();
  if (error) throw error;
  return data;
};

export const eliminarMesero = async (id) => {
  const { error } = await supabase.from('mesero').delete().eq('id', id);
  if (error) throw error;
  return true;
};

// Crear un pedido tomado en mesa por el mesero (mismo flujo que pedido, con mesa_numero)
export const crearPedidoEnMesa = async (mesero_id, mesa_numero, items) => {
  const total = items.reduce((sum, item) => sum + item.cantidad * item.precio_unitario, 0);

  const { data: pedido, error: errorPedido } = await supabase
    .from('pedido')
    .insert([{ mesero_id, mesa_numero, total, estado: 'pendiente', tipo: 'mesa' }])
    .select()
    .single();
  if (errorPedido) throw errorPedido;

  const detalles = items.map((item) => ({ ...item, pedido_id: pedido.id }));
  const { error: errorDetalle } = await supabase.from('detallePedido').insert(detalles);
  if (errorDetalle) throw errorDetalle;

  return pedido;
};

export default {
  listarMeseros,
  obtenerPorId,
  crearMesero,
  actualizarMesero,
  eliminarMesero,
  crearPedidoEnMesa
};