/*******************************************************************************
 * Copyright (c) 2021 Rishabh Rao.
 * All Rights Reserved.
 *
 ******************************************************************************/
import "package:flutter/material.dart";

import 'pages/welcome_page.dart';

void main() {
  runApp(const PITCHureThatApp());
}

class PITCHureThatApp extends StatelessWidget {
  const PITCHureThatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "PITCHureThat",
      theme: ThemeData(
        primaryColor: const Color(0xFFE61E3A),
        fontFamily: "HKGrotesk",
      ),
      home: const WelcomePage(),
    );
  }
}
