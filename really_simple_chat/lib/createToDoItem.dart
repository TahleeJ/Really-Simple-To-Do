import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'homepage.dart';
import 'signInScreen.dart';

/// Stateful class controlling the create task page
class CreatePage extends StatefulWidget {
  const CreatePage({Key? key}) : super(key: key);

  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  // Project's Firebase Build feature instances
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Controller managing the inputted task name's TextFormField
  final nameController = TextEditingController();

  /// Builder for the homepage screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        title: const Text("Really Simple To Do"),
        actions: <Widget>[
          // Sign out button
          Padding(
          padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              // Sign out the user and navigate to the sign in screen upon being clicked
              onTap: () { _signOut(); },
              child: Icon(Icons.exit_to_app_outlined, size: 26.0)
            )
          )
        ]
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Text("Create a New To Do Item", style: TextStyle(fontSize: 24))
              ),
              // Task name's TextFormField
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter your TO DO task',
                  ),
                ),
              ),
              // Secondary TextFormField
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Just another input field...',
                  ),
                ),
              ),
              // Add task container and button
              Container(
                margin: const EdgeInsets.only(top: 60),
                child: ElevatedButton(
                  // Handles the storage of the new task to Firestore upon the button being pressed
                  onPressed: _storeItem,
                  child: const Text("Add Item", style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.amber,
                    padding: const EdgeInsets.all(18.0),
                  )
                ),
              )
            ],
          ),
        ],
      ),
      // Button to navigate back to the home page
      floatingActionButton: Stack(
        children: [
          Positioned(
              left: 30,
              bottom: 20,
              child: FloatingActionButton(
                // Navigates to the home page upon being pressed
                onPressed: _goHome,
                child: const Icon(Icons.arrow_back),
                backgroundColor: Colors.grey
              )
          )
        ]
      )
    );
  }

  /// Stores a new task to the currently signed in user's document in Firestore
  void _storeItem() {
    User user = auth.currentUser!;
    late var userRef = store.collection("users").doc(user.uid);

    List<String> keys = ['latitude', 'longitude'];
    List<String> values = ["lat", "long"];

    // Stores the new task information in a map:
    // {task's name: {
    //    {latitude: task location's latitude},
    //    {longitude: task location's longitude}
    // }
    userRef
        .set({nameController.text: Map.fromIterables(keys, values)}, SetOptions(merge: true));

    // Navigates to the home page screen
    _goHome();
  }

  /// Signs out the currently signed in user and navigates to the sign in screen
  Future<void> _signOut() async {
    await auth.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();
    _goSignIn();
  }

  /// Navigates to the sign in screen
  void _goSignIn() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignInScreen()));
  }

  /// Navigates to the home page screen
  void _goHome() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }
}