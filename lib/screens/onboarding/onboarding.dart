import 'package:flutter/material.dart';
import 'package:mtn_chatbot/screens/onboarding/about.dart';
import 'package:mtn_chatbot/screens/onboarding/introduction.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Introduction(
              gotoAbout: () {
                _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn);
              },
            ),
            AboutScreen(
              quit: () {
                _pageController.previousPage(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut);
              },
            )
          ],
        ),
      ),
    );
  }
}
