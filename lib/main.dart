import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar la cámara
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  final camera = await CameraController(
    firstCamera,
    ResolutionPreset.high,
  ).initialize();

  runApp(MyApp(camera: camera));
}

class MyApp extends StatefulWidget {
  final CameraController camera;

  MyApp({required this.camera});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void takePicturesInIsolate() async {
    final isolate = await FlutterIsolate.spawn(_takePictures, null);
    // Espera a que se tomen todas las fotos antes de mostrar el mensaje
    await isolate.done;
    print('¡Se tomaron todas las fotos!');
  }

  static Future<void> _takePictures(_) async {
    for (var i = 0; i < 10; i++) {
      final Directory directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/image_$i.jpg';

      // Tomar foto y guardarla en el directorio temporal
      await Future.delayed(Duration(seconds: 1));
      await widget.camera.takePicture(filePath);
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
          child:
              Text('Presione el botón para tomar 10 fotos en segundo plano.'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            takePicturesInIsolate();
          },
          child: Icon(Icons.camera),
        ),
      ),
    );
  }
}
