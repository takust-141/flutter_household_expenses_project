import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:household_expenses_project/model/register.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:household_expenses_project/view_model/category_db_provider.dart';
import 'package:household_expenses_project/view_model/register_db_helper.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:household_expenses_project/constant/constant.dart';
import 'package:household_expenses_project/component/customed_register_keyboard.dart';

//-------入力画面------------
class RegisterPage extends StatefulHookConsumerWidget {
  final RouteObserver<PageRoute> routeObserver;
  const RegisterPage({super.key, required this.routeObserver});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> with RouteAware {
  final _formkey = GlobalKey();
  //フォームコントローラー
  final TextEditingController amountOfMoneyTextController =
      TextEditingController();
  final TextEditingController memoTextController = TextEditingController();

  //customKeyboard用
  late ValueNotifier<Category?> categoryNotifier;
  late ValueNotifier<Category?> subCategoryNotifier;
  late ValueNotifier<DateTime> dateNotifier;

  //FocusNode
  final CustomFocusNode amountOfMoneyNode = CustomFocusNode();
  final CustomFocusNode categoryNode = CustomFocusNode();
  final CustomFocusNode subCategoryNode = CustomFocusNode();
  final CustomFocusNode memoNode = CustomFocusNode();
  final CustomFocusNode dateNode = CustomFocusNode();

  final formatter = DateFormat('yyyy年 M月 d日');
  final double suffixIconSize = 20;
  final amountOfMoneyFormKey = GlobalKey();
  final memoFormKey = GlobalKey();

  late final RegisterCategoryStateNotifier registerCategoryStateProvider;

  late RegisterKeyboardAction registerKeyboardAction;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void initState() {
    super.initState();
    categoryNotifier = ValueNotifier<Category?>(null);
    subCategoryNotifier = ValueNotifier<Category?>(null);

    registerCategoryStateProvider =
        ref.read(registerCategoryStateNotifierProvider.notifier);

    dateNotifier = ValueNotifier<DateTime>(DateTime.now());

    registerKeyboardAction = RegisterKeyboardAction(
      moneyTextController: amountOfMoneyTextController,
      moneyNode: amountOfMoneyNode,
      categoryNotifier: categoryNotifier,
      categoryNode: categoryNode,
      subCategoryNode: subCategoryNode,
      subCategoryNotifier: subCategoryNotifier,
      memoTextController: memoTextController,
      memoNode: memoNode,
      dateNode: dateNode,
      dateNotifier: dateNotifier,
    );

    //金額Focusのcomputeリスナー
    amountOfMoneyNode.addListener(registerKeyboardAction.focusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? amountRenderBox =
          amountOfMoneyFormKey.currentContext?.findRenderObject() as RenderBox?;
      amountOfMoneyNode.setRenderBox(amountRenderBox);
      final RenderBox? memoRenderBox =
          memoFormKey.currentContext?.findRenderObject() as RenderBox?;
      memoNode.setRenderBox(memoRenderBox);
    });
  }

  @override
  void dispose() {
    amountOfMoneyTextController.dispose();
    widget.routeObserver.unsubscribe(this);
    amountOfMoneyNode.dispose();
    categoryNode.dispose();
    subCategoryNode.dispose();
    memoNode.dispose();
    dateNode.dispose();
    categoryNotifier.dispose();
    subCategoryNotifier.dispose();
    dateNotifier.dispose();
    super.dispose();
  }

  //カテゴリー新規登録からpopした時に呼ばれる
  @override
  void didPopNext() {
    primaryFocus?.unfocus();
    registerCategoryStateProvider.resetIsRoute();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final Color defaultColor = theme.colorScheme.onSurfaceVariant;
    final registerTextColor = theme.colorScheme.inverseSurface;

    //registerButton用
    final pushedDownRegisterButton = useState<bool>(false);
    final isActiveRegisterButton = useState<bool>(false);

    //フォーム入力チェック
    void formInputCheck() {
      debugPrint("formInput check");
      isActiveRegisterButton.value =
          amountOfMoneyTextController.text.isNotEmpty &&
              (categoryNotifier.value != null);
    }

    //フォーム入力チェックリスナー
    useEffect(() {
      amountOfMoneyTextController.addListener(formInputCheck);
      categoryNotifier.addListener(formInputCheck);
      return () {
        categoryNotifier.removeListener(formInputCheck);
        amountOfMoneyTextController.removeListener(formInputCheck);
      };
    }, []);

    //画面サイズ取得
    double appBarHeight = AppBar().preferredSize.height;
    double registerSpacerHeight = mediaQuery.size.height -
        appBarHeight -
        mediaQuery.padding.bottom -
        MediaQueryData.fromView(View.of(context)).padding.top -
        ((large * 3) +
            (medium * 4) +
            amountOfMoneyFormHeight +
            (registerItemHeight * 4) +
            registerButtonHeight);

    //カテゴリーListの監視
    ref.listen<AsyncValue<List<Category>>>(
      categoryListNotifierProvider,
      (_, state) {
        registerCategoryStateProvider.initCategory();
      },
    );

    //サブカテゴリーリストの監視
    ref.listen<AsyncValue<List<Category>>>(
      subCategoryListNotifierProvider,
      (_, state) {
        if (state.value?.isNotEmpty == true) {
          registerCategoryStateProvider.initSubCategory(state.value?.last);
        } else {
          registerCategoryStateProvider.initSubCategory(null);
        }
      },
    );

    //選択したカテゴリーの監視
    ref.listen<Category?>(
      registerCategoryStateNotifierProvider
          .select((categoryState) => categoryState.category),
      (_, newCategory) {
        categoryNotifier.value = newCategory;
      },
    );
    //選択したサブカテゴリーListの監視
    ref.listen<Category?>(
      registerCategoryStateNotifierProvider
          .select((categoryState) => categoryState.subCategory),
      (_, newCategory) {
        subCategoryNotifier.value = newCategory;
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
    Widget registerFormItem({
      required String title,
      required Widget formWidget,
      required CustomFocusNode formFocusNode,
      required Key registerFormItemKey,
    }) {
      return Row(
        key: registerFormItemKey,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              formFocusNode.requestFocus();
            },
            child: Container(
              margin: const EdgeInsets.only(right: small),
              width: registerItemTitleWidth,
              height: registerItemHeight,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: registerTextColor),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: registerItemHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: formInputBoarderRadius,
              ),
              child: formWidget,
            ),
          ),
        ],
      );
    }

    //登録処理
    void onTapRegister() {
      Register register;
      if (amountOfMoneyTextController.text.isNotEmpty ||
          categoryNotifier.value != null) {
        int? amount = int.tryParse(amountOfMoneyTextController.text);

        register = Register(
          amount: amount!,
          category: categoryNotifier.value,
          subCategory: subCategoryNotifier.value,
          memo: memoTextController.text,
          date: dateNotifier.value,
        );
        RegisterDBHelper().insertRegister(register);

        //フォームリセット
        amountOfMoneyTextController.clear();
        memoTextController.clear();
        registerCategoryStateProvider.initCategory();
        dateNotifier = ValueNotifier<DateTime>(DateTime.now());
      } else {
        //エラー表示
        const snackBar = SnackBar(
          content: Text('入力が正しくありません'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

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
            key: _formkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //-----金額-----
                SizedBox(
                  height: amountOfMoneyFormHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: amountOfMoneyFormKey,
                          keyboardType: TextInputType.number,
                          focusNode: amountOfMoneyNode,
                          controller: amountOfMoneyTextController,
                          decoration: InputDecoration(
                            contentPadding: mediumEdgeInsets,
                            isCollapsed: true,
                            isDense: true,
                            border: OutlineInputBorder(
                                borderRadius: formInputBoarderRadius),
                            labelText: '金額',
                            suffixIcon: Container(
                              margin: const EdgeInsets.fromLTRB(
                                  0, sssmall, ssmall, sssmall),
                              child: IconButton(
                                onPressed: () =>
                                    amountOfMoneyTextController.clear(),
                                icon: const Icon(Icons.cancel),
                                iconSize: suffixIconSize,
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
                ),
                const SizedBox(height: large),
                //-----カテゴリー-----
                KeyboardCustomInput<Category?>(
                  focusNode: categoryNode,
                  height: registerItemHeight,
                  notifier: categoryNotifier,
                  builder: categoryFormBulder("カテゴリー"),
                ),
                const SizedBox(height: medium),
                //-----サブカテゴリー-----
                KeyboardCustomInput<Category?>(
                  focusNode: subCategoryNode,
                  height: registerItemHeight,
                  notifier: subCategoryNotifier,
                  builder: categoryFormBulder("サブカテゴリー"),
                ),
                const SizedBox(height: medium),
                //-----メモ-----
                registerFormItem(
                  registerFormItemKey: memoFormKey,
                  formFocusNode: memoNode,
                  title: "メモ",
                  formWidget: TextField(
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    controller: memoTextController,
                    focusNode: memoNode,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: medium,
                          vertical: (registerItemHeight -
                                      (Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.fontSize ??
                                          0)) /
                                  2 -
                              formInputBoarderWidth * 2),
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
                  ),
                ),
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
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: mediumHorizontalEdgeInsets,
                              child: Text(
                                formatter.format(val),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: medium),
                SizedBox(
                    height: registerSpacerHeight.isNegative
                        ? 0
                        : registerSpacerHeight),

                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: isActiveRegisterButton.value
                      ? () => onTapRegister()
                      : null,
                  onTapDown: (_) => {pushedDownRegisterButton.value = true},
                  onTapUp: (_) => {pushedDownRegisterButton.value = false},
                  child: Container(
                    margin: mediumHorizontalEdgeInsets,
                    alignment: Alignment.center,
                    height: registerButtonHeight,
                    decoration: BoxDecoration(
                      color: isActiveRegisterButton.value
                          ? (pushedDownRegisterButton.value
                              ? Color.lerp(theme.colorScheme.primary,
                                  theme.colorScheme.surfaceContainer, 0.3)
                              : theme.colorScheme.primary)
                          : Color.lerp(theme.colorScheme.primary,
                              theme.colorScheme.surfaceContainer, 0.5),
                      borderRadius: registerButtomRadius,
                    ),
                    child: Text(
                      '登　　録',
                      style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontSize:
                              (theme.textTheme.titleMedium?.fontSize ?? 0) + 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
