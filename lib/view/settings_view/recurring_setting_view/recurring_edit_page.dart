import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/customed_register_recurring_keyboard.dart';
import 'package:household_expense_project/component/register_snackbar.dart';
import 'package:household_expense_project/component/setting_component.dart';
import 'package:household_expense_project/model/category.dart';
import 'package:household_expense_project/model/register_recurring.dart';
import 'package:household_expense_project/provider/register_recurring_list_provider.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/provider/setting_recurring_provider.dart';
import 'package:household_expense_project/view/settings_view/recurring_setting_view/recurring_setting_page.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:household_expense_project/constant/constant.dart';

//-------入力画面------------
class RecurringEditPage extends StatefulHookConsumerWidget {
  const RecurringEditPage({
    super.key,
    required this.formkey,
  });
  final GlobalKey<FormState>? formkey;

  @override
  ConsumerState<RecurringEditPage> createState() => _RecurringEditPageState();
}

class _RecurringEditPageState extends ConsumerState<RecurringEditPage> {
  //フォームコントローラー
  final TextEditingController amountOfMoneyTextController =
      TextEditingController();
  final TextEditingController memoTextController = TextEditingController();

  //customKeyboard用
  late ValueNotifier<Category?> categoryNotifier;
  late ValueNotifier<Category?> subCategoryNotifier;
  late ValueNotifier<DateTime> startDateNotifier;
  late ValueNotifier<DateTime?> endDateNotifier;

  //FocusNode
  final CustomFocusNode amountOfMoneyNode = CustomFocusNode();
  final CustomFocusNode categoryNode = CustomFocusNode();
  final CustomFocusNode subCategoryNode = CustomFocusNode();
  final CustomFocusNode memoNode = CustomFocusNode();
  final CustomFocusNode startDateNode = CustomFocusNode();
  final CustomFocusNode endDateNode = CustomFocusNode();

  final formatter = DateFormat('yyyy年 M月 d日');
  final double suffixIconSize = 20;
  final amountOfMoneyFormKey = GlobalKey();
  final memoFormKey = GlobalKey();

  //riverpod
  final NotifierProvider<SelectCategoryStateNotifier, SelectCategoryState>
      selectCategoryStateProvider = registerEditCategoryStateNotifierProvider;
  final int selectCategoryProviderIndex = 2;

  late RegisterRecurringKeyboardAction registerKeyboardAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color defaultColor = theme.colorScheme.onSurfaceVariant;
    final registerTextColor = theme.colorScheme.inverseSurface;

    //riverpod
    final registerRecurringNotifier =
        ref.read(registerRecurringListNotifierProvider.notifier);
    final settingRecurringNotifier =
        ref.read(settingRecurringyStateNotifierProvider.notifier);
    final settingRecurringState =
        ref.read(settingRecurringyStateNotifierProvider);

    //registerButton用
    final isActiveRegisterButton = useState<bool>(
        amountOfMoneyTextController.text.isNotEmpty &&
            (categoryNotifier.value != null));

    //フォーム入力チェック
    void formInputCheck() {
      isActiveRegisterButton.value =
          amountOfMoneyTextController.text.isNotEmpty &&
              (categoryNotifier.value != null);
    }

    //フォーム入力チェックリスナー
    //init処理
    useEffect(() {
      final RegisterRecurring? initalRegisterRecurring = ref.read(
          settingRecurringyStateNotifierProvider
              .select((p) => p.selectRegisterRecurring));

      //value初期値設定
      amountOfMoneyTextController.text =
          initalRegisterRecurring?.amount?.toString() ?? "";
      categoryNotifier = ValueNotifier<Category?>(
          ref.read(selectCategoryStateProvider.select((p) => p.category)));
      subCategoryNotifier = ValueNotifier<Category?>(
          ref.read(selectCategoryStateProvider.select((p) => p.subCategory)));
      memoTextController.text = initalRegisterRecurring?.memo ?? "";
      DateTime currentDate = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      startDateNotifier = ValueNotifier<DateTime>(
          initalRegisterRecurring?.startDate ?? currentDate);
      endDateNotifier =
          ValueNotifier<DateTime?>(initalRegisterRecurring?.endDate);

      formInputCheck();

      registerKeyboardAction = RegisterRecurringKeyboardAction(
        moneyTextController: amountOfMoneyTextController,
        moneyNode: amountOfMoneyNode,
        categoryNotifier: categoryNotifier,
        categoryNode: categoryNode,
        subCategoryNode: subCategoryNode,
        subCategoryNotifier: subCategoryNotifier,
        memoTextController: memoTextController,
        memoNode: memoNode,
        startDateNode: startDateNode,
        endDateNode: endDateNode,
        startDateNotifier: startDateNotifier,
        endDateNotifier: endDateNotifier,
        selectCategoryProviderIndex: selectCategoryProviderIndex,
        enableNewAdd: true,
      );

      //金額Focusのcomputeリスナー
      amountOfMoneyNode.addListener(registerKeyboardAction.focusChange);
      //inputCheckリスナー
      amountOfMoneyTextController.addListener(formInputCheck);
      categoryNotifier.addListener(formInputCheck);

      //FocusNode attach
      WidgetsBinding.instance.addPostFrameCallback((_) {
        memoNode.attach(memoFormKey.currentContext);
        amountOfMoneyNode.attach(amountOfMoneyFormKey.currentContext);
      });

      //dispose
      return () {
        categoryNotifier.removeListener(formInputCheck);
        amountOfMoneyTextController.removeListener(formInputCheck);
        amountOfMoneyTextController.dispose();
        amountOfMoneyNode.dispose();
        categoryNode.dispose();
        subCategoryNode.dispose();
        memoNode.dispose();
        startDateNode.dispose();
        endDateNode.dispose();
        categoryNotifier.dispose();
        subCategoryNotifier.dispose();
        startDateNotifier.dispose();
        endDateNotifier.dispose();
      };
    }, []);

    //selectRegisterRecrring更新時のコールバック

    if (settingRecurringState.selectRegisterRecurring?.id != null) {
      useEffect(() {
        final selectRegisterRecurring = ref.watch(
            settingRecurringyStateNotifierProvider
                .select((p) => p.selectRegisterRecurring));

        //value初期値設定
        amountOfMoneyTextController.text =
            selectRegisterRecurring?.amount?.toString() ?? "";
        categoryNotifier.value = selectRegisterRecurring?.category;
        subCategoryNotifier.value = selectRegisterRecurring?.subCategory;
        memoTextController.text = selectRegisterRecurring?.memo ?? "";

        DateTime currentDate = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);
        startDateNotifier.value =
            selectRegisterRecurring?.startDate ?? currentDate;
        endDateNotifier.value = selectRegisterRecurring?.endDate;
        return null;
      }, [
        ref.watch(settingRecurringyStateNotifierProvider
            .select((p) => p.selectInitNotifier))
      ]);
    }

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

    //繰り返し登録処理
    Future<void> onTapRecurringRegister() async {
      final bool isNewRecurring =
          settingRecurringState.selectRegisterRecurring?.id == null;
      //入力チェック
      if (!(amountOfMoneyTextController.text.isNotEmpty ||
          categoryNotifier.value != null)) {
        //エラー表示
        updateSnackBarCallBack(
          text: '入力が正しくありません',
          context: context,
          isError: true,
          ref: ref,
          isNotNeedBottomHeight: true,
        );
        return;
      }
      if (endDateNotifier.value != null &&
          startDateNotifier.value.isAfter(endDateNotifier.value!)) {
        //エラー表示
        updateSnackBarCallBack(
          text: '終了日付は開始日付より後にしてください',
          context: context,
          isError: true,
          ref: ref,
          isNotNeedBottomHeight: true,
        );
        return;
      }

      int amount = int.tryParse(amountOfMoneyTextController.text) ?? 0;
      final String actionText = isNewRecurring ? "登録" : "更新";
      String snackText = '定期収支を$actionTextしました';
      bool isError = false;
      bool isCompleted = false;

      RecurringSetting? recurringSetting =
          settingRecurringState.selectRegisterRecurring?.recurringSetting;
      RescheduleSetting rescheduleSetting =
          settingRecurringState.selectRegisterRecurring?.rescheduleSetting ??
              RescheduleSetting.defaultState();
      if ((!settingRecurringNotifier.registerFormCheck()) ||
          recurringSetting == null) {
        //繰り返し設定不足時
        if (context.mounted) {
          updateSnackBarCallBack(
            text: "繰り返し設定を正しく入力してください",
            context: context,
            isError: false,
            ref: ref,
            isNotNeedBottomHeight: true,
          );
        }
        return;
      }

      try {
        if (isNewRecurring) {
          await registerRecurringNotifier.insertRegisterRecurring(
            amount: amount,
            category: categoryNotifier.value!,
            subCategory: subCategoryNotifier.value,
            memo: memoTextController.text,
            startDate: startDateNotifier.value,
            endDate: endDateNotifier.value,
            recurringSetting: recurringSetting,
            rescheduleSetting: rescheduleSetting,
            context: context,
          );
          isCompleted = true;
        } else {
          final selectExpense = ref.read(
              registerEditCategoryStateNotifierProvider
                  .select((p) => p.selectExpense.text));
          RegisterRecurring oldRecurring =
              settingRecurringState.selectRegisterRecurring!;
          RegisterRecurring newRecurring = oldRecurring.copyWithUpdate(
            amount: amount,
            category: categoryNotifier.value!,
            subCategory: subCategoryNotifier.value,
            memo: memoTextController.text,
            startDate: startDateNotifier.value,
            endDate: endDateNotifier.value,
            recurringSetting: recurringSetting,
            rescheduleSetting: rescheduleSetting,
          );

          if (newRecurring.recurringSetting.recurringSettingtoString() ==
                  oldRecurring.recurringSetting.recurringSettingtoString() &&
              newRecurring.rescheduleSetting.rescheduleSettingtoString() ==
                  oldRecurring.rescheduleSetting.rescheduleSettingtoString() &&
              newRecurring.amount == oldRecurring.amount &&
              newRecurring.category == oldRecurring.category &&
              newRecurring.subCategory == oldRecurring.subCategory &&
              newRecurring.memo == oldRecurring.memo) {
            //期間のみの変更の時
            //ダイアログ表示
            openDialog(
              context: context,
              title: "定期$selectExpense更新",
              text: "期間を更新します",
              onTap: () async {
                //削除期間設定（start,end）
                List<(DateTime, DateTime?)> addDateRangeList = [];
                List<(DateTime, DateTime?)> delDateRangeList = [];

                final DateTime oldEndDate =
                    oldRecurring.endDate ?? DateTime(9999);
                final DateTime newEndDate =
                    newRecurring.endDate ?? DateTime(9999);

                if (oldEndDate.isAfter(newRecurring.startDate) ||
                    oldRecurring.startDate.isBefore(newEndDate)) {
                  //開始日判定
                  if (oldRecurring.startDate.isBefore(newRecurring.startDate)) {
                    //削除
                    delDateRangeList.add((
                      oldRecurring.startDate,
                      newRecurring.startDate.subtract(const Duration(days: 1))
                    ));
                  } else if (oldRecurring.startDate != newRecurring.startDate) {
                    //追加
                    addDateRangeList.add((
                      newRecurring.startDate,
                      oldRecurring.startDate.subtract(const Duration(days: 1))
                    ));
                  }

                  //終了日判定
                  if (oldEndDate.isBefore(newEndDate)) {
                    //追加
                    if (oldRecurring.endDate != null) {
                      addDateRangeList.add((
                        oldRecurring.endDate!.add(const Duration(days: 1)),
                        newRecurring.endDate
                      ));
                    }
                  } else if (oldEndDate != newEndDate) {
                    //削除
                    if (newRecurring.endDate != null) {
                      delDateRangeList.add((
                        newRecurring.endDate!.add(const Duration(days: 1)),
                        oldRecurring.endDate
                      ));
                    }
                  }

                  //db更新
                  await registerRecurringNotifier
                      .updateRegisterRecurringOfRangeList(
                    newRecurring,
                    addDateRangeList,
                    delDateRangeList,
                    context,
                  );
                } else {
                  //全削除＋追加
                  await registerRecurringNotifier.updateRegisterRecurring(
                    newRecurring,
                    context,
                  );
                }

                isCompleted = true;
              },
              buttonText: "更新",
            );
          } else {
            //ダイアログ表示
            openDialog(
              context: context,
              title: "定期$selectExpense更新",
              text: "個別で修正した定期$selectExpenseも全て更新されます",
              onTap: () async {
                await registerRecurringNotifier.updateRegisterRecurring(
                  newRecurring,
                  context,
                );
                isCompleted = true;
              },
              buttonText: "更新",
            );
          }
        }
      } catch (e) {
        snackText = '定期収支を$actionTextできませんでした';
        isError = true;
      } finally {
        if (isCompleted) {
          if (context.mounted) {
            updateSnackBarCallBack(
              text: snackText,
              context: context,
              isError: isError,
              ref: ref,
              isNotNeedBottomHeight: true,
            );
            if (!isError) {
              //登録完了時
              //選択初期化
              settingRecurringNotifier.clearRegisterRecurring();
              ref
                  .read(selectCategoryStateProvider.notifier)
                  .setInit(isCurrentExpense: true);
              //pop
              Navigator.of(context).pop();
            }
          }
        }
      }
    }

    return SafeArea(
      maintainBottomViewPadding: true,
      child: LayoutBuilder(builder: (context, constraints) {
        double registerSpacerHeight = constraints.maxHeight -
            ((large * 5) +
                small +
                (medium * 3) +
                amountOfMoneyFormHeight +
                (registerItemHeight * 6) +
                registerButtonHeight) -
            ((settingRecurringState.selectRegisterRecurring?.id ==
                    null) //更新時の一覧表示考慮
                ? 0
                : registerItemHeight);
        registerSpacerHeight =
            (registerSpacerHeight.isNegative) ? 0 : registerSpacerHeight;

        return Container(
          color: theme.colorScheme.surfaceContainer,
          child: KeyboardActions(
            keepFocusOnTappingNode: true,
            autoScroll: true,
            overscroll: 40,
            tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
            config: registerKeyboardAction.buildConfig(context),
            child: Padding(
              padding: viewEdgeInsets,
              child: Form(
                key: widget.formkey,
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
                              onSaved: (_) {
                                if (settingRecurringState
                                        .selectRegisterRecurring?.id !=
                                    null) {
                                  final selectExpense = ref.read(
                                      registerEditCategoryStateNotifierProvider
                                          .select((p) => p.selectExpense.text));
                                  openDialog(
                                    context: context,
                                    title: "定期$selectExpense削除",
                                    text: "この定期$selectExpenseを削除します",
                                    onTap: () async {
                                      await registerRecurringNotifier
                                          .deleteRegisterRecurringFromId(
                                              settingRecurringState
                                                  .selectRegisterRecurring!.id!,
                                              context);
                                    },
                                    buttonText: "削除",
                                  );
                                }
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
                    //開始日付
                    KeyboardCustomInput<DateTime>(
                      focusNode: startDateNode,
                      height: registerItemHeight,
                      notifier: startDateNotifier,
                      builder: (context, val, hasFocus) {
                        return Row(
                          children: [
                            SizedBox(
                              width: registerItemTitleWidth,
                              child: Text(
                                "開始日付",
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
                    //終了日付
                    KeyboardCustomInput<DateTime?>(
                      focusNode: endDateNode,
                      height: registerItemHeight,
                      notifier: endDateNotifier,
                      builder: (context, val, hasFocus) {
                        return Row(
                          children: [
                            SizedBox(
                              width: registerItemTitleWidth,
                              child: Text(
                                "終了日付",
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
                                    (val != null)
                                        ? formatter.format(val)
                                        : "終了日付なし",
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: large),

                    //繰り返し設定
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(containreBorderRadius),
                      ),
                      child: RecurringSettingListItem(
                        listTitle: "繰り返し設定",
                        subText: settingRecurringNotifier.getSubText(0),
                        nextRoot:
                            '/setting/recurring_list/recurring_edit/recurring_setting',
                      ),
                    ),
                    const SizedBox(height: large),

                    //一覧表示（更新時）
                    (settingRecurringState.selectRegisterRecurring?.id != null)
                        ? Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(containreBorderRadius),
                            ),
                            child: const RecurringSettingListItem(
                              listTitle: "一覧表示（個別変更）",
                              subText: "",
                              nextRoot:
                                  '/setting/recurring_list/recurring_edit/recurring_setting_register_list',
                            ),
                          )
                        : const SizedBox.shrink(),
                    SizedBox(height: registerSpacerHeight),

                    //登録or更新ボタン
                    Padding(
                      padding: mediumHorizontalEdgeInsets,
                      child: TextButton(
                        onPressed: isActiveRegisterButton.value
                            ? () => onTapRecurringRegister()
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
                          (settingRecurringState.selectRegisterRecurring?.id ==
                                  null)
                              ? "登　　録"
                              : "更　　新",
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
