import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        centerTitle: true,

        // on appbar text
        title: const Text("Really Simple To Do")
      ),

      // In body text containing 'Home page ' in center
      body: const Center(child:Text('Home page'))
    );
  }
}
