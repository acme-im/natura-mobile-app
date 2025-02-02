import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:natura/screens/settings.dart';
import 'package:natura/utils/conf.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class IntroScreen extends StatefulWidget {
  static const routePath = '/intro';

  const IntroScreen({super.key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.asset('assets/video/flag_eagle.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _videoPlayerController.setLooping(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _videoPlayerController.play();
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            _videoPlayerController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController),
                  )
                : Image.asset(
                    'assets/images/video-frame.jpg',
                  ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'What NaturaTest Offers',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.03,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Icon(
                            Icons.question_answer,
                            size: MediaQuery.of(context).size.height * 0.04,
                            color: Colors.green,
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Listen to the test questions and speak to answer',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height * 0.023,
                                ),
                              ),
                              Text(
                                'Voice recognition helps you practice',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height * 0.023,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Icon(
                            Icons.check_circle,
                            size: MediaQuery.of(context).size.height * 0.04,
                            color: Colors.green,
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Review test results to learn from your mistakes',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height * 0.023,
                                ),
                              ),
                              Text(
                                'Loop through 100 questions until you give right answers at all times',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height * 0.023,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Icon(
                            Icons.mic,
                            size: MediaQuery.of(context).size.height * 0.04,
                            color: Colors.green,
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hands-free practice with voice commands',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height * 0.023,
                                ),
                              ),
                              Text(
                                'Start an app and control your practice with voice only',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height * 0.023,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width * 0.4,
                      maxWidth: MediaQuery.of(context).size.width * 0.8),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      TextSpan(
                        text: "By clicking AGREE & PROCEED you confirm that you've read and agree to our ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                        ),
                      ),
                      TextSpan(
                        text: 'Privacy Policy.',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse('${appLandingUrl()}/privacy_policy.txt'));
                          },
                      ),
                    ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      Conf().showIntro = false;
                      // "arguments: true" passed into settings triggers address search
                      await Navigator.pushReplacementNamed(context, SettingsScreen.routePath,
                          arguments: IntroScreen.routePath);
                    },
                    child: const Text('AGREE & PROCEED'),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Text('v.${_packageInfo.version}+${_packageInfo.buildNumber}'),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
