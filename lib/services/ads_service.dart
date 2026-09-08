import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Wraps a persistent AdMob banner. Deliberately banner-only in the UI (no
/// interstitial shown anywhere yet): this app gets opened many times a day
/// for a quick glance, so an interstitial on every open would work against
/// the "nhẹ, ít quảng cáo" positioning this app is going for.
/// [interstitialAdUnitId] is defined for when that changes, but nothing
/// currently loads or shows one.
///
/// `google_mobile_ads` only supports Android/iOS, so every entry point
/// here is a no-op on web/desktop — keeps `flutter run -d chrome` usable
/// for previewing the UI without a phone.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  /// AdMob registers each platform as a separate "app", so Android and iOS
  /// have distinct ad unit IDs under the same `pub-9078637596840810`
  /// account even though it's the same Lịch Âm Dương listing.
  static String get bannerAdUnitId => defaultTargetPlatform == TargetPlatform.iOS
      ? 'ca-app-pub-9078637596840810/6692473766'
      : 'ca-app-pub-9078637596840810/4099910531';

  static String get interstitialAdUnitId => defaultTargetPlatform == TargetPlatform.iOS
      ? 'ca-app-pub-9078637596840810/6921021121'
      : '';

  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('AdsService.initialize failed: $e');
    }
  }

  BannerAd? createBannerAd({required void Function() onLoaded}) {
    if (kIsWeb) return null;
    final banner = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          debugPrint('AdsService: banner loaded');
          onLoaded();
        },
        // LoadAdError.code/message here is the actual reason (no fill,
        // invalid ad unit, network, not-yet-serving new unit, etc.) — the
        // widget just collapses to nothing on failure, so this debugPrint
        // (visible via `flutter logs` / `adb logcat`) is the only way to
        // tell those apart when a banner silently doesn't show up.
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdsService: banner failed to load — code ${error.code}: ${error.message}');
          ad.dispose();
        },
      ),
    );
    banner.load();
    return banner;
  }
}
