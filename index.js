import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Configurar variables de entorno
dotenv.config();

// 1. Inicializar Express primero
const app = express();

// 2. Middlewares globales
app.use(cors());
app.use(express.json());

// 3. Importar todas las rutas
import authRoutes from './routes/auth.js';
import recuperarRoutes from './routes/recuperar.js';
import usuarioRoutes from './routes/usuario.js';
import productoRoutes from './routes/producto.js';
import pedidoRoutes from './routes/pedido.js';
import detallePedidoRoutes from './routes/detallePedido.js';
import cocinaRoutes from './routes/cocina.js';
import domiciliarioRoutes from './routes/domiciliario.js';
import meseroRoutes from './routes/mesero.js';
import calificacionRoutes from './routes/calificacion.js';
import mensajesRoutes from './routes/mensajes.js';

// 4. Enlazar middlewares de rutas
app.use('/api/auth', authRoutes);
app.use('/api/recuperar', recuperarRoutes);
app.use('/api/usuarios', usuarioRoutes);
app.use('/api/productos', productoRoutes);
app.use('/api/pedidos', pedidoRoutes);
app.use('/api/detalle-pedidos', detallePedidoRoutes);
app.use('/api/cocina', cocinaRoutes);
app.use('/api/domiciliarios', domiciliarioRoutes);
app.use('/api/meseros', meseroRoutes);
app.use('/api/calificaciones', calificacionRoutes);
app.use('/api/mensajes', mensajesRoutes);

// Ruta de salud
app.get('/', (req, res) => {
  res.json({ mensaje: 'API de comida rápida funcionando 🍔' });
});

// Manejo de errores centralizado
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ ok: false, mensaje: 'Error interno del servidor' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`));