import 'dart:async';

import 'package:flutter/material.dart';
import '../login/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Visual constants for easy adjustment
  static const Color gradientStart = Color(0xFFFFFDFC);
  static const Color gradientEnd = Color(0xFFFFB36F);
  static const double cornerRadius = 40.0;
  static const Color logoColor = Color(0xFFFF8C42);
  static const double fontSize = 48.0;
  static const double spacing = 12.0;

  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  void _navigateToLogin() {
    _splashTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradientStart, gradientEnd],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(cornerRadius),
          child: Center(
            child: _buildLogo(),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogoIcon(),
        const SizedBox(width: spacing),
        _buildLogoText(),
      ],
    );
  }

  Widget _buildLogoIcon() {
    return Image.asset(
      'assets/zedai.png',
      width: 60,
      height: 60,
    );
  }

  Widget _buildLogoText() {
    return const Text(
      'ZED',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: logoColor,
        letterSpacing: 2,
      ),
    );
  }
}
