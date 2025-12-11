import 'package:flutter/material.dart';

class ReceiptsHome extends StatelessWidget {
  const ReceiptsHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recetas Flutter')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: const Text(
                'Menú de Recetas',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),

            // INICIO
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/');
              },
            ),

            // VIBRACIÓN
            ListTile(
              leading: const Icon(Icons.vibration),
              title: const Text('Vibración'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/vibration');
              },
            ),

            // CÁMARA
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/camera');
              },
            ),

            // GALERÍA
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/gallery');
              },
            ),

            // GPS
            ListTile(
              leading: const Icon(Icons.gps_fixed),
              title: const Text('GPS'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/gps');
              },
            ),

            // ACELERÓMETRO
            ListTile(
              leading: const Icon(Icons.sensors),
              title: const Text('Acelerómetro'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/accelerometer');
              },
            ),

            // MICRÓFONO
            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text('Micrófono'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/microphone');
              },
            ),

            // INFO DISPOSITIVO
            ListTile(
              leading: const Icon(Icons.devices),
              title: const Text('Info del Dispositivo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/device_info');
              },
            ),
          ],
        ),
      ),

      body: Center(
        child: Text(
          'Bienvenido a Recetas Flutter',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
