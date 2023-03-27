import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar la cámara
  final cameras = await availableCameras();

  final firstCamera = cameras.first;

  runApp(MyApp(camera: CameraController(firstCamera, ResolutionPreset.medium)));
}

class MyApp extends StatefulWidget {
  late CameraController camera;

  MyApp({required this.camera});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _photoCount = 0;
  late CameraDescription _currentCamera;

  void _switchCamera() async {
    // Encontrar la cámara opuesta a la actual
    final cameras = await availableCameras();
    _currentCamera =
        (_currentCamera == cameras.first) ? cameras.last : cameras.first;

    // Actualizar el controlador de la cámara con la nueva cámara seleccionada
    widget.camera.dispose();
    widget.camera = CameraController(_currentCamera, ResolutionPreset.medium);
    await widget.camera.initialize();
    setState(() {});
  }

  void _takePhoto() async {
    // Obtener el directorio de almacenamiento externo
    final Directory? extDir = await getExternalStorageDirectory();
    final String dirPath = '${extDir?.path}/Pictures/flutter_camera_background';
    await Directory(dirPath).create(recursive: true);

    // Generar el nombre de archivo para la foto
    final String filePath =
        "$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg";

    // Inicializar la cámara
    try {
      await widget.camera.initialize();
    } catch (e) {
      print('Error al inicializar la cámara: $e');
      return;
    }

    // Tomar la foto
    for (var i = 0; i < 10; i++) {
      try {
        final XFile photo = await widget.camera.takePicture();
        setState(() {
          _photoCount++;
        });

        // Guardar la foto en el almacenamiento local
        final File localFile = File(photo.path);
        await localFile.copy(filePath);

        // Guardar la foto en la galería
        await GallerySaver.saveImage(filePath);
      } catch (e) {
        print('Error al tomar la foto: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _currentCamera = widget.camera.description;
  }

  @override
  void dispose() {
    widget.camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CamMykey',
      home: Scaffold(
        appBar: AppBar(
          title: Text('camera'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Presione el botón para tomar una foto.'),
              SizedBox(height: 16),
              Text('$_photoCount fotos tomadas.'),
              ElevatedButton(
                  onPressed: _switchCamera, child: Text("Cambiar cámara")),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _takePhoto,
          child: Icon(Icons.camera),
        ),
      ),
    );
  }
}
