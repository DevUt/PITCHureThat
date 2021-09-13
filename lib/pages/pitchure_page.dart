/*******************************************************************************
 * Copyright (c) 2021 Rishabh Rao.
 * All Rights Reserved.
 *
 ******************************************************************************/
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class PITCHurePage extends StatefulWidget {
  const PITCHurePage({Key? key}) : super(key: key);

  @override
  State<PITCHurePage> createState() => _PITCHurePageState();
}

class _PITCHurePageState extends State<PITCHurePage> {
  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 0,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).primaryColor, // Status bar
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            "PITCHureThat!!!",
            style: TextStyle(
              fontSize: 40,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
