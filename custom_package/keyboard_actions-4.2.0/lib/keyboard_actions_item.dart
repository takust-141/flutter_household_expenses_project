import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

typedef ButtonBuilder = Widget Function(CustomFocusNode focusNode);

///Class to define the `focusNode` that you pass to your `TextField` too and other params to customize
///the bar that will appear over your keyboard
class KeyboardActionsItem {
  /// The Focus object coupled to TextField, listening for got/lost focus events
  final CustomFocusNode focusNode;

  /// Optional widgets to display to the right of the bar/
  /// NOTE: `toolbarButtons` override the Done button by default
  final List<ButtonBuilder>? toolbarButtons;

  /// true [default] to display the Done button
  final bool displayDoneButton;

  /// Optional callback if the Done button for TextField was tapped
  /// It will only work if `displayDoneButton` is [true] and `toolbarButtons` is null or empty
  final VoidCallback? onTapAction;

  /// true [default] to display the arrows to move between the fields
  final bool displayArrows;

  /// true [default] if the TextField is enabled
  final bool enabled;

  /// true [default] to display the action bar
  final bool displayActionBar;

  /// Builder for an optional widget to show below the action bar.
  ///
  /// Consider using for field validation or as a replacement for a system keyboard.
  ///
  /// This widget must be a PreferredSizeWidget to report its exact height; use [Size.fromHeight]
  final PreferredSizeWidget Function(BuildContext context)? footerBuilder;

  /// Alignment of the row that displays [toolbarButtons]. If you want to show your
  /// buttons from the left side of the toolbar, you can set [toolbarAlignment] and
  /// set the value of [displayArrows] to `false`
  final MainAxisAlignment toolbarAlignment;

  //カスタムキーボードの場合はtrue、カスタムfooterのみの場合はfalse
  final bool keyboardCustom;

  const KeyboardActionsItem({
    required this.focusNode,
    this.onTapAction,
    this.toolbarButtons,
    this.enabled = true,
    this.displayActionBar = true,
    this.displayArrows = true,
    this.displayDoneButton = true,
    this.footerBuilder,
    this.toolbarAlignment = MainAxisAlignment.end,
    this.keyboardCustom = false,
  });
}
