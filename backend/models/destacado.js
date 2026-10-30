import { supabase } from '../config/supabase.js';

export const obtenerDestacados = async () => {
    return await supabase
        .from('platos_destacados')
        .select('*')
        .order('id', { ascending: false });
};

export const crearDestacado = async (datos) => {
    return await supabase
        .from('platos_destacados')
        .insert(datos)
        .select();
};

export const actualizarDestacado = async (id, datos) => {
    return await supabase
        .from('platos_destacados')
        .update(datos)
        .eq('id', id)
        .select();
};

export const eliminarDestacado = async (id) => {
    return await supabase
        .from('platos_destacados')
        .delete()
        .eq('id', id);
};