import { obtenerClienteInventario } from '../config/inventarioSupabase.js';

const tablaInventario = 'inventario';

export const listarInventario = async () => {
  const { data, error } = await obtenerClienteInventario()
    .from(tablaInventario)
    .select('*')
    .order('nombre', { ascending: true });
  return { data, error };
};

export const crearIngrediente = async (ingrediente) => {
  const { data, error } = await obtenerClienteInventario()
    .from(tablaInventario)
    .insert(ingrediente)
    .select()
    .single();
  return { data, error };
};

export const actualizarIngrediente = async (id, ingrediente) => {
  const { data, error } = await obtenerClienteInventario()
    .from(tablaInventario)
    .update(ingrediente)
    .eq('id', id)
    .select()
    .single();
  return { data, error };
};

export const eliminarIngrediente = async (id) => {
  const { error } = await obtenerClienteInventario()
    .from(tablaInventario)
    .delete()
    .eq('id', id);
  return { error };
};
