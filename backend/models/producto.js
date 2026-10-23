import { supabase } from '../config/supabase.js';

export const obtenerProductos = async (categoria) => {
    // ⚠️ Nota: Cambia 'productos' por 'producto' si en tu Supabase la tabla está en singular
    let query = supabase.from('productos').select('*'); 

    // Si se envía una categoría, filtramos en la base de datos
    if (categoria) {
        query = query.eq('categoria', categoria);
    }

    const { data, error } = await query.order('id');
    return { data, error };
};

export const obtenerProductoPorId = async (id) => {
    const { data, error } = await supabase.from('productos').select('*').eq('id', id).single();
    return { data, error };
};

export const crearProducto = async (productoData) => {
    const { data, error } = await supabase.from('productos').insert(productoData).select();
    return { data, error };
};

export const actualizarProducto = async (id, productoData) => {
    const { data, error } = await supabase.from('productos').update(productoData).eq('id', id).select();
    return { data, error };
};

export const eliminarProducto = async (id) => {
    const { data, error } = await supabase.from('productos').delete().eq('id', id);
    return { data, error };
};
