import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:inventario_app/screens/add_edit_screen.dart';
import 'package:inventario_app/views/product_list_view.dart';
import 'package:inventario_app/views/reports_view.dart';
import 'package:inventario_app/views/search_view.dart';

class MainScreenHost extends StatefulWidget {
  const MainScreenHost({super.key});

  @override
  State<MainScreenHost> createState() => _MainScreenHostState();
}

class _MainScreenHostState extends State<MainScreenHost> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    // Calculamos el ancho de la barra una sola vez para reutilizarlo
    final barWidth = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      body: BottomBar(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 65,
              width: barWidth,
              decoration: BoxDecoration(
                color: Colors.blue.shade800,
                borderRadius: BorderRadius.circular(500),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                // Usamos spaceEvenly para una distribución equitativa
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildTabItem(icon: Icons.search, title: "Buscar", index: 0),
                  _buildTabItem(
                    icon: Icons.list_alt,
                    title: "Inventario",
                    index: 1,
                  ),
                ],
              ),
            ),
            // --- POSICIÓN Y FORMA CORREGIDAS ---
            Positioned(
              // Calculamos la posición para que quede perfectamente centrado en la barra
              left:
                  (barWidth / 2) -
                  28, // (Ancho de la barra / 2) - (Ancho del FAB / 2)
              top: -25,
              child: FloatingActionButton(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditScreen(),
                    ),
                  );
                },
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
        body: (context, controller) {
          switch (_currentPage) {
            case 0:
              return SearchView(scrollController: controller);
            case 1:
              return ProductListView(scrollController: controller);
            default:
              return SearchView(scrollController: controller);
          }
        },
        hideOnScroll: true,
        showIcon: true,
        icon: (width, height) => Center(
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: null,
            icon: Icon(
              Icons.arrow_upward_rounded,
              color: Colors.white,
              size: width,
            ),
          ),
        ),
        iconDecoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: BorderRadius.circular(500),
        ),
        borderRadius: BorderRadius.circular(500),
        width: barWidth,
        barAlignment: Alignment.bottomCenter,
        barColor: Colors.transparent,
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = _currentPage == index;
    final color = isSelected ? Colors.white : Colors.grey[300];
    return InkWell(
      onTap: () {
        setState(() {
          _currentPage = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.blue.shade900.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
