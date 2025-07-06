import 'package:dirgebeya/Pages/DashboardHome.dart';
import 'package:dirgebeya/Provider/login_provider.dart';
import 'package:dirgebeya/config/color.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(
  
  ); // Using a dummy text

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString('saved_phone');
    final savedPassword = prefs.getString('saved_password');
    final remember = prefs.getBool('remember_me') ?? false;

    if (remember) {
      setState(() {
        _rememberMe = true;
        _emailController.text = savedPhone ?? '';
        _passwordController.text = savedPassword ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Provider.of<LoginProvider>(context,listen :false).logout();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _buildLogo(),
                const SizedBox(height: 16),
                _buildAppName(theme),
                const SizedBox(height: 48),
                _buildLoginForm(theme),
                // const SizedBox(height: 24),
                // _buildFooterLinks(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the custom hexagonal logo
  Widget _buildLogo() {
    return ClipPath(
      clipper: HexagonClipper(),
      child: Container(
        width: 80,
        height: 90,

        child: Padding(
          padding: const EdgeInsets.all(8.0), // Optional padding
          child: Image.asset(
            'assets/image/logo.png', // Replace with your actual path
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  /// Builds the "Vendor APP" title with different styles
  Widget _buildAppName(ThemeData theme) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: '',
        ),
        children: [
          const TextSpan(
            text: 'ባለመሪው ነጋዴ',
            style: TextStyle(color: Color(0xFF333333)),
          ),
          TextSpan(
            text: '',
            style: TextStyle(color: theme.primaryColor),
          ),
        ],
      ),
    );
  }

  /// Builds the entire login form section
  Widget _buildLoginForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Log In',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xa61e49),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage your business from app',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        // Email Text Field
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration(prefixIcon: Icons.phone_android),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
        // Password Text Field
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: _inputDecoration(
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Remember Me & Forgot Password Row
        const SizedBox(height: 24),
        // Log In Button
        Consumer<LoginProvider>(
          builder: (context, loginProvider, child) {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loginProvider.isLoading
                    ? null
                    : () async {
                        await loginProvider.login(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );

                        if (loginProvider.token != null) {
                          if (!mounted) return;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const DashboardScreen(),
                            ),
                          );
                        } else {
                          Provider.of<LoginProvider>(context,listen :false).logout();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                loginProvider.error ?? "Login failed",
                              ),
                              backgroundColor: const Color.fromRGBO(
                                76,
                                175,
                                80,
                                1,
                              ),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA61E49),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFFA61E49).withOpacity(0.4),
                ),
                child: loginProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Helper method for consistent TextFormField styling
  InputDecoration _inputDecoration({
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 8, right: 12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(prefixIcon, color:AppColors.primary),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1.5,
        ),
      ),
    );
  }
}

/// A custom clipper to create the hexagonal shape for the logo.
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, 0); // Top center
    path.lineTo(size.width, size.height * 0.25); // Top right
    path.lineTo(size.width, size.height * 0.75); // Bottom right
    path.lineTo(size.width * 0.5, size.height); // Bottom center
    path.lineTo(0, size.height * 0.75); // Bottom left
    path.lineTo(0, size.height * 0.25); // Top left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
