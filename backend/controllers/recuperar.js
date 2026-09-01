import bcrypt from 'bcryptjs';
import { actualizarUsuario } from '../models/usuario.js';

export const cambiarPassword = async (req, res) => {
    try {
        const { password } = req.body;

        if (!password || password.length < 6) {
            return res.status(400).json({ error: 'La nueva contraseña debe tener al menos 6 caracteres' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const { error } = await actualizarUsuario(req.usuario.id, { password: hashedPassword });

        if (error) {
            return res.status(500).json({ error: 'No se pudo cambiar la contraseña' });
        }

        return res.status(200).json({ message: 'Contraseña actualizada' });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};