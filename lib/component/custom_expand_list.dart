import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CustomExpandList extends HookWidget {
  const CustomExpandList({
    required this.children,
    required this.childrenHeight,
    required this.title,
    required this.titleHeight,
    required this.titleWidth,
    this.padding,
    this.itemColor,
    super.key,
  });
  final List<Widget> children;
  final double childrenHeight;
  final String title;
  final double titleHeight;
  final double titleWidth;
  final EdgeInsets? padding;
  final Color? itemColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const Curve expandCurve = Curves.easeIn;
    final AnimationController expandController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    final expandAnimation =
        Tween<double>(begin: titleHeight, end: titleHeight + childrenHeight)
            .chain(CurveTween(curve: expandCurve))
            .animate(expandController);
    //アニメーションが更新された時にウィジェットを再ビルド
    useAnimation(expandAnimation);

    return SizedBox(
      height: expandAnimation.value,
      width: titleWidth,
      child: SingleChildScrollView(
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
                Material(
                    color: itemColor,
                    child: InkWell(
                      highlightColor:
                          theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      splashColor:
                          theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      onTap: () {
                        if (expandController.status.isForwardOrCompleted) {
                          expandController.reverse();
                        } else {
                          expandController.forward();
                        }
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: padding,
                        width: titleWidth,
                        height: titleHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.bodyMedium,
                            ),
                            Icon(
                              (expandController.isForwardOrCompleted)
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    )),
              ] +
              children,
        ),
      ),
    );
  }
}
