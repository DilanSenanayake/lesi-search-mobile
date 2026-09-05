import 'package:flutter/material.dart';

import '../widgets/common.dart';
import '../widgets/feedback_section.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LesiPage(
      showBack: true,
      title: 'Feedback',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: const [
          FeedbackSection(),
        ],
      ),
    );
  }
}
