import 'package:flutter/material.dart';
import 'package:elparchee/app_colors.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ManualUsuario extends StatelessWidget {
  const ManualUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        backgroundColor: AppColors.barraHome,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Ayuda - Manual de usuario',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SfPdfViewer.asset('assets/pdf/manual.pdf'),
    );
  }
}
