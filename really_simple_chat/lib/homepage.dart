import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'createToDoItem.dart';
import 'signInScreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';

/// Stateful class controlling the home page
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Project's Firebase Build feature instances
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  late GoogleMapController mapController;
  Location location = Location();

  final Set<Marker> markers = new Set();
  static const LatLng showLocation = const LatLng(37.3852, -122.1141);
  static const LatLng showLocation1 = const LatLng(37.3900, -122.1141);

  var latsLongs = [];

  LatLng _initialCameraPos = LatLng(20.5937, 67.32);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    location.onLocationChanged.listen((l) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(l.latitude!, l.longitude!),zoom: 12),
          ),
        );
    });
  }


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
      // Body of screen built upon reception of data from Firestore
      body: FutureBuilder(
        future: _getUserTasks(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              // Generate only as many cards as there is data sent back from Firestore
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                // Build custom task objects using information from each retrieved task from Firestore
                return _buildToDoItem(
                  snapshot.data![index]["name"],
                  snapshot.data![index]["latitude"],
                  snapshot.data![index]["longitude"],
                  addLatsLongs(snapshot.data![index]["name"], snapshot.data![index]["latitude"], snapshot.data![index]["longitude"])
                );
              }
            );
          } else {
            return const CircularProgressIndicator();
          }
        }
      ),

      // All floating action buttons appearing on the screen
      floatingActionButton: Stack(
        children: [
          Positioned(
            // Add task button
            right: 125,
            bottom: 150,
            child: FloatingActionButton.extended(
              shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.zero
              ),
              heroTag: "nearbyPlacesButton",
              onPressed: () => {
                showDialog(
                  context: context,
                  builder: (context) {

                      return Dialog(
                          child:
                                SizedBox(
                                    width: 500,
                                    height: 600,
                                    child: GoogleMap(
                                      onMapCreated: _onMapCreated,
                                      initialCameraPosition: CameraPosition(
                                          target: _initialCameraPos),
                                      mapType: MapType.normal,
                                      myLocationEnabled: true,
                                      markers: getmarkers(),
                                      zoomGesturesEnabled: true,
                                    )
                                )

                      );
                  },
                )
              },
              label: Text('tasks nearby'),
              backgroundColor: Colors.green,
            )
        ),
          Positioned(
            right: 10,
            bottom: 20,
            child: FloatingActionButton(
              heroTag: "addTaskButton",
              // Navigate to the create task page upon pressing the button
              onPressed: _goCreateItem,
              child: const Icon(Icons.add_circle_outline),
              backgroundColor: Colors.red,
            )
          ),
          // Refresh button
          Positioned(
            left: 30,
            bottom: 20,
            child: FloatingActionButton(
              heroTag: "refreshButton",
              // Refresh the page to eliminate deleted tasks from displaying upon pressing the button
              onPressed: () {setState((){});},
              child: const Icon(Icons.refresh_rounded),
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            )
          )
        ]
      ),
    );
  }

  /// Retrieves and returns all stored tasks the currently signed in user has in Firestore
  Future<List<Map<String, dynamic>>> _getUserTasks() async {
    var userRef = store.collection('users').doc(auth.currentUser?.uid);
    var userSnapshot = await userRef.get();
    Map<String, dynamic> userTasks;

    // List to structurally hold all of a user's tasks in maps:
    // {name: task's name},
    // {latitude: task location's latitude},
    // {longitude: task location's longitude}
    List<Map<String, dynamic>> userTaskList = [];

    if (userSnapshot.exists) {
      userTasks = userSnapshot.data()!;
      userTasks.forEach((key, mapValue) {
        List<String> keys = ['name', 'latitude', 'longitude'];
        List<String> values = [key, mapValue["latitude"], mapValue["longitude"]];

        // Append task's map to overall task map list
        userTaskList.add(Map.fromIterables(keys, values));
      });
    }

    return userTaskList;
  }

  /// Custom task object builder using the task's [name] and location([latitude] and [longitude)
  Widget _buildToDoItem(String name, String latitude, String longitude, void addLatsLongs) {
    bool _isDeleted = false;

    // Custom task object
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        StatefulBuilder(builder: (context, _setState) =>
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Task information
                    Text('${name}', style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        // Change color once it has been deleted
                        color: (_isDeleted) ? Colors.red : Colors.black,
                        // Strikethrough task name once it has been deleted
                        decoration: (_isDeleted) ? TextDecoration.lineThrough : TextDecoration.none
                      )
                    ),
                    Text('Latitude: ${latitude}, Longitude:${longitude}', style: TextStyle(fontSize: 14))
                  ]
                )
              ),
              // Delete button
              GestureDetector(
                  onTap: () {
                    _setState(() {
                      // If the task has not been deleted yet and the delete button has been pressed,
                      // the task name will be struck through and it and its delete button will turn red
                      if (!_isDeleted) {
                        _isDeleted = true;
                        _deleteToDo(name);
                      }
                    });
                  },
                  child: Icon(Icons.delete, size: 26.0, color: (_isDeleted) ? Colors.red : Colors.black)
              )
            ]
          ),
        ),
        // Divider underneath each task object
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

  /// Deletes currently signed user task under the name [taskName] from Firestore
  void _deleteToDo(String taskName) {
    var userRef = store.collection('users').doc(auth.currentUser?.uid);
    userRef.update({taskName: FieldValue.delete()});
  }

  void addLatsLongs(String name, String lat, String long) {
    if (lat != null && long != null && double.tryParse(lat) != null && double.tryParse(long) != null) {
      latsLongs.add(name);
      latsLongs.add(lat);
      latsLongs.add(long);
    }
  }

  /// Navigates to the sign in screen
  void goSignIn() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignInScreen()));
  }

  /// Signs out the currently signed in user and navigates to the sign in screen
  Future<void> _signOut() async {
    await auth.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();
    goSignIn();
  }

  /// Navigates to the create task screen
  void _goCreateItem() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => CreatePage()));
  }

  void goDisplayMap() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => CreatePage()));
  }

  Set<Marker> getmarkers() { //markers to place on map
      for (var i = 0; i < latsLongs.length; i += 3) {
        LatLng showLocation = LatLng(double.parse(latsLongs[i + 1]), double.parse(latsLongs[i + 2]));
        markers.add(Marker( //add first marker
          markerId: MarkerId(showLocation.toString()),
          position: showLocation, //position of marker
          infoWindow: InfoWindow( //popup info
            title: latsLongs[i],
            snippet: 'My Custom Subtitle',
          ),
          icon: BitmapDescriptor.defaultMarker, //Icon for Marker
        ));
      }

    return markers;
  }
}
