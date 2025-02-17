import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    return const AdState(adSize: null);
  }

  Future<void> initAdState(BuildContext context) async {
    final adSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    ) as AdSize;

    state = AdState(adSize: adSize);
  }
}

//
//Helper
class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        //test
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (kReleaseMode) {
        return 'ca-app-pub-1911558515475737/7713318577';
      }
    } else if (Platform.isIOS) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/2934735716';
      } else if (kReleaseMode) {
        return 'ca-app-pub-1911558515475737/2064270603';
      }
    }
    throw UnsupportedError('Unsupported platform');
  }
}

//
//widget
class AdaptiveAdBanner extends HookConsumerWidget {
  const AdaptiveAdBanner({super.key, this.setAdHeight});

  final ValueChanged<double>? setAdHeight;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adSize =
        ref.watch(adNotifierProvider.select((p) => p.adSize)) ?? AdSize.banner;

    final bannerAd = useState<BannerAd?>(null);

    useEffect(() {
      debugPrint("useeffect");
      BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        request: const AdRequest(),
        size: adSize,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            bannerAd.value = ad as BannerAd;
            debugPrint("load ad");
          },
          onAdFailedToLoad: (ad, err) {
            ad.dispose();
          },
        ),
      ).load();
      return () {
        bannerAd.value?.dispose();
        bannerAd.value = null;
      };
    }, []);

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      width: adSize.width.toDouble(),
      height: adSize.height.toDouble(),
      child: (bannerAd.value != null)
          ? AdWidget(ad: bannerAd.value!)
          : SizedBox.shrink(),
    );
  }
}
