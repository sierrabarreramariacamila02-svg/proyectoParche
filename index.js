const express = require('express');
const cors = require('cors');
require('dotenv').config();

const usuarioRoutes = require('./routes/usuario');
const productoRoutes = require('./routes/producto');
const pedidoRoutes = require('./routes/pedido');
const detallePedidoRoutes = require('./routes/detallePedido');
const cocinaRoutes = require('./routes/cocina');
const domiciliarioRoutes = require('./routes/domiciliario');
const meseroRoutes = require('./routes/mesero');
const calificacionRoutes = require('./routes/calificacion');
const mensajesRoutes = require('./routes/mensajes');

const app = express();

app.use(cors());
app.use(express.json());

// Rutas
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

// Manejo de errores centralizado (por si algo se escapa de los try/catch)
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ ok: false, mensaje: 'Error interno del servidor' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`));
