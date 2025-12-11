import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MicrophoneScreen extends StatefulWidget {
  const MicrophoneScreen({super.key});

  @override
  State<MicrophoneScreen> createState() => _MicrophoneScreenState();
}

class _MicrophoneScreenState extends State<MicrophoneScreen> {
  final AudioRecorder _record = AudioRecorder(); // CORREGIDO
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _grabando = false;
  String _rutaArchivo = '';
  String _mensaje = 'Presiona grabar para empezar';
  String _duracion = '00:00';
  bool _reproduciendo = false;
  Duration _duracionGrabacion = Duration.zero;

  Future<void> _iniciarGrabacion() async {
    try {
      bool permiso = await _record.hasPermission();

      if (!permiso) {
        setState(() {
          _mensaje = 'Permiso de micrófono denegado';
        });
        return;
      }

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String rutaArchivos =
          '${appDir.path}/grabaciones_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // NUEVA API
      await _record.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: rutaArchivos,
      );

      setState(() {
        _grabando = true;
        _rutaArchivo = rutaArchivos;
        _mensaje = 'Grabando...';
        _duracionGrabacion = Duration.zero;
      });

      _iniciarTemporizador();
    } catch (e) {
      setState(() {
        _mensaje = 'Error al iniciar grabación: $e';
      });
    }
  }

  void _iniciarTemporizador() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_grabando) {
        setState(() {
          _duracionGrabacion += const Duration(milliseconds: 100);
          _duracion =
              '${_duracionGrabacion.inMinutes.toString().padLeft(2, '0')}:${(_duracionGrabacion.inSeconds % 60).toString().padLeft(2, '0')}';
        });
        _iniciarTemporizador();
      }
    });
  }

  Future<void> _detenerGrabacion() async {
    try {
      await _record.stop(); // Sigue siendo válido

      setState(() {
        _grabando = false;
        _mensaje = 'Grabación completada';
      });
    } catch (e) {
      setState(() {
        _mensaje = 'Error al detener: $e';
      });
    }
  }

  Future<void> _reproducir() async {
    try {
      if (_rutaArchivo.isEmpty) {
        setState(() {
          _mensaje = 'No hay grabación para reproducir';
        });
        return;
      }

      setState(() {
        _reproduciendo = true;
        _mensaje = 'Reproduciendo...';
      });

      await _audioPlayer.play(DeviceFileSource(_rutaArchivo));

      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          _reproduciendo = false;
          _mensaje = 'Reproducción finalizada';
        });
      });
    } catch (e) {
      setState(() {
        _mensaje = 'Error al reproducir: $e';
        _reproduciendo = false;
      });
    }
  }

  Future<void> _pausarReproduccion() async {
    try {
      await _audioPlayer.pause();

      setState(() {
        _reproduciendo = false;
        _mensaje = 'Reproducción pausada';
      });
    } catch (e) {
      setState(() {
        _mensaje = 'Error al pausar: $e';
      });
    }
  }

  Future<void> _borrarGrabacion() async {
    try {
      if (_rutaArchivo.isEmpty) return;

      final File archivo = File(_rutaArchivo);
      if (await archivo.exists()) {
        await archivo.delete();
      }

      setState(() {
        _rutaArchivo = '';
        _mensaje = 'Grabación borrada';
        _duracion = '00:00';
        _reproduciendo = false;
      });

      await _audioPlayer.stop();
    } catch (e) {
      setState(() {
        _mensaje = 'Error al borrar: $e';
      });
    }
  }

  @override
  void dispose() {
    _record.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grabadora de Audio'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: _grabando ? Colors.red[50] : Colors.pink[50],
                  border: Border.all(
                    color: _grabando ? Colors.red : Colors.pink,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      _grabando ? Icons.mic : Icons.mic_none,
                      size: 80,
                      color: _grabando ? Colors.red : Colors.pink,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _duracion,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _grabando ? Colors.red : Colors.pink,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _mensaje,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _grabando ? null : _iniciarGrabacion,
                    icon: const Icon(Icons.radio_button_on),
                    label: const Text('Grabar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      disabledBackgroundColor: Colors.grey,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _grabando ? _detenerGrabacion : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Detener'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      disabledBackgroundColor: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_rutaArchivo.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _reproduciendo
                          ? _pausarReproduccion
                          : _reproducir,
                      icon: Icon(
                        _reproduciendo ? Icons.pause : Icons.play_arrow,
                      ),
                      label: Text(_reproduciendo ? 'Pausar' : 'Reproducir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _borrarGrabacion,
                      icon: const Icon(Icons.delete),
                      label: const Text('Borrar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 30),

              if (_rutaArchivo.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border.all(color: Colors.blue[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información de la grabación:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '📁 Archivo: ${_rutaArchivo.split('/').last}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '⏱️ Duración: $_duracion',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'No hay grabación aún. Presiona grabar para empezar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  border: Border.all(color: Colors.amber[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Cómo funciona:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '🎙️ Grabar: Inicia la captura de audio del micrófono',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '⏹️ Detener: Finaliza la grabación y guarda el archivo',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '▶️ Reproducir: Toca el audio grabado para escucharlo',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '🗑️ Borrar: Elimina la grabación actual',
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
