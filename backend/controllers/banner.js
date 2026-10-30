import { obtenerBanners, crearBanner, eliminarBanner } from '../models/banner.js';
import { cloudinary } from '../config/cloudinary.js';

// Función auxiliar para subir la imagen del banner a Cloudinary
const subirImagenBanner = (archivo) => new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
        { folder: 'banners', resource_type: 'image' },
        (error, resultado) => {
            if (error) return reject(error);
            if (!resultado?.secure_url) {
                return reject(new Error('No se pudo obtener la URL de la imagen del banner'));
            }
            resolve(resultado.secure_url);
        }
    );
    stream.end(archivo.buffer);
});

// 1. Listar todos los banners para mostrarlos en el carrusel del Home
export const listarBanners = async (req, res) => {
    try {
        const { data, error } = await obtenerBanners();
        if (error) {
            return res.status(500).json({ error: 'Error al obtener los banners', detalle: error.message });
        }
        return res.status(200).json(data || []);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// 2. Crear / Subir un nuevo banner de promoción desde el panel administrativo
export const crear = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'La imagen del banner es obligatoria' });
        }

        const imagenUrl = await subirImagenBanner(req.file);
        const { data, error } = await crearBanner({
            imagen_url: imagenUrl
        });

        if (error) {
            return res.status(500).json({ error: 'Error al registrar el banner en la base de datos', detalle: error.message });
        }

        return res.status(201).json({ 
            message: 'Banner creado con éxito', 
            banner: data && data.length > 0 ? data[0] : null 
        });

    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// 3. Eliminar un banner obsoleto o viejo
export const eliminar = async (req, res) => {
    try {
        const { id } = req.params;
        const { error } = await eliminarBanner(id);
        
        if (error) {
            return res.status(500).json({ error: 'Error al eliminar el banner', detalle: error.message });
        }
        return res.status(200).json({ message: 'Banner eliminado correctamente' });

    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};