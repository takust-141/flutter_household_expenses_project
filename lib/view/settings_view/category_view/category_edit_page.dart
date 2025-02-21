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
import 'package:household_expense_project/provider/reorderable_provider.dart';
import 'package:household_expense_project/provider/select_category_provider.dart';
import 'package:household_expense_project/provider/category_list_provider.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:household_expense_project/constant/constant.dart';

//-------カテゴリ編集ページ---------------------------
class CategoryEditPage extends StatefulHookConsumerWidget {
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

    final currentExpense =
        ref.watch(selectCategoryprovider.select((p) => p.selectExpense));

    //hooks
    final ValueNotifier<List<Category>> subCategoryList = useState(
        ref.watch(selectCategoryprovider.select((p) => p.subCategoryList)) ??
            []);
    useEffect(() {
      subCategoryList.value = [
        ...ref.watch(selectCategoryprovider.select((p) => p.subCategoryList)) ??
            []
      ];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(reorderableProvider.notifier).initReorderState();
      });
      return () {};
    }, [ref.watch(selectCategoryprovider.select((p) => p.subCategoryList))]);
    final isReorder =
        ref.watch(reorderableProvider.select((p) => p.isSubCategoryReorder));

    return SafeArea(
      child: Container(
        color: theme.colorScheme.surfaceContainer,
        child: LayoutBuilder(builder: (context, boxConstraints) {
          final double subCategoryAreaheight = boxConstraints.maxHeight -
              (large * 5 +
                  small * 2 +
                  categoryCardHeight +
                  formItemHeight * 4 +
                  listHeight);
          return KeyboardActions(
            keepFocusOnTappingNode: true,
            autoScroll: true,
            overscroll: 10,
            tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
            config: categoryKeyboardAction.buildConfig(context),
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
                  const SizedBox(height: large),

                  //-----フォーム-----
                  Form(
                    key: widget.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //カテゴリ名
                        categoryFormBulder<String>(
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
                        SizedBox(height: small),
                        //アイコン
                        KeyboardCustomInput<IconData>(
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
                        SizedBox(height: small),
                        //色
                        KeyboardCustomInput<Color>(
                          focusNode: categoryColorNode,
                          notifier: cateoryColorNotifer,
                          builder: categoryFormBulder<Color>(
                            title: "カラー",
                            inputWidgetBuilder: (val) => Container(
                              decoration: BoxDecoration(
                                color: val,
                                borderRadius: formInputBoarderRadius,
                              ),
                            ),
                          ),
                        ),

                        if (selectedCategory != null) ...{
                          if (!widget.isSubPage)
                            //サブカテゴリーヘッダ
                            Container(
                              margin: EdgeInsets.only(top: large),
                              height: listHeight,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                    top:
                                        Radius.circular(containreBorderRadius)),
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              padding: const EdgeInsets.only(left: medium),
                              child: Row(
                                children: [
                                  Text(
                                    "サブカテゴリー",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: theme.colorScheme.surface,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Spacer(),
                                  //reorderIconButton
                                  IconButton(
                                    icon: ref
                                            .watch(reorderableProvider)
                                            .isSubCategoryReorder
                                        ? const Icon(Icons.check)
                                        : const Icon(Icons.reorder),
                                    iconSize: IconTheme.of(context).size,
                                    color: theme.colorScheme.surface,
                                    disabledColor:
                                        Theme.of(context).disabledColor,
                                    onPressed: () => {
                                      ref
                                          .read(reorderableProvider.notifier)
                                          .changeSubCategoryReorder(context)
                                    },
                                    style: IconButton.styleFrom(
                                        overlayColor: Colors.transparent),
                                  ),
                                ],
                              ),
                            ),
                          //サブカテゴリーリスト
                          if (!widget.isSubPage)
                            SizedBox(
                              height: subCategoryAreaheight,
                              child: ReorderableListView(
                                buildDefaultDragHandles: false,
                                onReorder: (int oldIndex, int newIndex) {
                                  if (oldIndex < newIndex) {
                                    newIndex -= 1;
                                  }
                                  final Category item =
                                      subCategoryList.value.removeAt(oldIndex);
                                  subCategoryList.value.insert(newIndex, item);

                                  subCategoryList.value = [
                                    ...subCategoryList.value
                                  ]; //useStateリビルド用の再割り当て
                                  //update用セット
                                  ref
                                      .read(reorderableProvider.notifier)
                                      .setReorderSubCategoryList(
                                          subCategoryList.value);
                                },
                                footer: isReorder
                                    ? SizedBox.shrink()
                                    : SubCategoryListItem(
                                        isNewAdd: true,
                                        category: null,
                                        provider: selectCategoryprovider,
                                        isBottom: true,
                                      ),
                                children: [
                                  for (int i = 0;
                                      i < subCategoryList.value.length;
                                      i++) ...{
                                    (isReorder)
                                        ? ReorderableDragStartListener(
                                            key: Key(
                                                "${subCategoryList.value[i].id}"),
                                            index: i,
                                            child: SubCategoryListItem(
                                              key: Key(
                                                  "${subCategoryList.value[i].id}"),
                                              category:
                                                  subCategoryList.value[i],
                                              provider: selectCategoryprovider,
                                              isBottom: isReorder &&
                                                  (i ==
                                                      subCategoryList
                                                              .value.length -
                                                          1),
                                              isDivider: !isReorder ||
                                                  (i !=
                                                      subCategoryList
                                                              .value.length -
                                                          1),
                                            ),
                                          )
                                        : SubCategoryListItem(
                                            key: Key(
                                                "${subCategoryList.value[i].id}"),
                                            category: subCategoryList.value[i],
                                            provider: selectCategoryprovider,
                                            isBottom: isReorder &&
                                                (i ==
                                                    subCategoryList
                                                            .value.length -
                                                        1),
                                            isDivider: !isReorder ||
                                                (i !=
                                                    subCategoryList
                                                            .value.length -
                                                        1),
                                          ),
                                  },
                                ],
                              ),
                            ),
                          SizedBox(height: large),
                          SizedBox(
                            height: formItemHeight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                //カテゴリー移行
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
                                const SizedBox(width: medium),
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
                              ],
                            ),
                          ),
                        }
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
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
  final bool isBottom;
  final bool isDivider;
  const SubCategoryListItem({
    super.key,
    required this.category,
    this.isNewAdd = false,
    required this.provider,
    this.isBottom = false,
    this.isDivider = false,
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
        if (!ref
            .read(reorderableProvider.select((p) => p.isSubCategoryReorder))) {
          ref.read(provider.notifier).updateSelectSubCategory(category);
          //settingCategoryStateNotifierProviderをセット
          goRoute.push('/setting/category_list/category_edit/sub_category_edit',
              extra: 0);
        }
      },
      onTapDown: (_) =>
          {listItemColor.value = theme.colorScheme.surfaceContainerHighest},
      onTapUp: (_) => {listItemColor.value = theme.colorScheme.surfaceBright},
      onTapCancel: () =>
          {listItemColor.value = theme.colorScheme.surfaceBright},
      child: AnimatedContainer(
        height: listHeight,
        duration: listItemAnimationDuration,
        decoration: BoxDecoration(
          color: listItemColor.value,
          border: isDivider
              ? Border(
                  bottom: BorderSide(
                    width: 0.2,
                    color: theme.colorScheme.outline,
                  ),
                )
              : Border(),
          borderRadius: BorderRadius.vertical(
            bottom:
                isBottom ? Radius.circular(containreBorderRadius) : Radius.zero,
          ),
        ),
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
            (ref.watch(
                    reorderableProvider.select((p) => p.isSubCategoryReorder)))
                ? Icon(Symbols.reorder,
                    weight: 300,
                    size: 25,
                    color: theme.colorScheme.onSurfaceVariant)
                : Icon(Symbols.chevron_right,
                    weight: 300,
                    size: 25,
                    color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
