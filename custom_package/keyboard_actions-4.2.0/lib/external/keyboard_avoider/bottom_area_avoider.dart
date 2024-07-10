import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

final offsetProvider = StateProvider<double>((ref) => 0.0);
final offsetFocus = StateProvider<CustomFocusNode?>((ref) => null);

/// Helps [child] stay visible by resizing it to avoid the given [areaToAvoid].
///
/// Wraps the [child] in a [AnimatedContainer] that adjusts its bottom [padding] to accommodate the given area.
///
/// If [autoScroll] is true and the [child] contains a focused widget such as a [TextField],
/// automatically scrolls so that it is just visible above the keyboard, plus any additional [overscroll].
class BottomAreaAvoider extends ConsumerStatefulWidget {
  static const double defaultOverscroll = 12.0;
  static const bool defaultAutoScroll = false;
  static const Duration _defaultDuration = Duration(milliseconds: 300);
  static const Cubic _defaultCurve = Curves.easeOutCubic;

  /// The child to embed.
  ///
  /// If the [child] is not a [ScrollView], it is automatically embedded in a [SingleChildScrollView].
  /// If the [child] is a [ScrollView], it must have a [ScrollController].
  final Widget? child;

  /// Amount of bottom area to avoid. For example, the height of the currently-showing system keyboard, or
  /// any custom bottom overlays.
  //final double areaToAvoid;

  /// Whether to auto-scroll to the focused widget after the keyboard appears. Defaults to false.
  /// Could be expensive because it searches all the child objects in this widget's render tree.
  final bool autoScroll;

  /// Extra amount to scroll past the focused widget. Defaults to [defaultOverscroll].
  /// Useful in case the focused widget is inside a parent widget that you also want to be visible.
  final double overscroll;

  /// The [ScrollPhysics] of the [SingleChildScrollView] which contains child
  final ScrollPhysics? physics;
  final Duration duration;
  final Cubic curve;

  final ScrollController scrollController;

  BottomAreaAvoider({
    Key? key,
    required this.child,
    this.autoScroll = false,
    this.overscroll = defaultOverscroll,
    this.physics,
    required this.scrollController,
    this.duration = _defaultDuration,
    this.curve = _defaultCurve,
  }) : //assert(child is ScrollView ? child.controller != null : true),
        //assert(areaToAvoid >= 0, 'Cannot avoid a negative area'),
        super(key: key);

  BottomAreaAvoiderState createState() => BottomAreaAvoiderState();
}

class BottomAreaAvoiderState extends ConsumerState<BottomAreaAvoider> {
  @override
  Widget build(BuildContext context) {
    if (widget.child is SingleChildScrollView) {
      return _rewrapScrollView(widget.child as SingleChildScrollView);
    }
    if (widget.autoScroll) {
      return _wrapScrollView(widget.child);
    }
    // Just embed the [child] directly in an [AnimatedContainer].
    return widget.child!;
  }

  Widget _wrapScrollView(Widget? child) {
    return SingleChildScrollView(
      physics: widget.physics,
      controller: widget.scrollController,
      child: Column(
        children: [
          child ?? const SizedBox(),
          AnimatedSize(
            duration: widget.duration,
            curve: widget.curve,
            child: SizedBox(height: ref.watch(offsetProvider)),
          )
        ],
      ),
    );
  }

  Widget _rewrapScrollView(Widget scrollableWidget) {
    // scrollableWidgetの中身を取り出して、新しい子リストを作成
    List<Widget> children;
    if (scrollableWidget is SingleChildScrollView) {
      SingleChildScrollView scrollView = scrollableWidget;
      if (scrollView.child is Column) {
        Column column = scrollView.child as Column;
        children = List.from(column.children);
        children.add(SizedBox(height: ref.watch(offsetProvider)));
        return _wrapScrollView(
          SingleChildScrollView(
            physics: widget.physics,
            controller: widget.scrollController,
            child: Column(children: children),
          ),
        );
      }
    }
    return scrollableWidget;
  }
}
