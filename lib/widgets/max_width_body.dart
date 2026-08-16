import 'package:flutter/material.dart';

/// Centers [child] with a phone-sized max width on large screens (tablets,
/// foldables) instead of letting a single-column layout stretch edge to
/// edge — everything in this app was designed at phone width, and just
/// stretching it wider leaves cells/cards abnormally wide with a lot of
/// dead space below, rather than actually using the extra room well.
class MaxWidthBody extends StatelessWidget {
  final Widget child;
  static const double maxWidth = 480;

  const MaxWidthBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
