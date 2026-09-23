import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { logError } from './utils/logger.js';

// Importación de todas las rutas del backend de El Parche
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

dotenv.config();

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

// Ruta base de comprobación
app.get('/', (req, res) => {
  res.json({ mensaje: 'API de El Parche funcionando correctamente 🚀' });
});

// Ruta no encontrada (404) - antes solo mostraba el HTML feo de Express
app.use((req, res) => {
  console.warn(`\n⚠️ [404] No existe la ruta: ${req.method} ${req.originalUrl}`);
  res.status(404).json({ error: `No existe la ruta ${req.method} ${req.originalUrl}` });
});

// Manejador global de errores, ahora con el detalle completo
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