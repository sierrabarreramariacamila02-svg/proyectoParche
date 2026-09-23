import {
  crearUsuarioModel,
  buscarUsuarioPorEmailModel,
  actualizarUsuario
} from '../models/usuario.js';
import { enviarcodigoverificacion } from '../utils/emailService.js';
import { generarToken } from '../utils/generarToken.js';
import { logError } from '../utils/logger.js';
import bcrypt from 'bcrypt';

// Genera un código numérico de 6 dígitos
const generarCodigoVerificacion = () =>
  Math.floor(100000 + Math.random() * 900000).toString();

// Registro de usuario
export const registro = async (req, res) => {
  try {
    const { nombre, email, password, telefono, rol } = req.body;

    if (!nombre || !email || !password) {
      return res.status(400).json({ error: 'Nombre, email y password son obligatorios.' });
    }

    const usuarioExistente = await buscarUsuarioPorEmailModel(email);
    if (usuarioExistente) {
      return res.status(400).json({ error: 'El correo electrónico ya está registrado.' });
    }

    const codigo = generarCodigoVerificacion();
    const expiracion = new Date(Date.now() + 15 * 60 * 1000).toISOString(); // 15 minutos

    const nuevoUsuario = await crearUsuarioModel(
      nombre,
      email,
      password,
      telefono,
      rol,
      codigo,
      expiracion
    );

    try {
      await enviarcodigoverificacion(email, nombre, codigo);
    } catch (mailError) {
      logError('registro -> enviarcodigoverificacion', mailError);
    }

    res.status(201).json({
      mensaje: 'Usuario registrado con éxito. Revisa tu correo para verificar tu cuenta.',
      usuario: {
        id: nuevoUsuario.id,
        nombre: nuevoUsuario.nombre,
        email: nuevoUsuario.email,
        rol: nuevoUsuario.rol
      }
    });
  } catch (error) {
    logError('registro', error);
    res.status(500).json({ error: 'Error al registrar el usuario', detalle: error.message });
  }
};
export const registrarUsuario = registro;

// Login de usuario
export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'email y password son obligatorios.' });
    }

    const usuario = await buscarUsuarioPorEmailModel(email);
    if (!usuario) {
      return res.status(404).json({ error: 'Credenciales inválidas (usuario no encontrado).' });
    }

    const passwordValida = await bcrypt.compare(password, usuario.password);
    if (!passwordValida) {
      return res.status(401).json({ error: 'Credenciales inválidas (contraseña incorrecta).' });
    }

    if (!usuario.estaverificado) {
      return res.status(403).json({ error: 'Debes verificar tu cuenta antes de iniciar sesión.' });
    }

    const token = generarToken(usuario);

    res.json({
      mensaje: 'Inicio de sesión exitoso 🍻',
      token,
      usuario: {
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email,
        rol: usuario.rol
      }
    });
  } catch (error) {
    logError('login', error);
    res.status(500).json({ error: 'Error al iniciar sesión', detalle: error.message });
  }
};
export const loginUsuario = login;

// Verificación de cuenta con el código de 6 dígitos enviado por correo
export const verificarCuenta = async (req, res) => {
  try {
    const { email, codigo } = req.body;

    if (!email || !codigo) {
      return res.status(400).json({ error: 'email y codigo son obligatorios.' });
    }

    const usuario = await buscarUsuarioPorEmailModel(email);
    if (!usuario) {
      return res.status(404).json({ error: 'Usuario no encontrado.' });
    }

    if (usuario.estaverificado) {
      return res.status(200).json({ mensaje: 'La cuenta ya estaba verificada.' });
    }

    if (!usuario.codigoverificacion || usuario.codigoverificacion !== codigo) {
      return res.status(400).json({ error: 'Código de verificación incorrecto.' });
    }

    if (
      usuario.codigoverificacionexpiracion &&
      new Date(usuario.codigoverificacionexpiracion) < new Date()
    ) {
      return res.status(400).json({ error: 'El código de verificación ha expirado.' });
    }

    const { error } = await actualizarUsuario(usuario.id, {
      estaverificado: true,
      codigoverificacion: null,
      codigoverificacionexpiracion: null
    });

    if (error) {
      return res.status(500).json({ error: 'No se pudo verificar la cuenta.' });
    }

    return res.status(200).json({ mensaje: 'Cuenta verificada con éxito 🍻' });
  } catch (error) {
    logError('verificarCuenta', error);
    return res.status(500).json({ error: error.message });
  }
};

// Reenvía un código de verificación nuevo si el anterior expiró
export const reenviarCodigo = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: 'email es obligatorio.' });
    }

    const usuario = await buscarUsuarioPorEmailModel(email);
    if (!usuario) {
      return res.status(404).json({ error: 'Usuario no encontrado.' });
    }

    if (usuario.estaverificado) {
      return res.status(200).json({ mensaje: 'La cuenta ya estaba verificada.' });
    }

    const codigo = generarCodigoVerificacion();
    const expiracion = new Date(Date.now() + 15 * 60 * 1000).toISOString();

    const { error } = await actualizarUsuario(usuario.id, {
      codigoverificacion: codigo,
      codigoverificacionexpiracion: expiracion
    });

    if (error) {
      return res.status(500).json({ error: 'No se pudo generar un nuevo código.' });
    }

    try {
      await enviarcodigoverificacion(usuario.email, usuario.nombre, codigo);
    } catch (mailError) {
      logError('reenviarCodigo -> enviarcodigoverificacion', mailError);
    }

    return res.status(200).json({ mensaje: 'Se envió un nuevo código a tu correo.' });
  } catch (error) {
    logError('reenviarCodigo', error);
    return res.status(500).json({ error: error.message });
  }
};