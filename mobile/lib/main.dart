// Flutter main entry
import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Come Chat',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: ChatScreen(),
      
    );
  }
}

 