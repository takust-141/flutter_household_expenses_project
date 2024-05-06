import 'package:flutter/material.dart';
import 'package:keyboard_actions/external/keyboard_avoider/bottom_area_avoider.dart';
import 'package:provider/provider.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:household_expenses_project/model/my_app_state.dart';
import 'package:household_expenses_project/constant/constant.dart';

//-------ページ１（ホーム）---------------------------
class SettingPage extends StatelessWidget {
  SettingPage({super.key});
  //フォームコントローラー
  final _firstNameTextController = TextEditingController();
  final _lastNameTextController = TextEditingController();
  final _usernameTextController = TextEditingController();

  //キーボード
  final CustomFocusNode _nodeText1 = CustomFocusNode();
  final CustomFocusNode _nodeText2 = CustomFocusNode();
  final CustomFocusNode _nodeText3 = CustomFocusNode();
  final CustomFocusNode _nodeText4 = CustomFocusNode();
  final CustomFocusNode _nodeText5 = CustomFocusNode();
  final CustomFocusNode _nodeText6 = CustomFocusNode();
  final CustomFocusNode _nodeText7 = CustomFocusNode();
  final CustomFocusNode _nodeText9 = CustomFocusNode();
  final CustomFocusNode _nodeText10 = CustomFocusNode();

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: customKeyboardBarColor,
      nextFocus: true,
      defaultDoneWidget: const Icon(Icons.keyboard),
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
        ),
        KeyboardActionsItem(focusNode: _nodeText2, toolbarButtons: [
          (node) {
            return GestureDetector(
              onTap: () => _nodeText5.requestFocus(),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close),
              ),
            );
          }
        ]),
        KeyboardActionsItem(
          focusNode: _nodeText3,
        ),
        KeyboardActionsItem(
          focusNode: _nodeText4,
        ),
        KeyboardActionsItem(
          focusNode: _nodeText5,
        ),
        KeyboardActionsItem(
          focusNode: _nodeText6,
        ),
        KeyboardActionsItem(
          focusNode: _nodeText7,
        ),
        KeyboardActionsItem(
          focusNode: _nodeText9,
        ),
        KeyboardActionsItem(
          focusNode: _nodeText10,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return KeyboardActions(
      //bottomAvoiderScrollPhysics:,
      autoScroll: true,
      keepFocusOnTappingNode: true,
      //overscroll: 100,
      //tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
      config: _buildConfig(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              debugPrint("Press");
            },
            child: Text("aaa"),
          ),
          //カテゴリ
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _lastNameTextController,
              focusNode: _nodeText1,
              decoration: const InputDecoration(hintText: 'カテゴリ1'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              keyboardType: TextInputType.number,
              focusNode: _nodeText2,
              controller: _usernameTextController,
              decoration: const InputDecoration(hintText: 'カテゴリ2'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              keyboardType: TextInputType.number,
              focusNode: _nodeText3,
              controller: _usernameTextController,
              decoration: const InputDecoration(hintText: 'カテゴリ3'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              keyboardType: TextInputType.number,
              focusNode: _nodeText4,
              controller: _usernameTextController,
              decoration: const InputDecoration(hintText: 'カテゴリ4'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              keyboardType: TextInputType.datetime,
              focusNode: _nodeText5,
              controller: _usernameTextController,
              decoration: const InputDecoration(hintText: 'カテゴリ5'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              keyboardType: TextInputType.datetime,
              focusNode: _nodeText6,
              controller: _usernameTextController,
              decoration: const InputDecoration(hintText: 'カテゴリ6'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              keyboardType: TextInputType.datetime,
              focusNode: _nodeText7,
              controller: _usernameTextController,
              decoration: const InputDecoration(hintText: 'カテゴリ7'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              keyboardType: TextInputType.datetime,
              controller: _usernameTextController,
              decoration: const InputDecoration(hintText: 'カテゴリ2'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              keyboardType: TextInputType.datetime,
              controller: _usernameTextController,
              decoration: const InputDecoration(hintText: 'カテゴリ2'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              keyboardType: TextInputType.datetime,
              focusNode: _nodeText9,
              controller: _usernameTextController,
              decoration: const InputDecoration(hintText: 'カテゴリ9'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              keyboardType: TextInputType.datetime,
              focusNode: _nodeText10,
              controller: _usernameTextController,
              decoration: const InputDecoration(hintText: 'カテゴリ10'),
            ),
          ),
          //SizedBox(height: mediaQuery.viewInsets.bottom),
          SizedBox(height: mediaQuery.padding.bottom),
        ],
      ),
    );
  }
}
