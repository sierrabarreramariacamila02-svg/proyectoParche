import {supabase} from '../config/supabase.js';

// 1. Obtener todos los banners ordenados por fecha
export const obtenerBanners = async () => {
    return await supabase
        .from('banners')
        .select('*')
        .order('created_at', { ascending: false });
};

// 2. Insertar un nuevo banner en la base de datos
export const crearBanner = async (bannerData) => {
    return await supabase
        .from('banners')
        .insert([bannerData])
        .select();
};

// 3. Eliminar un banner por su ID
export const eliminarBanner = async (id) => {
    return await supabase
        .from('banners')
        .delete()
        .eq('id', id);
};