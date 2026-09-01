const nodemailer = require('nodemailer');
require('dotenv').config();

// Configura el transportador con las credenciales del .env
const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST,       // ej: smtp.gmail.com
  port: process.env.EMAIL_PORT || 587,
  secure: process.env.EMAIL_PORT == 465, // true si usas puerto 465
  auth: {
    user: process.env.EMAIL_USER,     // tu correo
    pass: process.env.EMAIL_PASS      // contraseña o "app password"
  }
});

/**
 * Envía un correo genérico
 * @param {string} to - correo destino
 * @param {string} subject - asunto
 * @param {string} html - contenido HTML del correo
 * @param {string} [text] - contenido en texto plano (opcional, fallback)
 */
const sendEmail = async ({ to, subject, html, text }) => {
  try {
    const info = await transporter.sendMail({
      from: `"${process.env.EMAIL_FROM_NAME || 'Comida Rápida App'}" <${process.env.EMAIL_USER}>`,
      to,
      subject,
      text: text || subject,
      html
    });
    return info;
  } catch (error) {
    console.error('Error al enviar correo:', error.message);
    throw error;
  }
};

/* ---------- Plantillas listas para usar en tu app ---------- */

// Correo de bienvenida al registrarse
const sendWelcomeEmail = async (to, nombre) => {
  return sendEmail({
    to,
    subject: '¡Bienvenido a Comida Rápida App! 🍔',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 500px; margin: auto;">
        <h2>¡Hola, ${nombre}!</h2>
        <p>Gracias por registrarte en nuestra app. Ya puedes empezar a pedir tu comida favorita.</p>
        <p style="color:#888; font-size:12px;">Si no creaste esta cuenta, ignora este mensaje.</p>
      </div>
    `
  });
};

// Confirmación de pedido
const sendOrderConfirmation = async (to, nombre, pedido) => {
  const itemsHtml = (pedido.detallePedido || [])
    .map(
      (item) =>
        `<li>${item.cantidad}x ${item.producto?.nombre || 'Producto'} - $${item.precio_unitario}</li>`
    )
    .join('');

  return sendEmail({
    to,
    subject: `Pedido #${pedido.id} confirmado ✅`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 500px; margin: auto;">
        <h2>¡Gracias por tu pedido, ${nombre}!</h2>
        <p>Tu pedido <strong>#${pedido.id}</strong> fue recibido y está en preparación.</p>
        <ul>${itemsHtml}</ul>
        <p><strong>Total: $${pedido.total}</strong></p>
        <p>Dirección de entrega: ${pedido.direccion_entrega}</p>
      </div>
    `
  });
};

// Notificación de cambio de estado del pedido
const sendOrderStatusUpdate = async (to, nombre, pedidoId, estado) => {
  const mensajesEstado = {
    en_preparacion: 'tu pedido está siendo preparado 👨‍🍳',
    listo: 'tu pedido está listo para salir 📦',
    en_camino: 'tu pedido va en camino 🛵',
    entregado: '¡tu pedido fue entregado! Buen provecho 🎉',
    cancelado: 'tu pedido fue cancelado ❌'
  };

  return sendEmail({
    to,
    subject: `Actualización de tu pedido #${pedidoId}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 500px; margin: auto;">
        <h2>Hola, ${nombre}</h2>
        <p>${mensajesEstado[estado] || `El estado de tu pedido cambió a: ${estado}`}</p>
      </div>
    `
  });
};

// Recuperación de contraseña
const sendPasswordReset = async (to, nombre, resetLink) => {
  return sendEmail({
    to,
    subject: 'Recupera tu contraseña',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 500px; margin: auto;">
        <h2>Hola, ${nombre}</h2>
        <p>Solicitaste restablecer tu contraseña. Haz clic en el siguiente enlace (válido por 1 hora):</p>
        <a href="${resetLink}" style="display:inline-block;padding:10px 20px;background:#e63946;color:#fff;text-decoration:none;border-radius:5px;">Restablecer contraseña</a>
        <p style="color:#888; font-size:12px;">Si no solicitaste esto, ignora este correo.</p>
      </div>
    `
  });
};

module.exports = {
  sendEmail,
  sendWelcomeEmail,
  sendOrderConfirmation,
  sendOrderStatusUpdate,
  sendPasswordReset
};
