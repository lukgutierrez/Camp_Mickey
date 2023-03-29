import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
  bool isTakingPhoto = false;
  Timer? _timer;
  late CameraDescription _currentCamera;

  void _switchCamera() async {
    print("Cambio de Camera");
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
    isTakingPhoto = true;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
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

      if (_photoCount++ == 10) {
        timer.cancel();
      }
    });
  }

  void _stopTakingPhotos() {
    if (isTakingPhoto) {
      _timer?.cancel();
      isTakingPhoto = false;
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: false),
      title: 'CamMickey',
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            SafeArea(
              child: Container(
                child: Image(image: AssetImage("assets/backgraund.png")),
              ),
            ),
          ],
        ),
        floatingActionButton: SpeedDial(
          backgroundColor: Color(0xFFF00A884),
          animatedIcon: AnimatedIcons.menu_close,
          visible: true,
          curve: Curves.bounceInOut,
          children: [
            SpeedDialChild(
                child: Icon(Icons.photo),
                backgroundColor: Color(0xFFF00A884),
                onTap: () {
                  _takePhoto();
                }),
            SpeedDialChild(
              child: Icon(Icons.block),
              backgroundColor: Color(0xFFF00A884),
              onTap: isTakingPhoto ? _stopTakingPhotos : _takePhoto,
            ),
            SpeedDialChild(
                child: Icon(Icons.camera_front),
                backgroundColor: Color(0xFFF00A884),
                labelStyle: TextStyle(fontSize: 20.0),
                onTap: () {
                  _switchCamera();
                }),
          ],
        ),
      ),
    );
  }
}
