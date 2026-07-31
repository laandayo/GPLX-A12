import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Adds desktop-style keyboard navigation to normal Windows application pages.
/// QuestionScreen provides its own, more specific, shortcuts.
class WindowsKeyboardNavigation extends StatelessWidget {
  final Widget child;

  const WindowsKeyboardNavigation({super.key, required this.child});

  bool get _isNativeWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  @override
  Widget build(BuildContext context) {
    if (!_isNativeWindows) return child;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        final key = event.logicalKey;
        final focusScope = FocusScope.of(context);
        if (key == LogicalKeyboardKey.arrowLeft ||
            key == LogicalKeyboardKey.arrowUp ||
            key == LogicalKeyboardKey.keyA ||
            key == LogicalKeyboardKey.keyW) {
          focusScope.previousFocus();
          return KeyEventResult.handled;
        }
        if (key == LogicalKeyboardKey.arrowRight ||
            key == LogicalKeyboardKey.arrowDown ||
            key == LogicalKeyboardKey.keyD ||
            key == LogicalKeyboardKey.keyS) {
          focusScope.nextFocus();
          return KeyEventResult.handled;
        }
        if (key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter) {
          Actions.invoke(context, const ActivateIntent());
          return KeyEventResult.handled;
        }
        if (key == LogicalKeyboardKey.escape) {
          Navigator.of(context).maybePop();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: FocusTraversalGroup(child: child),
    );
  }
}
