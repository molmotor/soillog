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
              print('Button pressed');
            },
            child: Text('Start New Log')
          )))
    );
  }
}



