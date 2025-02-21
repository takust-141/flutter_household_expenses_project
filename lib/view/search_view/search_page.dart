import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/ad_helper.dart';
import 'package:household_expense_project/component/custom_register_list_view/custom_register_list.dart';
import 'package:household_expense_project/constant/dimension.dart';
import 'package:household_expense_project/provider/search_page_provider.dart';

//-------検索ページ---------------------------
class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FocusNode? searchFocusNode =
        ref.watch(searchPageProvider).valueOrNull?.searchFocusNode;
    final registerList = ref.watch(searchPageProvider
            .select((p) => p.valueOrNull?.searchRegisterList)) ??
        [];

    return SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (_) => {searchFocusNode?.unfocus()},
        child: Column(
          children: [
            Expanded(
              child: CustomRegisterList(
                registerList: registerList,
                isDisplayYear: true,
                registerEditProvider: searchPageProvider,
              ),
            ),
            const AdaptiveAdBanner(3, key: GlobalObjectKey("search_ad"))
          ],
        ),
      ),
    );
  }
}

//
//---検索ページ用appバー
class SearchAppBar extends HookConsumerWidget {
  const SearchAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final FocusNode? searchFocusNode = ref.watch(
        searchPageProvider.select((p) => p.valueOrNull?.searchFocusNode));
    final TextEditingController? searchTextController = ref.watch(
        searchPageProvider.select((p) => p.valueOrNull?.searchTextController));
    final cancelIconColor =
        useState<Color?>(theme.colorScheme.onSurfaceVariant);

    return Container(
      padding: appbarSearchPadding,
      height: 60,
      child: TextField(
        controller: searchTextController,
        focusNode: searchFocusNode,
        onSubmitted: (_) =>
            {ref.read(searchPageProvider.notifier).searchRegister()},
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.all(7),
          prefixIconConstraints: const BoxConstraints(maxHeight: 30),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.search,
              size: 20,
            ),
          ),
          suffixIconConstraints:
              const BoxConstraints(maxHeight: 30, maxWidth: 35),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 7),
            child: IconButton(
              iconSize: 80,
              splashRadius: 10,
              padding: const EdgeInsets.all(5),
              onPressed: () => {searchTextController?.clear()},
              icon: Icon(
                Icons.cancel,
                color: cancelIconColor.value,
                size: 20,
              ),
              splashColor: theme.colorScheme.surface.withValues(alpha: 0.5),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: formInputBoarderRadius,
          ),
        ),
      ),
    );
  }
}
