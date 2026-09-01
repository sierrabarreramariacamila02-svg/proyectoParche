const supabase = require('../config/supabase');

const listarDomiciliarios = async () => {
  const { data, error } = await supabase.from('domiciliario').select('*');
  if (error) throw error;
  return data;
};

const listarDisponibles = async () => {
  const { data, error } = await supabase.from('domiciliario').select('*').eq('disponible', true);
  if (error) throw error;
  return data;
};

const obtenerPorId = async (id) => {
  const { data, error } = await supabase.from('domiciliario').select('*').eq('id', id).single();
  if (error) throw error;
  return data;
};

const crearDomiciliario = async (domiciliario) => {
  const { data, error } = await supabase.from('domiciliario').insert([domiciliario]).select().single();
  if (error) throw error;
  return data;
};

const actualizarDomiciliario = async (id, cambios) => {
  const { data, error } = await supabase
    .from('domiciliario')
    .update(cambios)
    .eq('id', id)
    .select()
    .single();
  if (error) throw error;
  return data;
};

const cambiarDisponibilidad = async (id, disponible) => {
  const { data, error } = await supabase
    .from('domiciliario')
    .update({ disponible })
    .eq('id', id)
    .select()
    .single();
  if (error) throw error;
  return data;
};

module.exports = {
  listarDomiciliarios,
  listarDisponibles,
  obtenerPorId,
  crearDomiciliario,
  actualizarDomiciliario,
  cambiarDisponibilidad
};
