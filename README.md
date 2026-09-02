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

 
