import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

class AdaptiveAdBanner extends StatelessWidget {
  const AdaptiveAdBanner({super.key, this.setAdHeight});

  final ValueChanged<double>? setAdHeight;

  @override
  Widget build(BuildContext context) {
    final adUnitId = AdHelper.bannerAdUnitId;
    return LayoutBuilder(builder: (context, constraint) {
      return HookBuilder(builder: (context) {
        final bannerLoaded = useState(false);
        final bannerAd = useFuture(
          useMemoized(
            () async {
              final adWidth = constraint.maxWidth.truncate();
              final adSize = await AdSize.getAnchoredAdaptiveBannerAdSize(
                MediaQuery.of(context).orientation,
                adWidth,
              ) as AdSize;

              return BannerAd(
                size: adSize,
                adUnitId: adUnitId,
                listener: BannerAdListener(
                  onAdFailedToLoad: (ad, error) {
                    ad.dispose();
                    bannerLoaded.value = false;
                    setAdHeight?.call(0);
                  },
                  onAdLoaded: (ad) {
                    bannerLoaded.value = true;
                    setAdHeight?.call(adSize.height.toDouble());
                  },
                ),
                request: const AdRequest(),
              );
            },
          ),
        ).data;

        if (bannerAd == null) {
          return const SizedBox.shrink();
        }

        useEffect(() {
          bannerAd.load();
          return () async => await bannerAd.dispose();
        }, [bannerAd]);

        return bannerLoaded.value
            ? SizedBox(
                width: bannerAd.size.width.toDouble(),
                height: bannerAd.size.height.toDouble(),
                child: AdWidget(ad: bannerAd),
              )
            : const SizedBox.shrink();
      });
    });
  }
}
