import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project/views/title_widget.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to HomeScreen after 3 seconds, but check if the widget is still mounted
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFF06292)], // Orange to Pink
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title Widget
              const TitleWidget(key: Key('titleWidget')),
              const SizedBox(height: 20),
              // Subtitle
              const Text(
                "Gifting made easy!",
                key: Key('subtitle'),
                style: TextStyle(
                  fontFamily: 'arima',
                  fontSize: 20.0,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 30),
              // Animated Loading Indicator
              const SpinKitFadingCircle(
                key: Key('loadingIndicator'),
                color: Colors.white,
                size: 60.0,
              ),
              const SizedBox(height: 30),
              // Loading Progress
              TweenAnimationBuilder<double>(
                key: Key('loadingProgress'),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 3),
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.pink[200],
                  minHeight: 6.0,
                ),
              ),
              const SizedBox(height: 20),
              // Loading Text
              const Text(
                'Loading, please wait...',
                key: Key('loadingText'),
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              // Tip Section
              Card(
                key: Key('tipCard'),
                color: Colors.white70,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: const [
                      Text(
                        "Tip of the Day",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Surprise someone special with a thoughtful gift today!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.pinkAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
