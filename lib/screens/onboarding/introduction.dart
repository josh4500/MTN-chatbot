import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mtn_chatbot/screens/signup/signup.dart';

import '../../widget/round_button.dart';

class Introduction extends StatelessWidget {
  const Introduction({super.key, required this.gotoAbout});
  final VoidCallback gotoAbout;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    child: Image.asset('assets/rsz_mtn_logo.png'),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'It is easy to talk to a bot than call a real person.',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFEF7),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Yello Friend',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFEAA9),
                    ),
                  ),
                  SizedBox(height: 25),
                  Text(
                    'A chatbot project created to facilitate help on common services.',
                    style: TextStyle(
                      color: Color(0xFF8D8C7C),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Center(
                child: Column(
                  children: [
                    RoundButton(
                      text: 'Get Started',
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (ctx) => const SignUp()),
                        );
                      },
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: gotoAbout,
                      child: const Text(
                        'About project',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
