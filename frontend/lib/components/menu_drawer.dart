import 'package:elparchee/pantallas/carrito.dart';
import 'package:elparchee/pantallas/inicio.dart';
import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Cabecera del Drawer (Inspirada en tu imagen de referencia)
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 139, 29, 29), // Tono rojo característico
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  '¡Hola, usuario!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                // Aquí puedes agregar tu avatar o correo
              ],
            ),
          ),

          // 1. Inicio
          ListTile(
            leading: const Icon(Icons.home, color: Color.fromARGB(255, 212, 94, 13)),
            title: const Text('Inicio'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context); // Cierra el drawer
               Navigator.push(context, MaterialPageRoute(builder: (context) => const Inicio()));
            },
          ),

          // 2. Platos destacados
          ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: const Text('Platos destacados'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              //Navigator.push(context, MaterialPageRoute(builder: (context) => const PlatosDes()));
            },
          ),

          // 3. Mi carrito
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.brown),
            title: const Text('Mi carrito'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Carrito()));
            },
          ),

          // 4. Mis pedidos
          ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.brown),
            title: const Text('Mis pedidos'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const PedidosScreen()));
            },
          ),

          // 5. Domicilios
          ListTile(
            leading: const Icon(Icons.delivery_dining, color: Colors.red),
            title: const Text('Domicilios'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const DomiciliosScreen()));
            },
          ),

          // 6. Favoritos
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.redAccent),
            title: const Text('Favoritos'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritosScreen()));
            },
          ),

          // 7. Promociones
          ListTile(
            leading: const Icon(Icons.local_offer, color: Colors.deepOrange),
            title: const Text('Promociones'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const PromocionesScreen()));
            },
          ),

          // 8. Mi perfil
          ListTile(
            leading: const Icon(Icons.person, color: Colors.grey),
            title: const Text('Mi perfil'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const PerfilScreen()));
            },
          ),

          const Divider(), // Línea divisoria

          // 9. Administración
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.blueGrey),
            title: const Text('Administración'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const AdministracionScreen()));
            },
          ),

          // 10. Cerrar sesión
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              // Aquí puedes redirigir al login o limpiar tokens
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
    );
  }
}
    