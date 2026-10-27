import { randomBytes } from 'node:crypto';
import bcrypt from 'bcryptjs';
import {
  getUsuarios,
  crearUsuarioAdministrativo,
  obtenerUsuarioPorEmail,
  obtenerUsuarioPorId,
  actualizarUsuario,
  eliminarUsuario
} from '../models/usuario.js';
import { logError } from '../utils/logger.js';

const ROLES_ADMINISTRABLES = new Set([
  'pendiente',
  'mesero',
  'cocinero',
  'domiciliario',
  'admin',
]);

// 1. Obtener todos los usuarios
export const getUsuariosController = async (req, res) => {

  try {
    const { data, error } = await getUsuarios();
    if (error) {
      return res.status(500).json({ error: 'Error al obtener los usuarios' });
    }
    return res.status(200).json({ usuarios: data });
  } catch (error) {
    logError('getUsuariosController', error);
    return res.status(500).json({ error: 'Error al obtener los usuarios' });
  }
};

export const crearUsuarioAdminController = async (req, res) => {
  try {
    const nombre = req.body.nombre?.trim();
    const email = req.body.email?.trim().toLowerCase();
    const rol = req.body.rol?.trim().toLowerCase();

    if (!nombre || !email || !rol) {
      return res.status(400).json({ error: 'Nombre, correo y rol son obligatorios' });
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return res.status(400).json({ error: 'El correo no es válido' });
    }
    if (!ROLES_ADMINISTRABLES.has(rol)) {
      return res.status(400).json({ error: 'El rol seleccionado no es válido' });
    }

    const { data: existente, error: errorBusqueda } = await obtenerUsuarioPorEmail(email);
    if (errorBusqueda) {
      logError('crearUsuarioAdminController: buscar correo', errorBusqueda);
      return res.status(500).json({ error: 'No se pudo validar el correo del usuario' });
    }

    let data;
    let error;
    let usuarioExistentePromovido = false;
    if (existente) {
      if (existente.creado_por_admin) {
        return res.status(409).json({ error: 'Ese usuario ya está agregado al panel' });
      }

      const resultado = await actualizarUsuario(existente.id, {
        nombre,
        rol,
        creado_por_admin: true,
      });
      data = Array.isArray(resultado.data) ? resultado.data[0] : resultado.data;
      error = resultado.error;
      usuarioExistentePromovido = true;
    } else {
      const passwordTemporal = await bcrypt.hash(randomBytes(32).toString('hex'), 10);
      const resultado = await crearUsuarioAdministrativo({
        nombre,
        email,
        password: passwordTemporal,
        telefono: req.body.telefono?.trim() || null,
        direccion: req.body.direccion?.trim() || null,
        rol,
        isverified: false,
        codigoverificacion: null,
        codigoverificacionexpiracion: null,
      });
      data = resultado.data;
      error = resultado.error;
    }

    if (error) {
      if (error.code === '23505') {
        return res.status(409).json({ error: 'Ya existe un usuario con ese correo' });
      }
      logError('crearUsuarioAdminController', error);
      return res.status(500).json({ error: 'No se pudo crear el usuario' });
    }

    return res.status(201).json({
      usuario: data,
      existentePromovido: usuarioExistentePromovido,
    });
  } catch (error) {
    logError('crearUsuarioAdminController', error);
    return res.status(500).json({ error: 'Error interno al crear el usuario' });
  }
};

export const actualizarRolUsuarioController = async (req, res) => {
  try {
    const { id } = req.params;
    const rol = req.body.rol?.trim().toLowerCase();

    if (!ROLES_ADMINISTRABLES.has(rol)) {
      return res.status(400).json({ error: 'El rol seleccionado no es válido' });
    }

    const { data: usuario, error: errorBusqueda } = await obtenerUsuarioPorId(id);
    if (errorBusqueda || !usuario) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    const { error } = await actualizarUsuario(id, {
      rol,
      creado_por_admin: true,
    });
    if (error) {
      return res.status(500).json({ error: 'No se pudo actualizar el rol' });
    }

    return res.status(200).json({ mensaje: 'Rol actualizado correctamente' });
  } catch (error) {
    logError('actualizarRolUsuarioController', error);
    return res.status(500).json({ error: 'Error interno al actualizar el rol' });
  }
};

// 2. Obtener un usuario por ID
export const getUsuarioPorIdController = async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await obtenerUsuarioPorId(id);

    if (error) {
      return res.status(500).json({ error: 'Error al obtener el usuario' });
    }

    if (!data) {
      return res.status(404).json({ error: 'Usuario no encontrado.' });
    }

    return res.status(200).json(data);
  } catch (error) {
    logError('getUsuarioPorIdController', error);
    return res.status(500).json({ error: 'Error al obtener el usuario.' });
  }
};
export const obtenerUsuarioPorIdController = getUsuarioPorIdController;

// 4. Actualizar usuario
export const actualizarUsuarioController = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, telefono, direccion, rol } = req.body;

    // Antes cualquier usuario logueado podía editar los datos (incluido el rol)
    // de cualquier otro usuario con solo cambiar el :id en la URL.
    // Ahora solo puede editar el dueño de la cuenta o un admin.
    const esDueno = String(req.usuario.id) === String(id);
    const esAdmin = ['admin', 'administrador'].includes(req.usuario.rol);
    if (!esDueno && !esAdmin) {
      return res.status(403).json({ error: 'No tienes permiso para editar este usuario' });
    }

    const { data: usuarioExistente, error: errorBusqueda } = await obtenerUsuarioPorId(id);
    if (errorBusqueda || !usuarioExistente) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    const datosActualizados = { nombre, telefono, direccion, rol };

    // Si quien edita no es admin, evitamos que se auto-asigne otro rol
    if (!esAdmin) {
      delete datosActualizados.rol;
    } else if (rol !== undefined) {
      if (!ROLES_ADMINISTRABLES.has(String(rol).trim().toLowerCase())) {
        return res.status(400).json({ error: 'El rol seleccionado no es válido' });
      }
      datosActualizados.rol = String(rol).trim().toLowerCase();
      datosActualizados.creado_por_admin = true;
    }

    // Quitamos campos undefined para no sobrescribir con "undefined" en Supabase
    Object.keys(datosActualizados).forEach((key) => {
      if (datosActualizados[key] === undefined) delete datosActualizados[key];
    });

    const { data, error } = await actualizarUsuario(id, datosActualizados);
    if (error) {
      return res.status(500).json({ error: 'Error al actualizar el usuario' });
    }

    return res.status(200).json({
      mensaje: 'Usuario actualizado correctamente',
      usuario: data
    });
  } catch (error) {
    logError('actualizarUsuarioController', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
};
export const updateUsuarioController = actualizarUsuarioController;

// 4. Eliminar usuario
export const eliminarUsuarioController = async (req, res) => {
  try {
    const { id } = req.params;
    if (String(req.usuario.id) === String(id)) {
      return res.status(400).json({ error: 'No puedes eliminar tu propia cuenta de administrador' });
    }

    const { data: usuario, error: errorBusqueda } = await obtenerUsuarioPorId(id);
    if (errorBusqueda || !usuario || !usuario.creado_por_admin) {
      return res.status(404).json({ error: 'Usuario administrativo no encontrado' });
    }

    const { error } = await eliminarUsuario(id);

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    return res.status(200).json({ mensaje: 'Usuario eliminado exitosamente' });
  } catch (error) {
    logError('eliminarUsuarioController', error);
    return res.status(500).json({ error: 'Error interno del servidor al eliminar el usuario.' });
  }
};
export const deleteUsuarioController = eliminarUsuarioController;