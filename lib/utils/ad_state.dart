import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:woobox/utils/constants.dart';

class AdState {
  Future<InitializationStatus> initialization;

  AdState({required this.initialization});

  String? getBannerAdUnitId() {
    if (Platform.isIOS) {
      return bannerIdForIos;
    } else if (Platform.isAndroid) {
      return bannerIdForAndroid;
    }
    return null;
  }

  String? getInterstitialAdUnitId() {
    if (Platform.isIOS) {
      return interstitialIdForIos;
    } else if (Platform.isAndroid) {
      return InterstitialIdForAndroid;
    }
    return null;
  }

  BannerAdListener get bannerAdlistener => _bannerAdListener;

  BannerAdListener _bannerAdListener = BannerAdListener(onAdLoaded: (ad) {
    print('$ad loaded.');
  }, onAdFailedToLoad: (ad, error) {
    print('RewardedAd failed to load: $error');
  }, onAdClicked: (ad) {
    print('Ad is clicked $ad');
  }, onAdWillDismissScreen: (ad) {
    print('$ad is dissmiss ');
  });

// 'ca-app-pub-3940256099942544/1033173712'
// 'ca-app-pub-3940256099942544/4411468910'

  static Future<InterstitialAd?> loadInterstialAd() async {
    InterstitialAd? interstitialAd;

    await InterstitialAd.load(
        adUnitId: Platform.isAndroid ? '' : '',
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
          },
        ));
    return interstitialAd;
  }
}
