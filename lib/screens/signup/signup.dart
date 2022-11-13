import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mtn_chatbot/api/auth.dart';
import 'package:mtn_chatbot/screens/chat/chat_screen.dart';
import 'package:mtn_chatbot/widget/round_button.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _pageController = PageController();

  ValueNotifier<Map<String, dynamic>> authData = ValueNotifier({});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF090C01),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    color: Colors.white,
                  ),
                  const SizedBox(height: 44),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Hi!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 32.0),
                          child: Text(
                            'Signin with number to save your session.',
                            style: TextStyle(
                              color: Color(0xFFFFEAA9),
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SignUpForm(
                    nameController: _nameController,
                    phoneController: _phoneController,
                    onClickSignup: _signup,
                  ),
                  ValueListenableBuilder<Map<String, dynamic>>(
                    valueListenable: authData,
                    builder: (context, value, _) {
                      return OTPVerifyForm(
                        resendToken: value['rt'],
                        resendOTP: _resendOTP,
                        verifyOTP: _verifyOTP,
                        codeController: _codeController,
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _signup() async {
    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty) {
      final data = await BotAuthtentication.createUser(phoneNumber: phone);
      if (data['error'] == null) {
        if (data['user'] == null) {
          print('Debug 4');
          authData.value = data;
          _pageController.jumpToPage(1);
        }
      }
    }
  }

  void _resendOTP(int? resendToken) async {
    await BotAuthtentication.createUser(resendToken: resendToken);
  }

  void _verifyOTP(String code) async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      if (await BotAuthtentication.verifyCode(
          authData.value['vid'], code, name)) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (ctx) => const ChatScreen(),
          ),
        );
      }
    }
  }
}

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    Key? key,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required this.onClickSignup,
  })  : _nameController = nameController,
        _phoneController = phoneController,
        super(key: key);

  final TextEditingController _nameController;
  final TextEditingController _phoneController;
  final VoidCallback onClickSignup;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(MediaQuery.of(context).size.width * 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              'Name',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusColor: Colors.white,
                hintText: 'Chioma Nsikwesi',
                hintStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.white12,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                  // borderRadius: BorderRadius.circular(15),
                ),
              ),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
              cursorColor: const Color(0xFFFFCB01),
            ),
            const SizedBox(height: 36),
            const Text(
              'Phone number',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusColor: Colors.white,
                hintText: '+234810912335',
                hintStyle: TextStyle(
                  color: Colors.white12,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                  // borderRadius: BorderRadius.circular(15),
                ),
              ),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: const Color(0xFFFFCB01),
            ),
            const Spacer(flex: 2),
            RoundButton(
              text: 'Sign In',
              onTap: onClickSignup,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class OTPVerifyForm extends StatelessWidget {
  const OTPVerifyForm({
    Key? key,
    required int? resendToken,
    required this.resendOTP,
    required this.verifyOTP,
    required TextEditingController codeController,
  })  : _codeController = codeController,
        _resendToken = resendToken,
        super(key: key);

  final TextEditingController _codeController;
  final int? _resendToken;
  final ValueChanged<int> resendOTP;
  final ValueChanged<String> verifyOTP;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(MediaQuery.of(context).size.width * 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const SizedBox(height: 8),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusColor: Colors.white,
                hintText: 'Code',
                hintStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.white12,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                  // borderRadius: BorderRadius.circular(15),
                ),
              ),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
              cursorColor: const Color(0xFFFFCB01),
            ),
            const SizedBox(height: 36),
            if (_resendToken != null)
              FutureBuilder(
                future: Future.delayed(const Duration(seconds: 30)),
                builder: (context, sp) {
                  return GestureDetector(
                    onTap: () {
                      resendOTP(_resendToken!);
                    },
                    child: const Text(
                      'Resend Code',
                      style: TextStyle(color: Colors.blue),
                    ),
                  );
                },
              ),
            const Spacer(flex: 2),
            RoundButton(
              text: 'Verify OTP',
              onTap: () {
                if (_codeController.text.isNotEmpty) {
                  verifyOTP(_codeController.text);
                }
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
