🍔 El Parche - API REST Backend

1. Breve Descripción
El Parche es una API REST desarrollada para la gestión integral de pedidos en un restaurante de comida rápida. Facilita la administración de roles de usuario, la gestión del menú digital, la recepción de pedidos en cocina, la atención de meseros y el seguimiento de domicilios en tiempo real.
---

2. Características Principales
* Autenticación y Autorización: Registro e inicio de sesión seguro mediante JSON Web Tokens (JWT) y encriptación de contraseñas con Bcrypt.
* Gestión de Roles Granular: Control de acceso según el tipo de usuario (`admin`, `cliente`, `mesero`, `cocina`, `domiciliario`).
* Menú Digital: Endpoints para crear, actualizar, listar y eliminar productos del restaurante.
* Integración en la Nube: Almacenamiento y persistencia de datos en PostgreSQL a través de Supabase y gestión de imágenes mediante Cloudinary.
* Mantenibilidad: Arquitectura modular siguiendo el patrón Modelo-Controlador-Ruta.

---

3. Prerrequisitos
Antes de comenzar, asegúrate de contar con las siguientes herramientas instaladas y configuradas:
* **Node.js** (v18.0.0 o superior)
* **npm** (gestor de paquetes de Node)
* Cuenta activa en **Supabase** (para la base de datos PostgreSQL)
* Cuenta activa en **Cloudinary** (para el alojamiento de imágenes)

---

4. Instalación

1. Clonar el repositorio:
   ```bash
   git clone [https://github.com/tu-usuario/proyectoParche.git](https://github.com/tu-usuario/proyectoParche.git)
   cd proyectoParche

   Paola Andrea Diaz.
