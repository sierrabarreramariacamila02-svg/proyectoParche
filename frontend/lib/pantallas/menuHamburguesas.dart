import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:elparchee/app_colors.dart';

class MenuHamburguesas extends StatefulWidget {
  const MenuHamburguesas({super.key});

  @override
  State<MenuHamburguesas> createState() => _MenuHamburguesasState();
}

class _MenuHamburguesasState extends State<MenuHamburguesas> {
  final List<Map<String, dynamic>> items = [
    {
      'title': 'Clásica con Queso',
      'desc': 'Carne angus, cheddar, lechuga',
      'price': '\$14,000',
      'qty': 1,
    },
    {
      'title': 'Hamburguesa Doble Tocino',
      'desc': 'Carne angus, cheddar, lechuga',
      'price': '\$17,000',
      'qty': 1,
    },
    {
      'title': 'Hamburguesa de Pollo Crispy',
      'desc': 'Carne de pollo, queso, lechuga',
      'price': '\$12,000',
      'qty': 1,
    },
  ];

 
  String _query = '';

  @override
  Widget build(BuildContext context) {
  
    final filtered = items
        .where((e) => (e['title'] as String)
            .toLowerCase()
            .contains(_query.trim().toLowerCase()))
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
    
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
      
        body: Column(
          children: [
           
            _MenuHeader(
              title: 'Hamburguesas',
              onBack: () => Navigator.pop(context),
              onSearchChanged: (text) => setState(() => _query = text),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No encontramos esa hamburguesa'))
                  : ListView.builder(
                    
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        
                        final item = filtered[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.barraInferior,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.fastfood,
                                  size: 50, color: Colors.orange),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      item['desc'],
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item['price'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF7A1C1C),
                                            fontSize: 15,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove,
                                                  size: 18),
                                              onPressed: () => setState(() {
                                                if (item['qty'] > 1) {
                                                  item['qty']--;
                                                }
                                              }),
                                            ),
                                            Text(
                                              '${item['qty']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add,
                                                  size: 18),
                                              onPressed: () => setState(
                                                  () => item['qty']++),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF7A1C1C),
                                                shadowColor: Colors.black12,
                                                elevation: 4,
                                              ),
                                              child: const Text(
                                                'Añadir',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: AppColors.buttonOrange,
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          label: const Text(
            'Ver mi Pedido',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}


class _MenuHeader extends StatelessWidget {
  const _MenuHeader({
    required this.title,
    required this.onBack,
    required this.onSearchChanged,
  });

  final String title;
  final VoidCallback onBack;
  final ValueChanged<String> onSearchChanged;

  static const double _searchHeight = 46;
  static const double _overlap = _searchHeight / 2;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Padding(
     
      padding: const EdgeInsets.only(bottom: _overlap),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, _overlap + 20),
            decoration: const BoxDecoration(
              color: AppColors.barraHome,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CircleButton(
                      icon: Icons.arrow_back_rounded,
                      background: const Color.fromRGBO(248, 242, 228, 0.16),
                      foreground: AppColors.background,
                      tooltip: 'Volver',
                      onTap: onBack,
                    ),
                    const _CircleButton(
                      icon: Icons.lunch_dining,
                      background: AppColors.background,
                      foreground: AppColors.barraHome,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 30,
                    height: 1.1,
                    color: AppColors.background,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: -_overlap,
            child: Container(
              height: _searchHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.inputBackground, width: 1),
              ),
              child: TextField(
                onChanged: onSearchChanged,
                cursorColor: AppColors.barraHome,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Buscar hamburguesa',
                  hintStyle: TextStyle(color: Colors.black45, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.black45),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.background,
    required this.foreground,
    this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: foreground, size: 22),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}