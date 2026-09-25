import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { supabase } from '../config/supabase.js';
import { crearUsuariocontroller, obtenerUsuarioPorEmail } from '../models/usuario.js';
import { enviarcodigoverificacion } from '../utils/emailService.js';


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

        const codigoverificacion = Math.floor(100000 + Math.random() * 900000).toString();
        const codigoverificacionexpiracion = new Date(Date.now() + 15 * 60 * 1000).toISOString();

        // Si envías 'admin' toma 'admin', de lo contrario asigna 'cliente' por defecto
        const rolFinal = rol ? rol : 'cliente';

        const { data: nuevoUsuario, error } = await crearUsuariocontroller(
            nombre,
            email,
            hashedPassword,
            telefono,
            direccion,
            rolFinal,
            codigoverificacion,
            codigoverificacionexpiracion
        );

        if (error) throw error;

        // Enviar el código de verificación por correo
        const { exito, error: emailError } = await enviarcodigoverificacion(email, nombre, codigoverificacion);
        if (!exito) {
            console.error("Error enviando correo de verificación:", emailError);
            return res.status(500).json({
                error: "Error al enviar el código de verificación. Por favor, intenta nuevamente más tarde."
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

// 2. VERIFICAR CODIGO
export const verificarCuenta = async (req, res) => {
  try {
    const { email, codigo } = req.body;

    if (!email || !codigo) {
      return res.status(400).json({ error: 'Email y codigo son obligatorios' });
    }

    const { data: usuario } = await obtenerUsuarioPorEmail(email);
    if (!usuario) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    if (usuario.isVerified) {
      return res.status(400).json({ mensaje: 'Esta cuenta ya esta verificada' });
    }

    if (usuario.codigoverificacion !== codigo) {
      return res.status(400).json({ error: 'Codigo de verificacion incorrecto' });
    }

    const ahora = new Date();
    const expiracion = new Date(usuario.codigoverificacionExpiracion);
    if (ahora > expiracion) {
      return res.status(400).json({ error: 'El codigo ha expirado. Solicita uno nuevo.' });
    }

    // Marcar como verificado y limpiar el codigo
    const { error } = await supabase
      .from('usuarios')
      .update({
        isVerified: true,
        codigoverificacion: null,
        codigoverificacionexpiracion: null
      })
      .eq('email', email);

    if (error) throw error;

    res.json({ mensaje: 'Cuenta verificada con exito. Ya puedes iniciar sesion.' });
  } catch (error) {
    console.error('Error en verificacion:', error);
    res.status(500).json({ error: 'Error al verificar la cuenta' });
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

        if (!usuario.isVerified) {
      return res.status(403).json({
        error: 'Cuenta no verificada. Por favor verifica tu correo antes de iniciar sesion.'
      });
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