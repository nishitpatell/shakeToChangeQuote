import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../utils/shake_detector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late ShakeDetector _shakeDetector;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Set up animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Initial animation to show the first quote
    _animationController.forward();

    // Set up shake detector
    _shakeDetector = ShakeDetector(
      onShake: _changeQuote,
    );
    _shakeDetector.startListening();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _changeQuote() {
    _animationController.reset();
    setState(() {
      _currentIndex = (_currentIndex + 1) % quotes.length;
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Shake for Quotes'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        quotes[_currentIndex].text,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "- ${quotes[_currentIndex].author}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
                Column(
                  children: [
                    const Icon(
                      Icons.vibration,
                      size: 48,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Shake your device for a new quote",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
