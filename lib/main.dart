import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(cameras: cameras),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  const HomeScreen({required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text(
          'SoilLog',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF8B4513), // Dirt brown color
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'No logs yet',
          style: TextStyle(
            fontSize: 20,
            color: Colors.brown[600],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CameraScreen(cameras: cameras),
            ),
          );
        },
        backgroundColor: Color(0xFF8B4513),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  late Future<void> _initializeControllerFuture;
  List<String> capturedImages = [];

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.high,
    );
    _initializeControllerFuture = controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await controller.takePicture();
      setState(() {
        capturedImages.add(image.path);
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take Photos (${capturedImages.length}/4)'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: CameraPreview(controller),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Photos taken: ${capturedImages.length}/4'),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: capturedImages.length < 4
          ? FloatingActionButton(
              onPressed: takePicture,
              child: Icon(Icons.camera),
            )
          : FloatingActionButton(
              onPressed: () {
                print('All 4 photos taken!');
              },
              child: Icon(Icons.arrow_forward),
            ),
    );
  }
}