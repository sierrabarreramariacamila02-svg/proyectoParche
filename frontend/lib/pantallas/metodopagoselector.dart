import 'package:flutter/material.dart';

import '../app_colors.dart';

class MetodoPagoSelector extends StatelessWidget {
  const MetodoPagoSelector({
    super.key,
    required this.seleccionado,
    required this.onChanged,
  });

  final String seleccionado;
  final ValueChanged<String> onChanged;

  static const metodos = <String, IconData>{
    'Efectivo': Icons.payments_outlined,
    'Nequi': Icons.phone_android,
    'Bancolombia': Icons.account_balance,
    'Daviplata': Icons.account_balance_wallet_outlined,
  };

  // Cambia estos números por los reales del negocio
  static const numerosPago = <String, String>{
    'Nequi': '3XX XXX XXXX',
    'Bancolombia': 'Cuenta/Llave: XXXXXXXX',
    'Daviplata': '3XX XXX XXXX',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medio de pago',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: metodos.entries.map((e) {
            return ChoiceChip(
              avatar: Icon(e.value, size: 18),
              label: Text(e.key),
              selected: seleccionado == e.key,
              selectedColor: AppColors.barraHome.withOpacity(0.2),
              onSelected: (_) => onChanged(e.key),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),
        if (seleccionado == 'Efectivo')
          const Text('Pagas en efectivo al recibir tu pedido.')
        else
          Text(
            'Transfiere a ${numerosPago[seleccionado]} y muestra el '
            'comprobante al repartidor.',
          ),
      ],
    );
  }
}
