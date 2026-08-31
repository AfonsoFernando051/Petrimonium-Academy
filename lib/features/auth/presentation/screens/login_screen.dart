import 'package:flutter/material.dart';
import '../widgets/login_background.dart';
import '../widgets/login_card.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          LoginBackground(),
          LoginCard(),
        ],
      ),
    );
  }
}