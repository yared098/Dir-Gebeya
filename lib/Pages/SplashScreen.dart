import 'dart:async';

import 'package:dirgebeya/Pages/DashboardHome.dart';
import 'package:dirgebeya/Pages/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/image/spv.mp4')
      ..initialize().then((_) async {
        debugPrint("Video initialized");
        setState(() {});

        await _videoController.play();

        // Wait for 3 seconds while video plays
        Future.delayed(const Duration(seconds: 3), () async {
          // Check token and navigate accordingly
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token'); // or your actual token key

          if (token != null && token.isNotEmpty) {
            // Token exists, go to Dashboard
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          } else {
            // No token, go to Login
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        });
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: Color(0xFF895129), // classic brown hex color
      body: Center(
        child: _videoController.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
