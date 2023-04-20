import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:volume_controller/volume_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _deviceVolume = 0;
  static const platform = MethodChannel('niza.volume_controller');

  @override
  void initState() {
    super.initState();
    VolumeController().showSystemUI = false;
    VolumeController().listener((volume) {
      setState(() {
        _deviceVolume = volume;
      });
    });
  }

  @override
  void dispose() {
    VolumeController().removeListener();
    super.dispose();
  }

  Future<int> convert(int dp) async {
    try {
      final int result = await platform.invokeMethod('getPx', {"dp": dp});
      return result;
    } on PlatformException catch (_) {
      return dp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Volume Controller',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/volume-up.png',
                      height: 35,
                      width: 37,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (_deviceVolume * 100).ceil().toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 8,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _deviceVolume,
                    activeColor: Colors.blue,
                    inactiveColor: const Color(0xffD9D9D9),
                    min: 0,
                    max: 1,
                    onChanged: (val) {
                      VolumeController().setVolume(val);
                    },
                  ),
                ),
                const SizedBox(height: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        bool? status =
                            await FlutterOverlayWindow.isPermissionGranted();

                        if (!status) {
                          status =
                              await FlutterOverlayWindow.requestPermission();
                        }

                        if (status == null || !status) return;

                        if (await FlutterOverlayWindow.isActive()) return;

                        await FlutterOverlayWindow.showOverlay(
                          enableDrag: true,
                          flag: OverlayFlag.defaultFlag,
                          alignment: OverlayAlignment.centerLeft,
                          visibility: NotificationVisibility.visibilityPrivate,
                          positionGravity: PositionGravity.auto,
                          overlayTitle: 'Volume control',
                          height: await convert(60),
                          width: await convert(70),
                        );
                      },
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Show Overlay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        FlutterOverlayWindow.closeOverlay();
                      },
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Remove Overlay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
