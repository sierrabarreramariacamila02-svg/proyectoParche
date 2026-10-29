import 'package:flutter/material.dart';
import 'package:elparchee/app_colors.dart';
import 'package:elparchee/components/productos.dart';
import 'package:elparchee/pantallas/buscar.dart';
import 'package:elparchee/pantallas/pedidos.dart';
import 'package:elparchee/pantallas/perfil.dart';
import 'package:elparchee/pantallas/domicilio.dart';
import 'package:elparchee/pantallas/notificaciones.dart';
import 'package:elparchee/pantallas/detalle_producto.dart';

class Carrito extends StatefulWidget {
  const Carrito({super.key});

  static List<Map<String, dynamic>> itemsMemoria = [];

  static void agregarItem(Map<String, dynamic> nuevoItem) {
    int index = itemsMemoria.indexWhere((item) =>
        item["nombre"] == nuevoItem["nombre"] &&
        item["acompanamiento"] == nuevoItem["acompanamiento"] &&
        item["bebida"] == nuevoItem["bebida"] &&
        item["sinCebolla"] == nuevoItem["sinCebolla"] &&
        item["sinLechuga"] == nuevoItem["sinLechuga"]);

    if (index >= 0) {
      itemsMemoria[index]["cant"] += nuevoItem["cant"];
    } else {
      itemsMemoria.add(nuevoItem);
    }
  }

  @override
  State<Carrito> createState() => _CarritoState();
}

class _CarritoState extends State<Carrito> {
  static const Color rojo = AppColors.barraHome;
  static const Color naranja = AppColors.buttonOrange;
  static const Color crema = AppColors.background;

  String _tipoPedido = 'recoger';

  bool _pedidoConfirmado = false; // Controla si se muestra el cuadro verde en recoger
  bool _tieneReserva = false;
  int _personasReserva = 2;
  TimeOfDay _horaReserva = const TimeOfDay(hour: 17, minute: 0);

  int get subtotal =>
      Carrito.itemsMemoria.fold(0, (s, i) => s + (i["precio"] as int) * (i["cant"] as int));
  
  int get costoDomicilio => _tipoPedido == 'domicilio' ? 8000 : 0;
  int get total => subtotal + costoDomicilio;

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');

  void _mostrarModalReserva(BuildContext context) {
    int personasTemp = _personasReserva;
    TimeOfDay horaTemp = _horaReserva;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.table_restaurant, color: naranja),
                  SizedBox(width: 10),
                  Text("Reservar Mesa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Dirección: Calle 3 #4-12, Tres Esquinas, Gigante, Huila", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 15),
                  const Text("Número de personas:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: rojo),
                        onPressed: () {
                          if (personasTemp > 1) {
                            setModalState(() => personasTemp--);
                          }
                        },
                      ),
                      Text("$personasTemp personas", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: rojo),
                        onPressed: () => setModalState(() => personasTemp++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Hora de llegada:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(horaTemp.format(context)),
                    trailing: const Icon(Icons.access_time, color: naranja),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: horaTemp,
                      );
                      if (time != null) {
                        setModalState(() => horaTemp = time);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: naranja,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    setState(() {
                      _tieneReserva = true;
                      _personasReserva = personasTemp;
                      _horaReserva = horaTemp;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("¡Reserva guardada con éxito!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text("Confirmar Reserva", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 50, 20, 15),
            decoration: const BoxDecoration(
              color: rojo,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "Carrito",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Notificaciones()),
                    );
                  },
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Carrito.itemsMemoria.isEmpty
                ? const Center(
                    child: Text(
                      "Tu carrito está vacío",
                      style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(15),
                    children: [
                      for (int i = 0; i < Carrito.itemsMemoria.length; i++) _tarjeta(i),
                      const SizedBox(height: 10),
                      
                      const Text("Tipo de pedido", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 10),
                      
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _tipoPedido = 'recoger';
                                _pedidoConfirmado = false;
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                                decoration: BoxDecoration(
                                  color: _tipoPedido == 'recoger' ? naranja.withValues(alpha: 0.15) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _tipoPedido == 'recoger' ? naranja : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.store, color: Colors.brown, size: 26),
                                        SizedBox(height: 6),
                                        Text("Recoger", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        SizedBox(height: 2),
                                        Text("En tienda", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                    if (_tipoPedido == 'recoger')
                                      const Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Icon(Icons.check_circle, color: naranja, size: 16),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _tipoPedido = 'reserva';
                                _pedidoConfirmado = false;
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                                decoration: BoxDecoration(
                                  color: _tipoPedido == 'reserva' ? naranja.withValues(alpha: 0.15) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _tipoPedido == 'reserva' ? naranja : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.table_restaurant, color: Colors.brown, size: 26),
                                        SizedBox(height: 6),
                                        Text("Reservar", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        SizedBox(height: 2),
                                        Text("Mesa", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                    if (_tipoPedido == 'reserva')
                                      const Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Icon(Icons.check_circle, color: naranja, size: 16),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _tipoPedido = 'domicilio';
                                _pedidoConfirmado = false;
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                                decoration: BoxDecoration(
                                  color: _tipoPedido == 'domicilio' ? naranja.withValues(alpha: 0.15) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _tipoPedido == 'domicilio' ? naranja : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.delivery_dining, color: Colors.brown, size: 26),
                                        SizedBox(height: 6),
                                        Text("Domicilio", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        SizedBox(height: 2),
                                        Text("A casa", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                    if (_tipoPedido == 'domicilio')
                                      const Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Icon(Icons.check_circle, color: naranja, size: 16),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_tipoPedido != 'domicilio') ...[
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.location_on, color: rojo, size: 20),
                                  SizedBox(width: 6),
                                  Text("Lugar:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "El Parche - Calle 3 #4-12, Tres Esquinas, Gigante, Huila",
                                style: TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Horario: 5:00 PM - 11:00 PM | Tiempo prep: 15 - 20 min",
                                style: TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                              
                              // Si es Recoger y ya se confirmó, muestra el cuadro verde. Si no, muestra el botón para confirmar.
                              if (_tipoPedido == 'recoger') ...[
                                if (_pedidoConfirmado) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEBF7ED),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          "Pedido confirmado",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF2E7D32),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  const Divider(height: 18),
                                  Center(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _pedidoConfirmado = true;
                                        });
                                      },
                                      icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
                                      label: const Text(
                                        "Confirmar pedido",
                                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: naranja,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ] else ...[
                                // Modo Reserva
                                if (_tieneReserva) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEBF7ED),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Mesa reservada: $_personasReserva pers. a las ${_horaReserva.format(context)}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF2E7D32),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const Divider(height: 18),
                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _mostrarModalReserva(context),
                                    icon: const Icon(Icons.table_restaurant, size: 16, color: Colors.white),
                                    label: Text(
                                      _tieneReserva ? "Modificar Reserva" : "Reservar Mesa",
                                      style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: naranja,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -3))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Subtotal", style: TextStyle(color: Colors.grey)),
                    Text("\$${_fmt(subtotal)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Domicilio", style: TextStyle(color: Colors.grey)),
                    Text(
                      _tipoPedido == 'domicilio' ? "\$${_fmt(costoDomicilio)}" : "\$0",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _tipoPedido == 'domicilio' ? Colors.black : Colors.green,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("\$${_fmt(total)} COP",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: rojo)),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: Carrito.itemsMemoria.isEmpty
                      ? null
                      : () {
                          if (_tipoPedido == 'domicilio') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DomicilioPantalla()),
                            );
                          } else if (_tipoPedido == 'reserva') {
                            if (!_tieneReserva) {
                              _mostrarModalReserva(context);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Pedidos(
                                    esReserva: true,
                                    personasReserva: _personasReserva,
                                    horaReserva: _horaReserva.format(context),
                                  ),
                                ),
                              );
                            }
                          } else {
                            // Botón inferior para recoger
                            setState(() {
                              _pedidoConfirmado = true;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Pedidos(esReserva: false),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: naranja,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text(
                    "Confirmar pedido",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      bottomNavigationBar: Container(
        color: AppColors.barraInferior,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SizedBox(
              height: 40,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.home_outlined, color: Colors.brown),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const Productos()),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.brown),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const Buscar()),
                          );
                        },
                      ),
                      const SizedBox(width: 50),
                      IconButton(
                        icon: const Icon(Icons.receipt_long_outlined, color: Colors.brown),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const Pedidos()),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_outline, color: Colors.brown),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const Perfil()),
                          );
                        },
                      ),
                    ],
                  ),
                  Positioned(
                    top: -24,
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.buttonOrange,
                      child: IconButton(
                        icon: const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tarjeta(int i) {
    final item = Carrito.itemsMemoria[i];
    final int cant = item["cant"];
    final int precio = item["precio"];

    return Dismissible(
      key: Key('${item["nombre"]}_$i'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 20),
            SizedBox(width: 5),
            Text("Eliminar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          Carrito.itemsMemoria.removeAt(i);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Producto eliminado del carrito"),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 242, 234, 216),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(item["icono"] ?? Icons.fastfood, color: Colors.deepOrange, size: 36),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item["nombre"], style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("${_fmt(precio)} COP x$cant",
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  if (item["acompanamiento"] != null)
                    Text("+ ${item["acompanamiento"]}",
                        style: const TextStyle(fontSize: 10, color: Colors.brown)),
                  if (item["bebida"] != null)
                    Text("+ ${item["bebida"]}",
                        style: const TextStyle(fontSize: 10, color: Colors.brown)),
                  Text("\$${_fmt(precio * cant)}",
                      style: const TextStyle(color: rojo, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    final resultado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          title: "Detalle del producto",
                          imageUrl: item["imageUrl"] ?? "assets/images/ha.jpg",
                          price: "\$${_fmt(item["rawPrice"]?.toInt() ?? precio)} COP",
                          name: item["nombre"],
                          description: item["description"] ?? "Deliciosa preparación.",
                          rawPrice: (item["rawPrice"] ?? precio).toDouble(),
                          initialAcompanamiento: item["acompanamiento"],
                          initialBebida: item["bebida"],
                          initialSinCebolla: item["sinCebolla"] ?? false,
                          initialSinLechuga: item["sinLechuga"] ?? false,
                          initialCantidad: cant,
                          onAgregarAlCarrito: (nuevoItem) {
                            setState(() {
                              Carrito.itemsMemoria[i] = nuevoItem;
                            });
                          },
                        ),
                      ),
                    );

                    if (resultado != null) {
                      setState(() {
                        Carrito.itemsMemoria[i] = resultado;
                      });
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text("Ver",
                          style: TextStyle(fontSize: 12, color: Colors.brown, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 10, color: Colors.brown),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}