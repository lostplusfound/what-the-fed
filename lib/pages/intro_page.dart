import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  final title = 'What the Fed?';
  final body =
      '''Ever wondered what the f(ed) the U.S. government is actually doing?
Look no further: What The Fed? makes it easy to follow what’s happening in Congress.
This is the MVP version of our app, a first look at how AI can make government processes easier to understand for everyone.

On the Congress page, you can:
• Track daily activity: We pull the official Congressional Record and use AI to summarize the day’s key highlights.
• Understand legislation: Search bills by type (H.R., S., etc.) and number to get clear, plain-English summaries powered by AI.
• Explore Members: Learn about your representatives and the bills they sponsor.

On the My Members page, you can:
• Look up your representatives by address and see their recent activity in Congress.

All AI chats support follow-up questions — so you can keep asking, exploring, and understanding until everything makes sense.''';
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/congress.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Semi-opaque overlay to improve text readability
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.35),
                    Color.fromRGBO(0, 0, 0, 0.35),
                  ],
                ),
              ),
            ),
          ),

          // Content — make scrollable on small screens while remaining centered on tall screens
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // Ensure the ConstrainedBox is at least the height of the viewport
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.vertical,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: (textTheme.headlineLarge ??
                                  const TextStyle(
                                      fontSize: 36, fontWeight: FontWeight.bold))
                              .copyWith(
                                  color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          body,
                          textAlign: TextAlign.center,
                          style: (textTheme.bodyLarge ??
                                  const TextStyle(fontSize: 18))
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
