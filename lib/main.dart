import 'package:chat_flutter/ui/ChatPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.amber,
          iconTheme: IconThemeData(color: Colors.amber)
      ),
      debugShowCheckedModeBanner: false,
      home: ChatPage(),
    );
  }
}
