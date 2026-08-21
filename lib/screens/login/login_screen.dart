import 'package:flutter/material.dart';
import '../ai_home/ai_home_screen.dart';
import '../../services/auth_service.dart';
import '../../models/zed/zed_api_exception.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Visual constants for easy adjustment
  static const Color gradientStart = Color(0xFFFFFDFC);
  static const Color gradientEnd = Color(0xFFFFB36F);
  static const double cornerRadius = 40.0;
  static const Color logoColor = Color(0xFFFF8C42);
  static const double iconSize = 60.0;
  static const double fontSize = 48.0;
  static const double spacing = 12.0;
  static const Color inputBackgroundColor = Color(0xFFF5F5F5);
  static const Color inputPlaceholderColor = Color(0xFF888888);
  static const Color buttonColor = Color(0xFFFF8C42);
  static const double inputHeight = 56.0;
  static const double buttonHeight = 56.0;
  static const double inputBorderRadius = 16.0;
  static const double horizontalPadding = 32.0;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthServiceImpl();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authService.dispose();
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildLogo(),
                const SizedBox(height: 32),
                _buildHeading(),
                const SizedBox(height: 40),
                _buildEmailInput(),
                const SizedBox(height: 16),
                _buildPasswordInput(),
                const SizedBox(height: 24),
                _buildLoginButton(),
                const Spacer(flex: 3),
              ],
            ),
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
      'asstes/zedai.png',
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

  Widget _buildHeading() {
    return const Text(
      'Login to an Account',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailInput() {
    return Container(
      height: inputHeight,
      decoration: BoxDecoration(
        color: inputBackgroundColor,
        borderRadius: BorderRadius.circular(inputBorderRadius),
      ),
      child: TextField(
        controller: _emailController,
        decoration: InputDecoration(
          hintText: 'Enter Email',
          hintStyle: const TextStyle(
            color: inputPlaceholderColor,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Container(
      height: inputHeight,
      decoration: BoxDecoration(
        color: inputBackgroundColor,
        borderRadius: BorderRadius.circular(inputBorderRadius),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Enter Password',
          hintStyle: const TextStyle(
            color: inputPlaceholderColor,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(inputBorderRadius),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Login your School',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.login(
        email: email,
        password: password,
      );

      // Navigate to AI Home screen on successful login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AiHomeScreen()),
        );
      }
    } on ZedApiException catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }
}
