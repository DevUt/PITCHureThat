/*******************************************************************************
 * Copyright (c) 2021 Rishabh Rao.
 * All Rights Reserved.
 *
 ******************************************************************************/
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_svg/svg.dart";
import "package:page_transition/page_transition.dart";
import "package:pitchure_that/pages/pitchure_page.dart";

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    bool _isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 0,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).primaryColor,
          systemNavigationBarColor: Theme.of(context).primaryColor,
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            const SizedBox(
              height: 25,
            ),
            Center(
              child: SvgPicture.asset(
                "assets/images/LogoWithText.svg",
                semanticsLabel: "PITCHureThat Logo",
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Image(
                  image: AssetImage("assets/images/Banner.png"),
                  semanticLabel: "PITCHureThat Banner",
                ),
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 70,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.audio).then(
                    (FilePickerResult? value) async {
                      if (value != null) {
                        await Navigator.push(
                          context,
                          PageTransition<PageTransitionType>(
                            curve: Curves.easeInOutBack,
                            type: PageTransitionType.rightToLeftJoined,
                            childCurrent: const WelcomePage(),
                            child: PITCHurePage(value.files.first),
                          ),
                        );
                      }
                    },
                    onError: (dynamic error) {
                      debugPrint(error.toString());
                    },
                  ).whenComplete(() {
                    setState(() {
                      _isLoading = false;
                    });
                  });
                },
                child: Text(
                  _isLoading ? "Loading..." : "Select Music",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 1.25,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 80,
            ),
          ],
        ),
      ),
    );
  }
}
