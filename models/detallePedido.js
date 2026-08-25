import supabase from '../config/supabase.js';

export const listarDomiciliarios = async () => {
  const { data, error } = await supabase.from('domiciliario').select('*');
  if (error) throw error;
  return data;
};

export const listarDisponibles = async () => {
  const { data, error } = await supabase.from('domiciliario').select('*').eq('disponible', true);
  if (error) throw error;
  return data;
};

export const obtenerPorId = async (id) => {
  const { data, error } = await supabase.from('domiciliario').select('*').eq('id', id).single();
  if (error) throw error;
  return data;
};

export const crearDomiciliario = async (domiciliario) => {
  const { data, error } = await supabase.from('domiciliario').insert([domiciliario]).select().single();
  if (error) throw error;
  return data;
};

export const actualizarDomiciliario = async (id, cambios) => {
  const { data, error } = await supabase
    .from('domiciliario')
    .update(cambios)
    .eq('id', id)
    .select()
    .single();
  if (error) throw error;
  return data;
};

export const cambiarDisponibilidad = async (id, disponible) => {
  const { data, error } = await supabase
    .from('domiciliario')
    .update({ disponible })
    .eq('id', id)
    .select()
    .single();
  if (error) throw error;
  return data;
};

export default {
  listarDomiciliarios,
  listarDisponibles,
  obtenerPorId,
  crearDomiciliario,
  actualizarDomiciliario,
  cambiarDisponibilidad
};