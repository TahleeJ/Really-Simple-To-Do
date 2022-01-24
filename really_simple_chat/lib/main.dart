// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/*
  The extension of this app as a StatelessWidget makes the app itself a widget as
  well as everything inside of the app a widget.
 */
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  /*
    A widget's main job is to provide a build method that describes how to display
    the widget in terms of other, lower level widgets
   */
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      /*
        Scaffold widget provides a default app bar and a body that holds the widget
        for the home screen
       */
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter'),
        ),
        body: const Center(
          child: Text('Hellooooo World'),
        ),
      ),
    );
  }
}