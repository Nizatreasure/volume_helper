import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_svg/svg.dart';
import 'package:volume_controller/volume_controller.dart';

import 'main.dart';

class VolumeBubble extends StatefulWidget {
  const VolumeBubble({super.key});

  @override
  State<VolumeBubble> createState() => _VolumeBubbleState();
}

class _VolumeBubbleState extends State<VolumeBubble> {
  Timer? _hideVolumeControl;
  double _deviceVolume = 0;

  @override
  void initState() {
    VolumeController().showSystemUI = false;
    VolumeController().listener((volume) {
      setState(() {
        _deviceVolume = volume;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    VolumeController().removeListener();
    _hideVolumeControl?.cancel();
    showVolume = false;
    super.dispose();
  }

  Future<void> resize() async {
    if (showVolume) {
      await FlutterOverlayWindow.resizeOverlay(70, 250);
    } else {
      await FlutterOverlayWindow.resizeOverlay(70, 60);
    }
    setState(() {});
  }

  startTimer() {
    setState(() {
      _hideVolumeControl?.cancel();
      _hideVolumeControl = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _hideVolumeControl = null;
          showVolume = false;
          FlutterOverlayWindow.updateDrag(true);
          resize();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  showVolume = !showVolume;
                  FlutterOverlayWindow.updateDrag(!showVolume);
                  resize();
                  await Future.delayed(const Duration(milliseconds: 1));
                  if (!showVolume) {
                    _hideVolumeControl?.cancel();
                    setState(() {
                      _hideVolumeControl = null;
                    });
                  } else {
                    startTimer();
                  }
                },
                child: const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.green,
                  child: CircleAvatar(
                    radius: 23,
                    backgroundColor: Color(0xff007AFF),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage('assets/launcher-icon.png'),
                    ),
                  ),
                ),
              ),
              if (showVolume)
                Container(
                  width: 50,
                  margin: const EdgeInsets.only(top: 15),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 50,
                        thumbShape: SliderComponentShape.noThumb,
                        activeTrackColor: Colors.grey,
                        inactiveTrackColor: const Color.fromRGBO(55, 55, 55, 1),
                        overlayShape: SliderComponentShape.noOverlay,
                        trackShape: const RectangularSliderTrackShape(),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Slider(
                              value: _deviceVolume,
                              min: 0,
                              max: 1,
                              onChanged: (val) {
                                VolumeController().setVolume(val);
                              },
                              onChangeStart: (value) {
                                _hideVolumeControl?.cancel();
                                _hideVolumeControl =
                                    Timer(const Duration(days: 1), () {});
                                setState(() {});
                              },
                              onChangeEnd: (value) async {
                                await Future.delayed(
                                    const Duration(milliseconds: 500));
                                startTimer();
                              },
                            ),
                          ),
                          Positioned(
                            left: 8,
                            child: IgnorePointer(
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: SvgPicture.asset(
                                  'assets/music.svg',
                                  width: 23,
                                  height: 23,
                                  colorFilter: ColorFilter.mode(
                                    _deviceVolume >= 0.12
                                        ? Colors.black
                                        : Colors.grey,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
