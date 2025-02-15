import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/component/category_component.dart';
import 'package:household_expense_project/component/customed_setting_keyboard.dart';
import 'package:household_expense_project/component/setting_component.dart';
import 'package:household_expense_project/constant/keyboard_components.dart';
import 'package:household_expense_project/model/category.dart';
import 'package:household_expense_project/provider/app_bar_provider.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/provider/category_list_provider.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:household_expense_project/constant/constant.dart';

//-------カテゴリ編集ページ---------------------------
class CategoryEditPage extends ConsumerStatefulWidget {
  final GlobalKey<FormState>? formKey;
  final bool isSubPage;
  final int providerIndex;
  const CategoryEditPage({
    this.formKey,
    this.isSubPage = false,
    required this.providerIndex,
    super.key,
  });

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
  late final CategoryKeyboardAction categoryKeyboardAction;

  late final String categoryTitle;
  late Category? selectedCategory;

  //provider
  late final NotifierProvider<SelectCategoryStateNotifier, SelectCategoryState>
      selectCategoryprovider;

  @override
  void initState() {
    super.initState();
    selectCategoryprovider = selectCategoryProviderList[widget.providerIndex];
    if (widget.isSubPage) {
      selectedCategory =
          ref.read(selectCategoryprovider.select((p) => p.subCategory));
      final parentCategory =
          ref.read(selectCategoryprovider.select((p) => p.category));
      categoryTitle = "サブカテゴリー";
      cateoryIconNotifer = ValueNotifier<IconData>(
          selectedCategory?.icon ?? parentCategory?.icon ?? defaultIcon);
      cateoryColorNotifer = ValueNotifier<Color>(
          selectedCategory?.color ?? parentCategory?.color ?? defaultColor);
      categoryNameController.text = selectedCategory?.name ?? "";
    } else {
      selectedCategory =
          ref.read(selectCategoryprovider.select((p) => p.category));
      categoryTitle = "カテゴリー";
      cateoryIconNotifer =
          ValueNotifier<IconData>(selectedCategory?.icon ?? defaultIcon);
      cateoryColorNotifer =
          ValueNotifier<Color>(selectedCategory?.color ?? defaultColor);
      categoryNameController.text = selectedCategory?.name ?? "";
    }

    categoryKeyboardAction = CategoryKeyboardAction(
      categoryNameController: categoryNameController,
      cateoryIconNotifer: cateoryIconNotifer,
      cateoryColorNotifer: cateoryColorNotifer,
      categoryNameNode: categoryNameNode,
      categoryIconNode: categoryIconNode,
      categoryColorNode: categoryColorNode,
    );

    categoryNameNode.addListener(_categoryNameFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      categoryNameNode.attach(_categoryKey.currentContext);
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
    cateoryIconNotifer.dispose();
    cateoryColorNotifer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);

    final categoryListProvider =
        ref.read(categoryListNotifierProvider.notifier);
    final selectCategoryStateNotifier =
        ref.read(selectCategoryprovider.notifier);

    final subCategoryListProvider =
        ref.watch(selectCategoryprovider.select((p) => p.subCategoryList));

    final currentExpense =
        ref.watch(selectCategoryprovider.select((p) => p.selectExpense));

    final int numOfSubCategory = ref
            .read(selectCategoryprovider.select((p) => p.subCategoryList))
            ?.length ??
        0;

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
                      width: categoryCardWidth,
                      height: categoryCardHeight,
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
                              return AutoSizeText(
                                categoryNameController.text,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                minFontSize: 11,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: color,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.fontSize,
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
                          onTap: () {
                            categoryNameNode.requestFocus();
                          },
                          inputWidgetBuilder: (_) => TextFormField(
                            autofocus: false,
                            onChanged: (value) => ref
                                .read(appBarProvider.notifier)
                                .updateActiveCategoryDoneButton(value),
                            // Form送信処理
                            onSaved: (value) async {
                              if (value?.trim().isNotEmpty ?? false) {
                                //selectがnullの場合は新規追加
                                if (selectedCategory == null) {
                                  widget.isSubPage
                                      ? await selectCategoryStateNotifier
                                          .insertSubCategoryOfDB(
                                            name: value!.trim(),
                                            icon: cateoryIconNotifer.value,
                                            color: cateoryColorNotifer.value,
                                            expense: currentExpense,
                                            context: context,
                                          )
                                          .catchError((err) =>
                                              {debugPrint(err.toString())})
                                      : await categoryListProvider
                                          .insertCategory(
                                            name: value!.trim(),
                                            icon: cateoryIconNotifer.value,
                                            color: cateoryColorNotifer.value,
                                            expense: currentExpense,
                                            context: context,
                                          )
                                          .catchError((err) =>
                                              {debugPrint(err.toString())});

                                  //registerPageから新規登録したカテゴリーをselect
                                  if (selectCategoryprovider ==
                                      registerCategoryStateNotifierProvider) {
                                    await selectCategoryStateNotifier
                                        .setNextInitStateAddCategory(
                                            widget.isSubPage);
                                  }
                                } else {
                                  widget.isSubPage
                                      ? await selectCategoryStateNotifier
                                          .updateCategoryOfDB(
                                              selectedCategory!.copyWith(
                                                  name: value!.trim(),
                                                  icon:
                                                      cateoryIconNotifer.value,
                                                  color: cateoryColorNotifer
                                                      .value),
                                              context)
                                      : await categoryListProvider
                                          .updateCategory(
                                              selectedCategory!.copyWith(
                                                  name: value!.trim(),
                                                  icon:
                                                      cateoryIconNotifer.value,
                                                  color: cateoryColorNotifer
                                                      .value),
                                              context);
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
                                      color: theme.colorScheme.onSurfaceVariant,
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          const EdgeInsets.only(left: medium),
                                      child: Text(
                                        "サブカテゴリー",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: theme.colorScheme.surface,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    for (int i = 0;
                                        i < numOfSubCategory;
                                        i++) ...{
                                      SubCategoryListItem(
                                        category: subCategoryListProvider![i],
                                        provider: selectCategoryprovider,
                                      ),
                                      Divider(
                                        height: 0,
                                        thickness: 0.2,
                                        color: theme.colorScheme.outline,
                                      ),
                                    },
                                    SubCategoryListItem(
                                      isNewAdd: true,
                                      category: null,
                                      provider: selectCategoryprovider,
                                    )
                                  ],
                                ),
                              ),
                            const SizedBox(height: medium),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                //カテゴリー移行
                                const SizedBox(width: medium),
                                Expanded(
                                  flex: 1,
                                  child: OutlinedButton(
                                    onPressed: () => openDialog(
                                      context: context,
                                      title: (widget.isSubPage
                                              ? "サブカテゴリー"
                                              : "カテゴリー") +
                                          moveCategoryTitle,
                                      text:
                                          '"${selectedCategory!.name}"$moveDialogText',
                                      buttonText: moveCategoryTitle,
                                      onTap: () async {
                                        if (widget.isSubPage) {
                                          await selectCategoryStateNotifier
                                              .deleteCategoryFromId(
                                                  selectedCategory!.id!,
                                                  context);
                                        } else {
                                          await categoryListProvider
                                              .deleteCategoryFromId(
                                                  selectedCategory!.id!,
                                                  context);
                                        }
                                      },
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: smallEdgeInsets,
                                      foregroundColor:
                                          theme.colorScheme.primary,
                                      side: BorderSide(
                                          color: theme.colorScheme.primary,
                                          width: 1.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            containreBorderRadius),
                                      ),
                                    ),
                                    child: AutoSizeText(
                                      categoryTitle + moveCategoryTitle,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: lmedium),
                                //カテゴリー削除
                                Expanded(
                                  flex: 1,
                                  child: OutlinedButton(
                                    onPressed: () => openDialog(
                                      context: context,
                                      title: (widget.isSubPage
                                              ? "サブカテゴリー"
                                              : "カテゴリー") +
                                          delCategoryTitle,
                                      text:
                                          '"${selectedCategory!.name}"$delDialogText',
                                      onTap: () async {
                                        if (widget.isSubPage) {
                                          await selectCategoryStateNotifier
                                              .deleteCategoryFromId(
                                                  selectedCategory!.id!,
                                                  context);
                                        } else {
                                          await categoryListProvider
                                              .deleteCategoryFromId(
                                                  selectedCategory!.id!,
                                                  context);
                                        }
                                      },
                                      buttonText: delCategoryTitle,
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: smallEdgeInsets,
                                      foregroundColor:
                                          theme.colorScheme.primary,
                                      side: BorderSide(
                                          color: theme.colorScheme.primary,
                                          width: 1.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            containreBorderRadius),
                                      ),
                                    ),
                                    child: AutoSizeText(
                                      categoryTitle + delCategoryTitle,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: medium),
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
  final NotifierProvider<SelectCategoryStateNotifier, SelectCategoryState>
      provider;
  const SubCategoryListItem({
    super.key,
    required this.category,
    this.isNewAdd = false,
    required this.provider,
  });
  final String _defaultName = "新規追加";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final listItemColor = useState<Color>(theme.colorScheme.surfaceBright);
    final GoRouter goRoute = GoRouter.of(context);
    final Color defaultColor = theme.colorScheme.onSurfaceVariant;
    useEffect(() {
      listItemColor.value = theme.colorScheme.surfaceBright;
      return () {};
    }, [theme]);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ref.read(provider.notifier).updateSelectSubCategory(category);
        //settingCategoryStateNotifierProviderをセット
        goRoute.push('/setting/category_list/category_edit/sub_category_edit',
            extra: 0);
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
            Expanded(
              child: Text(
                category?.name ?? _defaultName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
