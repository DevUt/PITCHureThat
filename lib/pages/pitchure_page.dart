/*******************************************************************************
 * Copyright (c) 2021 Rishabh Rao.
 * All Rights Reserved.
 *
 ******************************************************************************/
import "package:audio_video_progress_bar/audio_video_progress_bar.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";
import "package:flutter_svg/svg.dart";
import "package:just_audio/just_audio.dart";
import "package:rxdart/rxdart.dart";
import "package:sliding_up_panel/sliding_up_panel.dart";

// TODO: Speed Slider Animation
// TODO: Song Name from Metadata
// TODO: Equalizer with Animation
// TODO: Pitch Graph
// TODO: Functions with Animation
// TODO: Use file picker for music selection

class DurationState {
  DurationState({
    required this.progress,
    this.total,
  });

  final Duration progress;
  final Duration? total;
}

class PITCHurePage extends StatefulWidget {
  const PITCHurePage({Key? key}) : super(key: key);

  @override
  State<PITCHurePage> createState() => _PITCHurePageState();
}

class _PITCHurePageState extends State<PITCHurePage> {
  late AudioPlayer _player;
  late Stream<DurationState> _durationState;

  bool _isPanelOpen = false;
  bool _isSpeedExpanded = false;
  bool _isEqualizerExpanded = false;
  bool _isFunctionsExpanded = false;

  double _panelMaxHeight = 250;

  double _playerSpeed = 1;

  Future<void> _setupMusic() async {
    try {
      _player = AudioPlayer();
      _durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        _player.positionStream,
        _player.playbackEventStream,
        (Duration position, PlaybackEvent playbackEvent) => DurationState(
          progress: position,
          total: playbackEvent.duration,
        ),
      );
      await _player.setAsset("assets/music/music.mp3");
      // await _player.setUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3");
    } catch (e) {
      debugPrint("An error occurred $e");
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _setupMusic();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

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
        child: SlidingUpPanel(
          onPanelSlide: (double position) {
            setState(() {
              _isPanelOpen = position != 0;
            });
          },
          minHeight: 80,
          maxHeight: _panelMaxHeight,
          panelBuilder: (ScrollController _panelScrollController) =>
              _slideUpPanel(_panelScrollController),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(
                -3,
                -1,
              ),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 7,
              spreadRadius: -2,
              offset: const Offset(
                4,
                -5,
              ),
            )
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            bottomLeft: Radius.zero,
            bottomRight: Radius.zero,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          backdropEnabled: true,
          body: ListView(
            children: <Widget>[
              const SizedBox(
                height: 50,
              ),
              Center(
                child: PhysicalModel(
                  color: Theme.of(context).primaryColor,
                  elevation: 10,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 20,
                    ),
                    width: 300,
                    child: Row(
                      children: <Widget>[
                        SvgPicture.asset(
                          "assets/images/MusicalNote.svg",
                          semanticsLabel: "Musical Note",
                        ),
                        const Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Amare - Electrona",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 24,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 75,
              ),
              SvgPicture.asset(
                "assets/images/LineChart.svg",
                semanticsLabel: "Graph",
              ),
              const SizedBox(
                height: 100,
              ),
              _progressBar(),
              const SizedBox(
                height: 15,
              ),
              _playPauseButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slideUpPanel(ScrollController _panelScrollController) {
    return ListView.builder(
      controller: _panelScrollController,
      itemCount: 1,
      itemBuilder: (BuildContext context, int i) {
        return Column(
          children: <Widget>[
            const SizedBox(height: 15),
            Column(
              children: <Widget>[
                Center(
                  child: SvgPicture.asset(
                    _isPanelOpen ? "assets/images/DownArrow.svg" : "assets/images/UpArrow.svg",
                    semanticsLabel: _isPanelOpen ? "Close Panel" : "Open Panel",
                  ),
                ),
              ],
            ),
            if (_isPanelOpen) ...<Widget>[
              const SizedBox(height: 15),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AnimatedAlign(
                      alignment: _isSpeedExpanded ? Alignment.centerLeft : Alignment.center,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutBack,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isSpeedExpanded = !_isSpeedExpanded;
                            });
                          },
                          child: const Text(
                            "Speed",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isSpeedExpanded)
                    Expanded(
                      flex: 2,
                      child: Slider(
                        min: 0,
                        max: 5,
                        divisions: 20,
                        thumbColor: Theme.of(context).primaryColor,
                        activeColor: Theme.of(context).primaryColor,
                        inactiveColor: Theme.of(context).colorScheme.secondary,
                        label: _playerSpeed == 0 ? "0.01" : _playerSpeed.toStringAsPrecision(2),
                        value: _playerSpeed,
                        onChanged: (double newSpeed) {
                          _player.setSpeed(newSpeed);
                          setState(() {
                            _playerSpeed = newSpeed;
                          });
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AnimatedAlign(
                      alignment: _isEqualizerExpanded ? Alignment.centerLeft : Alignment.center,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutBack,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                          ),
                          onPressed: () {
                            int _heightDifference = 125;
                            setState(() {
                              _isEqualizerExpanded
                                  ? _panelMaxHeight -= _heightDifference
                                  : _panelMaxHeight += _heightDifference;
                              _isEqualizerExpanded = !_isEqualizerExpanded;
                            });
                          },
                          child: const Text(
                            "Equalizer",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isEqualizerExpanded)
                Center(
                  child: SvgPicture.asset(
                    "assets/images/LineChart.svg",
                    semanticsLabel: "Equalizer",
                    height: 125,
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AnimatedAlign(
                      alignment: _isFunctionsExpanded ? Alignment.centerLeft : Alignment.center,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutBack,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                          ),
                          onPressed: () {
                            int _heightDifference = 125;
                            setState(() {
                              _isFunctionsExpanded
                                  ? _panelMaxHeight -= _heightDifference
                                  : _panelMaxHeight += _heightDifference;
                              _isFunctionsExpanded = !_isFunctionsExpanded;
                            });
                          },
                          child: const Text(
                            "Functions",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isFunctionsExpanded)
                Center(
                  child: SvgPicture.asset(
                    "assets/images/LogoWithText.svg",
                    semanticsLabel: "Equalizer",
                  ),
                ),
            ]
          ],
        );
      },
    );
  }

  StreamBuilder<DurationState> _progressBar() {
    bool _isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return StreamBuilder<DurationState>(
      stream: _durationState,
      builder: (BuildContext context, AsyncSnapshot<DurationState> snapshot) {
        final DurationState? _durationState = snapshot.data;
        final Duration _progress = _durationState?.progress ?? Duration.zero;
        final Duration _total = _durationState?.total ?? Duration.zero;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: ProgressBar(
            progress: _progress,
            total: _total,
            onSeek: (Duration duration) {
              _player.seek(duration);
            },
            progressBarColor: Theme.of(context).primaryColor,
            baseBarColor: _isDark
                ? Theme.of(context).colorScheme.secondaryVariant
                : Theme.of(context).colorScheme.secondary,
            thumbColor: Theme.of(context).primaryColor,
            barHeight: 3,
            thumbRadius: 6,
            timeLabelPadding: 5,
            timeLabelTextStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Theme.of(context).primaryColor,
            ),
            thumbCanPaintOutsideBar: true,
          ),
        );
      },
    );
  }

  StreamBuilder<PlayerState> _playPauseButton() {
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
        final PlayerState? _playerState = snapshot.data;
        final ProcessingState? _processingState = _playerState?.processingState;
        final bool? _playing = _playerState?.playing;
        if (_playing != true || _processingState == ProcessingState.completed) {
          return Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(100),
                  ),
                ),
                elevation: 5,
                padding: const EdgeInsets.all(3),
                alignment: Alignment.center,
              ),
              onPressed: () {
                if (_processingState == ProcessingState.completed) {
                  _player.seek(Duration.zero);
                }
                _player.play();
              },
              child: SvgPicture.asset(
                "assets/images/Play.svg",
                semanticsLabel: "Play",
              ),
            ),
          );
        } else {
          return Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(100),
                  ),
                ),
                elevation: 5,
                padding: const EdgeInsets.all(3),
                alignment: Alignment.center,
              ),
              onPressed: () {
                _player.pause();
              },
              child: SvgPicture.asset(
                "assets/images/Pause.svg",
                semanticsLabel: "Pause",
              ),
            ),
          );
        }
      },
    );
  }
}
