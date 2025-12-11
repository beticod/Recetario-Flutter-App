import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class AccelerometerScreen extends StatefulWidget {
  const AccelerometerScreen({super.key});

  @override
  State<AccelerometerScreen> createState() => _AccelerometerScreenState();
}

class _AccelerometerScreenState extends State<AccelerometerScreen> {
  double _x = 0;
  double _y = 0;
  double _z = 0;
  double _magnitud = 0;
  String _orientacion = 'Neutral';
  Color _colorFondo = Colors.white;
  int _contadorSacudidas = 0;
  double _ultimaMagnitud = 0;

  @override
  void initState() {
    super.initState();
    _iniciarListenerAcelerometro();
  }

  void _iniciarListenerAcelerometro() {
    accelerometerEvents.listen((AccelerometerEvent evento) {
      setState(() {
        _x = evento.x;
        _y = evento.y;
        _z = evento.z;

        // Calcular magnitud (intensidad total de aceleración)
        _magnitud = sqrt(_x * _x + _y * _y + _z * _z);

        // Detectar sacudidas (cambio brusco de magnitud)
        if ((_magnitud - _ultimaMagnitud).abs() > 15) {
          _contadorSacudidas++;
        }
        _ultimaMagnitud = _magnitud;

        // Determinar orientación basada en eje dominante
        if (_x.abs() > _y.abs() && _x.abs() > _z.abs()) {
          if (_x > 5) {
            _orientacion = 'Inclinado a la derecha →';
            _colorFondo = Colors.red[100]!;
          } else if (_x < -5) {
            _orientacion = 'Inclinado a la izquierda ←';
            _colorFondo = Colors.blue[100]!;
          }
        } else if (_y.abs() > _x.abs() && _y.abs() > _z.abs()) {
          if (_y > 5) {
            _orientacion = 'Inclinado hacia arriba ↑';
            _colorFondo = Colors.green[100]!;
          } else if (_y < -5) {
            _orientacion = 'Inclinado hacia abajo ↓';
            _colorFondo = Colors.orange[100]!;
          }
        } else if (_z.abs() > _x.abs() && _z.abs() > _y.abs()) {
          _orientacion = 'Plano (paralelo al suelo)';
          _colorFondo = Colors.purple[100]!;
        } else {
          _orientacion = 'Neutral';
          _colorFondo = Colors.grey[100]!;
        }
      });
    });
  }

  void _resetearContador() {
    setState(() {
      _contadorSacudidas = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Acelerómetro'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Visualización de ejes
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _colorFondo,
                  border: Border.all(color: Colors.purple, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.screen_rotation,
                      size: 80,
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _orientacion,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Eje X (lateral): ${_x.toStringAsFixed(2)} m/s²',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: (_x.abs() / 15).clamp(0, 1),
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation(
                              _x > 0 ? Colors.red : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Eje Y (vertical): ${_y.toStringAsFixed(2)} m/s²',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: (_y.abs() / 15).clamp(0, 1),
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation(
                              _y > 0 ? Colors.green : Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Eje Z (profundidad): ${_z.toStringAsFixed(2)} m/s²',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: (_z.abs() / 15).clamp(0, 1),
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        border: Border.all(color: Colors.indigo),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Magnitud total: ${_magnitud.toStringAsFixed(2)} m/s²',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Detector de sacudidas
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  border: Border.all(color: Colors.amber, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_activity,
                      size: 60,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Detector de sacudidas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '$_contadorSacudidas',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'sacudidas detectadas',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _resetearContador,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Resetear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Información educativa
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
                      'Entendiendo los ejes:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '📊 Eje X: Movimiento lateral (izquierda-derecha)',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '📊 Eje Y: Movimiento vertical (arriba-abajo)',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '📊 Eje Z: Movimiento de profundidad (hacia ti-lejos)',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '⚡ Se mide en m/s² (metros por segundo al cuadrado)',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
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
