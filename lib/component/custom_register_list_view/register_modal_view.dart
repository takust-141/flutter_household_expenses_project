import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/register_snackbar.dart';
import 'package:household_expense_project/component/segmented_button.dart';
import 'package:household_expense_project/component/setting_component.dart';
import 'package:household_expense_project/model/category.dart';
import 'package:household_expense_project/model/register.dart';
import 'package:household_expense_project/provider/register_db_provider.dart';
import 'package:household_expense_project/provider/register_edit_state.dart';
import 'package:household_expense_project/provider/register_recurring_list_provider.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/provider/setting_recurring_provider.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:household_expense_project/constant/constant.dart';
import 'package:household_expense_project/component/customed_register_keyboard.dart';

//更新用provider
final formKeyProvider =
    NotifierProvider<FormKeyNotifier, FormKeyState>(FormKeyNotifier.new);

@immutable
class FormKeyState {
  final GlobalKey<FormState> formkey;
  final bool isNewRegister;
  const FormKeyState(this.formkey, this.isNewRegister);
}

class FormKeyNotifier extends Notifier<FormKeyState> {
  @override
  FormKeyState build() {
    return FormKeyState(GlobalKey<FormState>(), true);
  }

  void setIsNewRegister(bool isNewRegister) {
    state = FormKeyState(state.formkey, isNewRegister);
  }

  Future<void> save() async {
    state.formkey.currentState?.save();
  }
}

void showRegisterModal(
    BuildContext context,
    WidgetRef ref,
    Register? register,
    AsyncNotifierProvider<RegisterEditStateNotifier, RegisterEditState>
        registerEditStateProvider) {
  ref.read(registerEditStateProvider.notifier).initDoneButton();
  ref.read(formKeyProvider.notifier).setIsNewRegister(register == null);
  final theme = Theme.of(context);
  showModalBottomSheet<void>(
    clipBehavior: Clip.antiAlias,
    useSafeArea: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    backgroundColor: theme.colorScheme.surfaceContainer,
    context: Navigator.of(context, rootNavigator: true).context,
    builder: (BuildContext context) {
      return RegisterEditView(register, registerEditStateProvider);
    },
  );
}

//-----編集View-----
class RegisterEditView extends ConsumerWidget {
  RegisterEditView(this.register, this.registerEditStateProvider, {super.key});
  final Register? register;
  final AsyncNotifierProvider<RegisterEditStateNotifier, RegisterEditState>
      registerEditStateProvider;

  final NotifierProvider<SelectCategoryStateNotifier, SelectCategoryState>
      selectCategoryStateProvider = registerEditCategoryStateNotifierProvider;
  //画面遷移時のprovider共有用パラメータ
  final int selectCategoryProviderIndex = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    double appBarHeight = AppBar().preferredSize.height;

    return Column(
      children: [
        //appbar
        Material(
          elevation: 2,
          color: theme.scaffoldBackgroundColor,
          child: SizedBox(
            height: appBarHeight,
            child: Row(
              children: [
                const Expanded(flex: 1, child: AppBarCancelWidget()),
                //segmendedButton
                SelectExpenseButton(selectCategoryStateProvider),
                Expanded(
                    flex: 1,
                    child: AppBarDoneWidget(registerEditStateProvider)),
              ],
            ),
          ),
        ),

        //body
        Expanded(
          child: Container(
            color: theme.colorScheme.surfaceContainer,
            child: RegisterEditBodyView(
              register: register,
              selectCategoryStateProviderIndex: selectCategoryProviderIndex,
              registerEditStateProvider: registerEditStateProvider,
            ),
          ),
        ),
      ],
    );
  }
}

//キャンセルボタン
class AppBarCancelWidget extends HookWidget {
  const AppBarCancelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cancelTextColor = useState<Color>(theme.colorScheme.onSurface);
    useEffect(() {
      cancelTextColor.value = theme.colorScheme.onSurface;
      return () {};
    }, [theme]);

    return GestureDetector(
      child: AnimatedContainer(
        duration: listItemAnimationDuration,
        child: Padding(
          padding: const EdgeInsets.only(left: appbarSidePadding),
          child: Text(
            "キャンセル",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: cancelTextColor.value,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      onTap: () => Navigator.of(context).pop(),
      onTapDown: (_) => {cancelTextColor.value = theme.colorScheme.outline},
      onTapUp: (_) => {cancelTextColor.value = theme.colorScheme.onSurface},
      onTapCancel: () => {cancelTextColor.value = theme.colorScheme.onSurface},
    );
  }
}

//削除ボタン
class AppBarDoneWidget extends HookConsumerWidget {
  const AppBarDoneWidget(this.registerEditStateProvider, {super.key});
  final AsyncNotifierProvider<RegisterEditStateNotifier, RegisterEditState>
      registerEditStateProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final doneTextColor = useState<Color>(theme.colorScheme.onSurface);

    useEffect(() {
      doneTextColor.value = theme.colorScheme.onSurface;
      return () {};
    }, [theme]);

    //新規でない場合、削除ボタンを有効化
    return (ref.watch(formKeyProvider).isNewRegister)
        ? Padding(
            padding: const EdgeInsets.only(right: appbarSidePadding),
            child: Text(
              "削除",
              textAlign: TextAlign.right,
              style: TextStyle(
                color: theme.colorScheme.outline,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        : GestureDetector(
            child: AnimatedContainer(
              duration: listItemAnimationDuration,
              child: Padding(
                padding: const EdgeInsets.only(right: appbarSidePadding),
                child: Text(
                  "削除",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: doneTextColor.value,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            onTap: () {
              //削除処理
              ref.read(formKeyProvider.notifier).save();
            },
            onTapDown: (_) => {doneTextColor.value = theme.colorScheme.outline},
            onTapUp: (_) => {doneTextColor.value = theme.colorScheme.onSurface},
            onTapCancel: () =>
                {doneTextColor.value = theme.colorScheme.onSurface},
          );
  }
}

//
//-------register編集------------
class RegisterEditBodyView extends StatefulHookConsumerWidget {
  const RegisterEditBodyView({
    super.key,
    required this.register,
    required this.registerEditStateProvider,
    required this.selectCategoryStateProviderIndex,
  });
  final Register? register;
  final AsyncNotifierProvider<RegisterEditStateNotifier, RegisterEditState>
      registerEditStateProvider;
  final int selectCategoryStateProviderIndex;

  @override
  ConsumerState<RegisterEditBodyView> createState() =>
      _RegisterEditBodyViewState();
}

class _RegisterEditBodyViewState extends ConsumerState<RegisterEditBodyView> {
  final formatter = DateFormat('yyyy年 M月 d日');
  final double suffixIconSize = 20;
  final textFormKey = GlobalKey();
  final memoFormKey = GlobalKey();

  //FocusNode
  late final CustomFocusNode amountOfMoneyNode;
  late final CustomFocusNode categoryNode;
  late final CustomFocusNode subCategoryNode;
  late final CustomFocusNode memoNode;
  late final CustomFocusNode dateNode;

  //フォームコントローラー
  late final TextEditingController amountOfMoneyTextController;
  late final TextEditingController memoTextController;

  //customKeyboard用
  late ValueNotifier<Category?> categoryNotifier;
  late ValueNotifier<Category?> subCategoryNotifier;
  late ValueNotifier<DateTime> dateNotifier;

  late RegisterKeyboardAction registerKeyboardAction;
  VoidCallback? formInputCheck;

  //provider 初期化
  late final NotifierProvider<SelectCategoryStateNotifier, SelectCategoryState>
      selectCategoryStateProvider;

  @override
  void initState() {
    //riverpod
    selectCategoryStateProvider =
        selectCategoryProviderList[widget.selectCategoryStateProviderIndex];

    //keyboardaction
    amountOfMoneyNode = CustomFocusNode();
    categoryNode = CustomFocusNode();
    subCategoryNode = CustomFocusNode();
    memoNode = CustomFocusNode();
    dateNode = CustomFocusNode();

    amountOfMoneyTextController =
        TextEditingController(text: widget.register?.amount.toString() ?? "");
    memoTextController =
        TextEditingController(text: widget.register?.memo ?? "");

    categoryNotifier = ValueNotifier<Category?>(
        ref.read(selectCategoryStateProvider).category);
    subCategoryNotifier = ValueNotifier<Category?>(
        ref.read(selectCategoryStateProvider).subCategory);
    dateNotifier = ValueNotifier<DateTime>(widget.register?.date ??
        ref
            .read(widget.registerEditStateProvider.notifier)
            .currentSelectDate() ??
        DateTime.now());

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
      selectCategoryProviderIndex: widget.selectCategoryStateProviderIndex,
      enableNewAdd: false,
    );

    //金額Focusのcomputeリスナー
    amountOfMoneyNode.addListener(registerKeyboardAction.focusChange);

    //完了ボタンのリスナー追加
    formInputCheck() => ref
        .read(widget.registerEditStateProvider.notifier)
        .formInputCheck(amountOfMoneyTextController, categoryNotifier);

    //各コントローラーが変化した際にリスナーを実施
    amountOfMoneyTextController.addListener(formInputCheck);
    categoryNotifier.addListener(formInputCheck);
    subCategoryNotifier.addListener(formInputCheck);
    memoTextController.addListener(formInputCheck);
    dateNotifier.addListener(formInputCheck);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      amountOfMoneyNode.attach(textFormKey.currentContext);
      memoNode.attach(memoFormKey.currentContext);
    });

    super.initState();
  }

  @override
  void dispose() {
    if (formInputCheck != null) {
      amountOfMoneyTextController.removeListener(formInputCheck!);
      memoTextController.removeListener(formInputCheck!);
      categoryNotifier.removeListener(formInputCheck!);
      subCategoryNotifier.removeListener(formInputCheck!);
      dateNotifier.removeListener(formInputCheck!);
    }

    amountOfMoneyTextController.dispose();
    memoTextController.dispose();

    categoryNotifier.dispose();
    subCategoryNotifier.dispose();
    dateNotifier.dispose();

    amountOfMoneyNode.dispose();
    categoryNode.dispose();
    subCategoryNode.dispose();
    memoNode.dispose();
    dateNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color defaultColor = theme.colorScheme.onSurfaceVariant;
    final registerTextColor = theme.colorScheme.inverseSurface;
    //登録ボタン用
    final isActiveRegisterButton = ref
            .watch(widget.registerEditStateProvider)
            .valueOrNull
            ?.isActiveDoneButton ??
        false;

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

    //更新or新規登録　処理
    Future<void> onTapUpdateRegister(context) async {
      Register newRegister;

      if (amountOfMoneyTextController.text.isNotEmpty ||
          categoryNotifier.value != null) {
        int amount = int.tryParse(amountOfMoneyTextController.text) ?? 0;

        newRegister = Register(
          id: widget.register?.id,
          amount: amount,
          category: categoryNotifier.value,
          subCategory: subCategoryNotifier.value,
          memo: memoTextController.text,
          date: dateNotifier.value,
          recurringId: widget.register?.recurringId,
          registrationDate: widget.register?.registrationDate ?? DateTime.now(),
          updateDate: (widget.register?.id == null) ? null : DateTime.now(),
        );

        if (newRegister.id == null) {
          //新規登録
          await RegisterDBProvider.insertRegister(newRegister, ref, context);
          Navigator.of(context).pop();
        } else {
          if (newRegister.recurringId == null) {
            //register更新
            await RegisterDBProvider.updateRegister(newRegister, ref, context);
            Navigator.of(context).pop();
          } else {
            //繰り返し収支の更新の場合
            //ダイアログ表示（日付を変更している場合はボタン非活性）
            openDialogContainWidget(
              context: context,
              title: "定期明細の更新",
              onTapList: [
                //この収支のみを更新
                () async {
                  await RegisterDBProvider.updateRegister(
                      newRegister, ref, context);
                  ref
                      .read(settingRecurringyStateNotifierProvider.notifier)
                      .setInitNotifier(); //変更通知（recurring用）
                },
                //日付以降を変更
                (widget.register?.date == newRegister.date)
                    ? () async {
                        //更新用 Idのバックアップ（recurringList更新用）
                        ref
                            .read(
                                settingRecurringyStateNotifierProvider.notifier)
                            .setSelectRegisterRecurringBackUp();
                        await ref
                            .read(
                                registerRecurringListNotifierProvider.notifier)
                            .updateRegisterRecurringFromRegisterAfterBaseDate(
                              newRegister,
                              newRegister.date,
                              context,
                            );
                      }
                    : null,
                //全てを変更
                (widget.register?.date == newRegister.date)
                    ? () async {
                        //更新用 Idのバックアップ（recurringList更新用）
                        ref
                            .read(
                                settingRecurringyStateNotifierProvider.notifier)
                            .setSelectRegisterRecurringBackUp();
                        await ref
                            .read(
                                registerRecurringListNotifierProvider.notifier)
                            .updateRegisterRecurringFromRegister(
                              newRegister,
                              context,
                            );
                      }
                    : null,
              ],
              buttonTextList: [
                "この明細のみを更新する",
                "この日付以降の定期明細を更新する",
                "この定期収支の明細を全て更新する"
              ],
            );
          }
        }
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

    //削除確認ダイアログ
    void openConfDialog(Function onTap) async {
      final theme = Theme.of(context);
      final navigator = Navigator.of(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(dialogRadius),
            ),
            child: Container(
              padding: largeEdgeInsets,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(dialogRadius),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AutoSizeText(
                    "この明細を削除します\nよろしいですか？",
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  const SizedBox(height: large),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: smallEdgeInsets,
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(
                                color: theme.colorScheme.primary, width: 1.3),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(containreBorderRadius),
                            ),
                          ),
                          child: const AutoSizeText(
                            "キャンセル",
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            await onTap();
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            navigator.pop();
                          },
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(containreBorderRadius),
                            ),
                          ),
                          child: const AutoSizeText(
                            "削除",
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    //削除処理
    void onTapDeleteRegister() {
      openConfDialog(() {
        RegisterDBProvider.deleteRegisterFromId(widget.register!, ref, context);
        ref
            .read(settingRecurringyStateNotifierProvider.notifier)
            .setInitNotifier();
      });
    }

    return SafeArea(
      maintainBottomViewPadding: true,
      child: LayoutBuilder(builder: (context, constraints) {
        double registerSpacerHeight = constraints.maxHeight -
            ((large * 3) +
                (medium * 4) +
                amountOfMoneyFormHeight +
                (registerItemHeight * 4) +
                registerButtonHeight);
        registerSpacerHeight =
            (registerSpacerHeight.isNegative) ? 0 : registerSpacerHeight;

        return KeyboardActions(
          keepFocusOnTappingNode: true,
          autoScroll: true,
          overscroll: 10,
          tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
          config: registerKeyboardAction.buildConfig(context),
          child: Padding(
            padding: viewEdgeInsets,
            child: Form(
              key: ref.watch(formKeyProvider.select((p) => p.formkey)),
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
                          key: textFormKey,
                          child: TextFormField(
                            onSaved: (_) async {
                              //削除処理
                              onTapDeleteRegister();
                            },
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
                            style: const TextStyle(
                                fontSize: 20, letterSpacing: 1.5),
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

                  SizedBox(height: registerSpacerHeight),

                  Padding(
                    padding: mediumHorizontalEdgeInsets,
                    child: TextButton(
                      onPressed: isActiveRegisterButton
                          ? () => onTapUpdateRegister(context)
                          : null,
                      style: TextButton.styleFrom(
                        fixedSize:
                            const Size(double.maxFinite, registerButtonHeight),
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
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: registerButtomRadius,
                        ),
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                            fontSize:
                                (theme.textTheme.titleMedium?.fontSize ?? 0) +
                                    2),
                      ),
                      child: AutoSizeText(
                        (widget.register?.recurringId == null)
                            ? "登　　録"
                            : "更　　新",
                        maxLines: 1,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
