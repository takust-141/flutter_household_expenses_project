import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/constant/dimension.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:household_expenses_project/view_model/category_db_provider.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/component/customed_register_keyboard.dart';

//-------入力画面------------
class RegisterPage extends ConsumerStatefulWidget {
  final RouteObserver<PageRoute> routeObserver;
  const RegisterPage({super.key, required this.routeObserver});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> with RouteAware {
  //フォームコントローラー
  final TextEditingController paymentAmountTextController =
      TextEditingController();
  final TextEditingController memoTextController = TextEditingController();

  //customKeyboard用
  late ValueNotifier<Category?> cateoryNotifier;
  late ValueNotifier<Category?> subCateoryNotifier;
  late ValueNotifier<DateTime> dateNotifier;

  //FocusNode
  final CustomFocusNode amountOfMoneyNode = CustomFocusNode();
  final CustomFocusNode categoryNode = CustomFocusNode();
  final CustomFocusNode subCategoryNode = CustomFocusNode();
  final CustomFocusNode memoNode = CustomFocusNode();
  final CustomFocusNode dateNode = CustomFocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void initState() {
    super.initState();
    cateoryNotifier = ValueNotifier<Category?>(null);
    subCateoryNotifier = ValueNotifier<Category?>(null);
    dateNotifier = ValueNotifier<DateTime>(DateTime.now());
  }

  @override
  void dispose() {
    paymentAmountTextController.dispose();
    widget.routeObserver.unsubscribe(this);
    super.dispose();
  }

  //カテゴリー新規登録からpopした時に呼ばれる
  @override
  void didPopNext() {
    initCategoryKeyboardNotifier(
        ref.read(categoryListNotifierProvider).value?[0]);
  }

  void initCategoryKeyboardNotifier(Category? initCategoryData) {
    cateoryNotifier.value = initCategoryData;
    subCateoryNotifier.value = null;
    primaryFocus?.unfocus();
    Future.delayed(const Duration(seconds: 1), () {
      ref.read(selectCategoryNotifierProvider.notifier).updateCategory(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final Color defaultColor = theme.colorScheme.onSurfaceVariant;
    final registerTextColor = theme.colorScheme.inverseSurface;
    ref.listen<AsyncValue<List<Category>>>(
      categoryListNotifierProvider,
      (_, state) {
        state.when(
            data: (data) {
              initCategoryKeyboardNotifier(data[0]);
            },
            error: (error, _) => cateoryNotifier.value = null,
            loading: () => cateoryNotifier.value = null);
      },
    );

    //カテゴリーフォームビルダー
    Widget Function(BuildContext, Category?, bool?) categoryFormBulder(
        String title) {
      return (context, val, hasFocus) {
        return Row(
          children: [
            SizedBox(
              width: registerItemTitleWidth,
              child: Text(
                title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: registerTextColor),
              ),
            ),
            const SizedBox(width: small),
            Expanded(
              child: Container(
                height: registerItemHeight,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: formInputBoarderRadius,
                  border: hasFocus ?? false
                      ? Border.all(
                          color: theme.colorScheme.primary,
                          width: formInputBoarderWidth)
                      : Border.all(
                          color: Colors.transparent,
                          width: formInputBoarderWidth),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: smedium),
                    Icon(
                      val?.icon,
                      color: val?.color ?? defaultColor,
                      size: 25,
                      weight: 500,
                    ),
                    const SizedBox(width: medium),
                    Expanded(
                      child: Text(
                        val?.name ?? "",
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(width: small),
                  ],
                ),
              ),
            ),
          ],
        );
      };
    }

    //フォームアイテム
    Widget registerFormItem(String title, Widget formWidget) {
      return Row(
        children: [
          SizedBox(
            width: registerItemTitleWidth,
            child: Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: registerTextColor),
            ),
          ),
          const SizedBox(width: small),
          Expanded(
            child: Container(
              transformAlignment: Alignment.center,
              height: registerItemHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: formInputBoarderRadius,
                /*border: hasFocus ?? false
                    ? Border.all(
                        color: theme.colorScheme.primary,
                        width: formInputBoarderWidth)
                    : Border.all(
                        color: Colors.transparent,
                        width: formInputBoarderWidth),*/
              ),
              child: formWidget,
            ),
          ),
        ],
      );
    }

    RegisterKeyboardAction registerKeyboardAction = RegisterKeyboardAction(
      moneyTextController: paymentAmountTextController,
      moneyNode: amountOfMoneyNode,
      cateoryNotifier: cateoryNotifier,
      categoryNode: categoryNode,
      subCategoryNode: subCategoryNode,
      subCateoryNotifier: subCateoryNotifier,
      memoTextController: memoTextController,
      memoNode: memoNode,
      dateNode: dateNode,
      dateNotifier: dateNotifier,
    );

    return KeyboardActions(
      keepFocusOnTappingNode: true,
      autoScroll: true,
      overscroll: 40,
      tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
      config: registerKeyboardAction.buildConfig(context),
      child: Padding(
        padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
        child: Padding(
          padding: viewEdgeInsets,
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //-----金額-----
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        focusNode: amountOfMoneyNode,
                        controller: paymentAmountTextController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: '金額',
                          suffixIcon: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                0, sssmall, ssmall, sssmall),
                            child: IconButton(
                              onPressed: () =>
                                  paymentAmountTextController.clear(),
                              icon: const Icon(Icons.cancel),
                              iconSize: 20,
                            ),
                          ),
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(20),
                          FilteringTextInputFormatter.allow(
                            RegExp(
                                "[0-9.${MathSymbol.sum.value}${MathSymbol.diff.value}${MathSymbol.multiplication.value}${MathSymbol.division.value}]"),
                          ),
                        ],
                        style:
                            const TextStyle(fontSize: 20, letterSpacing: 1.5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: medium),
                      child: Text(currencyUnit,
                          style: TextStyle(
                              fontSize: 25, color: registerTextColor)),
                    ),
                  ],
                ),
                const SizedBox(height: large),
                //-----カテゴリー-----
                KeyboardCustomInput<Category?>(
                  focusNode: categoryNode,
                  height: registerItemHeight,
                  notifier: cateoryNotifier,
                  builder: categoryFormBulder("カテゴリー"),
                ),
                const SizedBox(height: medium),
                //-----サブカテゴリー-----
                KeyboardCustomInput<Category?>(
                  focusNode: subCategoryNode,
                  height: registerItemHeight,
                  notifier: subCateoryNotifier,
                  builder: categoryFormBulder("サブカテゴリー"),
                ),
                const SizedBox(height: medium),
                //-----メモ-----
                registerFormItem(
                    "メモ",
                    TextField(
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      controller: memoTextController,
                      focusNode: memoNode,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: formInputBoarderRadius,
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: formInputBoarderWidth,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: formInputBoarderRadius,
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: formInputBoarderWidth,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: formInputBoarderRadius,
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: formInputBoarderWidth,
                          ),
                        ),
                      ),
                    )),
                const SizedBox(height: medium),
                //日付
                KeyboardCustomInput<DateTime>(
                  focusNode: dateNode,
                  height: registerItemHeight,
                  notifier: dateNotifier,
                  builder: (context, val, hasFocus) {
                    return Row(
                      children: [
                        SizedBox(
                          width: registerItemTitleWidth,
                          child: Text(
                            "日付",
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: registerTextColor),
                          ),
                        ),
                        const SizedBox(width: small),
                        Expanded(
                          child: Container(
                            height: registerItemHeight,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: formInputBoarderRadius,
                              border: hasFocus ?? false
                                  ? Border.all(
                                      color: theme.colorScheme.primary,
                                      width: formInputBoarderWidth)
                                  : Border.all(
                                      color: Colors.transparent,
                                      width: formInputBoarderWidth),
                            ),
                            child: Padding(
                              padding: ssmallHorizontalEdgeInsets,
                              child: Text(
                                val.toString(),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 120),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.disabled)
                          ? null
                          : theme.colorScheme.onPrimary;
                    }),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.disabled)
                          ? null
                          : theme.colorScheme.primary;
                    }),
                  ),
                  onPressed: null,
                  child: const Text('送信'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
