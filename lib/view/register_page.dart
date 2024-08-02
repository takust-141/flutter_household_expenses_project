import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:household_expenses_project/view_model/category_db_provider.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/component/customed_register_keyboard.dart';

//-------入力画面------------
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  //フォームコントローラー
  final TextEditingController paymentAmountTextController =
      TextEditingController();

  //customKeyboard用
  late ValueNotifier<Category?> cateoryNotifer;
  late ValueNotifier<Category?> subCateoryNotifer;

  //FocusNode
  final CustomFocusNode amountOfMoneyNode = CustomFocusNode();
  final CustomFocusNode categoryNode = CustomFocusNode();
  final CustomFocusNode subCategoryNode = CustomFocusNode();

  @override
  void initState() {
    super.initState();
    cateoryNotifer = ValueNotifier<Category?>(null);
    subCateoryNotifer = ValueNotifier<Category?>(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final Color defaultColor = theme.colorScheme.onSurfaceVariant;
    final registerTextColor = theme.colorScheme.inverseSurface;
    ref.listen<AsyncValue<List<Category>>>(
      categorListNotifierProvider,
      (_, state) {
        state.when(
            data: (data) {
              cateoryNotifer.value = data[0];
              ref
                  .read(selectCategoryNotifierProvider.notifier)
                  .updateCategory(data[0]);
              subCateoryNotifer.value = null;
            },
            error: (error, _) => cateoryNotifer.value = null,
            loading: () => cateoryNotifer.value = null);
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
                //textAlign: TextAlign.center,
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

    RegisterKeyboardAction registerKeyboardAction = RegisterKeyboardAction(
      moneyTextController: paymentAmountTextController,
      moneyNode: amountOfMoneyNode,
      cateoryNotifer: cateoryNotifer,
      categoryNode: categoryNode,
      subCategoryNode: subCategoryNode,
      subCateoryNotifer: subCateoryNotifer,
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
                //金額
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
                //カテゴリー
                KeyboardCustomInput<Category?>(
                  focusNode: categoryNode,
                  height: registerItemHeight,
                  notifier: cateoryNotifer,
                  builder: categoryFormBulder("カテゴリー"),
                ),
                const SizedBox(height: medium),
                //サブカテゴリー
                KeyboardCustomInput<Category?>(
                  focusNode: subCategoryNode,
                  height: registerItemHeight,
                  notifier: subCateoryNotifer,
                  builder: categoryFormBulder("サブカテゴリー"),
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
                  onPressed: (null),
                  child: const Text('送信'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    paymentAmountTextController.dispose();
    super.dispose();
  }
}
