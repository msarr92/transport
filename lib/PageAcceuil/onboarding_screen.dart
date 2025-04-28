// screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:transport/PageAcceuil/onboarding_page.dart';
import 'package:transport/PageAcceuil/page_indicator.dart';
import 'package:transport/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = [
    const OnboardingPage(
      image: 'assets/images/20945990.jpg',
      title: '01_Onboarding',
      subtitle: '0x4t',
      description: 'Anywhere you are\nSelf inside easily with the help of\nfollowing on our choice this helps to go\nfrom waiting more.',
    ),
    const OnboardingPage(
      image: 'assets/images/3411096.jpg',
      title: '02_Onboarding',
      subtitle: '0x4t',
      description: 'At anytime\nSelf inside easily with the help of\nfollowing on our choice this helps to go\non waiting more.',
    ),
    const OnboardingPage(
      image: 'assets/images/3634312.jpg',
      title: '03_Onboarding',
      subtitle: '0x4t',
      description: 'Book your car\nSelf inside easily with the help of\nfollowing on our choice this helps to get\nan writing more.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: _pages,
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                PageIndicator(
                  currentIndex: _currentPage,
                  pageCount: _pages.length,
                  activeColor: Colors.blue,
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage == _pages.length - 1)
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          ),
                          child: const Text('Commencer',
                              style: TextStyle(color: Colors.blue, fontSize: 18)),
                        )
                      else const SizedBox(),
                      FloatingActionButton(
                        backgroundColor: Colors.blue,
                        onPressed: () => _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut),
                        child: Icon(
                            _currentPage == _pages.length - 1
                                ? Icons.check
                                : Icons.arrow_forward,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}