import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Wraps a persistent AdMob banner behind Google's official TEST ad unit
/// ID. Swap for a real AdMob ad unit ID before publishing — see README.md
/// "Trước khi publish". Deliberately banner-only (no interstitial): this
/// app gets opened many times a day for a quick glance, so an interstitial
/// on every open would work against the "nhẹ, ít quảng cáo" positioning
/// this app is going for.
///
/// `google_mobile_ads` only supports Android/iOS, so every entry point
/// here is a no-op on web/desktop — keeps `flutter run -d chrome` usable
/// for previewing the UI without a phone.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  Future<void> initialize() async {
    if (kIsWeb) return;
    await MobileAds.instance.initialize();
  }

  BannerAd? createBannerAd({required void Function() onLoaded}) {
    if (kIsWeb) return null;
    final banner = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    banner.load();
    return banner;
  }
}
