export 'ad_config.dart';
export 'app_banner_ad_bar.dart';
export 'interstitial_ad_service.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'interstitial_ad_service.dart';

class AdsBootstrap {
  AdsBootstrap._();

  static Future<InitializationStatus> initialize() async {
    final status = await MobileAds.instance.initialize();
    InterstitialAdService.instance.preload();
    return status;
  }
}
