import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _videoSeleccionado;
  VideoPlayerController? _videoController;
  String _mensaje = 'Presiona capturar para grabar un vídeo';
  bool _reproduciendo = false;
  Duration _duracionTotal = Duration.zero;
  Duration _posicionActual = Duration.zero;

  Future<void> _capturarVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        setState(() {
          _videoSeleccionado = video;
          _mensaje = 'Vídeo capturado: ${video.name}';
        });

        await _inicializarVideoController(video.path);
      } else {
        setState(() {
          _mensaje = 'Cancelaste la grabación';
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error: $e';
      });
    }
  }

  Future<void> _seleccionarDelGaleria() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

      if (video != null) {
        setState(() {
          _videoSeleccionado = video;
          _mensaje = 'Vídeo de galería: ${video.name}';
        });

        await _inicializarVideoController(video.path);
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error: $e';
      });
    }
  }

  Future<void> _inicializarVideoController(String rutaVideo) async {
    try {
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(rutaVideo));

      await _videoController!.initialize();

      setState(() {
        _duracionTotal = _videoController!.value.duration;
        _posicionActual = Duration.zero;
      });

      _videoController!.addListener(_actualizarPosicion);
    } catch (e) {
      setState(() {
        _mensaje = 'Error al cargar vídeo: $e';
      });
    }
  }

  void _actualizarPosicion() {
    if (_videoController != null && _videoController!.value.isPlaying) {
      setState(() {
        _posicionActual = _videoController!.value.position;
      });
    }
  }

  Future<void> _reproducir() async {
    try {
      await _videoController!.play();
      setState(() {
        _reproduciendo = true;
        _mensaje = 'Reproduciendo...';
      });
    } catch (e) {
      setState(() {
        _mensaje = 'Error al reproducir: $e';
      });
    }
  }

  Future<void> _pausar() async {
    try {
      await _videoController!.pause();
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

  String _formatearDuracion(Duration duracion) {
    String dosDig(int n) => n.toString().padLeft(2, '0');
    final hours = dosDig(duracion.inHours);
    final minutes = dosDig(duracion.inMinutes.remainder(60));
    final seconds = dosDig(duracion.inSeconds.remainder(60));
    return '${hours == '00' ? '' : '$hours:'}$minutes:$seconds';
  }

  void _limpiar() {
    _videoController?.dispose();
    _videoController = null;
    setState(() {
      _videoSeleccionado = null;
      _mensaje = 'Vídeo eliminado';
      _reproduciendo = false;
      _duracionTotal = Duration.zero;
      _posicionActual = Duration.zero;
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reproductor de vídeo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Visualizador de vídeo
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.deepOrange, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    _videoController != null &&
                        _videoController!.value.isInitialized
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            ),
                            if (!_reproduciendo)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(12),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.videocam, size: 80, color: Colors.grey),
                          SizedBox(height: 15),
                          Text(
                            'No hay vídeo cargado',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 20),

              // Barra de progreso
              if (_videoController != null &&
                  _videoController!.value.isInitialized)
                Column(
                  children: [
                    VideoProgressIndicator(
                      _videoController!,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: Colors.deepOrange,
                        bufferedColor: Colors.grey[300]!,
                        backgroundColor: Colors.grey[600]!,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatearDuracion(_posicionActual),
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          _formatearDuracion(_duracionTotal),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // Botones de captura
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _capturarVideo,
                    icon: const Icon(Icons.videocam),
                    label: const Text('Grabar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _seleccionarDelGaleria,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Botones de reproducción
              if (_videoSeleccionado != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _reproduciendo ? _pausar : _reproducir,
                      icon: Icon(
                        _reproduciendo ? Icons.pause : Icons.play_arrow,
                      ),
                      label: Text(_reproduciendo ? 'Pausar' : 'Reproducir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _limpiar,
                      icon: const Icon(Icons.delete),
                      label: const Text('Borrar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 30),

              // Información del vídeo
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_mensaje, style: const TextStyle(fontSize: 13)),
                    if (_videoSeleccionado != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        '📁 ${_videoSeleccionado!.name}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '⏱️ Duración: ${_formatearDuracion(_duracionTotal)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
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
                      'Cómo usar:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '🎬 Grabar: Captura vídeo con tu cámara (máx 5 min)',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '📸 Galería: Selecciona vídeos existentes',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '▶️ Reproducir: Toca el vídeo o presiona botón',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '⏸️ Pausar: Detén la reproducción en cualquier momento',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '🗑️ Borrar: Elimina el vídeo cargado',
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
