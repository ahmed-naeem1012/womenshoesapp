import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:woobox/main.dart';
import 'package:woobox/screens/HomeScreen/HomeScreen4.dart';
import 'package:woobox/utils/constants.dart';
import 'package:woobox/utils/images.dart';
import '../app_localizations.dart';
import '../utils/ad_state.dart';
import 'CategoriesScreen.dart';
import 'HomeScreen/HomeScreen1.dart';
import 'HomeScreen/HomeScreen2.dart';
import 'HomeScreen/HomeScreen3.dart';
import 'MyCartScreen.dart';
import 'ProfileScreen.dart';
import 'WishListScreen.dart';

class DashBoardScreen extends StatefulWidget {
  static String tag = '/DashBoardScreen';

  @override
  DashBoardScreenState createState() => DashBoardScreenState();
}

class DashBoardScreenState extends State<DashBoardScreen> {
  int _currentIndex = 0;

  final tab = [
    if (isFestival)
      HomeScreen4()
    else if (builderResponse.dashboard!.layout == 'dashboard1')
      HomeScreen1()
    else if (builderResponse.dashboard!.layout == 'dashboard2')
      HomeScreen2()
    else
      HomeScreen3(),
    CategoriesScreen(),
    MyCartScreen(isShowBack: false),
    WishListScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setState(() {
      appStore.isLoggedIn = getBoolAsync(IS_LOGGED_IN);
    });
    setValue(CARTCOUNT, appStore.count);

    window.onPlatformBrightnessChanged = () {
      if (getIntAsync(THEME_MODE_INDEX) == ThemeModeSystem) {
        appStore.setDarkMode(
            aIsDarkMode:
                MediaQuery.of(context).platformBrightness == Brightness.light);
      }
    };
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    window.onPlatformBrightnessChanged = null;
    super.dispose();
  }

  //Kashif --start
  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;
  bool loading = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final adState = Provider.of<AdState>(context);
    adState.initialization.then((value) {
      setState(() {
        bannerAd = BannerAd(
            size: AdSize.banner,
            adUnitId: adState.getBannerAdUnitId() ?? '',
            listener: adState.bannerAdlistener,
            request: AdRequest())
          ..load();
        _createInterstitialAd();
      });
    });
  }

  Future<void> _createInterstitialAd() async {
    await InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-9759446350792793/9173592916'
            : 'ca-app-pub-9759446350792793/9173592916',
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
  }

  //Kashif --end

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return SafeArea(
      top: isIos ? false : true,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            Expanded(child: tab[_currentIndex]),
            //KASHIF --START
            //WRAP WITH COLUMN BY KASHIF
            bannerAd == null
                ? SizedBox(
                    height: 40,
                  )
                : Container(
                    height: 45,
                    decoration: BoxDecoration(
                        border: Border.all(
                      color: Colors.black,
                    )),
                    child: AdWidget(ad: bannerAd!),
                  ),
            // --END
          ],
        ),
        bottomNavigationBar: Observer(
          builder: (_) => Container(
            decoration: boxDecorationRoundedWithShadow(16),
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: BottomNavigationBar(
              elevation: 8,
              backgroundColor: Theme.of(context).appBarTheme.iconTheme!.color,
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
              showSelectedLabels: true,
              currentIndex: _currentIndex,
              unselectedItemColor: Theme.of(context).textTheme.subtitle1!.color,
              unselectedLabelStyle: TextStyle(
                  color: Theme.of(context).textTheme.subtitle1!.color),
              selectedLabelStyle: TextStyle(color: primaryColor),
              selectedItemColor: primaryColor,
              onTap: (index) {
                //Kashif --start
                // _createInterstitialAd();
                // if (interstitialAd != null) {
                //   print('ad is not null at $_currentIndex');
                //   interstitialAd!.show();
                // }
                // print('ad is null at $_currentIndex');

                //Kashif --end
                _currentIndex = index;
                setState(() {});
              },
              items: [
                BottomNavigationBarItem(
                    icon: Image.asset(ic_home,
                        height: 20,
                        width: 20,
                        color: Theme.of(context).textTheme.subtitle1!.color),
                    activeIcon: Icon(Icons.home, size: 24, color: primaryColor),
                    label: appLocalization.translate("lbl_home")),
                BottomNavigationBarItem(
                    icon: Image.asset(ic_category,
                        height: 20,
                        width: 20,
                        color: Theme.of(context).textTheme.subtitle1!.color),
                    activeIcon:
                        Icon(Icons.widgets, size: 24, color: primaryColor),
                    label: appLocalization.translate("lbl_categories")!),
                BottomNavigationBarItem(
                    icon: Stack(
                      children: <Widget>[
                        Image.asset(ic_shopping_cart,
                            height: 22,
                            width: 28,
                            color:
                                Theme.of(context).textTheme.subtitle1!.color),
                        appStore.count! > 0 && appStore.count != null
                            ? Positioned(
                                top: 5,
                                left: 6,
                                child: Observer(
                                  builder: (_) => CircleAvatar(
                                    maxRadius: 7,
                                    backgroundColor:
                                        primaryColor!.withOpacity(0.8),
                                    child: FittedBox(
                                        child: Text('${appStore.count}',
                                            style: secondaryTextStyle(
                                                color: white))),
                                  ),
                                ),
                              ).visible(appStore.isLoggedIn ||
                                getBoolAsync(IS_GUEST_USER) == true)
                            : SizedBox()
                      ],
                    ),
                    activeIcon: Stack(
                      children: <Widget>[
                        Icon(
                          Feather.shopping_cart,
                          size: 24,
                        ),
                        if (appStore.count.toString() != "0")
                          Positioned(
                            top: 0,
                            left: 10,
                            child: Observer(
                              builder: (_) => CircleAvatar(
                                maxRadius: 7,
                                backgroundColor: white,
                                child: FittedBox(
                                  child: Text('${appStore.count}',
                                      style: secondaryTextStyle(color: black)),
                                ),
                              ),
                            ),
                          ).visible(appStore.isLoggedIn ||
                              getBoolAsync(IS_GUEST_USER) == true),
                      ],
                    ),
                    label: appLocalization.translate("lbl_basket")),
                BottomNavigationBarItem(
                    icon: Image.asset(ic_heart,
                        height: 20,
                        width: 20,
                        color: Theme.of(context).textTheme.subtitle1!.color),
                    activeIcon:
                        Icon(Icons.favorite, size: 24, color: primaryColor),
                    label: appLocalization.translate("lbl_wishlist")),
                BottomNavigationBarItem(
                  icon: Image.asset(ic_user,
                      height: 20,
                      width: 20,
                      color: Theme.of(context).textTheme.subtitle1!.color),
                  activeIcon: Image.asset(ic_user_profile,
                      height: 20, width: 20, color: primaryColor),
                  label: appLocalization.translate("lbl_account"),
                )
              ],
            ).cornerRadiusWithClipRRect(16),
          ),
        ),
      ),
    );
  }
}
