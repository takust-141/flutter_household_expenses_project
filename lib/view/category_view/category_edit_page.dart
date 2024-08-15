import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/component/customed_setting_keyboard.dart';
import 'package:household_expenses_project/constant/keyboard_components.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:household_expenses_project/provider/app_bar_provider.dart';
import 'package:household_expenses_project/provider/select_category_provider.dart';
import 'package:household_expenses_project/view_model/category_db_provider.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:household_expenses_project/constant/constant.dart';

//-------カテゴリ編集ページ---------------------------
class CategoryEditPage extends ConsumerStatefulWidget {
  final GlobalKey<FormState>? formKey;
  const CategoryEditPage(this.formKey, {super.key});

  @override
  ConsumerState<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends ConsumerState<CategoryEditPage> {
  //デフォルト
  static final defaultIcon = keyboardIcons[0];
  static final defaultColor = keyboardColors[0];
  //フォーム
  final TextEditingController categoryNameController = TextEditingController();
  //customKeyboard用
  late ValueNotifier<IconData> cateoryIconNotifer;
  late ValueNotifier<Color> cateoryColorNotifer;
  //FocusNode
  final CustomFocusNode categoryNameNode = CustomFocusNode();
  final CustomFocusNode categoryIconNode = CustomFocusNode();
  final CustomFocusNode categoryColorNode = CustomFocusNode();

  @override
  void initState() {
    super.initState();
    final selectCategoryProvider = ref.read(selectCategoryNotifierProvider);
    cateoryIconNotifer =
        ValueNotifier<IconData>(selectCategoryProvider?.icon ?? defaultIcon);
    cateoryColorNotifer =
        ValueNotifier<Color>(selectCategoryProvider?.color ?? defaultColor);
    categoryNameController.text = selectCategoryProvider?.name ?? "";

    categoryNameNode.addListener(_categoryNameFocusChange);
  }

  bool categoryNameHasFocus = false;
  void _categoryNameFocusChange() {
    if (categoryNameHasFocus != categoryNameNode.hasFocus) {
      setState(() {
        categoryNameHasFocus = categoryNameNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    categoryNameController.removeListener(_categoryNameFocusChange);
    categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);
    final selectCategoryProvider = ref.watch(selectCategoryNotifierProvider);
    final categoryListProvider =
        ref.read(categoryListNotifierProvider.notifier);
    final subCategoryListProvider = ref.watch(subCategoryListNotifierProvider);
    final int numOfCategory = subCategoryListProvider.value?.length ?? 0;

    final CategoryKeyboardAction categoryKeyboardAction =
        CategoryKeyboardAction(
      categoryNameController: categoryNameController,
      cateoryIconNotifer: cateoryIconNotifer,
      cateoryColorNotifer: cateoryColorNotifer,
      categoryNameNode: categoryNameNode,
      categoryIconNode: categoryIconNode,
      categoryColorNode: categoryColorNode,
    );

    //ダイアログ
    void openDialog({
      required BuildContext context,
      required String title,
      required String text,
      required Future Function() onTap,
    }) async {
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
                  Text(
                    "カテゴリー$title",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: large),
                  Text(text, textAlign: TextAlign.center),
                  const SizedBox(height: large),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(
                              color: theme.colorScheme.primary, width: 1.3),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(containreBorderRadius),
                          ),
                        ),
                        child: const SizedBox(
                            width: 75,
                            child: Text("キャンセル", textAlign: TextAlign.center)),
                      ),
                      FilledButton(
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
                        child: SizedBox(
                            width: 75,
                            child: Text(title, textAlign: TextAlign.center)),
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

    //フォームビルダー
    Widget Function(BuildContext, T, bool?) categoryFormBulder<T>(
        String title, Widget Function(T) inputWidgetBuilder) {
      return (context, val, hasFocus) {
        return Container(
          margin: mediumEdgeInsets,
          height: formItemHeight,
          child: Row(
            children: [
              SizedBox(
                width: formItemNameWidth,
                child: Text(title, textAlign: TextAlign.center),
              ),
              const SizedBox(width: medium),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
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
                    decoration: BoxDecoration(
                      borderRadius: formInputBoarderRadius,
                      color: theme.colorScheme.surfaceBright,
                    ),
                    height: formItemHeight,
                    child: inputWidgetBuilder(val),
                  ),
                ),
              ),
            ],
          ),
        );
      };
    }

    return Container(
      color: theme.colorScheme.surfaceContainer,
      child: KeyboardActions(
        keepFocusOnTappingNode: true,
        autoScroll: true,
        overscroll: 10,
        tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
        config: categoryKeyboardAction.buildConfig(context),
        child: Padding(
          padding: EdgeInsets.only(bottom: medium),
          child: Padding(
            padding: viewEdgeInsets,
            child: Column(
              children: [
                //-----カテゴリーカード表示-----
                ValueListenableBuilder(
                  valueListenable: cateoryColorNotifer,
                  builder: (context, color, _) {
                    return Container(
                      width: categoryCardHeight,
                      height: categoryCardWidth,
                      padding: smallEdgeInsets,
                      margin: mediumEdgeInsets,
                      decoration: BoxDecoration(
                        border: Border.all(color: color, width: 3),
                        borderRadius: BorderRadius.circular(small),
                      ),
                      child: Column(
                        children: [
                          ValueListenableBuilder(
                            valueListenable: cateoryIconNotifer,
                            builder: (BuildContext context, iconData, _) {
                              return Icon(
                                iconData,
                                color: color,
                                size: 60,
                                weight: 300,
                              );
                            },
                          ),
                          const Spacer(),
                          ValueListenableBuilder(
                            valueListenable: categoryNameController,
                            builder: (BuildContext context, value, _) {
                              return Text(
                                categoryNameController.text,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 13,
                                ),
                              );
                            },
                          ),
                          const Spacer(),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: medium),

                //-----フォーム-----
                Form(
                  key: widget.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //カテゴリ名
                      categoryFormBulder<String>(
                        "カテゴリー名",
                        (_) => TextFormField(
                          autofocus: false,
                          onChanged: (value) => ref
                              .read(doneButtonProvider.notifier)
                              .setState(value),
                          // Form送信処理
                          onSaved: (value) async {
                            if (value?.trim().isNotEmpty ?? false) {
                              debugPrint("send form");
                              if (selectCategoryProvider == null) {
                                debugPrint("insert");

                                await categoryListProvider
                                    .insertCategory(
                                        name: value!.trim(),
                                        icon: cateoryIconNotifer.value,
                                        color: cateoryColorNotifer.value)
                                    .catchError(
                                        (err) => {debugPrint(err.toString())});
                              } else {
                                debugPrint("edit");
                                await categoryListProvider.updateCategory(
                                    selectCategoryProvider.copyWith(
                                        name: value!.trim(),
                                        icon: cateoryIconNotifer.value,
                                        color: cateoryColorNotifer.value));
                              }
                              navigator.pop();
                            }
                          },
                          focusNode: categoryNameNode,
                          keyboardType: TextInputType.text,
                          controller: categoryNameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: smallHorizontalEdgeInsets,
                          ),
                        ),
                      )(context, "val", categoryNameHasFocus),

                      //アイコン
                      KeyboardCustomInput<IconData>(
                        focusNode: categoryIconNode,
                        notifier: cateoryIconNotifer,
                        builder: categoryFormBulder<IconData>(
                          "アイコン",
                          (val) => Icon(
                            val,
                            size: 30,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),

                      //色
                      KeyboardCustomInput<Color>(
                        focusNode: categoryColorNode,
                        notifier: cateoryColorNotifer,
                        builder: categoryFormBulder<Color>(
                          "カラー",
                          (val) => Container(
                            decoration: BoxDecoration(
                              color: val,
                              borderRadius: formInputInnerBoarderRadius,
                            ),
                          ),
                        ),
                      ),

                      if (selectCategoryProvider != null)
                        Column(
                          children: [
                            //サブカテゴリー
                            Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: formInputInnerBoarderRadius),
                              margin: mediumEdgeInsets,
                              child: Column(
                                children: [
                                  Container(
                                    height: listHeight,
                                    color: theme.colorScheme.outline,
                                    alignment: Alignment.centerLeft,
                                    padding:
                                        const EdgeInsets.only(left: medium),
                                    child: Text(
                                      "サブカテゴリー",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: theme
                                              .colorScheme.onInverseSurface,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  for (int i = 0; i < numOfCategory; i++) ...{
                                    SubCategoryListItem(
                                      category:
                                          subCategoryListProvider.value![i],
                                    ),
                                    Divider(
                                      height: 0,
                                      thickness: 0.2,
                                      color: theme.colorScheme.outline,
                                    ),
                                  },
                                  const SubCategoryListItem(
                                    isNewAdd: true,
                                    category: null,
                                  )
                                ],
                              ),
                            ),

                            const SizedBox(height: medium),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                //カテゴリー移行
                                OutlinedButton(
                                  onPressed: () => openDialog(
                                    context: context,
                                    title: moveCategoryTitle,
                                    text:
                                        '"${selectCategoryProvider.name}"$moveDialogText',
                                    onTap: () => categoryListProvider
                                        .deleteCategoryFromId(
                                            selectCategoryProvider.id!),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme.colorScheme.primary,
                                    side: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 1.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          containreBorderRadius),
                                    ),
                                  ),
                                  child: const Text("カテゴリー$moveCategoryTitle"),
                                ),
                                //カテゴリー削除
                                OutlinedButton(
                                  onPressed: () => openDialog(
                                    context: context,
                                    title: delCategoryTitle,
                                    text:
                                        '"${selectCategoryProvider.name}"$delDialogText',
                                    onTap: () => categoryListProvider
                                        .deleteCategoryFromId(
                                            selectCategoryProvider.id!),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme.colorScheme.primary,
                                    side: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 1.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          containreBorderRadius),
                                    ),
                                  ),
                                  child: const Text("カテゴリー$delCategoryTitle"),
                                ),
                              ],
                            ),
                            const SizedBox(height: large),
                          ],
                        ),
                    ],
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

//カテゴリカード
class CategoryCard extends StatelessWidget {
  final String categoryName;
  final Color color;
  final IconData iconData;
  const CategoryCard({
    super.key,
    required this.categoryName,
    required this.color,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(small),
      ),
      padding: smallEdgeInsets,
      child: Column(
        children: [
          Icon(
            iconData,
            color: color,
          ),
          Text(
            categoryName,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}

//サブカテゴリーListItem
class SubCategoryListItem extends HookConsumerWidget {
  final Category? category;
  final bool isNewAdd;
  const SubCategoryListItem({
    super.key,
    required this.category,
    this.isNewAdd = false,
  });
  final String _defaultName = "新規追加";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final listItemColor = useState<Color>(theme.colorScheme.surfaceBright);
    final GoRouter goRoute = GoRouter.of(context);
    final Color defaultColor = theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ref
            .read(selectSubCategoryNotifierProvider.notifier)
            .updateCategory(category);
        ref.read(doneButtonProvider.notifier).setState(category?.name);
        goRoute.go('/setting/category_list/category_edit/sub_category_edit');
      },
      onTapDown: (_) =>
          {listItemColor.value = theme.colorScheme.surfaceContainerHighest},
      onTapUp: (_) => {listItemColor.value = theme.colorScheme.surfaceBright},
      onTapCancel: () =>
          {listItemColor.value = theme.colorScheme.surfaceBright},
      child: AnimatedContainer(
        color: listItemColor.value,
        height: listHeight,
        duration: listItemAnimationDuration,
        padding: const EdgeInsets.fromLTRB(medium, small, medium, small),
        child: Row(
          children: [
            isNewAdd
                ? Icon(
                    Symbols.variable_add,
                    color: defaultColor,
                  )
                : Container(
                    padding: sssmallEdgeInsets,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: category?.color ?? defaultColor,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      category?.icon,
                      color: category?.color ?? defaultColor,
                      size: 16,
                      weight: 600,
                    ),
                  ),
            const SizedBox(width: small),
            Text(category?.name ?? _defaultName),
            const Spacer(),
            Icon(Symbols.chevron_right,
                weight: 300,
                size: 25,
                color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
