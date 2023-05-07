import 'package:bha_app_driver/profile/profile_screen.dart';
import 'package:bha_app_driver/register/view/register_screen.dart';
import 'package:bha_app_driver/splash/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'dashboard/dash_board_screen.dart';
import 'login/view/login_screen.dart';
import 'otp/view/otp_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/splash': (BuildContext context) => const SplashScreen(),
        '/login': (BuildContext context) => LoginScreen(),
        '/register': (BuildContext context) => const RegisterScreen(),
        '/otp': (BuildContext context) => OtpScreen(
              verificationId: '',
            ),
        '/dash': (BuildContext context) => const DashBoardScreen(),
        '/profile': (BuildContext context) => const ProfileScreen(),
      },
    );
  }
}
