import Groq from "groq-sdk";
import { supabase } from "../config/supabase.js";
import { obtenerBanners } from "../models/banner.js";

const normalizar = (texto) =>
  String(texto ?? "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase();

const palabrasClave = (texto) =>
  normalizar(texto)
    .match(/[a-z0-9]+/g)
    ?.filter((palabra) => palabra.length > 2) ?? [];

const esSolicitudRecomendacion = (mensaje) =>
  /\b(recomiend\w*|suger\w*|opcion\w*|alternativ\w*|que puedo pedir)\b/.test(
    normalizar(mensaje),
  );

const seleccionarProductos = (mensaje, productos) => {
  const consulta = normalizar(mensaje);
  const tokensConsulta = new Set(palabrasClave(mensaje));
  const puntuados = productos.map((producto) => {
    const textoProducto = `${producto.nombre ?? ""} ${producto.categoria ?? ""} ${producto.descripcion ?? ""}`;
    const tokensProducto = palabrasClave(textoProducto);
    const coincidencias = tokensProducto.filter((token) =>
      tokensConsulta.has(token),
    ).length;
    return {
      producto,
      puntuacion:
        tokensProducto.length === 0 ? 0 : coincidencias / tokensProducto.length,
      nombreCoincide: normalizar(producto.nombre).length > 0 &&
        consulta.includes(normalizar(producto.nombre)),
    };
  });

  if (esSolicitudRecomendacion(mensaje)) {
    return puntuados
      .sort((a, b) => b.puntuacion - a.puntuacion || Math.random() - 0.5)
      .slice(0, 3)
      .map(({ producto }) => producto);
  }

  return puntuados
    .filter(({ puntuacion, nombreCoincide }) => nombreCoincide || puntuacion >= 0.6)
    .sort((a, b) => Number(b.nombreCoincide) - Number(a.nombreCoincide) || b.puntuacion - a.puntuacion)
    .slice(0, 3)
    .map(({ producto }) => producto);
};

const historialValido = (historial) =>
  Array.isArray(historial)
    ? historial
        .filter(
          (item) =>
            item &&
            (item.role === "user" || item.role === "assistant") &&
            typeof item.content === "string",
        )
        .slice(-12)
        .map((item) => ({
          role: item.role,
          content: item.content.slice(0, 1500),
        }))
    : [];

export const chatParche = async (req, res) => {
  try {
    const { message, sesionId, usuarioId, historial } = req.body;
    if (typeof message !== "string" || !message.trim()) {
      return res.status(400).json({ message: "Debes enviar un mensaje." });
    }

    const idSesionValido = sesionId || `parche_sesion_${Date.now()}`;
    const { data: productos, error: errorProductos } = await supabase
      .from("productos")
      .select("*")
      .order("id");

    if (errorProductos) {
      console.error("Error al consultar productos:", errorProductos.message);
      return res.status(500).json({ message: "Error al consultar productos." });
    }

    const { data: banners, error: errorBanners } = await obtenerBanners();
    if (errorBanners) {
      console.error("Error al consultar promociones:", errorBanners.message);
    }

    const catalogoTexto = (productos ?? [])
      .map((producto) => {
        const detalleDescuento = producto.descuento
          ? ` | Descuento: ${producto.descuento}`
          : "";
        return `- ${producto.nombre}: $${Number(producto.precio).toLocaleString("es-CO")} COP | Categoría: ${producto.categoria || "Sin categoría"} | Descripción: ${producto.descripcion || "Sin descripción"}${detalleDescuento}`;
      })
      .join("\n");

    const promocionesTexto = (banners ?? [])
      .map((banner) => banner.descripcion?.trim())
      .filter(Boolean)
      .map((descripcion) => `- ${descripcion}`)
      .join("\n");

    const systemPrompt = `
Eres el asesor virtual de Restaurante El Parche: amable, natural y útil.
Responde en español colombiano, teniendo en cuenta el historial y sin repetir saludos, frases ni recomendaciones que ya diste.

CATÁLOGO ACTUAL (consultado en cada mensaje):
${catalogoTexto || "No hay productos disponibles en este momento."}

PROMOCIONES ACTUALES (consultadas en cada mensaje):
${promocionesTexto || "No hay descripciones registradas para las promociones. No inventes descuentos; indica que pueden ver las imágenes vigentes en el carrusel de promociones del inicio."}

REGLAS:
- Si piden una recomendación, ofrece tres opciones distintas del catálogo actual, con una breve razón y sus precios.
- Si preguntan cómo pedir, explícales que pueden tocar «Agregar al carrito» debajo de las opciones y luego revisar el carrito para finalizar.
- Si no indican producto al pedir, pregunta qué se les antoja y cuántas unidades desean.
- Usa solo precios, productos y descuentos incluidos arriba. Nunca inventes disponibilidad ni promociones.
- Si preguntan por descuentos y no hay descripción registrada, diles con claridad que consulten las imágenes del carrusel; no supongas su contenido.
- Sé conversacional, breve y responde específicamente a la última pregunta.
`;

    const productosSugeridos = seleccionarProductos(
      message.trim(),
      productos ?? [],
    );
    const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });
    const completion = await groq.chat.completions.create({
      model: "openai/gpt-oss-20b",
      messages: [
        { role: "system", content: systemPrompt },
        ...historialValido(historial),
        { role: "user", content: message.trim() },
      ],
      temperature: 0.7,
      max_tokens: 500,
    });

    const respuestaTexto =
      completion.choices[0]?.message?.content ||
      "No pude generar una respuesta. ¿Puedes intentarlo de nuevo?";

    const registrosAInsertar = [
      {
        sesion_id: idSesionValido,
        usuario_id: usuarioId || null,
        emisor: "user",
        mensaje: message.trim(),
      },
      {
        sesion_id: idSesionValido,
        usuario_id: usuarioId || null,
        emisor: "bot",
        mensaje: respuestaTexto,
      },
    ];

    const { error: errorInsert } = await supabase
      .from("mensajes_chat")
      .insert(registrosAInsertar);

    if (errorInsert) {
      console.error("Error guardando el historial en Supabase:", errorInsert.message);
    }

    return res.status(200).json({
      respuesta: respuestaTexto,
      message: respuestaTexto,
      sesionId: idSesionValido,
      productosSugeridos,
    });
  } catch (error) {
    console.error("Error en Groq Chat EL PARCHE:", error);
    return res.status(500).json({
      message: "Error al procesar la respuesta",
      error: error.message,
    });
  }
};

export const obtenerHistorialELPARCHE = async (req, res) => {
  try {
    const { sesionId } = req.params;

    const { data: historial, error } = await supabase
      .from("mensajes_chat")
      .select("emisor, mensaje, created_at")
      .eq("sesion_id", sesionId)
      .order("created_at", { ascending: true });

    if (error) {
      return res.status(500).json({
        message: "Error al consultar historial",
        error: error.message,
      });
    }

    return res.status(200).json({ historial: historial || [] });
  } catch (error) {
    return res.status(500).json({ message: "Error interno", error: error.message });
  }
};
