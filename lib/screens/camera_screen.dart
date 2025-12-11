import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  XFile? _imagen;
  final ImagePicker _picker = ImagePicker();
  String _mensaje = 'Aún no has capturado ninguna foto';

  Future<void> capturarFoto() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (foto != null) {
        setState(() {
          _imagen = foto;
          _mensaje = 'Foto capturada: ${foto.name}';
        });
      } else {
        setState(() {
          _mensaje = 'Cancelaste la captura';
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error: $e';
      });
    }
  }

  Future<void> seleccionarDelGaleria() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (foto != null) {
        setState(() {
          _imagen = foto;
          _mensaje = 'Foto de galería: ${foto.name}';
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error: $e';
      });
    }
  }

  void limpiarFoto() {
    setState(() {
      _imagen = null;
      _mensaje = 'Foto eliminada';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Captura de fotos'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.pink, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: _imagen == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.camera_alt,
                            size: 80,
                            color: Colors.pink,
                          ),
                          SizedBox(height: 20),
                          Text('Aquí aparecerá tu foto'),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(_imagen!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: capturarFoto,
                    icon: const Icon(Icons.camera),
                    label: const Text('Cámara'),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton.icon(
                    onPressed: seleccionarDelGaleria,
                    icon: const Icon(Icons.image),
                    label: const Text('Galería'),
                  ),
                ],
              ),
              if (_imagen != null)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: ElevatedButton.icon(
                    onPressed: limpiarFoto,
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  border: Border.all(color: Colors.pink),
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
            ],
          ),
        ),
      ),
    );
  }
}