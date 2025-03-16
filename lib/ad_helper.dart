import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:household_expense_project/provider/setting_remove_ad_provider.dart';

//広告高さ考慮用Provider
final adNotifierProvider =
    NotifierProvider<AdStateNotifier, AdState>(AdStateNotifier.new);

@immutable
class AdState {
  final AdSize? adSize;

  const AdState({
    required this.adSize,
  });

  AdState copyWith({
    AdSize? adSize,
  }) {
    return AdState(
      adSize: adSize ?? this.adSize,
    );
  }
}

class AdStateNotifier extends Notifier<AdState> {
  @override
  AdState build() {
    return const AdState(
      adSize: null,
    );
  }

  Future<void> initAdState(BuildContext context) async {
    final ProductState settingRemoveAdState = await ref.read(
        settingRemoveAdProvider.selectAsync((p) => p.removedAdProductState));

    late final AdSize? adSize;
    if (settingRemoveAdState != ProductState.purchased) {
      if (context.mounted) {
        adSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
          MediaQuery.of(context).size.width.truncate(),
        ) as AdSize;
      } else {
        adSize = AdSize.banner;
      }
    } else {
      adSize = null;
    }

    state = state.copyWith(adSize: adSize);
    debugPrint("comp initAdState");
  }

  void removeAd() {
    state = AdState(adSize: null);
  }
}

//
//Helper
class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (kProfileMode || kReleaseMode) {
        return 'ca-app-pub-1911558515475737/7713318577';
      }
    } else if (Platform.isIOS) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/2934735716';
      } else if (kProfileMode || kReleaseMode) {
        return 'ca-app-pub-1911558515475737/2064270603';
      }
    }
    throw UnsupportedError('Unsupported platform');
  }
}

//
//widget
class AdaptiveAdBanner extends HookConsumerWidget {
  const AdaptiveAdBanner(this.page, {super.key, this.setAdHeight});

  final int page; //0:register、1:calendar、2:chart、3:search、4:setting
  final ValueChanged<double>? setAdHeight;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(settingRemoveAdProvider).valueOrNull?.removedAdProductState ==
        ProductState.purchased) {
      //広告削除済みの場合
      return SizedBox.shrink();
    } else {
      //未削除
      final adSize = ref.watch(adNotifierProvider.select((p) => p.adSize)) ??
          AdSize.banner;
      String? adUnitId;
      try {
        adUnitId = AdHelper.bannerAdUnitId;
      } catch (e) {
        debugPrint("Ad platform is not found");
      }

      final isLoaded = useState<bool>(false);
      final bannerAd = useMemoized(
          () => (adUnitId != null)
              ? BannerAd(
                  size: adSize,
                  adUnitId: adUnitId,
                  listener: BannerAdListener(
                    onAdFailedToLoad: (ad, error) {
                      ad.dispose();
                    },
                    onAdLoaded: (ad) {
                      isLoaded.value = true;
                    },
                  ),
                  request: const AdRequest(),
                )
              : null,
          [adUnitId]);

      useEffect(() {
        bannerAd?.load();
        return () async => await bannerAd?.dispose();
      }, [bannerAd]);

      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        width: adSize.width.toDouble(),
        height: adSize.height.toDouble(),
        child: (isLoaded.value && bannerAd != null)
            ? AdWidget(key: Key(page.toString()), ad: bannerAd)
            : SizedBox.shrink(),
      );
    }
  }
}
