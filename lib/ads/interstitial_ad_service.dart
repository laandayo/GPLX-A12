import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';

class InterstitialAdService {
  InterstitialAdService._();

  static final InterstitialAdService instance = InterstitialAdService._();

  InterstitialAd? _interstitialAd;
  bool _isLoading = false;

  void preload() {
    if (_isLoading || _interstitialAd != null) {
      return;
    }

    _isLoading = true;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  void showAfterExam({required Future<void> Function() onFinished}) {
    final ad = _interstitialAd;
    if (ad == null) {
      preload();
      onFinished();
      return;
    }

    _interstitialAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preload();
        onFinished();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        preload();
        onFinished();
      },
    );
    ad.show();
  }
}
