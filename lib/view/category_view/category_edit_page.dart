import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/component/category_component.dart';
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
  final bool isSubPage;
  const CategoryEditPage({this.formKey, this.isSubPage = false, super.key});

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

  final _categoryKey = GlobalKey();

  late final String categoryTitle;
  late Category? selectedCategory;
  late final CategoryNotifier currentListProvider;

  @override
  void initState() {
    super.initState();

    final selectSubCategoryProvider =
        ref.read(selectSubCategoryNotifierProvider);

    if (widget.isSubPage) {
      categoryTitle = "サブカテゴリー";
      currentListProvider = ref.read(subCategoryListNotifierProvider.notifier);
      selectedCategory = ref.read(selectSubCategoryNotifierProvider);
      cateoryIconNotifer = ValueNotifier<IconData>(
          selectSubCategoryProvider?.icon ??
              selectedCategory?.icon ??
              defaultIcon);
      cateoryColorNotifer = ValueNotifier<Color>(
          selectSubCategoryProvider?.color ??
              selectedCategory?.color ??
              defaultColor);
      categoryNameController.text = selectSubCategoryProvider?.name ?? "";
    } else {
      categoryTitle = "カテゴリー";
      currentListProvider = ref.read(categoryListNotifierProvider.notifier);
      selectedCategory = ref.read(selectCategoryNotifierProvider);
      cateoryIconNotifer =
          ValueNotifier<IconData>(selectedCategory?.icon ?? defaultIcon);
      cateoryColorNotifer =
          ValueNotifier<Color>(selectedCategory?.color ?? defaultColor);
      categoryNameController.text = selectedCategory?.name ?? "";
    }

    categoryNameNode.addListener(_categoryNameFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
          _categoryKey.currentContext?.findRenderObject() as RenderBox?;
      categoryNameNode.setRenderBox(renderBox);
    });
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
    categoryNameNode.dispose();
    categoryIconNode.dispose();
    categoryColorNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);

    final categoryListProvider =
        ref.read(categoryListNotifierProvider.notifier);

    final subCategoryListProvider = ref.watch(subCategoryListNotifierProvider);

    final int numOfCategory =
        ref.read(subCategoryListNotifierProvider).value?.length ?? 0;

    final CategoryKeyboardAction categoryKeyboardAction =
        CategoryKeyboardAction(
      categoryNameController: categoryNameController,
      cateoryIconNotifer: cateoryIconNotifer,
      cateoryColorNotifer: cateoryColorNotifer,
      categoryNameNode: categoryNameNode,
      categoryIconNode: categoryIconNode,
      categoryColorNode: categoryColorNode,
    );

    void resetSelectCategory(bool isSub) {
      if (isSub) {
        ref
            .read(selectSubCategoryNotifierProvider.notifier)
            .updateCategory(null);
      } else {
        ref.read(selectCategoryNotifierProvider.notifier).updateCategory(null);
      }
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
          padding: const EdgeInsets.only(bottom: medium),
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
                      Padding(
                        padding: mediumEdgeInsets,
                        child: categoryFormBulder<String>(
                          title: widget.isSubPage
                              ? "サブ\nカテゴリー名"
                              : "$categoryTitle名",
                          key: _categoryKey,
                          onTap: () => categoryNameNode.requestFocus(),
                          inputWidgetBuilder: (_) => TextFormField(
                            autofocus: false,
                            onChanged: (value) => ref
                                .read(doneButtonProvider.notifier)
                                .setState(value),
                            // Form送信処理
                            onSaved: (value) async {
                              //registerから新規登録した際のパラメーター
                              ref
                                  .read(registerCategoryStateNotifierProvider
                                      .notifier)
                                  .setAddCategory();

                              if (value?.trim().isNotEmpty ?? false) {
                                debugPrint("send form");
                                if (selectedCategory == null) {
                                  debugPrint("insert");
                                  widget.isSubPage
                                      ? await (currentListProvider
                                              as SubCategoryNotifier)
                                          .insertSubCategory(
                                              name: value!.trim(),
                                              icon: cateoryIconNotifer.value,
                                              color: cateoryColorNotifer.value,
                                              parentId: ref
                                                  .read(
                                                      selectCategoryNotifierProvider)!
                                                  .id!)
                                          .catchError((err) =>
                                              {debugPrint(err.toString())})
                                      : await currentListProvider
                                          .insertCategory(
                                              name: value!.trim(),
                                              icon: cateoryIconNotifer.value,
                                              color: cateoryColorNotifer.value)
                                          .catchError((err) =>
                                              {debugPrint(err.toString())});
                                } else {
                                  debugPrint("edit");
                                  await currentListProvider.updateCategory(
                                      selectedCategory!.copyWith(
                                          name: value!.trim(),
                                          icon: cateoryIconNotifer.value,
                                          color: cateoryColorNotifer.value));
                                }
                                resetSelectCategory(widget.isSubPage);
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
                      ),

                      //アイコン
                      Padding(
                        padding: mediumEdgeInsets,
                        child: KeyboardCustomInput<IconData>(
                          focusNode: categoryIconNode,
                          notifier: cateoryIconNotifer,
                          builder: categoryFormBulder<IconData>(
                            title: "アイコン",
                            inputWidgetBuilder: (val) => Icon(
                              val,
                              size: 30,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),

                      //色
                      Padding(
                        padding: mediumEdgeInsets,
                        child: KeyboardCustomInput<Color>(
                          focusNode: categoryColorNode,
                          notifier: cateoryColorNotifer,
                          builder: categoryFormBulder<Color>(
                            title: "カラー",
                            inputWidgetBuilder: (val) => Container(
                              decoration: BoxDecoration(
                                color: val,
                                borderRadius: formInputInnerBoarderRadius,
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (selectedCategory != null)
                        Column(
                          children: [
                            if (!widget.isSubPage)
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
                                        '"${selectedCategory!.name}"$moveDialogText',
                                    onTap: () async {
                                      await categoryListProvider
                                          .deleteCategoryFromId(
                                              selectedCategory!.id!);
                                      resetSelectCategory(widget.isSubPage);
                                    },
                                    isSubCategory: widget.isSubPage,
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
                                  child:
                                      Text(categoryTitle + moveCategoryTitle),
                                ),
                                //カテゴリー削除
                                OutlinedButton(
                                  onPressed: () => openDialog(
                                    context: context,
                                    title: delCategoryTitle,
                                    text:
                                        '"${selectedCategory!.name}"$delDialogText',
                                    onTap: () async {
                                      await categoryListProvider
                                          .deleteCategoryFromId(
                                              selectedCategory!.id!);
                                      resetSelectCategory(widget.isSubPage);
                                    },
                                    isSubCategory: widget.isSubPage,
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
                                  child: Text(categoryTitle + delCategoryTitle),
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
        goRoute.push('/setting/category_list/category_edit/sub_category_edit');
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
