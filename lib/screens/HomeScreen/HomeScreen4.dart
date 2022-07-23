import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:woobox/component/HomeComponent/Dashboard4/DashboardComponent4.dart';
import 'package:woobox/component/HomeComponent/Dashboard4/GradientProductComponent4.dart';
import 'package:woobox/component/HomeComponent/Dashboard4/HomeCategoryListComponent4.dart';
import 'package:woobox/component/HomeComponent/Dashboard4/VendorWidget4.dart';
import 'package:woobox/model/CartModel.dart';
import 'package:woobox/model/CategoryData.dart';
import 'package:woobox/model/ProductResponse.dart';
import 'package:woobox/model/SaleBannerResponse.dart';
import 'package:woobox/model/SliderModel.dart';
import 'package:woobox/network/rest_apis.dart';
import 'package:woobox/utils/ad_state.dart';
import 'package:woobox/utils/app_widgets.dart';
import 'package:woobox/utils/colors.dart';
import 'package:woobox/utils/common.dart';
import 'package:woobox/utils/constants.dart';
import 'package:woobox/utils/images.dart';
import 'package:woobox/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../app_localizations.dart';
import '../../main.dart';
import '../SearchScreen.dart';
import '../ViewAllScreen.dart';
import '../ExternalProductScreen.dart';
import 'dart:math' as math;

class HomeScreen4 extends StatefulWidget {
  static String tag = '/HomeScreen4';

  @override
  HomeScreen4State createState() => HomeScreen4State();
}

class HomeScreen4State extends State<HomeScreen4> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  List<String?> mSliderImages = [];
  List<String?> mSaleBannerImages = [];
  List<ProductResponse> mNewestProductModel = [];
  List<ProductResponse> mFeaturedProductModel = [];
  List<ProductResponse> mDealProductModel = [];
  List<ProductResponse> mSellingProductModel = [];
  List<ProductResponse> mSaleProductModel = [];
  List<ProductResponse> mOfferProductModel = [];
  List<ProductResponse> mSuggestedProductModel = [];
  List<ProductResponse> mYouMayLikeProductModel = [];
  List<VendorResponse> mVendorModel = [];
  List<Category> mCategoryModel = [];
  List<Widget> data = [];
  List<SliderModel> mSliderModel = [];
  List<Salebanner> mSaleBanner = [];
  CartResponse mCartModel = CartResponse();

  PageController salePageController = PageController(initialPage: 0);
  PageController bannerPageController = PageController(initialPage: 0);

  int selectIndex = 0;
  int _currentPage = 0;

  String mErrorMsg = '';

  bool isWasConnectionLoss = false;
  bool isDone = false;

  @override
  void initState() {
    super.initState();
    init();
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
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  setTimer() {
    Timer.periodic(Duration(seconds: 25), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (bannerPageController.hasClients) {
        //Kashif --start
        _createInterstitialAd();
        if (interstitialAd != null) {
          print('ad is not null at $_currentPage');
          interstitialAd!.show();
        }
        print('ad is null at $_currentPage');
        //Kashif --end
        bannerPageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
    Timer.periodic(Duration(seconds: 15), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (salePageController.hasClients) {
        salePageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  init() async {
    await setValue(CARTCOUNT, appStore.count);
    setTimer();
    fetchDashboardData();
    fetchCategoryData();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        isWasConnectionLoss = true;
        Scaffold(body: noInternet(context)).launch(context);
      } else {
        if (isWasConnectionLoss) finish(context);
      }
    });
  }

  Future fetchCategoryData() async {
    await getCategories(1, TOTAL_CATEGORY_PER_PAGE).then((res) {
      if (!mounted) return;
      setState(() {
        Iterable mCategory = res;
        mCategoryModel =
            mCategory.map((model) => Category.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
    });
  }

  Future fetchDashboardData() async {
    var appLocalization = AppLocalizations.of(context)!;
    appStore.isLoading = true;
    setState(() {});
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        if (!await isGuestUser() && await isLoggedIn()) {
          await getCartList().then((res) {
            if (!mounted) return;
            setState(() {
              mCartModel = CartResponse.fromJson(res);
              if (mCartModel.data!.isNotEmpty) {
                appStore.setCount(mCartModel.totalQuantity);
              }
            });
          }).catchError((error) {
            log(error.toString());
            setState(() {});
          });
        }
        await getDashboardApi().then((res) async {
          if (!mounted) return;
          appStore.isLoading = false;
          setValue(DEFAULT_CURRENCY,
              parseHtmlString(res['currency_symbol']['currency_symbol']));
          setValue(CURRENCY_CODE, res['currency_symbol']['currency']);
          await setValue(DASHBOARD_DATA, jsonEncode(res));
          setProductData(res);
          if (res['social_link'] != null) {
            setValue(WHATSAPP, res['social_link']['whatsapp']);
            setValue(FACEBOOK, res['social_link']['facebook']);
            setValue(TWITTER, res['social_link']['twitter']);
            setValue(INSTAGRAM, res['social_link']['instagram']);
            setValue(CONTACT, res['social_link']['contact']);
            setValue(PRIVACY_POLICY, res['social_link']['privacy_policy']);
            setValue(
                TERMS_AND_CONDITIONS, res['social_link']['term_condition']);
            setValue(COPYRIGHT_TEXT, res['social_link']['copyright_text']);
          }
          await setValue(PAYMENTMETHOD, res['payment_method']);
          await setValue(ENABLECOUPON, res['enable_coupons']);
        }).catchError((error) {
          if (!mounted) return;
          appStore.isLoading = false;
          mErrorMsg = error.toString();
          log("test" + error.toString());
        });

        isDone = true;
      } else {
        toast(appLocalization.translate("toast_txt_internet_connection"));
        if (!mounted) return;
        appStore.isLoading = false;
      }
      setState(() {});
    });
  }

  void setProductData(res) async {
    Iterable newest = res['newest'];
    mNewestProductModel =
        newest.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable featured = res['featured'];
    mFeaturedProductModel =
        featured.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable deal = res['deal_of_the_day'];
    mDealProductModel =
        deal.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable selling = res['best_selling_product'];
    mSellingProductModel =
        selling.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable sale = res['sale_product'];
    mSaleProductModel =
        sale.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable offer = res['offer'];
    mOfferProductModel =
        offer.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable suggested = res['suggested_for_you'];
    mSuggestedProductModel =
        suggested.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable youMayLike = res['you_may_like'];
    mYouMayLikeProductModel =
        youMayLike.map((model) => ProductResponse.fromJson(model)).toList();

    if (res['vendors'] != null) {
      Iterable vendorList = res['vendors'];
      mVendorModel =
          vendorList.map((model) => VendorResponse.fromJson(model)).toList();
    }

    if (res['slider'] != null) {
      mSaleBannerImages.clear();
      Iterable bannerList = res['slider'];
      mSaleBanner =
          bannerList.map((model) => Salebanner.fromJson(model)).toList();
      mSaleBanner.forEach((s) => mSaleBannerImages.add(s.image));
    }

    mSliderImages.clear();
    Iterable list = res['banner'];
    mSliderModel = list.map((model) => SliderModel.fromJson(model)).toList();
    log("$mSliderModel");
    mSliderModel.forEach((s) => mSliderImages.add(s.image));

    setState(() {});
  }

  List<T?> map<T>(List list, Function handler) {
    List<T?> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  void dispose() {
    salePageController.dispose();
    bannerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    Widget availableOfferAndDeal(String title, List<ProductResponse> product) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.bottomCenter,
                  color: diwaliPattern1,
                  height: 428,
                ),
                Column(
                  children: [
                    Transform.rotate(
                        angle: math.pi / 1,
                        child: Image.asset(ic_1,
                            width: context.width(),
                            color: white,
                            height: 24,
                            fit: BoxFit.fill)),
                    Column(
                      children: [
                        Text(title.toUpperCase(),
                            style: GoogleFonts.alegreyaSc(
                                color: white.withOpacity(0.7),
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        4.height,
                        Row(
                          children: [
                            Divider(
                                    thickness: 1,
                                    height: 10,
                                    color: white.withOpacity(0.7),
                                    indent: 50,
                                    endIndent: 10)
                                .expand(),
                            Image.asset(
                              ic_diwali_icon3,
                              height: 24,
                              width: 24,
                              color: white.withOpacity(0.7),
                            ),
                            Divider(
                                    thickness: 1,
                                    height: 10,
                                    color: white.withOpacity(0.7),
                                    indent: 10,
                                    endIndent: 50)
                                .expand()
                          ],
                        ),
                      ],
                    ).paddingOnly(left: 12, top: 24, bottom: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          HorizontalList(
                            padding:
                                EdgeInsets.only(left: 12, right: 8, bottom: 16),
                            itemCount: product.length > 6 ? 6 : product.length,
                            itemBuilder: (context, i) {
                              return GradientProductComponent4(
                                      mProductModel: product[i],
                                      width: context.width() * 0.45)
                                  .paddingOnly(right: 4, top: 8);
                            },
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            margin: EdgeInsets.only(right: 8),
                            decoration: boxDecorationRoundedWithShadow(
                                defaultRadius.toInt(),
                                backgroundColor:
                                    Theme.of(context).cardTheme.color!),
                            child: Row(
                              children: [
                                Text(
                                  builderResponse
                                      .dashboard!.youMayAlsoLike!.viewAll!,
                                  style: boldTextStyle(color: primaryColor),
                                )
                                    .paddingOnly(right: 10, top: 8, bottom: 8)
                                    .onTap(
                                  () {
                                    if (title ==
                                        builderResponse
                                            .dashboard!.todayDeal!.title) {
                                      ViewAllScreen(title,
                                              isSpecialProduct: true,
                                              specialProduct: "deal_of_the_day")
                                          .launch(context);
                                    } else if (title ==
                                        builderResponse
                                            .dashboard!.moreOffer!.title) {
                                      ViewAllScreen(
                                              appLocalization
                                                  .translate('lbl_offer'),
                                              isSpecialProduct: true,
                                              specialProduct: "offer")
                                          .launch(context);
                                    } else {
                                      ViewAllScreen(title);
                                    }
                                  },
                                ),
                                Icon(Icons.arrow_forward_outlined,
                                    color: primaryColor!)
                              ],
                            ),
                          ).visible(product.length > 6),
                        ],
                      ),
                    ),
                    8.height,
                    Image.asset(ic_1,
                        width: context.width(),
                        color: white,
                        height: 24,
                        fit: BoxFit.fill)
                  ],
                ),
              ],
            ),
          ),
          12.height,
        ],
      ).paddingOnly(
        top: spacing_standard_new.toDouble(),
      );
    }

    Widget _category() {
      return mCategoryModel.isNotEmpty
          ? HomeCategoryListComponent4(mCategoryModel: mCategoryModel)
          : SizedBox();
    }

    Widget _slider() {
      return mSliderModel.isNotEmpty
          ? Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 254,
                      color: primaryColor,
                    ),
                    Column(
                      children: [
                        Container(
                          height: 230,
                          child: PageView(
                            controller: bannerPageController,
                            onPageChanged: (i) {
                              selectIndex = i;
                              setState(() {});
                            },
                            children: mSliderModel.map((i) {
                              return commonCacheImageWidget(i.image.validate(),
                                      width: context.width() * .95,
                                      fit: BoxFit.cover)
                                  .onTap(() {
                                if (i.url!.isNotEmpty) {
                                  ExternalProductScreen(
                                          mExternal_URL: i.url, title: i.title)
                                      .launch(context);
                                } else {
                                  toast(appLocalization.translate("txt_sorry"));
                                }
                              });
                            }).toList(),
                          ),
                        ),
                        Image.asset(ic_3,
                            width: context.width(),
                            fit: BoxFit.fitWidth,
                            color: Colors.white),
                      ],
                    ),
                  ],
                ),
                4.height,
                DotIndicator(
                  pageController: bannerPageController,
                  pages: mSliderModel,
                  indicatorColor: primaryColor,
                  unselectedIndicatorColor: grey.withOpacity(0.2),
                  currentBoxShape: BoxShape.rectangle,
                  boxShape: BoxShape.rectangle,
                  borderRadius: radius(2),
                  currentBorderRadius: radius(3),
                  currentDotSize: 18,
                  currentDotWidth: 6,
                  dotSize: 6,
                ),
                16.height
              ],
            )
          : SizedBox();
    }

    Widget mSaleBannerWidget() {
      return mSaleBanner.isNotEmpty
          ? Column(
              children: [
                Stack(
                  children: [
                    Container(
                      color: primaryColor,
                      child: Image.asset(ic_diwali_frame13,
                          fit: BoxFit.fitWidth,
                          height: 240,
                          width: context.width()),
                    ),
                    Container(
                      height: 240,
                      padding: EdgeInsets.all(2),
                      child: PageView(
                        controller: salePageController,
                        onPageChanged: (i) {
                          selectIndex = i;
                          setState(() {});
                        },
                        children: mSaleBanner.map((i) {
                          return Container(
                            padding: EdgeInsets.all(18),
                            child: commonCacheImageWidget(i.image.validate(),
                                width: double.infinity, fit: BoxFit.cover),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                DotIndicator(
                  pageController: salePageController,
                  pages: mSaleBanner,
                  indicatorColor: primaryColor,
                  unselectedIndicatorColor: grey.withOpacity(0.2),
                  currentBoxShape: BoxShape.rectangle,
                  boxShape: BoxShape.rectangle,
                  borderRadius: radius(2),
                  currentBorderRadius: radius(3),
                  currentDotSize: 18,
                  currentDotWidth: 6,
                  dotSize: 6,
                ),
              ],
            )
          : SizedBox();
    }

    Widget _newProduct() {
      return DashboardComponent4(
        title: builderResponse.dashboard!.newArrivals!.title!,
        subTitle: builderResponse.dashboard!.newArrivals!.viewAll!,
        color: diwaliPattern1,
        image: ic_diwali_pattern1,
        product: mNewestProductModel,
        onTap: () {
          ViewAllScreen(builderResponse.dashboard!.newArrivals!.title,
                  isNewest: true)
              .launch(context);
        },
      );
    }

    Widget _feature() {
      return DashboardComponent4(
        title: builderResponse.dashboard!.spotLight!.title!,
        subTitle: builderResponse.dashboard!.spotLight!.viewAll!,
        product: mFeaturedProductModel,
        color: diwaliPattern3,
        image: ic_diwali_pattern3,
        onTap: () {
          ViewAllScreen(builderResponse.dashboard!.spotLight!.title,
                  isFeatured: true)
              .launch(context);
        },
      );
    }

    Widget _dealOfTheDay() {
      return availableOfferAndDeal(
        builderResponse.dashboard!.todayDeal!.title!,
        mDealProductModel,
      ).visible(mDealProductModel.isNotEmpty);
    }

    Widget _bestSelling() {
      return DashboardComponent4(
        title: builderResponse.dashboard!.topPicks!.title!,
        subTitle: builderResponse.dashboard!.topPicks!.viewAll!,
        product: mSellingProductModel,
        color: diwaliPattern2,
        image: ic_diwali_pattern2,
        onTap: () {
          ViewAllScreen(builderResponse.dashboard!.topPicks!.title,
                  isBestSelling: true)
              .launch(context);
        },
      );
    }

    Widget _saleProduct() {
      return DashboardComponent4(
        title: builderResponse.dashboard!.trendingProduct!.title!,
        subTitle: builderResponse.dashboard!.trendingProduct!.viewAll!,
        product: mSaleProductModel,
        color: diwaliPattern4,
        image: ic_diwali_pattern5,
        onTap: () {
          ViewAllScreen(builderResponse.dashboard!.trendingProduct!.title,
                  isSale: true)
              .launch(context);
        },
      );
    }

    Widget _offer() {
      return Column(
        children: [
          availableOfferAndDeal(builderResponse.dashboard!.moreOffer!.title!,
                  mOfferProductModel)
              .visible(mOfferProductModel.isNotEmpty),
        ],
      );
    }

    Widget _suggested() {
      return DashboardComponent4(
        title: builderResponse.dashboard!.hotRightNow!.title!,
        subTitle: builderResponse.dashboard!.hotRightNow!.viewAll!,
        product: mSuggestedProductModel,
        color: diwaliPattern6,
        image: ic_diwali_pattern6,
        onTap: () {
          ViewAllScreen(builderResponse.dashboard!.hotRightNow!.title,
                  isSpecialProduct: true, specialProduct: "suggested_for_you")
              .launch(context);
        },
      );
    }

    Widget _youMayLike() {
      return DashboardComponent4(
        title: builderResponse.dashboard!.youMayAlsoLike!.title!,
        subTitle: builderResponse.dashboard!.youMayAlsoLike!.viewAll!,
        product: mYouMayLikeProductModel,
        color: diwaliPattern5,
        image: ic_diwali_pattern1,
        onTap: () {
          ViewAllScreen(
            builderResponse.dashboard!.youMayAlsoLike!.title,
            isSpecialProduct: true,
            specialProduct: "you_may_like",
          ).launch(context);
        },
      );
    }

    Widget body = ListView(
      shrinkWrap: true,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 16),
          itemCount: builderResponse.dashboard == null
              ? 0
              : builderResponse.dashboard!.sorting!.length,
          itemBuilder: (_, index) {
            if (builderResponse.dashboard!.sorting![index] ==
                'advertiseSlider') {
              return _slider()
                  .visible(builderResponse.dashboard!.advertiseBanner!.enable!);
            } else if (builderResponse.dashboard!.sorting![index] ==
                'categories') {
              return _category()
                  .visible(builderResponse.dashboard!.category!.enable!)
                  .paddingOnly(top: 8, bottom: 8);
            } else if (builderResponse.dashboard!.sorting![index] ==
                'saleBanner') {
              return mSaleBannerWidget()
                  .visible(builderResponse.dashboard!.saleBanner!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] ==
                'newArrivals') {
              return _newProduct()
                  .visible(builderResponse.dashboard!.newArrivals!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] == 'store') {
              return mVendorWidget4(
                      context,
                      mVendorModel,
                      builderResponse.dashboard!.vendor!.title!.toUpperCase(),
                      builderResponse.dashboard!.vendor!.viewAll)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] ==
                'spotLight') {
              return _feature()
                  .visible(builderResponse.dashboard!.spotLight!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] ==
                'todayDeal') {
              return _dealOfTheDay()
                  .visible(builderResponse.dashboard!.todayDeal!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] ==
                'topPicks') {
              return _bestSelling()
                  .visible(builderResponse.dashboard!.topPicks!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] ==
                'trendingProduct') {
              return _saleProduct()
                  .visible(builderResponse.dashboard!.trendingProduct!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] ==
                'moreOffer') {
              return _offer()
                  .visible(builderResponse.dashboard!.moreOffer!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] ==
                'hotRightNow') {
              return _suggested()
                  .visible(builderResponse.dashboard!.hotRightNow!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] ==
                'youMayAlsoLike') {
              return _youMayLike()
                  .visible(builderResponse.dashboard!.youMayAlsoLike!.enable!)
                  .paddingTop(8);
            } else {
              return 0.height;
            }
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(ic_diwali_icon5,
                width: 38, height: 38, color: primaryColor!.withOpacity(0.6)),
            Text(
              "Happy Diwali",
              style: GoogleFonts.kaushanScript(
                  fontSize: 30,
                  letterSpacing: 0,
                  color: primaryColor!.withOpacity(0.6)),
            ),
            Image.asset(ic_diwali_icon5,
                width: 38, height: 38, color: primaryColor!.withOpacity(0.6)),
          ],
        ).paddingOnly(left: 16, right: 16),
        16.height
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: mTop(
        context,
        appLocalization.translate('app_name'),
        actions: [
          IconButton(
            icon: Icon(Icons.search_sharp, color: white),
            onPressed: () {
              SearchScreen().launch(context);
            },
          )
        ],
      ) as PreferredSizeWidget?,
      key: scaffoldKey,
      body: RefreshIndicator(
        backgroundColor: Theme.of(context).cardTheme.color,
        color: primaryColor!,
        onRefresh: () {
          return fetchDashboardData();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            body.visible(!appStore.isLoading!),
            mProgress().center().visible(appStore.isLoading!),
          ],
        ),
      ),
    );
  }
}
