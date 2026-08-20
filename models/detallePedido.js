const supabase = require('../config/supabase');

const listarPorPedido = async (pedido_id) => {
  const { data, error } = await supabase
    .from('detallePedido')
    .select('*, producto(*)')
    .eq('pedido_id', pedido_id);
  if (error) throw error;
  return data;
};

const agregarItem = async (item) => {
  const { data, error } = await supabase.from('detallePedido').insert([item]).select().single();
  if (error) throw error;
  return data;
};

const actualizarItem = async (id, cambios) => {
  const { data, error } = await supabase
    .from('detallePedido')
    .update(cambios)
    .eq('id', id)
    .select()
    .single();
  if (error) throw error;
  return data;
};

const eliminarItem = async (id) => {
  const { error } = await supabase.from('detallePedido').delete().eq('id', id);
  if (error) throw error;
  return true;
};

module.exports = { listarPorPedido, agregarItem, actualizarItem, eliminarItem };
