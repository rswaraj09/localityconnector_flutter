import 'package:flutter/material.dart';
import 'package:localityconnector/widgets/chat_bubble.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final bool showChatBubble;
  final Map<String, dynamic>? contextData;

  const AppLayout({
    super.key,
    required this.child,
    this.showChatBubble = false,
    this.contextData,
  });

  @override
  Widget build(BuildContext context) {
    if (!showChatBubble) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned(
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: ChatBubble(
              contextData: contextData,
            ),
          ),
        ),
      ],
    );
  }
}
