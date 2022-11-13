import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mtn_chatbot/provider/chat_provider.dart';
import 'package:mtn_chatbot/screens/onboarding/about.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sound_stream/sound_stream.dart';

import '../../widget/chat/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final RecorderStream _recorder = RecorderStream();
  StreamSubscription? _recorderStatus;
  StreamSubscription<List<int>>? _audioStreamSubscription;
  BehaviorSubject<List<int>>? _audioStream;

  final ValueNotifier<bool> _isRecording = ValueNotifier(false);

  final _scrollController = ScrollController();
  bool get textNotEmpty => _messageController.text.isNotEmpty;
  String get message => _messageController.text.trim();

  @override
  void initState() {
    super.initState();
    initPlugin();
  }

  @override
  void dispose() {
    _recorderStatus?.cancel();
    _audioStreamSubscription?.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlugin() async {
    _recorderStatus = _recorder.status.listen((status) {
      if (mounted) {
        _isRecording.value = status == SoundStreamStatus.Playing;
      }
    });

    await Future.wait([_recorder.initialize()]);

    // TODO Get a Service account
  }

  void stopStream() async {
    await _recorder.stop();
    await _audioStreamSubscription?.cancel();
    await _audioStream?.close();
  }

  void handleStream() async {
    _recorder.start();

    _audioStream = BehaviorSubject<List<int>>();
    _audioStreamSubscription = _recorder.audioStream.listen((data) {
      print(data);
      _audioStream?.add(data);
    });

    // TODO Get the transcript and detectedIntent and show on screen
  }

  void _handleSubmitted() {
    if (textNotEmpty) {
      context.read<ChatProvider>().sendMessage(message);
      _messageController.clear();
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
      //TODO Dialogflow Code
    }
  }

  final ValueNotifier<bool> _openMenu = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B02),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 77,
                child: Row(
                  children: [
                    InkWell(
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                      ),
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 15),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: 32,
                        height: 32,
                        color: const Color(0xFFFFCB01),
                        child: Image.asset('assets/rsz_mtn_logo.png'),
                      ),
                    ),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Text(
                        'MTN Zigi clone',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _openMenu.value = !_openMenu.value;
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _openMenu,
                        builder: (context, value, _) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: !value
                                ? const Icon(
                                    CupertinoIcons.ellipsis_vertical_circle,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : const Icon(
                                    CupertinoIcons.arrow_right_circle,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                          );
                        },
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _openMenu,
                      builder: (context, value, _) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeIn,
                            width: value ? 150 : 0.0,
                            height: 35,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: ListView(
                              padding: const EdgeInsets.all(3),
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              children: [
                                OptionWidget(
                                  text: 'About Project',
                                  color: Colors.teal,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (ctx) => AboutScreen(
                                          quit: () => Navigator.pop(context),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                OptionWidget(
                                  text: 'About Project',
                                  color: Colors.blueGrey,
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Material(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Expanded(
                        child: Consumer<ChatProvider>(
                          builder: (context, state, _) {
                            return Stack(
                              children: [
                                ListView.builder(
                                  reverse: true,
                                  controller: _scrollController,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    var next = false;
                                    final message = state.messages[index];
                                    // if (index + 1 < state.msgCount) {
                                    //   final nextMessage =
                                    //       state.messages[index + 1];
                                    //   next = (nextMessage.isMe && message.isMe);
                                    // } else {
                                    //   next = false;
                                    // }
                                    // if (index == 0) next = message.isMe;

                                    return MessageBubble(
                                      message: message,
                                      next: next,
                                    );
                                  },
                                  itemCount: state.msgCount,
                                ),
                                // ClipRRect(
                                //   borderRadius: const BorderRadius.only(
                                //     topLeft: Radius.circular(60),
                                //     topRight: Radius.circular(60),
                                //   ),
                                //   child: Container(
                                //     height: 20,
                                //     decoration: const BoxDecoration(
                                //       gradient: LinearGradient(
                                //         colors: [
                                //           Colors.black26,
                                //           Colors.transparent,
                                //         ],
                                //         begin: Alignment.topCenter,
                                //         end: Alignment.bottomCenter,
                                //       ),
                                //     ),
                                //   ),
                                // )
                              ],
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 8,
                          top: 4,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GestureDetector(
                                child: Container(
                                  height: 40,
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(bottom: 3),
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFECB5FF),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.mic_fill,
                                    color: Color(0xFF8A3891),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: TextField(
                                  cursorColor: Colors.black,
                                  controller: _messageController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Message',
                                    hintStyle: TextStyle(fontSize: 16.5),
                                  ),
                                  style: const TextStyle(fontSize: 16.5),
                                  minLines: 1,
                                  maxLines: 5,
                                ),
                              ),
                              const SizedBox(width: 9),
                              GestureDetector(
                                onTap: _handleSubmitted,
                                child: Container(
                                  height: 40,
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(bottom: 3),
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFDFDEF9),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.paperplane_fill,
                                    color: Color(0xFF3F428B),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OptionWidget extends StatelessWidget {
  const OptionWidget(
      {Key? key, required this.text, required this.color, this.onTap})
      : super(key: key);
  final String text;
  final Color color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
