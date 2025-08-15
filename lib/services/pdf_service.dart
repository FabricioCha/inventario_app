import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  Future<void> generatePdfReport(List<Map<String, dynamic>> products) async {
    final pdf = pw.Document();

    // Cargar una fuente que soporte caracteres especiales (como acentos y €)
    final fontData = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    // Definir los encabezados de la tabla
    final headers = ['Categoría', 'Modelo', 'Descripción', 'Fecha Registro'];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(ttf),
            pw.SizedBox(height: 20),
            _buildTable(products, headers, ttf),
            pw.SizedBox(height: 20),
            _buildSummary(products.length, ttf),
          ];
        },
        footer: (pw.Context context) {
          return _buildFooter(context, ttf);
        },
      ),
    );

    // Guardar y abrir el archivo
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/reporte_inventario.pdf");
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }

  pw.Widget _buildHeader(pw.Font ttf) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Reporte de Inventario',
          style: pw.TextStyle(
            font: ttf,
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          'Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
          style: pw.TextStyle(font: ttf, fontSize: 12),
        ),
      ],
    );
  }

  pw.Widget _buildTable(
    List<Map<String, dynamic>> products,
    List<String> headers,
    pw.Font ttf,
  ) {
    return pw.Table.fromTextArray(
      headers: headers,
      data: products.map((product) {
        return headers.map((header) {
          if (header == 'Fecha Registro') {
            final date = DateTime.tryParse(product['fechaRegistro'] ?? '');
            return date != null
                ? '${date.day}/${date.month}/${date.year}'
                : 'N/A';
          }
          return product[header]?.toString() ?? 'N/A';
        }).toList();
      }).toList(),
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(
        font: ttf,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
      cellStyle: pw.TextStyle(font: ttf),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.center,
      },
    );
  }

  pw.Widget _buildSummary(int productCount, pw.Font ttf) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'Total de productos en el reporte: $productCount',
        style: pw.TextStyle(font: ttf, fontStyle: pw.FontStyle.italic),
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context, pw.Font ttf) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
      child: pw.Text(
        'Página ${context.pageNumber} de ${context.pagesCount}',
        style: pw.TextStyle(font: ttf, color: PdfColors.grey),
      ),
    );
  }
}
