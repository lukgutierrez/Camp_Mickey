// import 'package:camera/camera.dart';
// import 'package:camp_mikey/page/Home_Page.dart';
// import 'package:flutter/material.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   final cameras = await availableCameras();
//   final firstCamera = cameras.first;
//   final camera = await CameraController(firstCamera,ResolutionPreset.medium).initialize();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         theme: ThemeData(primaryColor: Colors.red),
//         debugShowCheckedModeBanner: false,
//         title: 'CAMPMICKEY',
//         home: HomePage(camera: ));
//   }
// }

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar la cámara
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: CameraController(firstCamera, ResolutionPreset.medium)));
}

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  final CameraController camera;

  MyApp({required this.camera});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _photoCount = 0;

  void _takePhoto() async {
    // Obtener el directorio de almacenamiento externo
    final Directory? extDir = await getExternalStorageDirectory();
    final String dirPath = '${extDir?.path}/Pictures/flutter_camera_background';
    await Directory(dirPath).create(recursive: true);

    // Generar el nombre de archivo para la foto
    // late final String filePath =
    //     "$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg";
    // Init Camera
    try {
      await widget.camera.initialize();
    } catch (e) {
      print('Error al inicializar la cámara: $e');
      return;
    }

    // Tomar la foto
    try {
      await widget.camera.initialize();
      await widget.camera.takePicture();
      setState(() {
        _photoCount++;
      });
    } catch (e) {
      print('Error al tomar la foto: $e');
    }
  }

  @override
  void dispose() {
    widget.camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Background Camera Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Background Camera Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Presione el botón para tomar 10 fotos automáticamente.'),
              SizedBox(height: 16),
              Text('$_photoCount fotos tomadas.'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            for (var i = 0; i < 10; i++) {
              _takePhoto();
            }
          },
          child: Icon(Icons.camera),
        ),
      ),
    );
  }
}
