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
    hideVolumeUI(true);
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
    hideVolumeUI(false);
    super.dispose();
  }

  void hideVolumeUI(bool value) async {
    await platform
        .invokeMethod("chaneListenToVolume", {"listenToVolume": value});
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
    ThemeData themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: themeData.primaryColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: themeData.primaryColor,
        shadowColor: themeData.textTheme.bodyLarge!.color,
        automaticallyImplyLeading: false,
        title: Text(
          'Volume Controller',
          style: themeData.textTheme.bodyLarge,
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
                      color: themeData.textTheme.bodyLarge!.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (_deviceVolume * 100).ceil().toString(),
                      style:
                          themeData.textTheme.bodyLarge!.copyWith(fontSize: 24),
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
                    activeColor: const Color(0xff007AFF),
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
                          overlayTitle: 'Volume Control',
                          overlayContent: 'This app is controlling your volume',
                          height: await convert(60),
                          width: await convert(70),
                        );
                      },
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xff007AFF),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'Show Control',
                          style: TextStyle(
                            color: themeData.textTheme.bodyLarge!.color!
                                .withOpacity(0.8),
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: () {
                        FlutterOverlayWindow.closeOverlay();
                      },
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: themeData.textTheme.bodyLarge!.color!
                                .withOpacity(0.8),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'Hide Control',
                          style: themeData.textTheme.bodyLarge!.copyWith(
                            fontSize: 17,
                            color: const Color(0xff007AFF),
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
