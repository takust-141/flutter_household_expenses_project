import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/register_snackbar.dart';
import 'package:household_expense_project/model/category.dart';
import 'package:household_expense_project/model/register.dart';
import 'package:household_expense_project/provider/app_version_provider.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/provider/register_db_provider.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:household_expense_project/constant/constant.dart';
import 'package:household_expense_project/component/customed_register_keyboard.dart';
import 'package:household_expense_project/ad_helper.dart';

//-------入力画面------------
class RegisterPage extends StatefulHookConsumerWidget {
  final RouteObserver<PageRoute> routeObserver;
  const RegisterPage({super.key, required this.routeObserver});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> with RouteAware {
  final int selectCategoryProviderIndex = 1;
  final NotifierProvider<SelectCategoryStateNotifier, SelectCategoryState>
      selectCategoryStateProvider = registerCategoryStateNotifierProvider;

  //customKeyboard用
  late ValueNotifier<Category?> categoryNotifier;
  late ValueNotifier<Category?> subCategoryNotifier;
  late ValueNotifier<DateTime> dateNotifier;

  //FocusNode
  late CustomFocusNode amountOfMoneyNode;
  late CustomFocusNode categoryNode;
  late CustomFocusNode subCategoryNode;
  late CustomFocusNode memoNode;
  late CustomFocusNode dateNode;

  final formatter = DateFormat('yyyy年 M月 d日');
  final double suffixIconSize = 20;
  final amountOfMoneyFormKey = GlobalKey();
  final memoFormKey = GlobalKey();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //画面遷移検出
    widget.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  //カテゴリー新規登録からpopした時に呼ばれる
  @override
  void didPopNext() {
    primaryFocus?.unfocus();
    ref
        .read(selectCategoryStateProvider.notifier)
        .resetSelectCategoryStateFromRegister();
  }

  @override
  void dispose() {
    widget.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formkey = GlobalKey();

    //フォームコントローラー
    TextEditingController amountOfMoneyTextController =
        useTextEditingController();
    TextEditingController memoTextController = useTextEditingController();

    final ValueNotifier<RegisterKeyboardAction?> registerKeyboardAction =
        useState(null);

    //init
    useEffect(() {
      categoryNotifier = ValueNotifier<Category?>(null);
      subCategoryNotifier = ValueNotifier<Category?>(null);
      dateNotifier = ValueNotifier<DateTime>(DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day));
      amountOfMoneyNode = CustomFocusNode();
      categoryNode = CustomFocusNode();
      subCategoryNode = CustomFocusNode();
      memoNode = CustomFocusNode();
      dateNode = CustomFocusNode();

      registerKeyboardAction.value = RegisterKeyboardAction(
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
        selectCategoryProviderIndex: selectCategoryProviderIndex,
        enableNewAdd: true,
      );

      //金額Focusのcomputeリスナー
      amountOfMoneyNode.addListener(registerKeyboardAction.value!.focusChange);

      //FocusNode attach
      WidgetsBinding.instance.addPostFrameCallback((_) {
        memoNode.attach(memoFormKey.currentContext);
        amountOfMoneyNode.attach(amountOfMoneyFormKey.currentContext);
      });

      //初期化完了後にスプラッシュをremove
      FlutterNativeSplash.remove();
      return () {
        amountOfMoneyNode.dispose();
        categoryNode.dispose();
        subCategoryNode.dispose();
        memoNode.dispose();
        dateNode.dispose();
        categoryNotifier.dispose();
        subCategoryNotifier.dispose();
        dateNotifier.dispose();
      };
    }, []);

    final theme = Theme.of(context);
    final Color defaultColor = theme.colorScheme.onSurfaceVariant;
    final registerTextColor = theme.colorScheme.inverseSurface;

    //選択したカテゴリーの監視
    ref.listen<Category?>(
      selectCategoryStateProvider
          .select((categoryState) => categoryState.category),
      (_, newCategory) {
        categoryNotifier.value = newCategory;
      },
    );
    //選択したサブカテゴリーListの監視
    ref.listen<Category?>(
      selectCategoryStateProvider
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
                    const SizedBox(width: msmall),
                    Icon(
                      val?.icon,
                      color: val?.color ?? defaultColor,
                      size: 25,
                      weight: 500,
                    ),
                    const SizedBox(width: msmall),
                    Expanded(
                      child: Text(
                        val?.name ?? "",
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.1),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: msmall),
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
    Future<void> onTapRegister() async {
      Register register;
      if (amountOfMoneyTextController.text.isNotEmpty ||
          categoryNotifier.value != null) {
        int amount = int.tryParse(amountOfMoneyTextController.text) ?? 0;

        register = Register(
          amount: amount,
          category: categoryNotifier.value,
          subCategory: subCategoryNotifier.value,
          memo: memoTextController.text,
          date: dateNotifier.value,
          recurringId: null,
          registrationDate: DateTime.now(),
        );

        await RegisterDBProvider.insertRegister(register, ref, context);
        //フォームリセット
        amountOfMoneyTextController.clear();
        memoTextController.clear();
      } else {
        //エラー表示
        updateSnackBarCallBack(
          text: '入力が正しくありません',
          context: context,
          isError: true,
          ref: ref,
        );
      }
    }

    return SafeArea(
      maintainBottomViewPadding: false,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  double registerSpacerHeight = constraints.maxHeight -
                      ((large * 3) +
                          (medium * 4) +
                          amountOfMoneyFormHeight +
                          (registerItemHeight * 4) +
                          registerButtonHeight);
                  registerSpacerHeight = (registerSpacerHeight.isNegative)
                      ? 0
                      : registerSpacerHeight;
                  return KeyboardActions(
                    keepFocusOnTappingNode: true,
                    autoScroll: true,
                    overscroll: 40,
                    tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
                    config: registerKeyboardAction.value!.buildConfig(context),
                    child: Padding(
                      padding: viewEdgeInsets,
                      child: Form(
                        key: formkey,
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
                                    key: amountOfMoneyFormKey,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      focusNode: amountOfMoneyNode,
                                      controller: amountOfMoneyTextController,
                                      decoration: InputDecoration(
                                        contentPadding: mediumEdgeInsets,
                                        isCollapsed: true,
                                        isDense: true,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                formInputBoarderRadius),
                                        labelText: '金額',
                                        suffixIcon: Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              0, sssmall, ssmall, sssmall),
                                          child: IconButton(
                                            onPressed: () =>
                                                amountOfMoneyTextController
                                                    .clear(),
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
                                      style: const TextStyle(
                                          fontSize: 20, letterSpacing: 1.5),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: medium),
                                    child: Text(currencyUnit,
                                        style: TextStyle(
                                            fontSize: 25,
                                            color: registerTextColor)),
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
                                            ?.copyWith(
                                                color: registerTextColor),
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
                                                  color:
                                                      theme.colorScheme.primary,
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
                            SizedBox(height: registerSpacerHeight),
                            Padding(
                              padding: mediumHorizontalEdgeInsets,
                              child: HookBuilder(builder: (context) {
                                //registerButton用
                                final isActiveRegisterButton = useState<bool>(
                                    amountOfMoneyTextController
                                            .text.isNotEmpty &&
                                        (categoryNotifier.value != null));
                                //フォーム入力チェック
                                void formInputCheck() {
                                  isActiveRegisterButton.value =
                                      amountOfMoneyTextController
                                              .text.isNotEmpty &&
                                          (categoryNotifier.value != null);
                                }

                                //フォーム入力チェックリスナー
                                useEffect(() {
                                  amountOfMoneyTextController
                                      .addListener(formInputCheck);
                                  categoryNotifier.addListener(formInputCheck);
                                  return () {
                                    categoryNotifier
                                        .removeListener(formInputCheck);
                                    amountOfMoneyTextController
                                        .removeListener(formInputCheck);
                                  };
                                }, []);

                                return TextButton(
                                  onPressed: isActiveRegisterButton.value
                                      ? () => onTapRegister()
                                      : null,
                                  style: TextButton.styleFrom(
                                    fixedSize: const Size(
                                        double.maxFinite, registerButtonHeight),
                                    padding: smallEdgeInsets,
                                    overlayColor: theme.colorScheme.onPrimary,
                                    disabledBackgroundColor: Color.lerp(
                                        theme.colorScheme.primary,
                                        theme.colorScheme.surface,
                                        0.7),
                                    disabledForegroundColor: Color.lerp(
                                        theme.colorScheme.onPrimary,
                                        theme.colorScheme.surface,
                                        0.7),
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: registerButtomRadius,
                                    ),
                                    textStyle: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            fontSize: (theme
                                                        .textTheme
                                                        .titleMedium
                                                        ?.fontSize ??
                                                    0) +
                                                2),
                                  ),
                                  child: const AutoSizeText(
                                    "登　　録",
                                    maxLines: 1,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const AdaptiveAdBanner(0, key: GlobalObjectKey("register_ad")),
            ],
          ),
          VersionUpdateSnackBar(),
        ],
      ),
    );
  }
}
