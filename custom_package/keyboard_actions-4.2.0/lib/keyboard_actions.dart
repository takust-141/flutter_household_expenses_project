import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/external/keyboard_avoider/bottom_area_avoider.dart';
import 'package:keyboard_actions/external/platform_check/platform_check.dart';

import 'keyboard_actions_config.dart';
import 'keyboard_actions_item.dart';

export 'keyboard_actions_config.dart';
export 'keyboard_actions_item.dart';
export 'keyboard_custom.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

const double _kBarSize = 45.0;
const Duration _timeToDismiss = Duration(milliseconds: 300);
const Duration _reverseTimeToDismiss = Duration(milliseconds: 220);
const Duration _timeToDismissBottomArea = Duration(milliseconds: 300);
const Duration _timeToDismissBar = Duration(milliseconds: 260);
const Duration _reverseTimeToDismissBar = Duration(milliseconds: 220);
const Duration _scrollAdditionalTime = Duration(milliseconds: 150);
const Cubic animationCurve = Curves.easeInOutSine;
const Cubic barAnimationCurve = Curves.easeOutSine;
const Curve defaultCurve = Curves.easeIn;

enum KeyboardActionsPlatform {
  ANDROID,
  IOS,
  ALL,
}

/// The behavior when tapped outside the keyboard.
///
/// none: no overlay is added;
///
/// opaqueDismiss: an overlay is added which blocks the underneath widgets from
/// gestures. Once tapped, the keyboard will be dismissed;
///
/// translucentDismiss: an overlay is added which permits the underneath widgets
/// to receive gestures. Once tapped, the keyboard will be dismissed;
enum TapOutsideBehavior {
  none,
  opaqueDismiss,
  translucentDismiss,
}

/// A widget that shows a bar of actions above the keyboard, to help customize input.
///
/// To use this class, add it somewhere higher up in your widget hierarchy. Then, from any child
/// widgets, add [KeyboardActionsConfig] to configure it with the [KeyboardAction]s you'd
/// like to use. These will be displayed whenever the wrapped focus nodes are selected.
///
/// This widget wraps a [KeyboardAvoider], which takes over functionality from [Scaffold]: when the
/// focus changes, this class re-sizes [child]'s focused object to still be visible, and scrolls to the
/// focused node. **As such, set [Scaffold.resizeToAvoidBottomInset] to _false_ when using this Widget.**
///
/// We manage resizing ourselves so that:
///
///   1. using scaffold is not required
///   2. content is only shrunk as needed (a problem with scaffold)
///   3. we shrink an additional [_kBarSize] so the keyboard action bar doesn't cover content either.
class KeyboardActions extends ConsumerStatefulWidget {
  /// Any content you want to resize/scroll when the keyboard comes up
  final Widget? child;

  /// Keyboard configuration
  final KeyboardActionsConfig config;

  /// If you want the content to auto-scroll when focused; see [KeyboardAvoider.autoScroll]
  final bool autoScroll;

  /// In case you don't want to enable keyboard_action bar (e.g. You are running your app on iPad)
  final bool enable;

  /// If you are using keyboard_actions inside a Dialog it must be true
  final bool isDialog;

  /// Tap outside the keyboard will dismiss this
  @Deprecated('Use tapOutsideBehavior instead.')
  final bool tapOutsideToDismiss;

  /// Tap outside behavior
  final TapOutsideBehavior tapOutsideBehavior;

  /// If you want to add overscroll. Eg: In some cases you have a [TextField] with an error text below that.
  final double overscroll;

  /// If you want to control the scroll physics of [BottomAreaAvoider] which uses a [SingleChildScrollView] to contain the child.
  final ScrollPhysics? bottomAvoiderScrollPhysics;

  /// If you are using [KeyboardActions] for just one textfield and don't need to scroll the content set this to `true`
  final bool disableScroll;

  /// Does not clear the focus if you tap on the node focused, useful for keeping the text cursor selection working. Usually used with tapOutsideBehavior as translucent
  final bool keepFocusOnTappingNode;

  const KeyboardActions(
      {super.key,
      this.child,
      this.bottomAvoiderScrollPhysics,
      this.enable = true,
      this.autoScroll = true,
      this.isDialog = false,
      @Deprecated('Use tapOutsideBehavior instead.')
      this.tapOutsideToDismiss = false,
      this.tapOutsideBehavior = TapOutsideBehavior.none,
      required this.config,
      this.overscroll = 12.0,
      this.disableScroll = false,
      this.keepFocusOnTappingNode = false})
      : assert(child != null);

  @override
  KeyboardActionstate createState() => KeyboardActionstate();
}

/// State class for [KeyboardActions].
class KeyboardActionstate extends ConsumerState<KeyboardActions>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  /// The currently configured keyboard actions
  KeyboardActionsConfig? config;

  /// private state
  Map<int, KeyboardActionsItem> _map = {};
  KeyboardActionsItem? _currentAction;
  int? _currentIndex = 0;
  OverlayEntry? _overlayEntry;
  PreferredSizeWidget? _currentFooter;
  bool _dismissAnimationNeeded = true;
  final _keyParent = GlobalKey();
  Completer<void>? _dismissAnimation;
  OverlayState? _overlayState;

  //アニメーション用パラメータ
  late AnimationController _slideKeyboardAnimationController;
  late AnimationController _slideBarAnimationController;
  late Animation<Offset> _slideKeyboardAnimation;
  late Animation<double> _slideBarAnimation;

  //スクロールパラメータ
  late ScrollController _bottomAvoidScrollController;

  /// If the keyboard bar is on for the current platform
  bool get _isAvailable {
    return config!.keyboardActionsPlatform == KeyboardActionsPlatform.ALL ||
        (config!.keyboardActionsPlatform == KeyboardActionsPlatform.IOS &&
            PlatformCheck.isIOS) ||
        (config!.keyboardActionsPlatform == KeyboardActionsPlatform.ANDROID &&
            PlatformCheck.isAndroid);
  }

  /// If we are currently showing the keyboard bar
  bool get _isShowing {
    return _overlayEntry != null;
  }

  /// The current previous index, or null.
  int? get _previousIndex {
    final nextIndex = _currentIndex! - 1;
    return nextIndex >= 0 ? nextIndex : null;
  }

  /// The current next index, or null.
  int? get _nextIndex {
    final nextIndex = _currentIndex! + 1;
    return nextIndex < _map.length ? nextIndex : null;
  }

  /// The distance from the bottom of the KeyboardActions widget to the
  /// bottom of the view port.
  ///
  /// Used to correctly calculate the offset to "avoid" with BottomAreaAvoider.
  double get _distanceBelowWidget {
    if (_keyParent.currentContext != null) {
      final widgetRenderBox =
          _keyParent.currentContext!.findRenderObject() as RenderBox;
      final fullHeight = MediaQuery.of(context).size.height;
      final widgetHeight = widgetRenderBox.size.height;
      final widgetTop = widgetRenderBox.localToGlobal(Offset.zero).dy;
      final widgetBottom = widgetTop + widgetHeight;
      final distanceBelowWidget = fullHeight - widgetBottom;
      return distanceBelowWidget;
    }
    return 0;
  }

  /// Set the config for the keyboard action bar.
  void setConfig(KeyboardActionsConfig newConfig) {
    clearConfig();
    config = newConfig;
    for (int i = 0; i < config!.actions!.length; i++) {
      _addAction(i, config!.actions![i]);
    }
    _startListeningFocus();
  }

  /// Clear any existing configuration. Unsubscribe from focus listeners.
  void clearConfig() {
    _dismissListeningFocus();
    _clearAllFocusNode();
    config = null;
  }

  void _addAction(int index, KeyboardActionsItem action) {
    _map[index] = action;
  }

  void _clearAllFocusNode() {
    _map = <int, KeyboardActionsItem>{};
  }

  void _clearFocus() {
    _currentAction?.focusNode.unfocus();
  }

  bool hasFocusFound = false;
  Future<Null> _focusNodeListener() async {
    hasFocusFound = false;
    for (var key in _map.keys) {
      final currentAction = _map[key]!;
      if (currentAction.focusNode.hasFocus) {
        hasFocusFound = true;
        _currentAction = currentAction;
        _currentIndex = key;
        continue;
      }
    }
    _focusChanged(hasFocusFound);
  }

  void _shouldGoToNextFocus(KeyboardActionsItem action, int? nextIndex) async {
    _dismissAnimationNeeded = true;

    _currentAction!.focusNode.unfocus();
    await _dismissAnimation?.future;
    action.focusNode.requestFocus();
  }

  void _onTapUp() {
    //DumpFocusTree();
    if (_previousIndex != null) {
      final currentAction = _map[_previousIndex!]!;
      if (currentAction.enabled) {
        //currentAction.focusNode.previousFocus();
        _shouldGoToNextFocus(currentAction, _previousIndex);
      } else {
        _currentIndex = _previousIndex;
        _onTapUp();
      }
    }
  }

  void _onTapDown() {
    if (_nextIndex != null) {
      final currentAction = _map[_nextIndex!]!;
      if (currentAction.enabled) {
        //currentAction.focusNode.nextFocus();
        _shouldGoToNextFocus(currentAction, _nextIndex);
      } else {
        _currentIndex = _nextIndex;
        _onTapDown();
      }
    }
  }

  /// Shows or hides the keyboard bar as needed, and re-calculates the overlay offset.
  ///
  /// Called every time the focus changes, and when the app is resumed on Android.

  Completer<void>? _softwearKeyboardOpenCompleter;

  void _focusChanged(bool showBar) async {
    if (_isAvailable) {
      if (!showBar && _isShowing) {
        _softwearKeyboardOpenCompleter = null;
        await _removeOverlay();
        _dismissAnimation?.complete();
        _dismissAnimation = null;
        CustomFocusNode.waitAnimation = null;
      } else {
        await _dismissAnimation?.future;
        if (showBar &&
            (!_isShowing ||
                (_currentFooter == null ||
                    _currentAction!.keyboardCustom == false))) {
          if (!_currentAction!.keyboardCustom) {
            _softwearKeyboardOpenCompleter = Completer<void>();
          }
          await _softwearKeyboardOpenCompleter?.future;
          _insertOverlay();
          _dismissAnimation = Completer<void>();
          CustomFocusNode.waitAnimation = _dismissAnimation;
        }
      }
    }
  }

  @override
  void didChangeMetrics() {
    if (PlatformCheck.isAndroid) {
      final value = View.of(context).viewInsets.bottom;
      bool keyboardIsOpen = value > 0;
      _onKeyboardChanged(keyboardIsOpen);
      isKeyboardOpen = keyboardIsOpen;
    }

    //ソフトウェアキーボードが開いているかどうかの判定
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    if (bottomInset > 0 &&
        _softwearKeyboardOpenCompleter != null &&
        !_softwearKeyboardOpenCompleter!.isCompleted) {
      _softwearKeyboardOpenCompleter!.complete(); // キーボードが開いたことを検知
    }
  }

  void _startListeningFocus() {
    for (var action in _map.values) {
      action.focusNode.addListener(_focusNodeListener);
    }
  }

  void _dismissListeningFocus() {
    for (var action in _map.values) {
      action.focusNode.removeListener(_focusNodeListener);
    }
  }

  bool _inserted = false;

  /// Insert the keyboard bar as an Overlay.
  ///
  /// This will be inserted above everything else in the MaterialApp, including dialog modals.
  ///
  /// Position the overlay based on the current [MediaQuery] to land above the keyboard.

  void _insertOverlay() {
    _inserted = true;
    _overlayEntry = OverlayEntry(builder: (context) {
      // Update and build footer, if any
      _currentFooter = (_currentAction!.footerBuilder != null)
          ? _currentAction!.footerBuilder!(context)
          : null;

      final queryData = MediaQuery.of(context);
      return Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          if (widget.tapOutsideBehavior != TapOutsideBehavior.none ||
              // ignore: deprecated_member_use_from_same_package
              widget.tapOutsideToDismiss)
            Positioned.fill(
              child: Listener(
                //-----オーバーレイタップ時のイベント-----
                onPointerDown: (event) {
                  if (!widget.keepFocusOnTappingNode ||
                      _currentAction!.focusNode.rect.contains(event.position) !=
                          true) {
                    _clearFocus();
                  }
                },
                behavior: widget.tapOutsideBehavior ==
                        TapOutsideBehavior.translucentDismiss
                    ? HitTestBehavior.translucent
                    : HitTestBehavior.opaque,
              ),
            ),
          if (!_currentAction!.keyboardCustom)
            SizeTransition(
              sizeFactor: _slideBarAnimation,
              axis: Axis.vertical,
              axisAlignment: -1,
              child: Material(
                color: config!.keyboardBarColor ?? Colors.grey[200],
                elevation: config!.keyboardBarElevation ?? 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (_currentAction!.displayActionBar)
                      _buildBar(_currentAction!.displayArrows),
                    if (_currentFooter != null)
                      SizedBox(
                        height: _inserted
                            ? _currentFooter!.preferredSize.height
                            : 0,
                        child: _currentFooter,
                      ),
                    SizedBox(
                      height: queryData.viewInsets.bottom,
                    ),
                  ],
                ),
              ),
            ),
          if (_currentAction!.keyboardCustom)
            SlideTransition(
              position: _slideKeyboardAnimation,
              child: Material(
                color: config!.keyboardBarColor ?? Colors.grey[200],
                elevation: config!.keyboardBarElevation ?? 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (_currentAction!.displayActionBar)
                      _buildBar(_currentAction!.displayArrows),
                    SizedBox(
                      height:
                          _inserted ? _currentFooter!.preferredSize.height : 0,
                      child: _currentFooter,
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });

    _overlayState!.insert(_overlayEntry!);

    if (_dismissAnimationNeeded) {
      if (_currentAction!.footerBuilder == null ||
          _currentAction!.keyboardCustom == false) {
        // カスタムバーの場合
        _slideBarAnimationController.forward();
      } else {
        //カスタムキーボードの場合
        _slideKeyboardAnimationController.forward();
      }
    }
  }

  /// Remove the overlay bar. Call when losing focus or being dismissed.
  Future<void> _removeOverlay({bool fromDispose = false}) async {
    if (_dismissAnimationNeeded) {
      if (mounted && !fromDispose) {
        _overlayEntry?.markNeedsBuild();
        // add a completer to indicate the completion of dismiss animation.
        if (_currentFooter == null || _currentAction!.keyboardCustom == false) {
          // カスタムバーの場合
          await _slideBarAnimationController.reverse();
        } else {
          //カスタムキーボードの場合
          await _slideKeyboardAnimationController.reverse();
        }
      }
    }
    _inserted = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _currentFooter = null;
    _dismissAnimationNeeded = true;
  }

  void _updateOffset() {
    ref.read(offsetFocus.notifier).state = _currentAction?.focusNode;
    if (!mounted) {
      return;
    }

    if (!_isShowing || !_isAvailable) {
      ref.read(offsetProvider.notifier).state = 0.0;
      scrollToObject(_bottomAvoidScrollController, _timeToDismissBottomArea,
          animationCurve);
      return;
    }

    double newOffset = _currentAction!.displayActionBar
        ? _kBarSize
        : 0; // offset for the actions bar

    final keyboardHeight = EdgeInsets.fromViewPadding(
      View.of(context).viewInsets,
      View.of(context).devicePixelRatio,
    ).bottom;

    newOffset += keyboardHeight; // + offset for the system keyboard

    if (_currentFooter != null) {
      newOffset +=
          _currentFooter!.preferredSize.height; // + offset for the footer
    }

    newOffset -= _localMargin + _distanceBelowWidget;

    if (newOffset < 0) newOffset = 0;

    // Update state if changed
    if (ref.watch(offsetProvider) != newOffset) {
      ref.read(offsetProvider.notifier).state = newOffset;
      scrollToObject(_bottomAvoidScrollController, _timeToDismissBottomArea,
          animationCurve);
    }
  }

  void _resetOffset() {
    if (!mounted) {
      return;
    }
    ref.read(offsetProvider.notifier).state = 0.0;
    return;
  }

  void scrollToObject(
      ScrollController scrollController, Duration duration, Cubic? curve) {
    final focusNode = ref.read(offsetFocus);
    final offset = ref.read(offsetProvider);
    final voidSpan = (focusNode?.size.height ?? 0) + widget.overscroll;
    if (focusNode != null) {
      final focuRenderObject = focusNode.context?.findRenderObject();
      if (focuRenderObject is RenderBox) {
        final focusOffset = focuRenderObject.localToGlobal(Offset.zero).dy;
        final screenHeight = MediaQuery.of(context).size.height;
        final keyboardOffset = screenHeight - offset;
        if (focusOffset + voidSpan > keyboardOffset) {
          double scrollOffset = focusOffset + voidSpan - keyboardOffset;
          scrollController.animateTo(
            scrollController.offset + scrollOffset,
            duration: duration,
            curve: curve ?? defaultCurve,
          );
        }
      }
    }
  }

  double _localMargin = 0.0;

  void _onLayout() {
    if (widget.isDialog) {
      final render =
          _keyParent.currentContext?.findRenderObject() as RenderBox?;
      final fullHeight = MediaQuery.of(context).size.height;
      final localHeight = render?.size.height ?? 0;
      _localMargin = (fullHeight - localHeight) / 2;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (state == AppLifecycleState.paused) {
        FocusScope.of(context).requestFocus(FocusNode());
        _focusChanged(false);
      }
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void didUpdateWidget(KeyboardActions oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    clearConfig();
    _removeOverlay(fromDispose: true);
    _dismissAnimation = null;
    _slideBarAnimationController.dispose();
    _slideKeyboardAnimationController.dispose();
    _bottomAvoidScrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    _bottomAvoidScrollController = ScrollController();
    _bottomAvoidScrollController.addListener(() {
      // スクロール位置が変更された際の処理
      //_currentAction?.focusNode.resizeRect();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //_currentAction?.focusNode.resizeRect();
    });

    _overlayState = Overlay.of(context, rootOverlay: true);
    WidgetsBinding.instance.addObserver(this);
    if (widget.enable) {
      setConfig(widget.config);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onLayout();
        _resetOffset();
      });
    }
    setAnimationController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void setAnimationController() {
    //アニメーション用パラメータ
    _slideKeyboardAnimationController = AnimationController(
      vsync: this,
      duration: _timeToDismiss,
      reverseDuration: _reverseTimeToDismiss,
    );
    _slideBarAnimationController = AnimationController(
      vsync: this,
      duration: _timeToDismissBar,
      reverseDuration: _reverseTimeToDismissBar,
    );

    _slideKeyboardAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    )
        .chain(CurveTween(curve: animationCurve))
        .animate(_slideKeyboardAnimationController);

    _slideBarAnimation = Tween<double>(
      begin: 0,
      end: 1,
    )
        .chain(CurveTween(curve: barAnimationCurve))
        .animate(_slideBarAnimationController);

    _slideKeyboardAnimationController
        .addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _updateOffset();
      }
      if (status == AnimationStatus.dismissed) {
        _resetOffset();
      }
    });
    _slideBarAnimationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(_scrollAdditionalTime, () {
          _updateOffset();
        });
      }
      if (status == AnimationStatus.dismissed) {
        _resetOffset();
      }
    });
  }

  var isKeyboardOpen = false;

  void _onKeyboardChanged(bool isVisible) {
    bool footerHasSize = _checkIfFooterHasSize();
    if (!isVisible && isKeyboardOpen && !footerHasSize) {
      _clearFocus();
    }
  }

  bool _checkIfFooterHasSize() {
    return _currentFooter != null &&
        (_currentFooter?.preferredSize.height ?? 0) > 0;
  }

  /// Build the keyboard action bar based on the current [config].
  Widget _buildBar(bool displayArrows) {
    return Container(
      height: _kBarSize,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: widget.config.keyboardSeparatorColor,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          mainAxisAlignment:
              _currentAction?.toolbarAlignment ?? MainAxisAlignment.end,
          children: [
            if (config!.nextFocus && displayArrows) ...[
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up),
                tooltip: 'Previous',
                iconSize: IconTheme.of(context).size!,
                color: IconTheme.of(context).color,
                disabledColor: Theme.of(context).disabledColor,
                onPressed: _previousIndex != null ? _onTapUp : null,
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                tooltip: 'Next',
                iconSize: IconTheme.of(context).size!,
                color: IconTheme.of(context).color,
                disabledColor: Theme.of(context).disabledColor,
                onPressed: _nextIndex != null ? _onTapDown : null,
              ),
              const Spacer(),
            ],
            if (_currentAction?.displayDoneButton != null &&
                _currentAction!.displayDoneButton &&
                (_currentAction!.toolbarButtons == null ||
                    _currentAction!.toolbarButtons!.isEmpty))
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: InkWell(
                  onTap: () {
                    if (_currentAction?.onTapAction != null) {
                      _currentAction!.onTapAction!();
                    }
                    _clearFocus();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 12.0),
                    child: config?.defaultDoneWidget ??
                        const Text(
                          "Done",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  ),
                ),
              ),
            if (_currentAction?.toolbarButtons != null)
              ..._currentAction!.toolbarButtons!
                  .map((item) => item(_currentAction!.focusNode))
          ],
        ),
      ),
    );
  }

  final GlobalKey<BottomAreaAvoiderState> bottomAreaAvoiderKey =
      GlobalKey<BottomAreaAvoiderState>();

  @override
  Widget build(BuildContext context) {
    // Return the given child wrapped in a [KeyboardAvoider].
    // We will call [_buildBar] and insert it via overlay on demand.
    // Add [_kBarSize] padding to ensure we scroll past the action bar.

    // We need to add this sized box to support embedding in IntrinsicWidth
    // areas, like AlertDialog. This is because of the LayoutBuilder KeyboardAvoider uses
    // if it has no child ScrollView.
    // If we don't, we get "LayoutBuilder does not support returning intrinsic dimensions".
    // See https://github.com/flutter/flutter/issues/18108.
    // The SizedBox can be removed when thats fixed.
    return widget.enable && !widget.disableScroll
        ? Material(
            color: Colors.transparent,
            child: SizedBox(
              width: double.maxFinite,
              key: _keyParent,
              child: BottomAreaAvoider(
                duration: _timeToDismissBottomArea,
                curve: animationCurve,
                key: bottomAreaAvoiderKey,
                overscroll: widget.overscroll,
                autoScroll: widget.autoScroll,
                physics: widget.bottomAvoiderScrollPhysics,
                scrollController: _bottomAvoidScrollController,
                child: widget.child,
              ),
            ),
          )
        : widget.child!;
  }
}

//CustomFocusNode：CustomTextField(タップ反応Rectサイズ変更)、カスタムキーボードアニメーションの待機
class CustomFocusNode extends FocusNode {
  CustomFocusNode({
    super.debugLabel,
    super.onKeyEvent,
    super.skipTraversal,
    super.canRequestFocus,
    super.descendantsAreFocusable,
    super.descendantsAreTraversable,
  });

  static Completer<void>? _waitAnimation;

  static set waitAnimation(Completer<void>? value) {
    _waitAnimation = value;
  }

  @override
  void requestFocus([FocusNode? node]) async {
    if (!hasFocus) {
      await _waitAnimation?.future;
    }
    super.requestFocus(node);
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
