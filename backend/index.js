import dotenv from 'dotenv';
import express from 'express';
import cors from 'cors';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import admin from 'firebase-admin';

import { logError } from './utils/logger.js';
import authRoutes from './routes/auth.js';
import usuarioRoutes from './routes/usuario.js';
import productoRoutes from './routes/producto.js';
import pedidoRoutes from './routes/pedido.js';
import detallePedidoRoutes from './routes/detallePedido.js';
import cocinaRoutes from './routes/cocina.js';
import domiciliarioRoutes from './routes/domiciliario.js';
import meseroRoutes from './routes/mesero.js';
import calificacionRoutes from './routes/calificacion.js';
import mensajesRoutes from './routes/mensajes.js';
import chatBotRoutes from './routes/chatBot.js';
import recuperarRoutes from './routes/recuperar.js';
import bannerRoutes from './routes/banners.js';
import destacadoRoutes from './routes/destacado.js';

dotenv.config();

// Obtener __dirname en ES Modules para leer archivos locales de forma segura
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Cargar la clave de Firebase Admin usando fs
// Si index.js está dentro de una carpeta como 'src', usa esto:


console.log('🔥 Firebase Admin SDK inicializado correctamente');

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(express.json());

// 🔍 Middleware de diagnóstico (imprime las peticiones en tu terminal)
app.use((req, res, next) => {
  console.log(`\n-----------------------------------------`);
  console.log(`📥 [PETICIÓN] ${req.method} -> ${req.url}`);
  if (req.body && Object.keys(req.body).length > 0) {
    console.log('📦 Body:', JSON.stringify(req.body, null, 2));
  }
  console.log(`-----------------------------------------`);
  next();
});

// Registro de endpoints de la API
app.use('/api/auth', authRoutes);
app.use('/api/usuarios', usuarioRoutes);
app.use('/api/productos', productoRoutes);
app.use('/api/pedidos', pedidoRoutes);
app.use('/api/detalles-pedido', detallePedidoRoutes);
app.use('/api/cocina', cocinaRoutes);
app.use('/api/domiciliarios', domiciliarioRoutes);
app.use('/api/meseros', meseroRoutes);
app.use('/api/calificaciones', calificacionRoutes);
app.use('/api/mensajes', mensajesRoutes);
app.use('/api/chatbot', chatBotRoutes);
app.use('/api/recuperar', recuperarRoutes);
app.use('/api/banners', bannerRoutes);
app.use('/api/destacados', destacadoRoutes);

// 🚀 Endpoint de prueba para enviar notificaciones push a través de Firebase Admin
app.post('/api/notificaciones/test', async (req, res) => {
  const { fcmToken, titulo, mensaje } = req.body;

  if (!fcmToken) {
    return res.status(400).json({ error: 'El campo fcmToken es obligatorio' });
  }

  const payload = {
    notification: {
      title: titulo || '🔥 Alerta desde el Backend de El Parche',
      body: mensaje || '¡Esta es una notificación enviada directamente desde tu servidor Node.js!'
    },
    token: fcmToken
  };

  try {
    const response = await admin.messaging().send(payload);
    console.log('✅ Notificación enviada con éxito desde Node.js. ID:', response);
    res.json({ success: true, messageId: response });
  } catch (error) {
    console.error('❌ Error enviando notificación desde Node.js:', error);
    res.status(500).json({ error: 'Error al enviar la notificación', detalle: error.message });
  }
});

// Ruta base de comprobación
app.get('/', (req, res) => {
  res.json({ mensaje: 'API de El Parche funcionando correctamente 🚀' });
});

// Ruta no encontrada (404)
app.use((req, res) => {
  console.warn(`\n⚠️ [404] No existe la ruta: ${req.method} ${req.originalUrl}`);
  res.status(404).json({ error: `No existe la ruta ${req.method} ${req.originalUrl}` });
});

// Manejador global de errores
app.use((err, req, res, next) => {
  logError(`Excepción no controlada en ${req.method} ${req.originalUrl}`, err);
  res.status(500).json({
    error: 'Error interno del servidor',
    detalle: err.message
  });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`\n🚀 Servidor corriendo en el puerto ${PORT}`);
});