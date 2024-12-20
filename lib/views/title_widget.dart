import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated Text
        AnimatedTextKit(
          animatedTexts: [
            ColorizeAnimatedText(
              'Hedieaty',
              textStyle: const TextStyle(
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
                fontFamily: "gvibes",
              ),
              colors: [
                Colors.white,
                Colors.amber,
                Colors.pinkAccent,
                Colors.orange,
              ],
            ),
          ],
          isRepeatingAnimation: true,
        ),
        const SizedBox(width: 10),
        // Animated Icon
        SpinKitPulse(
          color: Colors.white,
          size: 40.0,
        ),
      ],
    );
  }
}
