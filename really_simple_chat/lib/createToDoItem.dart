import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({Key? key}) : super(key: key);

  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          centerTitle: true,

          // on appbar text
          title: const Text("Really Simple To Do")
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Just another input field...',
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 60),
                child: ElevatedButton(
                  onPressed: storeItem,
                  child: const Text("Add Item", style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.amber,
                    padding: const EdgeInsets.all(18.0),
                  )
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              margin: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: goHome,
                child: const Text("Go Back", style: TextStyle(fontSize: 20, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 50),
                )
              )
            )
          )
        ],
      )
    );
  }

  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  void storeItem() {
    User? user = auth.currentUser;
    late var userRef;

    if (user != null) {
      userRef = store.collection("users").doc(user.uid);
    }

    List<String> keys = ['latitude', 'longitude'];
    List<String> values = ["lat", "long"];

    userRef
        .set({nameController.text: Map.fromIterables(keys, values)}, SetOptions(merge: true));

    goHome();
  }

  void goHome() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }
}