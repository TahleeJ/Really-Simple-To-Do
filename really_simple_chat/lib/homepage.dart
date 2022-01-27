import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'createToDoItem.dart';
import 'signInScreen.dart';

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
        title: const Text("Really Simple To Do"),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () { _signOut(); },
              child: Icon(Icons.exit_to_app_outlined, size: 26.0)
            )
          )
        ]
      ),
      body: FutureBuilder(
        future: _getUserTasks(),
        // initialData: [],
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildToDoItem(
                  snapshot.data![index]["name"],
                  snapshot.data![index]["latitude"],
                  snapshot.data![index]["longitude"]
                );
              }
            );
          } else {
            return const CircularProgressIndicator();
          }
        }
      ),
      // In body text containing 'Home page ' in center
      floatingActionButton: Stack(
        children: [
          Positioned(
            right: 30,
            bottom: 20,
            child: FloatingActionButton(
              heroTag: "addTaskButton",
              onPressed: goCreateItem,
              child: const Icon(Icons.add_circle_outline),
              // label: const Text("Add a To Do item"),
              backgroundColor: Colors.red,
            )
          ),
          Positioned(
            left: 30,
            bottom: 20,
            child: FloatingActionButton(
              heroTag: "refreshButton",
              onPressed: () {setState((){});},
              child: const Icon(Icons.refresh_rounded),
              // label: const Text("Add a To Do item"),
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            )
          )
        ]
      ),
    );
  }

  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> _signOut() async {
    await auth.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();
    goSignIn();
  }

  Future<List<Map<String, dynamic>>> _getUserTasks() async {
    var userRef = store.collection('users').doc(auth.currentUser?.uid);
    var userSnapshot = await userRef.get();
    Map<String, dynamic> userTasks;

    List<Map<String, dynamic>> userTaskList = [];

    if (userSnapshot.exists) {
      userTasks = userSnapshot.data()!;
      userTasks.forEach((key, mapValue) {
        List<String> keys = ['name', 'latitude', 'longitude'];
        List<String> values = [key, mapValue["latitude"], mapValue["longitude"]];

        userTaskList.add(Map.fromIterables(keys, values));
      });
    }

    return userTaskList;
  }

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
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
        ),
        const Divider(
          height: 20.0,
          thickness: 1.0,
          color: Colors.grey,
          indent: 20.0,
          endIndent: 20.0
        )
      ]
    );
  }

  void deleteToDo(String taskName) {
    var userRef = store.collection('users').doc(auth.currentUser?.uid);
    userRef.update({taskName: FieldValue.delete()});
  }

  void showCreateItem() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  void goSignIn() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignInScreen()));
  }

  void goCreateItem() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => CreatePage()));
  }
}
