import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

      // In body text containing 'Home page ' in center

      floatingActionButton: FloatingActionButton.extended(
        onPressed: goCreateItem,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text("Add a To Do item"),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _createToDoItem() {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: const Text("Create a To Do Item"),
            trailing: SizedBox(
              width: 100.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(),
                    child:
                    Expanded(
                      flex: 3,
                      child: TextField(
                        textAlign: TextAlign.end,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: "Enter your task"
                        ),
                      )
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(),
                    child:
                    Expanded(
                      flex: 3,
                      child: TextField(
                        textAlign: TextAlign.end,
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            hintText: "Just another text field"
                        ),
                      )
                    )
                  ),
                ],
              )
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: showCreateItem,
                child: const Text("Add item", style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  primary: Colors.amber,
                  padding: const EdgeInsets.all(8.0),
                )
              )
            ]
          )
        ]
      )
    );
  }

  // Widget _buildToDoItems() {
  //   return ListView.builder(
  //     itemBuilder: (context, i) {
  //
  //     },
  //   );
  // }

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
