import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'createToDoItem.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          centerTitle: true,

          // on appbar text
          title: const Text("Really Simple To Do")
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          _buildToDoItem("This is a name", "1234", "5678"),
          const Divider(
            height: 20.0,
            thickness: 1.0,
            color: Colors.grey,
            indent: 20.0,
            endIndent: 20.0
          ),
          _buildToDoItem("Yet another name", "6546", "1373")
        ]
      ),

      // In body text containing 'Home page ' in center
      floatingActionButton: FloatingActionButton(
        onPressed: goCreateItem,
        child: const Icon(Icons.add_circle_outline),
        // label: const Text("Add a To Do item"),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Widget _buildToDoItems() {
  //   return ListView.builder(
  //     itemBuilder: (context, i) {
  //
  //     },
  //   );
  // }

  Widget _buildToDoItem(String name, String latitude, String longitude) {
    bool _isChecked = false;

    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.amberAccent;
      }
      return Colors.blue;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('${name}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Latitude: ${latitude}, Longitude:${longitude}', style: TextStyle(fontSize: 14))
            ]
          )
        ),
        StatefulBuilder( builder: (context, _setState) =>
            Checkbox(
              fillColor: MaterialStateColor.resolveWith((states) => getColor(states)),
              value: _isChecked,
              onChanged: (value) {
                _setState(() {
                  _isChecked = value!;
                  deleteToDo(name);
                });
              }
            )
        )
      ]
    );
  }

  void deleteToDo(String taskName) {

  }

  void showCreateItem() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  void goCreateItem() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => CreatePage()));
  }
}
