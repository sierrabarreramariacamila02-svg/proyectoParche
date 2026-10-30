import {
    obtenerDestacados,
    crearDestacado,
    actualizarDestacado,
    eliminarDestacado
} from '../models/destacado.js';
import { cloudinary } from '../config/cloudinary.js';

// Sube el buffer de multer a Cloudinary (carpeta "destacados")
const subirImagen = (buffer) => new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
        { folder: 'destacados', resource_type: 'image' },
        (error, resultado) => {
            if (error) return reject(error);
            if (!resultado?.secure_url) {
                return reject(new Error('No se pudo obtener la URL de la imagen'));
            }
            resolve(resultado.secure_url);
        }
    );
    stream.end(buffer);
});

// "$ 15.000" -> 15000
const limpiarPrecio = (valor) => Number(String(valor).replace(/[^0-9.]/g, ''));

export const listar = async (req, res) => {
    try {
        const { data, error } = await obtenerDestacados();
        if (error) {
            return res.status(500).json({ error: 'Error al obtener los platos destacados', detalle: error.message });
        }
        return res.status(200).json(data || []);
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const crear = async (req, res) => {
    try {
        const { nombre, descripcion, precio } = req.body;

        if (!nombre || precio === undefined || precio === '') {
            return res.status(400).json({ error: 'Nombre y precio son obligatorios' });
        }

        const precioLimpio = limpiarPrecio(precio);
        if (Number.isNaN(precioLimpio)) {
            return res.status(400).json({ error: 'El precio no es válido' });
        }

        if (!req.file) {
            return res.status(400).json({ error: 'La imagen es obligatoria' });
        }

        const imagenUrl = await subirImagen(req.file.buffer);

        const { data, error } = await crearDestacado({
            nombre,
            descripcion: descripcion || '',
            precio: precioLimpio,
            imagen_url: imagenUrl
        });

        if (error) {
            return res.status(500).json({ error: 'Error al guardar el plato destacado', detalle: error.message });
        }

        return res.status(201).json({
            message: 'Plato destacado creado',
            destacado: data && data.length > 0 ? data[0] : null
        });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const editar = async (req, res) => {
    try {
        const { id } = req.params;
        const { nombre, descripcion, precio } = req.body;

        const datos = {};
        if (nombre !== undefined) datos.nombre = nombre;
        if (descripcion !== undefined) datos.descripcion = descripcion;

        if (precio !== undefined && precio !== '') {
            const precioLimpio = limpiarPrecio(precio);
            if (Number.isNaN(precioLimpio)) {
                return res.status(400).json({ error: 'El precio no es válido' });
            }
            datos.precio = precioLimpio;
        }

        // Solo se cambia la imagen si el admin eligió una nueva
        if (req.file) {
            datos.imagen_url = await subirImagen(req.file.buffer);
        }

        if (Object.keys(datos).length === 0) {
            return res.status(400).json({ error: 'No hay datos para actualizar' });
        }

        const { data, error } = await actualizarDestacado(id, datos);

        if (error) {
            return res.status(500).json({ error: 'Error al actualizar el plato destacado', detalle: error.message });
        }

        return res.status(200).json({
            message: 'Plato destacado actualizado',
            destacado: data && data.length > 0 ? data[0] : null
        });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const eliminar = async (req, res) => {
    try {
        const { id } = req.params;
        const { error } = await eliminarDestacado(id);

        if (error) {
            return res.status(500).json({ error: 'Error al eliminar el plato destacado', detalle: error.message });
        }
        return res.status(200).json({ message: 'Plato destacado eliminado' });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};