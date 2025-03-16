import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/constant/dimension.dart';
import 'package:household_expense_project/interface/firebase_remote_config.dart';
import 'package:url_launcher/url_launcher.dart';

//Provider
final appVersionProvider =
    AsyncNotifierProvider<AppVersionNotifier, AppVersionState>(
        AppVersionNotifier.new);

//状態管理
@immutable
class AppVersionState {
  final bool needUpdateInfo; //0：不要、1：要
  final bool displayInfoSnackBar;
  const AppVersionState({
    required this.needUpdateInfo,
    required this.displayInfoSnackBar,
  });

  AppVersionState copyWith({
    bool? needUpdateInfo,
    bool? displayInfoSnackBar,
  }) {
    return AppVersionState(
      needUpdateInfo: needUpdateInfo ?? this.needUpdateInfo,
      displayInfoSnackBar: displayInfoSnackBar ?? this.displayInfoSnackBar,
    );
  }

  const AppVersionState.defaultState()
      : needUpdateInfo = false,
        displayInfoSnackBar = false;
}

//Notifier
class AppVersionNotifier extends AsyncNotifier<AppVersionState> {
  @override
  Future<AppVersionState> build() async {
    final needUpdate = await CheckVersionHelper.checkAppVersion();
    return AppVersionState(
      needUpdateInfo: needUpdate,
      displayInfoSnackBar: false,
    );
  }

  void showInformation() {
    final preState = state.valueOrNull ?? AppVersionState.defaultState();
    state = AsyncData(preState.copyWith(displayInfoSnackBar: true));
  }

  void hideInfomation() {
    final preState = state.valueOrNull ?? AppVersionState.defaultState();
    state = AsyncData(preState.copyWith(displayInfoSnackBar: false));
  }
}

class VersionUpdateSnackBar extends ConsumerWidget {
  const VersionUpdateSnackBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return (ref.watch(appVersionProvider
                .select((p) => p.valueOrNull?.displayInfoSnackBar)) ==
            true)
        ? Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                padding: msmallEdgeInsets,
                margin: EdgeInsets.fromLTRB(medium, lmedium, medium, small),
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(ssmall),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "バージョン更新のお知らせ",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "ストアよりアプリをアップデートしてご利用ください",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.surface,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: theme.primaryColor,
                        ),
                        onPressed: () async {
                          String updateUrl;
                          if (Theme.of(context).platform ==
                              TargetPlatform.android) {
                            // Android
                            updateUrl = "https://play.google.com/store/apps/";
                          } else if (Theme.of(context).platform ==
                              TargetPlatform.iOS) {
                            // ios
                            updateUrl =
                                "itms-apps://apps.apple.com/jp/app/id6742489643";
                          } else {
                            return;
                          }
                          debugPrint(Uri.parse(updateUrl).path);
                          if (await canLaunchUrl(Uri.parse(updateUrl))) {
                            launchUrl(Uri.parse(updateUrl));
                          }
                        },
                        child: Text(
                          "更新する",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                width: 26,
                height: 26,
                margin: smallEdgeInsets,
                child: IconButton.filledTonal(
                  alignment: Alignment.topRight,
                  padding: EdgeInsets.all(4),
                  constraints:
                      const BoxConstraints(maxHeight: 26, maxWidth: 26),
                  icon: const Icon(Icons.close),
                  iconSize: 18,
                  onPressed: () =>
                      {ref.read(appVersionProvider.notifier).hideInfomation()},
                ),
              ),
            ],
          )
        : SizedBox.shrink();
  }
}
