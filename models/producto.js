import supabase from '../config/supabase.js';

export const listarProductos = async () => {
  const { data, error } = await supabase
    .from('producto')
    .select('*')
    .order('nombre');
  if (error) throw error;
  return data;
};

export const listarDisponibles = async () => {
  const { data, error } = await supabase
    .from('producto')
    .select('*')
    .order('nombre');
  if (error) throw error;
  return data;
};

export const obtenerPorId = async (id) => {
  const { data, error } = await supabase
    .from('producto')
    .select('*')
    .eq('Id_producto', id)
    .single();
  if (error) throw error;
  return data;
};

export const crearProducto = async (producto) => {
  const { nombre, descripcion, precio, existencias, imagen_url } = producto;

  // Mapeamos las llaves al nombre exacto de la columna en Supabase
  const payload = {
    nombre,
    precio: parseFloat(precio),
    existencias: existencias ? parseInt(existencias) : 10
  };

  // Mapeo especial para la columna con tilde en Supabase
  if (descripcion) {
    payload['descripción'] = descripcion;
  }

  // Agregamos imagen_url si existe la columna en tu tabla
  if (imagen_url) {
    payload.imagen_url = imagen_url;
  }

  const { data, error } = await supabase
    .from('producto')
    .insert([payload])
    .select()
    .single();

  if (error) throw error;
  return data;
};

export const actualizarProducto = async (id, cambios) => {
  const payload = { ...cambios };

  // Mapear tilde si se actualiza la descripción
  if (payload.descripcion) {
    payload['descripción'] = payload.descripcion;
    delete payload.descripcion;
  }

  const { data, error } = await supabase
    .from('producto')
    .update(payload)
    .eq('Id_producto', id)
    .select()
    .single();

  if (error) throw error;
  return data;
};

export const eliminarProducto = async (id) => {
  const { error } = await supabase
    .from('producto')
    .delete()
    .eq('Id_producto', id);

  if (error) throw error;
  return true;
};

export default {
  listarProductos,
  listarDisponibles,
  obtenerPorId,
  crearProducto,
  actualizarProducto,
  eliminarProducto
};