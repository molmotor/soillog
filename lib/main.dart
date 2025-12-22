import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, this.cameras = const []});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(cameras: cameras),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  const HomeScreen({super.key, required this.cameras});

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
        backgroundColor: Color(0xFF8B4513),
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
  const CameraScreen({super.key, required this.cameras});

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
      if (!mounted) return;
      final image = await controller.takePicture();
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageEditorScreen(
            imagePath: image.path,
            onSave: (editedPath) {
              setState(() {
                capturedImages.add(editedPath);
              });
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take Photos (${capturedImages.length}/4)'),
        backgroundColor: Color(0xFF8B4513),
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
              backgroundColor: Color(0xFF8B4513),
              child: Icon(Icons.camera, color: Colors.white),
            )
          : FloatingActionButton(
              onPressed: () {
                debugPrint('All 4 photos taken!');
              },
              backgroundColor: Color(0xFF8B4513),
              child: Icon(Icons.arrow_forward, color: Colors.white),
            ),
    );
  }
}

class ImageEditorScreen extends StatefulWidget {
  final String imagePath;
  final Function(String) onSave;

  const ImageEditorScreen({
    super.key,
    required this.imagePath,
    required this.onSave,
  });

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  List<Offset?> points = [];
  Color selectedColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Photo'),
        backgroundColor: Color(0xFF8B4513),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: () {
              widget.onSave(widget.imagePath);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.contain,
                ),
                GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      RenderBox box = context.findRenderObject() as RenderBox;
                      Offset point = box.globalToLocal(details.globalPosition);
                      points.add(point);
                    });
                  },
                  onPanEnd: (details) {
                    points.add(null);
                  },
                  child: CustomPaint(
                    painter: DrawingPainter(points, selectedColor),
                    size: Size.infinite,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.clear, color: Color(0xFF8B4513)),
                  onPressed: () {
                    setState(() {
                      points.clear();
                    });
                  },
                  tooltip: 'Clear',
                ),
                ...[ Colors.red, Colors.blue, Colors.green, Colors.black, Colors.white]
                    .map((color) => GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        )),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;

  DrawingPainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}