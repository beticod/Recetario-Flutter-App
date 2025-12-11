import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final List<XFile> _fotosSeleccionadas = [];
  final ImagePicker _picker = ImagePicker();
  String _mensaje = 'Aún no has seleccionado fotos';

  Future<void> seleccionarMultiplesFotos() async {
    try {
      final List<XFile> fotos = await _picker.pickMultiImage(imageQuality: 80);

      if (fotos.isNotEmpty) {
        setState(() {
          _fotosSeleccionadas.addAll(fotos);
          _mensaje = 'Fotos seleccionadas: ${_fotosSeleccionadas.length}';
        });
      } else {
        setState(() {
          _mensaje = 'No seleccionaste ninguna foto';
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error: $e';
      });
    }
  }

  void eliminarFoto(int indice) {
    setState(() {
      _fotosSeleccionadas.removeAt(indice);
      _mensaje = 'Fotos seleccionadas: ${_fotosSeleccionadas.length}';
    });
  }

  void limpiarTodas() {
    setState(() {
      _fotosSeleccionadas.clear();
      _mensaje = 'Galería limpiada';
    });
  }

  void mostrarFotoEnGrande(int indice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Image.file(
                  File(_fotosSeleccionadas[indice].path),
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  _fotosSeleccionadas[indice].name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galería de fotos'),
        centerTitle: true,
        actions: [
          if (_fotosSeleccionadas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '${_fotosSeleccionadas.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: seleccionarMultiplesFotos,
                  icon: const Icon(Icons.image),
                  label: const Text('Seleccionar fotos'),
                ),
                if (_fotosSeleccionadas.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: limpiarTodas,
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('Limpiar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green),
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
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _fotosSeleccionadas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.photo_library,
                          size: 100,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No hay fotos seleccionadas',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _fotosSeleccionadas.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          mostrarFotoEnGrande(index);
                        },
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Eliminar foto'),
                                content: Text(
                                  '¿Estás seguro de que quieres eliminar ${_fotosSeleccionadas[index].name}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      eliminarFoto(index);
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green[300]!,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.file(
                                  File(_fotosSeleccionadas[index].path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
