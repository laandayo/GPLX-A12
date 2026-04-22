import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';

class HomeBannerAdBar extends StatefulWidget {
  const HomeBannerAdBar({super.key});

  @override
  State<HomeBannerAdBar> createState() => _HomeBannerAdBarState();
}

class _HomeBannerAdBarState extends State<HomeBannerAdBar> {
  BannerAd? _bannerAd;
  AdSize? _adSize;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null && !_loading) {
      _loadBanner();
    }
  }

  Future<void> _loadBanner() async {
    _loading = true;
    final mediaQuery = MediaQuery.of(context);
    final width = (mediaQuery.size.width - mediaQuery.padding.left - mediaQuery.padding.right).truncate();
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);

    if (!mounted || size == null) {
      _loading = false;
      return;
    }

    final bannerAd = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _adSize = size;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    await bannerAd.load();
    _loading = false;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerAd = _bannerAd;
    final adSize = _adSize;
    if (bannerAd == null || adSize == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Center(
        child: SizedBox(
          width: bannerAd.size.width.toDouble(),
          height: adSize.height.toDouble(),
          child: AdWidget(ad: bannerAd),
        ),
      ),
    );
  }
}
