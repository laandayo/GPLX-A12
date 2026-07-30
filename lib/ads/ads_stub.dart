/// Browser implementation of the mobile-ad boundary.
///
/// Google Mobile Ads does not support Flutter web. Keeping this implementation
/// intentionally empty ensures the PWA never delays study or exam flows for an
/// advertisement.
class AdsBootstrap {
  AdsBootstrap._();

  static Future<void> initialize() async {}
}

class InterstitialAdService {
  InterstitialAdService._();

  static final InterstitialAdService instance = InterstitialAdService._();

  void preload() {}

  void showAfterExam({required Future<void> Function() onFinished}) {
    onFinished();
  }
}
