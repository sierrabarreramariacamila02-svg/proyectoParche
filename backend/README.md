# 🍔 EL PARCHE - SISTEMA DE PEDIDOS Y GESTIÓN DE RESTAURANTE

SISTEMA INTEGRAL RESTful PARA GESTIONAR EL CATÁLOGO DE PRODUCTOS, PEDIDOS, COCINA, DOMICILIARIOS Y ATENCIÓN A MESAS, DESARROLLADO CON UNA EXCELENTE TECNOLOGÍA.

---

## 🛠️ Stack Tecnológico

El proyecto utiliza una arquitectura moderna basada en un servidor backend API REST y una base de datos en la nube, integrando las siguientes tecnologías:

*   **Node.js + Express** (backend)
*   **Supabase** (base de datos y almacenamiento)
*   **Cloudinary** (gestión de imágenes)
*   **Brevo** (envío de correos transaccionales)
*   **JWT & Bcrypt** (autenticación y encriptación)

---

## 🚀 Características del Proyecto

### 🔒 1. Autenticación y Seguridad

*   **Registro e Inicio de Sesión:** Autenticación segura para usuarios mediante tokens (JWT) y verificación de cuenta por código vía correo electrónico.
*   **Control de Acceso Basado en Roles (RBAC):** Vistas y permisos diferenciados para perfiles Cliente, Administrador, Cocina, Mesero y Domiciliario.
*   **Protección de Rutas:** Middlewares en el backend para restringir el acceso a endpoints sensibles según el rol.
*   **Gestión de Sesión:** Cierre de sesión seguro y expiración automática de credenciales.

### 🍽️ 2. Gestión Operativa de Restaurante

*   **Gestión de Menú:** Control CRUD de productos y categorías.
*   **Módulo de Pedidos:** Flujo completo de pedidos para consumo en mesa o servicio a domicilio.
*   **Panel de Cocina:** Control del estado de preparación de los pedidos en tiempo real.
*   **Módulo de Meseros y Domiciliarios:** Asignación de entregas y seguimiento de atenciones en mesa.
*   **Calificaciones y Mensajería:** Sistema de retroalimentación de usuarios y chat interno de soporte/conversaciones.

### Flujo de pedidos de mesa entre mesero y cocina

* El mesero autenticado crea un pedido con `POST /api/pedidos`, enviando `tipo_pedido: "mesa"`, `numero_mesa` y `productos` (cada producto incluye `producto_id` y `cantidad`). El backend calcula los precios desde el catálogo y registra los detalles y el pedido de cocina.
* Cocina consulta los pedidos con `GET /api/pedidos`. Los estados se actualizan con `PUT /api/pedidos/:id/estado`: `pendiente` → `en_preparacion` → `listo`.
* El mesero consulta sus pedidos con `GET /api/pedidos/mis-pedidos`; cuando cocina marca un pedido como `listo`, la pantalla del mesero lo detecta y muestra una notificación en la aplicación. Tras la entrega, el mesero puede marcarlo como `entregado`.
* La aplicación actualiza ambas pantallas consultando el backend cada cinco segundos mientras están abiertas.

---

## 🛠️ Instalación y Configuración

### 1. Clonar el repositorio

*   `git clone  https://github.com/sierrabarreramariacamila02-svg/proyectoParche.git
*   Instalación de Node.js
*   Ejecutar `npm install`
*   Instalar librería de express
*   Instalar librería de supabase

## 2. Ejecutar al servidor
** npm run dev

## 3. Preparar la gestión de usuarios administrativos

Antes de usar la creación, edición o eliminación de usuarios desde el panel, ejecuta
`migrations/202610270001_add_admin_managed_users.sql` en el SQL Editor de Supabase.
Esta migración añade la marca que separa las cuentas creadas/gestionadas desde el
panel de los registros normales.

## 4. Configurar el inventario

En el SQL Editor de Supabase, ejecuta `migrations/202611030002_secure_inventory_access.sql`.
En el `.env` del backend, configura `SUPABASE_SERVICE_ROLE_KEY` con la clave `service_role`
del proyecto Supabase y reinicia el servidor. Esta clave se usa únicamente en el backend;
no la incluyas en Flutter ni la publiques. La consulta de inventario permite a admin,
cocina y cocinero; las operaciones para crear, editar o eliminar ingredientes son solo
para admin.

## 5. Habilitar pedidos a domicilio

En el SQL Editor del mismo proyecto Supabase, ejecuta
`migrations/202611100001_enable_delivery_order_details.sql`. La migración agrega la dirección,
los datos de contacto y el método de pago que registra el checkout de domicilio. Después,
despliega o reinicia el backend para habilitar el guardado y consulta de esos datos.

## 6. Habilitar descripciones de promociones para el chatbot

En el SQL Editor de Supabase, ejecuta
`migrations/202611100002_add_banner_description.sql`. Después, despliega o reinicia el
backend. Al subir un banner desde el panel, registra su descuento y condiciones para que
el chatbot pueda informar la promoción vigente.

## 7. Configurar el envío de códigos de verificación

En las variables de entorno del backend (por ejemplo, en Render), configura:

- `BREVO_API_KEY`: API Key de Brevo (no la clave SMTP) con acceso al envío de correos transaccionales.
- `BREVO_SENDER_EMAIL`: dirección remitente verificada en Brevo.
- `BREVO_SENDER_NAME` (opcional): nombre que aparecerá como remitente.

Como compatibilidad, también se aceptan `EMAIL_USER` y `EMAIL_FROM_NAME` para la dirección
y el nombre del remitente. Después de guardar las variables, vuelve a desplegar el backend.
Si Brevo responde `401 Unauthorized`, crea una API Key nueva desde **Brevo → SMTP & API → API Keys**,
actualiza `BREVO_API_KEY` en Render y vuelve a desplegar. No compartas la clave en capturas ni mensajes.
El botón **Verificar** del registro crea la cuenta y envía el código de seis dígitos al correo
ingresado; si el envío falla, la cuenta no verificada puede volver a registrarse para solicitar
un nuevo código.

## 8. Configurar el inicio de sesión con Google

En Render, configura `GOOGLE_CLIENT_ID` con el ID del cliente OAuth de tipo **Aplicación web**
del mismo proyecto Firebase/Google Cloud usado por Flutter. En Google Cloud Console, agrega
el dominio donde está publicada la aplicación Flutter a los **Orígenes autorizados de JavaScript**
y vuelve a desplegar el backend. Para compilar Flutter Web con otro cliente web, puedes indicar
`--dart-define=GOOGLE_WEB_CLIENT_ID=...`; el valor predeterminado usa el cliente web incluido
en `frontend/android/app/google-services.json`.

---

## 📂 Estructura del proyecto
proyectoParche/
└── backend/
    ├── config/             # Configuración de Supabase y Cloudinary
    ├── controllers/        # Lógica para usuarios, productos, pedidos, cocina, etc.
    ├── middlewares/        # Validación de JWT y control de roles
    ├── models/             # Consultas y esquemas de base de datos en Supabase
    ├── node_modules/       # Dependencias instaladas
    ├── routes/             # Definición de rutas API REST
    ├── utils/              # Servicios auxiliares (envío de emails, tokens, respuestas)
    ├── .env                # Variables de entorno
    ├── .gitignore          # Archivos y carpetas ignorados por Git
    ├── index.js            # Servidor principal Express
    ├── package-lock.json   # Registro de versiones exactas de dependencias
    └── package.json        # Configuración del proyecto y dependencias

---
    

### 👨‍💻 Autor / Equipo de Desarrollo

* **Paola Diaz**
  * **Rol:** Desarrolladora Backend
  * **Especialidad:** Arquitectura de APIs RESTful, Node.js, Express y gestión de bases de datos.

* **Camila Sierra**
  * **Rol:** Desarrolladora Frontend / Mobile
  * **Especialidad:** Desarrollo de la aplicación móvil en Flutter y UI/UX.

 
