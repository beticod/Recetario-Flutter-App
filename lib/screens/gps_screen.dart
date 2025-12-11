import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GPSScreen extends StatefulWidget {
  const GPSScreen({super.key});

  @override
  State<GPSScreen> createState() => _GPSScreenState();
}

class _GPSScreenState extends State<GPSScreen> {
  Position? _posicionActual;
  String _mensaje = 'Presiona el botón para obtener tu ubicación';
  String _precision = '';
  bool _obteniendo = false;

  Future<void> _obtenerUbicacionActual() async {
    try {
      setState(() {
        _obteniendo = true;
        _mensaje = 'Obteniendo ubicación...';
      });

      bool permisoUbicacion = await _verificarPermisos();

      if (!permisoUbicacion) {
        setState(() {
          _mensaje = 'Permiso de ubicación denegado';
          _obteniendo = false;
        });
        return;
      }

      final Position posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _posicionActual = posicion;
        _mensaje = 'Ubicación obtenida correctamente';
        _precision =
            'Precisión: ±${posicion.accuracy.toStringAsFixed(2)} metros';
        _obteniendo = false;
      });
    } catch (e) {
      setState(() {
        _mensaje = 'Error: $e';
        _obteniendo = false;
      });
    }
  }

  Future<bool> _verificarPermisos() async {
    LocationPermission permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    return permiso == LocationPermission.whileInUse ||
        permiso == LocationPermission.always;
  }

  Future<void> _iniciarSeguimientoEnTiempoReal() async {
    try {
      bool permisoUbicacion = await _verificarPermisos();

      if (!permisoUbicacion) {
        setState(() {
          _mensaje = 'Permiso de ubicación denegado';
        });
        return;
      }

      final Geolocator geolocator = Geolocator();

      setState(() {
        _mensaje = 'Siguiendo tu ubicación en tiempo real...';
      });

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      StreamSubscription<Position> positionStream =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen((Position posicion) {
            setState(() {
              _posicionActual = posicion;
              _precision =
                  'Precisión: ±${posicion.accuracy.toStringAsFixed(2)} metros';
            });
          });

      await Future.delayed(const Duration(seconds: 60));
      await positionStream.cancel();
      setState(() {
        _mensaje = 'Seguimiento finalizado (60 segundos)';
      });
    } catch (e) {
      setState(() {
        _mensaje = 'Error en seguimiento: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tu ubicación GPS'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepOrange[50],
                  border: Border.all(color: Colors.deepOrange, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 80,
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(height: 20),
                    if (_posicionActual != null) ...[
                      Text(
                        'Latitud: ${_posicionActual!.latitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Longitud: ${_posicionActual!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Altitud: ${_posicionActual!.altitude.toStringAsFixed(2)} m',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Velocidad: ${(_posicionActual!.speed * 3.6).toStringAsFixed(1)} km/h',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _precision,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ] else
                      const Text(
                        'Aún no hay ubicación',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _obteniendo ? null : _obtenerUbicacionActual,
                icon: const Icon(Icons.my_location),
                label: _obteniendo
                    ? const Text('Obteniendo ubicación...')
                    : const Text('Obtener ubicación'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.deepOrange,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: _iniciarSeguimientoEnTiempoReal,
                icon: const Icon(Icons.gps_fixed),
                label: const Text('Seguimiento en tiempo real (60s)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _mensaje,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Datos que obtenemos:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '📍 Latitud y Longitud: Coordenadas exactas',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '📏 Altitud: Tu altura respecto al nivel del mar',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '⚡ Velocidad: Tu velocidad de movimiento actual',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '🎯 Precisión: El margen de error de la medición',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '⏰ Timestamp: Hora exacta de la medición',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
