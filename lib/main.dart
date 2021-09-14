/*******************************************************************************
 * Copyright (c) 2021 Rishabh Rao.
 * All Rights Reserved.
 *
 ******************************************************************************/
import "package:flutter/material.dart";
import "package:pitchure_that/pages/welcome_page.dart";

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
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFF9C9D0),
          secondaryVariant: const Color(0xFF520F18),
        ),
        sliderTheme: ThemeData.dark().sliderTheme.copyWith(
              valueIndicatorColor: const Color(0xFFE61E3A),
            ),
      ),
      home: const WelcomePage(),
    );
  }
}
