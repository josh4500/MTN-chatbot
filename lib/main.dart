import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mtn_chatbot/api/auth.dart';
import 'package:mtn_chatbot/provider/chat_provider.dart';
import 'package:mtn_chatbot/repository/base.dart';
import 'package:mtn_chatbot/screens/chat/chat_screen.dart';
import 'package:mtn_chatbot/screens/onboarding/onboarding.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  await BaseRepository.instance.ensureInitialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ChatProvider())],
      child: MaterialApp(
        title: 'MTN Chatbot By Chioma Nsikwesi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: StreamBuilder(
            stream: BotAuthtentication.authStream,
            builder: (context, sp) {
              if (sp.data != null) {
                return const ChatScreen();
              }
              return const Onboarding();
            }),
      ),
    );
  }
}
