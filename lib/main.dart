import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inventario_app/screens/main_screen_host.dart';

void main() async {
  // Asegura que Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Hive
  await Hive.initFlutter();

  // Abrimos la caja existente para los productos
  await Hive.openBox<Map>('productos');

  // --- LÍNEA CLAVE QUE SOLUCIONA EL ERROR ---
  // Abrimos la nueva caja para guardar las configuraciones del usuario
  await Hive.openBox('settings');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Inventario',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const MainScreenHost(),
    );
  }
}
