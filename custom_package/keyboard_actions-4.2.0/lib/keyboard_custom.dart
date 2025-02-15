import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Signature for a function that creates a widget for a given value
typedef WidgetKeyboardBuilder<T> = Widget Function(
    BuildContext context, T value, bool? hasFocus);

class KeyboardCustomInput<T> extends HookWidget {
  final WidgetKeyboardBuilder<T> builder;
  final FocusNode focusNode;
  final double? height;
  final ValueNotifier<T> notifier;

  const KeyboardCustomInput({
    super.key,
    required this.focusNode,
    required this.builder,
    required this.notifier,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final hasFocus = useState(focusNode.hasFocus);
    return Focus(
        focusNode: focusNode,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!focusNode.hasFocus) {
              focusNode.requestFocus();
            }
          },
          child: SizedBox(
            height: height,
            width: double.maxFinite,
            child: ValueListenableBuilder(
              valueListenable: notifier,
              builder: (context, value, child) {
                return builder(context, notifier.value, hasFocus.value);
              },
            ),
          ),
        ),
        onFocusChange: (newValue) => {hasFocus.value = newValue});
  }
}

/// A mixin which help to update the notifier, you must mix this class in case you want to create your own keyboard
mixin KeyboardCustomPanelMixin<T> {
  ///We'll use this notifier to send the data and refresh the widget inside [KeyboardCustomInput]
  ValueNotifier<T> get notifier;

  ///This method will update the notifier
  void updateValue(T value) {
    notifier.value = value;
  }
}
