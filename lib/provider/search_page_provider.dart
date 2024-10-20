import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expenses_project/model/category.dart';
import 'package:household_expenses_project/model/register.dart';
import 'package:household_expenses_project/provider/register_edit_state.dart';
import 'package:household_expenses_project/provider/register_db_provider.dart';

//Provider
final searchPageProvider =
    AsyncNotifierProvider<SearchPageNotifier, SearchPageState>(
        SearchPageNotifier.new);

@immutable
class SearchPageState implements RegisterEditState {
  final List<Register> searchRegisterList;
  final FocusNode searchFocusNode;
  final TextEditingController searchTextController;

  @override
  final bool isActiveDoneButton;

  const SearchPageState({
    required this.searchRegisterList,
    required this.searchFocusNode,
    required this.isActiveDoneButton,
    required this.searchTextController,
  });

  SearchPageState copyWith({
    List<Register>? searchRegisterList,
    FocusNode? searchFocusNode,
    bool? isActiveDoneButton,
    TextEditingController? searchTextController,
  }) {
    return SearchPageState(
      searchRegisterList: searchRegisterList ?? this.searchRegisterList,
      searchFocusNode: searchFocusNode ?? this.searchFocusNode,
      isActiveDoneButton: isActiveDoneButton ?? this.isActiveDoneButton,
      searchTextController: searchTextController ?? this.searchTextController,
    );
  }
}

//Notifier
class SearchPageNotifier extends RegisterEditStateNotifier<SearchPageState> {
  late final SearchPageState _defaultState;
  @override
  Future<SearchPageState> build() async {
    ref.onDispose(() {
      state.valueOrNull?.searchFocusNode.dispose();
      state.valueOrNull?.searchTextController.dispose();
    });

    _defaultState = SearchPageState(
      searchRegisterList: const [],
      searchFocusNode: FocusNode(),
      isActiveDoneButton: false,
      searchTextController: TextEditingController(),
    );
    return _defaultState;
  }

  //検索実行時
  Future<void> searchRegister() async {
    String? searchText = state.valueOrNull?.searchTextController.text;
    if (searchText != null && searchText.isNotEmpty) {
      state = const AsyncLoading<SearchPageState>().copyWithPrevious(state);
      state = await AsyncValue.guard(() async {
        return state.valueOrNull?.copyWith(
                searchRegisterList:
                    await RegisterDBProvider.getRegisterStateOfText(
                        searchText)) ??
            _defaultState;
      });
    }
  }

  //registerList更新時に検索結果も更新する
  Future<void> reSearchRegister() async {
    String? searchText = state.valueOrNull?.searchTextController.text;
    if (searchText != null && searchText.isNotEmpty) {
      state = const AsyncLoading<SearchPageState>().copyWithPrevious(state);
      state = await AsyncValue.guard(() async {
        return state.valueOrNull?.copyWith(
                searchRegisterList:
                    await RegisterDBProvider.getRegisterStateOfText(
                        searchText)) ??
            _defaultState;
      });
    } else {
      state = AsyncData(
          state.valueOrNull?.copyWith(searchRegisterList: []) ?? _defaultState);
    }
  }

  @override
  void formInputCheck(
      TextEditingController controller, ValueNotifier<Category?> notifier) {
    final bool isActive =
        controller.text.isNotEmpty && (notifier.value != null);
    state = AsyncData(
        state.valueOrNull?.copyWith(isActiveDoneButton: isActive) ??
            _defaultState);
  }

  //新規追加用（検索ページからは新規追加は不可のため、nullを返す）
  @override
  DateTime? currentSelectDate() {
    return null;
  }

  @override
  void initDoneButton() {
    state = AsyncData(state.valueOrNull?.copyWith(isActiveDoneButton: false) ??
        _defaultState);
  }
}
