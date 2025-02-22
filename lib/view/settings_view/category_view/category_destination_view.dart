import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/custom_expand_list.dart';
import 'package:household_expense_project/model/category.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/provider/category_list_provider.dart';
import 'package:household_expense_project/view_model/category_db_helper.dart';
import 'package:household_expense_project/constant/constant.dart';

//Provider
final destinationCategory =
    NotifierProvider<DestinationCategoryNotifier, DestinationCategoryState>(
        DestinationCategoryNotifier.new);

//状態管理
@immutable
class DestinationCategoryState {
  final Category? selectDestinationCategory;
  final String? parentCategoryName;
  const DestinationCategoryState({
    required this.selectDestinationCategory,
    required this.parentCategoryName,
  });

  DestinationCategoryState copyWith({
    Category? selectDestinationCategory,
    String? parentCategoryName,
  }) {
    return DestinationCategoryState(
      selectDestinationCategory:
          selectDestinationCategory ?? this.selectDestinationCategory,
      parentCategoryName: parentCategoryName ?? this.parentCategoryName,
    );
  }
}

//Notifier
class DestinationCategoryNotifier extends Notifier<DestinationCategoryState> {
  @override
  DestinationCategoryState build() {
    return DestinationCategoryState(
      selectDestinationCategory: null,
      parentCategoryName: null,
    );
  }

  void setDestinationCategory(Category? category, String? parentCategoryName) {
    state = DestinationCategoryState(
      selectDestinationCategory: category,
      parentCategoryName: parentCategoryName,
    );
  }

  void initSelectCategory() {
    state = DestinationCategoryState(
      selectDestinationCategory: null,
      parentCategoryName: null,
    );
  }
}

//
//カテゴリー移行用セレクター
const double selectDisplayheight = 40;
const EdgeInsets destinationSelectorEdgeInsets =
    EdgeInsets.symmetric(vertical: small, horizontal: medium);

class DestinationCategorySelector extends HookConsumerWidget {
  const DestinationCategorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MenuController menuSelectController = MenuController();
    final ScrollController selectorDropDownListScrollController =
        useScrollController();
    final theme = Theme.of(context);

    //カテゴリーリスト
    final Map<SelectExpense, List<Category>>? categoryListMap =
        ref.watch(categoryListNotifierProvider).valueOrNull;

    final categoryListOutgo = categoryListMap?[SelectExpense.outgo] ?? [];
    final categoryListIncome = categoryListMap?[SelectExpense.income] ?? [];

    final getSubCategoryListsOutgo = useMemoized(() {
      List<int> idList =
          categoryListOutgo.map((category) => category.id!).toList();
      return CategoryDBHelper.getAllSubCategoryList(idList);
    });
    final getSubCategoryListsIncome = useMemoized(() {
      List<int> idList =
          categoryListIncome.map((category) => category.id!).toList();
      return CategoryDBHelper.getAllSubCategoryList(idList);
    });
    final subCategoryListOutgo = useFuture(getSubCategoryListsOutgo);
    final subCategoryListIncome = useFuture(getSubCategoryListsIncome);

    return LayoutBuilder(builder: (context, constraints) {
      return MenuAnchor(
        alignmentOffset: const Offset(0, 4), //余白
        controller: menuSelectController,
        style: MenuStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: chartListItemRadius,
            ),
          ),
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          backgroundColor:
              WidgetStateProperty.all(theme.colorScheme.surfaceBright),
          minimumSize:
              WidgetStateProperty.all(Size.fromHeight(selectDisplayheight * 3)),
          maximumSize: WidgetStateProperty.all(
              Size.fromHeight(selectDisplayheight * 5 + 4)),
        ),
        consumeOutsideTap: true,
        layerLink: LayerLink(),
        //メニュー内容
        menuChildren: [
          SizedBox(
            height: selectDisplayheight * 5 + 4,
            width: constraints.maxWidth,
            child: RawScrollbar(
              controller: selectorDropDownListScrollController,
              thickness: 4,
              radius: const Radius.circular(8.0),
              thumbVisibility: true,
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: SingleChildScrollView(
                  controller: selectorDropDownListScrollController,
                  child: Column(
                    children: [
                      Container(
                        color: theme.colorScheme.primaryContainer,
                        height: selectDisplayheight,
                        width: double.maxFinite,
                        padding: destinationSelectorEdgeInsets,
                        child: Text(
                          "支出",
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      //選択項目：支出カテゴリー
                      for (int i = 0; i < categoryListOutgo.length; i++) ...{
                        const Divider(height: 1, thickness: 0.5),
                        CustomExpandList(
                          itemColor: theme.colorScheme.surfaceBright,
                          title: categoryListOutgo[i].name,
                          padding: destinationSelectorEdgeInsets,
                          titleHeight: selectDisplayheight,
                          titleWidth: constraints.maxWidth,
                          childrenHeight: (selectDisplayheight + 1) *
                              ((subCategoryListOutgo.data?[i].length ?? 0) + 1),
                          children: [
                            const Divider(height: 1, thickness: 0.5),
                            //選択項目：サブカテゴリーなし
                            DestinationDropDownListItem(
                              category: categoryListOutgo[i],
                              menuController: menuSelectController,
                              isParentCategory: true,
                              parentCategoryName: categoryListOutgo[i].name,
                            ),
                            //選択項目：サブカテゴリー
                            if (subCategoryListOutgo.hasData)
                              for (Category categoryOutgo
                                  in subCategoryListOutgo.data?[i] ?? []) ...{
                                const Divider(height: 1, thickness: 0.5),
                                DestinationDropDownListItem(
                                  category: categoryOutgo,
                                  menuController: menuSelectController,
                                  parentCategoryName: categoryListOutgo[i].name,
                                ),
                              },
                          ],
                        ),
                      },
                      //選択項目：収入カテゴリー
                      Container(
                        color: theme.colorScheme.primaryContainer,
                        height: selectDisplayheight,
                        width: double.maxFinite,
                        padding: destinationSelectorEdgeInsets,
                        child: Text(
                          "収入",
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      //カテゴリー
                      for (int i = 0; i < categoryListIncome.length; i++) ...{
                        const Divider(height: 1, thickness: 0.5),
                        CustomExpandList(
                          itemColor: theme.colorScheme.surfaceBright,
                          title: categoryListIncome[i].name,
                          padding: destinationSelectorEdgeInsets,
                          titleHeight: selectDisplayheight,
                          titleWidth: constraints.maxWidth,
                          childrenHeight: (selectDisplayheight + 1) *
                              ((subCategoryListIncome.data?[i].length ?? 0) +
                                  1),
                          children: [
                            const Divider(height: 1, thickness: 0.5),
                            //選択項目：サブカテゴリーなし
                            DestinationDropDownListItem(
                              category: categoryListIncome[i],
                              menuController: menuSelectController,
                              isParentCategory: true,
                              parentCategoryName: categoryListIncome[i].name,
                            ),
                            //選択項目：サブカテゴリー
                            if (subCategoryListIncome.hasData)
                              for (Category categoryIncome
                                  in subCategoryListIncome.data?[i] ?? []) ...{
                                const Divider(height: 1, thickness: 0.5),
                                DestinationDropDownListItem(
                                  category: categoryIncome,
                                  menuController: menuSelectController,
                                  parentCategoryName:
                                      categoryListIncome[i].name,
                                ),
                              },
                          ],
                        ),
                      }
                    ],
                  )),
            ),
          ),
        ],
        //セレクターDisplay
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
          return GestureDetector(
            onTap: () =>
                {controller.isOpen ? controller.close() : controller.open()},
            child: Container(
              alignment: Alignment.centerLeft,
              height: selectDisplayheight,
              width: double.maxFinite,
              padding: destinationSelectorEdgeInsets,
              decoration: BoxDecoration(
                borderRadius: chartListItemRadius,
                color: theme.colorScheme.surfaceBright,
              ),
              child: AutoSizeText(
                (ref.watch(destinationCategory).selectDestinationCategory !=
                        null)
                    ? "${ref.watch(destinationCategory).parentCategoryName ?? ""} / ${(ref.watch(destinationCategory).selectDestinationCategory?.parentId != null) ? ref.watch(destinationCategory).selectDestinationCategory!.name : "サブカテゴリーなし"}"
                    : "",
                maxLines: 1,
                minFontSize: 10,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      );
    });
  }
}

//カテゴリー選択リストアイテム
class DestinationDropDownListItem extends ConsumerWidget {
  const DestinationDropDownListItem({
    required this.category,
    required this.menuController,
    super.key,
    this.isParentCategory = false,
    this.parentCategoryName = "",
  });
  final Category? category;
  final MenuController menuController;
  final bool isParentCategory;
  final String parentCategoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectDestinationCategory =
        ref.watch(destinationCategory).selectDestinationCategory;

    return SizedBox(
      height: selectDisplayheight,
      child: TextButton(
        style: TextButton.styleFrom(
          textStyle: theme.textTheme.bodyMedium,
          foregroundColor: theme.colorScheme.onSurface,
          alignment: Alignment.centerLeft,
          fixedSize: const Size(double.maxFinite, selectDisplayheight),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: destinationSelectorEdgeInsets,
          overlayColor: theme.colorScheme.onSurface,
          backgroundColor: (selectDestinationCategory == category)
              ? theme.colorScheme.onSurface.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceBright,
        ),
        onPressed: () {
          ref
              .read(destinationCategory.notifier)
              .setDestinationCategory(category, parentCategoryName);
          menuController.close();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: medium),
          child: AutoSizeText(
            isParentCategory ? "サブカテゴリーなし" : (category?.name ?? ""),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

//汎用ダイアログ
void openDestinationDialog({
  required BuildContext context,
  required String title,
  required String text,
  required String buttonText,
  required Future<bool> Function()? onTap, //falseの時popしない
  Widget? aditionalWidget,
  required ValueNotifier<String?> errTextNotifiere,
}) async {
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
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: large),
              AutoSizeText(text, textAlign: TextAlign.left),
              ValueListenableBuilder(
                valueListenable: errTextNotifiere,
                builder: (BuildContext context, value, Widget? child) {
                  return Padding(
                    padding: EdgeInsets.only(top: small),
                    child: AutoSizeText(
                      value ?? "",
                      textAlign: TextAlign.left,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  );
                },
              ),
              if (aditionalWidget != null) ...{
                const SizedBox(height: medium),
                aditionalWidget,
              },
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
                        if (onTap != null) {
                          final bool result = await onTap();
                          if (result && context.mounted) {
                            Navigator.pop(context);
                            navigator.pop();
                          }
                        }
                      },
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(containreBorderRadius),
                        ),
                      ),
                      child: AutoSizeText(
                        buttonText,
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
