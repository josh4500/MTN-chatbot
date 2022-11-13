import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class BotAuthtentication {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static Stream<User?> authStream = auth.authStateChanges();

  static void initialize() async {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }

  ///returns example {'vid': "foo", 'rt': 123456 }
  static Future<Map<String, dynamic>> createUser(
      {String? phoneNumber, int? resendToken}) async {
    Map<String, dynamic> verificationData = {};
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          await auth.signInWithCredential(credential);
          verificationData = {'user': true};
        },
        verificationFailed: (exception) {
          verificationData['error'] = 'Failed Verification';
        },
        forceResendingToken: resendToken,
        timeout: const Duration(seconds: 30),
        codeSent: (vid, resendToken) {
          verificationData['vid'] = vid;
          verificationData['rt'] = resendToken;
        },
        codeAutoRetrievalTimeout: (verificationId) {
          verificationData['error'] = 'Timeout';
        },
      );
    } catch (e) {
      verificationData['error'] = 'Phone verification disabled.';
    }
    return verificationData;
  }

  static Future<bool> verifyCode(
      String verificationId, String smsCode, String name) async {
    try {
      final cred = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      final userCred = await auth.signInWithCredential(cred);
      await userCred.user?.updateDisplayName(name);
      return userCred.user != null;
    } catch (e) {
      return false;
    }
  }
}
