import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { connectaDB } from './config/supabase.js';

import authRoutes from './routes/auth.js';
import usuarioRoutes from './routes/usuario.js';
import productoRoutes from './routes/producto.js';
import pedidoRoutes from './routes/pedido.js';
import detallePedidoRoutes from './routes/detallePedido.js';
import cocinaRoutes from './routes/cocina.js';
import domiciliarioRoutes from './routes/domiciliario.js';
import meseroRoutes from './routes/mesero.js';
import mensajesRoutes from './routes/mensajes.js';
import calificacionRoutes from './routes/calificacion.js';
import recuperarRoutes from './routes/recuperar.js';
import chatRoutes from "./routes/chatBot.js";

connectaDB();

const app = express();
app.use(cors());
app.use(express.json());


app.get('/', (req, res) => {
    res.json({
        Mensaje: "Bienvenido al backend de proyectoParche",
        Estado: "En linea",
        Version: "1.0.0"
    });
});

app.use('/auth', authRoutes);
app.use('/usuarios', usuarioRoutes);
app.use('/productos', productoRoutes);
app.use('/pedidos', pedidoRoutes);
app.use('/detalles-pedido', detallePedidoRoutes);
app.use('/cocina', cocinaRoutes);
app.use('/domiciliarios', domiciliarioRoutes);
app.use('/meseros', meseroRoutes);
app.use('/mensajes', mensajesRoutes);
app.use('/calificaciones', calificacionRoutes);
app.use('/recuperar', recuperarRoutes);
app.use("/api/chat", chatRoutes);


const PORT =  3000;

const servidor = app.listen(PORT, () => {
    console.log(`🚀 Servidor corriendo en el puerto ${PORT}`);
    console.log(`📍 http://localhost:${PORT}`);
    console.log(`📍 Registro: http://localhost:${PORT}`);
});