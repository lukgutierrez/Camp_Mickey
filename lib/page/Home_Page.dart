import 'dart:io';

import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  final CameraController camera;
  HomePage({required this.camera});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _photoCount = 0;

  void _takePhoto() async {
    // Obtener el directorio de almacenamiento externo
    final Directory? extDir = await getExternalStorageDirectory();
    final String dirPath = '${extDir?.path}/Pictures/flutter_camera_background';
    await Directory(dirPath).create(recursive: true);

    // Generar el nombre de archivo para la foto
    final String filePath =
        '$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Tomar la foto
    try {
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



// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';

// import 'Camera_Page.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.red,
//         title: Text("Test")),
//       body: SafeArea(
//         child: Center(
//             child: ElevatedButton(
//           onPressed: () async {
//             await availableCameras().then((value) => Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => CameraPage(cameras: value))));
//           },
//           child:  Text("Take a Picture"),
//         )),
//       ),
//     );
//   }
// }
