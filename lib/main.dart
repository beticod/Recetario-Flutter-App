import 'package:flutter/material.dart';

// IMPORTA TODAS TUS PANTALLAS
import 'screens/home_screen.dart';
import 'screens/vibration_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/gps_screen.dart';
import 'screens/accelerometer_screen.dart';
import 'screens/microphone_screen.dart';
import 'screens/video_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recetas Flutter',
      initialRoute: '/',
      routes: {
        '/': (context) => const ReceiptsHome(),
        '/vibration': (context) => const VibrationScreen(),
        '/camera': (context) => const CameraScreen(),
        '/gallery': (context) => const GalleryScreen(),
        '/gps': (context) => const GPSScreen(),
        '/accelerometer': (context) => const AccelerometerScreen(),
        '/microphone': (context) => const MicrophoneScreen(),
        '/video': (context) => const VideoScreen(),
      },
    );
  }
}
