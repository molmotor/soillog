import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends  StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home : Scaffold(
        appBar: AppBar(
          title: Text('SoilLog'),
          ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CameraScreen()),
              );
            },
            child: Text('Start New Log')
          )))
    );
  }
}

class CameraScreen extends StatelessWidget {

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take Photos'),
      ),
      body: Center(
        child: Text('Camera screen - we will add camera here'),
      ),
    );
  }
}




