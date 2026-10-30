import { obtenerProductos, obtenerProductoPorId, crearProducto, actualizarProducto, eliminarProducto } from '../models/producto.js';
import { cloudinary } from '../config/cloudinary.js';

// Función auxiliar para subir el buffer de multer a Cloudinary mediante una Promesa
const subirACloudinary = (fileBuffer) => {
    return new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream(
            { folder: 'productos' }, // Carpeta opcional en tu cuenta de Cloudinary
            (error, result) => {
                if (error) return reject(error);
                resolve(result.secure_url);
            }
        );
        stream.end(fileBuffer);
    });
};  

export const listarProductos = async (req, res) => {
    try {
        const { categoria } = req.query;
        const { data, error } = await obtenerProductos(categoria);

        if (error) return res.status(500).json({ error: error.message });
        return res.status(200).json(data);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const obtenerProducto = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await obtenerProductoPorId(id);

        if (error || !data) {
            console.error('❌ Producto no encontrado o error:', error);
            return res.status(404).json({ error: 'Producto no encontrado' });
        }

        return res.status(200).json(data);
    } catch (error) {
        console.error('❌ Excepción en obtenerProducto:', error);
        return res.status(500).json({ error: error.message });
    }
};

export const crear = async (req, res) => {
    try {
        const { nombre, descripcion, precio, categoria, destacado } = req.body;

        if (!nombre || !precio) {
            return res.status(400).json({ error: 'Nombre y precio son obligatorios' });
        }

        // Limpiar precio (ej: "$ 15.000" se convierte en 15000 numérico)
        const precioLimpio = Number(precio.toString().replace(/[^0-9.]/g, ''));

        let imagenUrl = null;
        if (req.file) {
            imagenUrl = await subirACloudinary(req.file.buffer);
        }

        const productoData = {
            nombre,
            descripcion,
            precio: precioLimpio,
            categoria,
            destacado: destacado === 'true' || destacado === true,
            ...(imagenUrl && { imagen_url: imagenUrl })
        };

        const { data, error } = await crearProducto(productoData);
        if (error) return res.status(500).json({ error: error.message });

        return res.status(201).json({ message: 'Producto creado', producto: data[0] });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};
export const editar = async (req, res) => {
    try {
        const { id } = req.params;
        const { nombre, descripcion, precio, categoria, imagen_url, destacado } = req.body;

        let datosActualizados = { nombre, descripcion, categoria };

        if (destacado !== undefined) {
        datosActualizados.destacado = destacado === 'true' || destacado === true;
}

        if (precio !== undefined && precio !== '') {
            datosActualizados.precio = Number(precio.toString().replace(/[^0-9.]/g, ''));
        }

        // Si subió una foto nueva, se sube a Cloudinary y se guarda esa URL
        if (req.file) {
            datosActualizados.imagen_url = await subirACloudinary(req.file.buffer);
        } else if (imagen_url) {
            datosActualizados.imagen_url = imagen_url;
        }

        const { data, error } = await actualizarProducto(id, datosActualizados);

        if (error) {
            console.error('❌ Error al actualizar producto en Supabase:', error);
            return res.status(500).json({ error: 'Error al actualizar el producto', detalle: error.message });
        }

        return res.status(200).json({
            message: 'Producto actualizado',
            producto: data && data.length > 0 ? data[0] : null
        });

    } catch (error) {
        console.error('❌ Excepción en editar producto:', error);
        return res.status(500).json({ error: error.message });
    }
};

export const eliminar = async (req, res) => {
    try {
        const { id } = req.params;
        const { error } = await eliminarProducto(id);

        if (error) {
            return res.status(500).json({ error: 'Error al eliminar el producto' });
        }

        return res.status(200).json({ message: 'Producto eliminado correctamente' });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};