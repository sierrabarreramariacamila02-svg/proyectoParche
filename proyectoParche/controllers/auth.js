import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { crearUsuario, obtenerUsuarioPorEmail } from '../models/usuario.js';

// Registro de usuario
export const registro = async (req, res) => {
    try {
        // Extraemos 'rol' además de los otros datos del body
        const { nombre, email, password, telefono, direccion, rol } = req.body;

        if (!nombre || !email || !password) {
            return res.status(400).json({
                error: "Faltan campos obligatorios (nombre, email, password)"
            });
        }

        const { data: usuarioExiste } = await obtenerUsuarioPorEmail(email);
        if (usuarioExiste) {
            return res.status(400).json({
                error: "El email ya está registrado"
            });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        // Si envías 'admin' toma 'admin', de lo contrario asigna 'cliente' por defecto
        const rolFinal = rol ? rol : 'cliente';

        const { data: nuevoUsuario, error } = await crearUsuario(
            nombre,
            email,
            hashedPassword,
            telefono,
            direccion,
            rolFinal
        );

        if (error) {
            console.error("Error en el registro:", error);
            return res.status(500).json({
                error: "Error al crear el usuario en la base de datos"
            });
        }

        return res.status(201).json({
            message: "Usuario creado exitosamente",
            usuario: nuevoUsuario
        });

    } catch (error) {
        console.error("Error en el registro:", error);
        return res.status(500).json({
            error: "Error interno del servidor"
        });
    }
};

// Login
export const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ error: "Email y password son requeridos" });
        }

        const { data: usuario, error } = await obtenerUsuarioPorEmail(email);
        if (error || !usuario) {
            return res.status(401).json({ error: "Credenciales incorrectas" });
        }

        const passwordValido = await bcrypt.compare(password, usuario.password);
        if (!passwordValido) {
            return res.status(401).json({ error: "Credenciales incorrectas" });
        }

        const token = jwt.sign(
            {
                id: usuario.id,
                email: usuario.email,
                rol: usuario.rol
            },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );

        const usuarioSinPassword = { ...usuario };
        delete usuarioSinPassword.password;

        return res.json({
            message: "Login exitoso",
            usuario: usuarioSinPassword,
            token: token
        });

    } catch (error) {
        console.error(error);
        return res.status(500).json({ error: "Error interno del servidor" });
    }
};