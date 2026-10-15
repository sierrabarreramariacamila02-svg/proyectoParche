import { BrevoClient } from '@getbrevo/brevo';

export const enviarcodigoverificacion = async (emailDestino, nombreDestino, codigo) => {
  try {
    // 1. Instanciar el cliente dentro de la funcion para asegurar la lectura del .env
    const brevo = new BrevoClient({
      apiKey: process.env.BREVO_API_KEY
    });

    const result = await brevo.transactionalEmails.sendTransacEmail({
      subject: 'Codigo de verificacion - EL PARCHE',
      sender: {
        name: process.env.EMAIL_FROM_NAME || 'EL PARCHE',
        email: process.env.EMAIL_USER
      },
      to: [
        {
          email: emailDestino,
          name: nombreDestino
        }
      ],
      htmlContent: `
  <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#fdf2f4">
    <tr>
      <td align="center" style="padding: 24px;">

        <table width="500" cellpadding="0" cellspacing="0" border="0"
          background="https://collection.cloudinary.com/j7vqjtlj/5bdd2d7d875946a89d4685f10b245ab8"
          bgcolor="#fdf2f4"
          style="max-width:500px; width:100%; background-image:url('https://collection.cloudinary.com/j7vqjtlj/5bdd2d7d875946a89d4685f10b245ab8'); background-size:cover; background-position:center; border:1px solid #e0e6e6; border-radius:8px;">
          <tr>
            <td align="center" style="padding: 24px; font-family: Arial, sans-serif;">

              <h2 style="color:#EEA639; margin-bottom:8px;">EL PARCHE</h2>
              <h3 style="color:#590606; margin-top:0;">Verifica tu cuenta</h3>

              <p style="color:#D0971A; font-size:15px;">Hola <strong>${nombreDestino}</strong>,</p>
              <p style="color:#555555; font-size:15px;">
                Gracias por unirte a EL PARCHE. Usa el siguiente código de verificación de 6 dígitos para activar y/o recuperar tu cuenta. Este código vencerá en 15 minutos.
              </p>

              <div style="margin:30px 0;">
                <span style="font-size:32px; font-weight:bold; letter-spacing:6px; color:#650505; background:#fdf2f4; padding:12px 24px; border-radius:8px;">
                  ${codigo}
                </span>
              </div>

              <p style="color:#888888; font-size:12px; margin-top:30px;">
                Si no creaste una cuenta en EL PARCHE, puedes ignorar este correo.
              </p>

            </td>
          </tr>
        </table>

      </td>
    </tr>
  </table>
`
    });

    console.log('Correo enviado con exito');
    return { exito: true, result };
  } catch (error) {
    console.error('Error enviando correo con Brevo:', error);
    return { exito: false, error };
  }
};