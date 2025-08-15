import 'package:hive/hive.dart';
import 'package:inventario_app/services/data_change_notifier.dart';
import 'package:uuid/uuid.dart';

class HiveService {
  final Box<Map> _productosBox = Hive.box<Map>('productos');
  final _uuid = const Uuid();

  List<Map<String, dynamic>> getProductos() {
    final data = _productosBox.values.toList();
    data.sort((a, b) {
      final dateA =
          DateTime.tryParse(a['fechaRegistro'] ?? '') ?? DateTime(1970);
      final dateB =
          DateTime.tryParse(b['fechaRegistro'] ?? '') ?? DateTime(1970);
      return dateB.compareTo(dateA);
    });
    return data.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> addProducto(Map<String, dynamic> producto) async {
    final String id = _uuid.v4();
    final nuevoProducto = Map<String, dynamic>.from(producto);
    nuevoProducto['id'] = id;

    // --- MODIFICACIÓN CLAVE ---
    // Guardamos la fecha de creación automáticamente.
    // Esta fecha no se modificará al editar.
    nuevoProducto['createdAt'] = DateTime.now().toIso8601String();

    await _productosBox.put(id, nuevoProducto);
    dataChangeNotifier.notify();
  }

  Future<void> updateProducto(String id, Map<String, dynamic> producto) async {
    final productoActualizado = Map<String, dynamic>.from(producto);
    productoActualizado['id'] = id;

    // Al actualizar, mantenemos la fecha de creación original si ya existe.
    final productoOriginal = _productosBox.get(id);
    if (productoOriginal != null && productoOriginal.containsKey('createdAt')) {
      productoActualizado['createdAt'] = productoOriginal['createdAt'];
    }

    await _productosBox.put(id, productoActualizado);
    dataChangeNotifier.notify();
  }

  Future<void> deleteProducto(String id) async {
    await _productosBox.delete(id);
    dataChangeNotifier.notify();
  }

  // --- NUEVO MÉTODO ---
  // Añadimos la lógica de filtrado que usaremos para los reportes.
  Future<List<Map<String, dynamic>>> getFilteredProducts({
    DateTime? startDate,
    String? category,
  }) async {
    // Usamos 'async' para que la firma coincida con el plan, aunque la operación es síncrona.
    final allProducts = getProductos();
    List<Map<String, dynamic>> filteredList = allProducts;

    // Filtrar por categoría si se proporciona
    if (category != null && category.isNotEmpty) {
      filteredList = filteredList
          .where(
            (p) =>
                p['Categoría'] != null &&
                p['Categoría'].toLowerCase() == category.toLowerCase(),
          )
          .toList();
    }

    // Filtrar por fecha de creación si se proporciona
    if (startDate != null) {
      filteredList = filteredList.where((p) {
        // Usamos 'createdAt' para el filtro, ya que es la fecha de creación real.
        if (p['createdAt'] == null) return false;
        final createdAt = DateTime.parse(p['createdAt']);
        return createdAt.isAfter(startDate);
      }).toList();
    }

    return filteredList;
  }
}
