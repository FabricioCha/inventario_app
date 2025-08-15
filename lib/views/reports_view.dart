import 'package:flutter/material.dart';
import 'package:inventario_app/services/hive_service.dart';
import 'package:inventario_app/services/pdf_service.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  final HiveService _hiveService = HiveService();
  final PdfService _pdfService = PdfService();
  final _categoryController = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() => _isLoading = true);

    try {
      final filteredProducts = await _hiveService.getFilteredProducts(
        category: _categoryController.text,
        startDate: _selectedDate,
      );

      if (filteredProducts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se encontraron productos con esos filtros.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Antes de generar el PDF, asegúrate de que la fuente esté disponible.
      // Crea una carpeta 'assets/fonts' en la raíz de tu proyecto
      // y añade un archivo de fuente como 'OpenSans-Regular.ttf'.
      // Luego, declara la carpeta en tu pubspec.yaml:
      // flutter:
      //   assets:
      //     - assets/fonts/
      await _pdfService.generatePdfReport(filteredProducts);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar el reporte: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generar Reportes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filtros para el Reporte',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // Filtro por Categoría
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Filtrar por Categoría (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 16),

            // Filtro por Fecha
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              leading: const Icon(Icons.date_range),
              title: Text(
                _selectedDate == null
                    ? 'Filtrar desde una fecha (opcional)'
                    : 'Desde: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
              trailing: _selectedDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _selectedDate = null),
                    )
                  : null,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 32),

            // Botón para generar el PDF
            ElevatedButton.icon(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf),
              label: const Text('Generar Reporte en PDF'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: _isLoading ? null : _generateReport,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }
}
