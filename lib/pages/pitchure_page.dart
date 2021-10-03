/*******************************************************************************
 * Copyright (c) 2021 Rishabh Rao.
 * All Rights Reserved.
 *
 ******************************************************************************/
import "dart:math";

import "package:audio_video_progress_bar/audio_video_progress_bar.dart";
import "package:equalizer/equalizer.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/painting.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";
import "package:flutter_svg/svg.dart";
import "package:just_audio/just_audio.dart";
import "package:marquee_text/marquee_text.dart";
import "package:rxdart/rxdart.dart";
import "package:sliding_up_panel/sliding_up_panel.dart";
import "package:syncfusion_flutter_charts/charts.dart";

// TODO: 3 remaining functions
// TODO: Fix flac null error bug
// TODO: Wavelength and Wave amplitude Slider, Store in State and update live
// TODO: Do not play in background
// TODO: Pitch Graph with start and end points to select region and slider knob to change pitch of that particular region
// TODO: Save Button to Save music to Storage

class DurationState {
  DurationState({
    required this.progress,
    this.total,
  });

  final Duration progress;
  final Duration? total;
}

class PITCHurePage extends StatefulWidget {
  const PITCHurePage(this.filePickerResult, {Key? key}) : super(key: key);

  final PlatformFile? filePickerResult;

  @override
  State<PITCHurePage> createState() => _PITCHurePageState();
}

class _PITCHurePageState extends State<PITCHurePage> {
  late AudioPlayer _player;
  late Stream<DurationState> _durationState;

  bool _isPanelOpen = false;
  bool _isSpeedExpanded = false;
  bool _isPitchExpanded = false;
  bool _isEqualizerExpanded = false;
  bool _isFunctionsExpanded = false;

  double _panelMaxHeight = 310;

  double _playerSpeed = 1;
  double _playerPitch = 0;

  String _musicTitle = "Loading...";

  int _eqBandLevelMin = -15;
  int _eqBandLevelMax = 15;
  final List<int> _eqBandFreqs = <int>[];
  final List<int> _eqBandLevels = <int>[];

  int _secondsInMusic = 0;
  final List<List<double>> _pitches = <List<double>>[
    <double>[0, 1]
  ];

  Future<void> _setupMusic() async {
    try {
      _player = AudioPlayer();

      _durationState =
          Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        _player.positionStream,
        _player.playbackEventStream,
        (Duration position, PlaybackEvent playbackEvent) => DurationState(
          progress: position,
          total: playbackEvent.duration,
        ),
      );

      PlatformFile? musicFile = widget.filePickerResult;
      if (musicFile != null) {
        await _player.setFilePath(musicFile.path!, preload: true);

        setState(() {
          _musicTitle = _player.icyMetadata?.info?.title ?? musicFile.name;
          _secondsInMusic = _player.playbackEvent.duration?.inSeconds ?? 0;
        });

        for (int i = 1; i <= _secondsInMusic; i++) {
          _pitches.add(<double>[i.toDouble(), 1]);
        }
      } else {
        Navigator.pop(context);
      }

      _player.androidAudioSessionIdStream.first
          .then((int? _playerAudioSessionId) {
        if (_playerAudioSessionId != null) {
          Equalizer.init(_playerAudioSessionId);
          Equalizer.setEnabled(true);
          Equalizer.getBandLevelRange().then((List<int> value) {
            setState(() {
              _eqBandLevelMin = value[0];
              _eqBandLevelMax = value[1];
            });
          });
          Equalizer.getCenterBandFreqs().then((List<int> value) {
            while (value.length > 6) {
              value.removeLast();
            }
            _eqBandFreqs.addAll(value);
            for (int levelIdx = 0; levelIdx < value.length; levelIdx++) {
              Equalizer.getBandLevel(levelIdx).then((int level) {
                _eqBandLevels.add(level);
              });
            }
            while (_eqBandFreqs.length > 6) {
              _eqBandFreqs.removeLast();
            }
            while (_eqBandLevels.length > 6) {
              _eqBandLevels.removeLast();
            }
          });
        }
      });
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
    Equalizer.release();
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
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: ListView(
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
                          vertical: 10,
                          horizontal: 15,
                        ),
                        width: 300,
                        child: Row(
                          children: <Widget>[
                            SvgPicture.asset(
                              "assets/images/MusicalNote.svg",
                              semanticsLabel: "Musical Note",
                            ),
                            Expanded(
                              child: Transform(
                                transform: Matrix4.translationValues(-5, 0, 0),
                                child: Center(
                                  child: MarqueeText(
                                    text: _musicTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 24,
                                      color: Colors.white,
                                    ),
                                    speed: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  SfCartesianChart(
                    primaryXAxis: NumericAxis(),
                    primaryYAxis: NumericAxis(
                      minimum: -12,
                      maximum: 12,
                      interval: 6,
                    ),
                    series: <SplineSeries<List<double>, double>>[
                      SplineSeries<List<double>, double>(
                        dataSource: _pitches,
                        xValueMapper: (List<double> pitch, _) => pitch[0],
                        yValueMapper: (List<double> pitch, _) =>
                            (pitch[1] / 0.0416666667) + _playerPitch - 24,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  _progressBar(),
                  const SizedBox(
                    height: 15,
                  ),
                  _playPauseButton(),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
            SlidingUpPanel(
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
            )
          ],
        ),
      ),
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

        _player.setPitch(
          (_pitches[_progress.inSeconds][1] + _playerPitch + 23) * 0.0416666667,
        );

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
                    _isPanelOpen
                        ? "assets/images/DownArrow.svg"
                        : "assets/images/UpArrow.svg",
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
                      alignment: _isSpeedExpanded
                          ? Alignment.centerLeft
                          : Alignment.center,
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
                        label: _playerSpeed == 0
                            ? "0.01"
                            : _playerSpeed.toStringAsPrecision(2),
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
                      alignment: _isPitchExpanded
                          ? Alignment.centerLeft
                          : Alignment.center,
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
                              _isPitchExpanded = !_isPitchExpanded;
                            });
                          },
                          child: const Text(
                            "Pitch",
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
                  if (_isPitchExpanded)
                    Expanded(
                      flex: 2,
                      child: Slider(
                        min: -12,
                        max: 12,
                        divisions: 24,
                        thumbColor: Theme.of(context).primaryColor,
                        activeColor: Theme.of(context).primaryColor,
                        inactiveColor: Theme.of(context).colorScheme.secondary,
                        label: (_playerPitch).round().toString(),
                        value: _playerPitch,
                        onChanged: (double newPitch) {
                          setState(() {
                            _playerPitch = newPitch;
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
                      alignment: _isEqualizerExpanded
                          ? Alignment.centerLeft
                          : Alignment.center,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutBack,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                          ),
                          onPressed: () {
                            int _heightDifference = 235;
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
              if (_isEqualizerExpanded) _equalizer(),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AnimatedAlign(
                      alignment: _isFunctionsExpanded
                          ? Alignment.centerLeft
                          : Alignment.center,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutBack,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                          ),
                          onPressed: () {
                            int _heightDifference = 130;
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
                  if (_isFunctionsExpanded)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _functionButton("Reset", () {
                        for (int i = 0; i < _pitches.length; i++) {
                          _pitches[i][1] = 1;
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              if (_isFunctionsExpanded)
                Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _functionButton("Sine", () {
                          for (int i = 0; i < _pitches.length; i++) {
                            double _amplitude = 0.4;
                            double _wavelength = 1;
                            double _sine =
                                _amplitude * sin(i / (2 * pi * _wavelength));
                            _pitches[i][1] = _sine + 1;
                          }
                        }),
                        const SizedBox(width: 30),
                        _functionButton("Cosine", () {
                          for (int i = 0; i < _pitches.length; i++) {
                            double _amplitude = 0.4;
                            double _wavelength = 1;
                            double _cosine =
                                _amplitude * cos(i / (2 * pi * _wavelength));
                            _pitches[i][1] = _cosine + 1;
                          }
                        }),
                        const SizedBox(width: 30),
                        _functionButton("Tangent", () {
                          for (int i = 0; i < _pitches.length; i++) {
                            double _amplitude = 0.4;
                            double _wavelength = 3;
                            double _tangent =
                                _amplitude * tan(i / (2 * pi * _wavelength));
                            _pitches[i][1] = _tangent + 1;
                          }
                        }),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _functionButton("Sawtooth", () {}),
                        const SizedBox(width: 30),
                        _functionButton("Exponential", () {}),
                        const SizedBox(width: 30),
                        _functionButton("Step", () {}),
                      ],
                    ),
                  ],
                )
            ]
          ],
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

  Widget _equalizer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFE8E8E8),
            width: 2,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (int i = 0; i < _eqBandFreqs.length; i++)
              RotatedBox(
                quarterTurns: 3,
                child: Row(
                  children: <Widget>[
                    Transform(
                      transform: Matrix4.rotationZ(pi / 4),
                      alignment: Alignment.center,
                      origin: const Offset(5, 25),
                      child: Text(
                        (_eqBandFreqs[i] ~/ 1e3 > 1e3
                                ? ((_eqBandFreqs[i] ~/ 1e6).toString() + " k")
                                : ((_eqBandFreqs[i] ~/ 1e3).toString() + " ")) +
                            "Hz",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 15,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8.48,
                          elevation: 0,
                        ),
                      ),
                      child: Slider(
                        min: _eqBandLevelMin.toDouble(),
                        max: _eqBandLevelMax.toDouble(),
                        divisions: _eqBandLevelMax - _eqBandLevelMin,
                        thumbColor: Theme.of(context).primaryColor,
                        activeColor: Theme.of(context).primaryColor,
                        inactiveColor: Theme.of(context).colorScheme.secondary,
                        label: _eqBandLevels[i].toString(),
                        value: _eqBandLevels[i].toDouble(),
                        onChanged: (double newLevel) {
                          Equalizer.setBandLevel(i, newLevel.round());
                          _eqBandLevels[i] = newLevel.round();
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _functionButton(String _buttonText, void Function() _buttonPressedFn) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 1,
        padding: const EdgeInsets.all(10),
      ),
      onPressed: _buttonPressedFn,
      child: Text(
        _buttonText,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 1.25,
          color: Colors.white,
        ),
      ),
    );
  }
}
