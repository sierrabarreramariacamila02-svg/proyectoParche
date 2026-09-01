import { supabase } from '../config/supabase.js';

export const obtenerDomiciliarios = async () => {
  const { data, error } = await supabase
    .from('domiciliario')
    .select('*, pedido:pedido_id(*), repartidor:repartidor_id(id, nombre, email, telefono)')
    .order('id', { ascending: false });
  return { data, error };
};

export const crearDomiciliario = async (domiciliarioData) => {
  const { data, error } = await supabase.from('domiciliario').insert(domiciliarioData).select();
  return { data, error };
};

export const actualizarDomiciliario = async (id, cambios) => {
  const { data, error } = await supabase.from('domiciliario').update(cambios).eq('id', id).select();
  return { data, error };
};