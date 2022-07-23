// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:woobox/component/HtmlWidget.dart';
import 'package:woobox/model/CartModel.dart';
import 'package:woobox/model/ProductDetailResponse.dart';
import 'package:woobox/model/ProductReviewModel.dart';
import 'package:woobox/model/WishListResponse.dart';
import 'package:woobox/network/rest_apis.dart';
import 'package:woobox/screens/ProductDetail/ProductDetailScreen2.dart';
import 'package:woobox/utils/Countdown.dart';
import 'package:woobox/utils/app_widgets.dart';
import 'package:woobox/utils/colors.dart';
import 'package:woobox/utils/common.dart';
import 'package:woobox/utils/constants.dart';
import 'package:woobox/utils/images.dart';
import 'package:woobox/utils/shared_pref.dart';

import '../../app_localizations.dart';
import '../../main.dart';
import '../ExternalProductScreen.dart';
import '../ProductImageScreen.dart';
import '../ReviewScreen.dart';
import '../SignInScreen.dart';
import '../VendorProfileScreen.dart';
import '../ViewAllScreen.dart';
import 'ProductDetailScreen3.dart';

class ProductDetailScreen1 extends StatefulWidget {
  final int? mProId;

  ProductDetailScreen1({Key? key, this.mProId}) : super(key: key);

  @override
  _ProductDetailScreen1State createState() => _ProductDetailScreen1State();
}

class _ProductDetailScreen1State extends State<ProductDetailScreen1> {
  ProductDetailResponse? productDetailNew;
  ProductDetailResponse? mainProduct;

  List<ProductDetailResponse> mProducts = [];
  List<ProductReviewModel> mReviewModel = [];
  List<ProductDetailResponse> mProductsList = [];
  List<String?> mProductOptions = [];
  List<int> mProductVariationsIds = [];
  List<ProductDetailResponse> product = [];
  List<String?> productImg1 = [];

  InterstitialAd? interstitialAd;

  PageController _pageController = PageController(initialPage: 0);
  ScrollController _scrollController = ScrollController();

  bool mIsGroupedProduct = false;
  bool mIsExternalProduct = false;
  bool isAddedToCart = false;
  bool mIsInWishList = false;
  bool mIsLoggedIn = false;
  bool isExpanded = false;

  double rating = 0.0;
  double discount = 0.0;

  int selectIndex = 0;
  int _currentPage = 0;
  int? selectedOption = 0;

  String? mProfileImage = '';
  String? videoType = '';
  String? mSelectedVariation = '';
  String? mExternalUrl = '';

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  setTimer() {
    Timer.periodic(Duration(seconds: 15), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  init() async {
    productDetail();
    fetchReviewData();
    setTimer();
    _createInterstitialAd();
  }

  @override
  void didChangeDependencies() {
    _createInterstitialAd();
    super.didChangeDependencies();
  }

  adShow() async {
    if (interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    enableAds ? interstitialAd!.show() : SizedBox();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Future<void> dispose() async {
    _pageController.dispose();
    if (interstitialAd != null) {
      if (mAdShowCount < 5) {
        mAdShowCount++;
      } else {
        mAdShowCount = 0;
        adShow();
      }
      interstitialAd?.dispose();
    }

    super.dispose();
  }

  Future productDetail() async {
    mIsLoggedIn = getBoolAsync(IS_LOGGED_IN);
    await getProductDetail(widget.mProId).then((res) {
      log("Product Response:$res");
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
        Iterable mInfo = res;
        mProducts = mInfo
            .map((model) => ProductDetailResponse.fromJson(model))
            .toList();
        if (mProducts.isNotEmpty) {
          productDetailNew = mProducts[0];
          mainProduct = mProducts[0];

          rating = double.parse(mainProduct!.averageRating!);
          productDetailNew!.variations!.forEach((element) {
            mProductVariationsIds.add(element);
          });
          if (getBoolAsync(IS_GUEST_USER) == true) {
            if (appStore.mCartList.isNotEmpty) {
              appStore.mCartList.forEach((element) {
                if (element.proId == mainProduct!.id) {
                  isAddedToCart = true;
                }
              });
            }
            if (appStore.mWishList.isNotEmpty) {
              appStore.mWishList.forEach((element) {
                if (element.proId == mainProduct!.id) {
                  mIsInWishList = true;
                }
              });
            }
          } else {
            if (mainProduct!.isAddedCart!) {
              isAddedToCart = true;
            } else {
              isAddedToCart = false;
            }
            if (mainProduct!.isAddedWishList!) {
              mIsInWishList = true;
            } else {
              mIsInWishList = false;
            }
          }
          mProductsList.clear();

          for (var i = 0; i < mProducts.length; i++) {
            if (i != 0) {
              mProductsList.add(mProducts[i]);
            }
          }

          if (mainProduct!.type == "variable" ||
              mainProduct!.type == "variation") {
            mProductOptions.clear();
            mProductsList.forEach((product) {
              var option = '';

              product.attributes!.forEach((attribute) {
                if (option.isNotEmpty) {
                  option = '$option - ${attribute.option.validate()}';
                } else {
                  option = attribute.option.validate();
                }
              });

              if (product.onSale!) {
                option = '$option [Sale]';
              }
              mProductOptions.add(option);
            });

            if (mProductOptions.isNotEmpty)
              mSelectedVariation = mProductOptions.first;

            if (mainProduct!.type == "variable" ||
                mainProduct!.type == "variation" && mProductsList.isNotEmpty) {
              productDetailNew = mProductsList[0];
              mProducts = mProducts;
            }
            log('mProductOptions');
          } else if (mainProduct!.type == 'grouped') {
            mIsGroupedProduct = true;
            product.clear();
            product.addAll(mProductsList);
          }

          mImage();
          setPriceDetail();
        }
      });
    }).catchError((error) {
      log('error:$error');
      appStore.isLoading = false;
      toast(error.toString());
      setState(() {});
    });
  }

  Future fetchReviewData() async {
    setState(() {
      appStore.isLoading = true;
    });
    await getProductReviews(widget.mProId).then((res) {
      if (!mounted) return;
      setState(() {
        appStore.isLoading = false;
        Iterable list = res;
        mReviewModel =
            list.map((model) => ProductReviewModel.fromJson(model)).toList();
      });
    }).catchError((error) {
      setState(() {
        appStore.isLoading = false;
      });
    });
  }

// Set Price Detail
  Widget setPriceDetail() {
    setState(() {
      if (productDetailNew!.onSale!) {
        double mrp = double.parse(productDetailNew!.regularPrice!).toDouble();
        double discountPrice =
            double.parse(productDetailNew!.price!).toDouble();
        discount = ((mrp - discountPrice) / mrp) * 100;
      }
    });
    return SizedBox();
  }

  void mImage() {
    setState(() {
      productImg1.clear();
      productDetailNew!.images!.forEach((element) {
        productImg1.add(element.src);
      });
    });
  }

  Widget mDiscount() {
    if (mainProduct!.onSale!)
      return Container(
        padding: EdgeInsets.all(4),
        decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 0.1, color: Colors.red)),
        child: Text(
          '${discount.toInt()} % ${AppLocalizations.of(context)!.translate('lbl_off1')!}',
          style: secondaryTextStyle(color: Colors.red),
        ),
      );
    else
      return SizedBox();
  }

  Widget mSpecialPrice(String? value) {
    if (mainProduct != null) {
      if (mainProduct!.dateOnSaleFrom != "") {
        var endTime = mainProduct!.dateOnSaleTo.toString() + " 23:59:59.000";
        var endDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(endTime);
        var currentDate =
            DateFormat('yyyy-MM-dd HH:mm:ss').parse(DateTime.now().toString());
        var format = endDate.subtract(Duration(
            days: currentDate.day,
            hours: currentDate.hour,
            minutes: currentDate.minute,
            seconds: currentDate.second));
        log(format);

        return Countdown(
          duration: Duration(
              days: format.day,
              hours: format.hour,
              minutes: format.minute,
              seconds: format.second),
          onFinish: () {
            log('finished!');
          },
          builder: (BuildContext ctx, Duration? remaining) {
            var seconds = ((remaining!.inMilliseconds / 1000) % 60).toInt();
            var minutes =
                (((remaining.inMilliseconds / (1000 * 60)) % 60)).toInt();
            var hours =
                (((remaining.inMilliseconds / (1000 * 60 * 60)) % 24)).toInt();
            log(hours);
            return Column(
              children: [
                Row(
                  children: [
                    Divider(
                            thickness: 1,
                            height: 10,
                            color: grey.withOpacity(0.15),
                            indent: 16)
                        .expand(),
                    Icon(Entypo.infinity, color: grey.withOpacity(0.15)),
                    Divider(
                            thickness: 1,
                            height: 10,
                            color: grey.withOpacity(0.15),
                            endIndent: 16)
                        .expand()
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(value! + " ",
                        style: primaryTextStyle(
                            color: primaryColor!.withOpacity(0.5))),
                    Text(
                        '${remaining.inDays}d ${hours}h ${minutes}m ${seconds}s',
                        style: boldTextStyle(color: primaryColor, size: 14)),
                  ],
                ),
                Row(
                  children: [
                    Divider(
                            thickness: 1,
                            height: 10,
                            color: grey.withOpacity(0.15),
                            indent: 16)
                        .expand(),
                    Icon(Entypo.infinity, color: grey.withOpacity(0.15)),
                    Divider(
                            thickness: 1,
                            height: 10,
                            color: grey.withOpacity(0.15),
                            endIndent: 16)
                        .expand()
                  ],
                ),
              ],
            );
          },
        );
      } else {
        return SizedBox();
      }
    } else {
      return SizedBox();
    }
  }

  void removeWishListItem() async {
    if (!await isLoggedIn()) {
      //Kashif --start
      if (!isFirst) {
        await _createInterstitialAd();
        print('interstitial ad now is $interstitialAd');
        if (interstitialAd != null) {
          interstitialAd!.show();
          isFirst = true;
        }
      } else {
        isFirst = false;
      }
      //Kashif --end
      SignInScreen().launch(context);
      return;
    }
    await removeWishList({
      'pro_id': mainProduct!.id,
    }).then((res) {
      if (!mounted) return;
      productDetail();
      setState(() {
        toast(res[msg]);
        mIsInWishList = false;
      });
    }).catchError((error) {
      setState(() {
        toast(error.toString());
      });
    });
  }

  void addToWishList() async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }
    var request = {'pro_id': mainProduct!.id};
    await addWishList(request).then((res) {
      if (!mounted) return;
      productDetail();
      setState(() {
        toast(res[msg]);
        mIsInWishList = true;
      });
    }).catchError((error) {
      setState(() {
        toast(error.toString());
      });
    });
  }

// get Additional Information
  String getAllAttribute(Attribute attribute) {
    String attributes = "";
    for (var i = 0; i < attribute.options!.length; i++) {
      attributes = attributes + attribute.options![i];
      if (i < attribute.options!.length - 1) {
        attributes = attributes + " , ";
      }
    }
    return attributes;
  }

// Set additional information
  Widget mSetAttribute() {
    return ListView.builder(
      itemCount: mainProduct!.attributes!.length,
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
      ),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemBuilder: (context, i) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mainProduct!.attributes![i].name! + ' : ',
              style: secondaryTextStyle(size: 16),
            ),
            Text(
              getAllAttribute(mainProduct!.attributes![i]),
              maxLines: 4,
              style: secondaryTextStyle(color: textSecondaryColour),
            ).paddingTop(2).expand(),
          ],
        ).paddingOnly(
            left: spacing_standard.toDouble(),
            bottom: spacing_control.toDouble(),
            top: spacing_control.toDouble());
      },
    );
  }

// ignore: missing_return
  mOtherAttribute() {
    toast('Product type not supported');
    finish(context);
  }

  bool isFirst = true;
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

  @override
  Widget build(BuildContext context) {
    setValue(CARTCOUNT, appStore.count);

    var appLocalization = AppLocalizations.of(context);

    // API calling for add to cart
    Future addToCartApi(proId, int quantity, {returnExpected = false}) async {
      if (!await isLoggedIn()) {
        //Kashif --start
        if (!isFirst) {
          await _createInterstitialAd();
          print('interstitial ad now is $interstitialAd');
          if (interstitialAd != null) {
            interstitialAd!.show();
            isFirst = true;
          }
        } else {
          isFirst = false;
        }
        //Kashif --end
        SignInScreen().launch(context);
        return;
      }
      var request = {"pro_id": proId, "quantity": quantity};
      await addToCart(request).then((res) {
        toast(appLocalization!.translate('msg_add_cart'));
        appStore.isLoading = false;
        isAddedToCart = true;
        appStore.increment();
        init();
        setState(() {});
        return returnExpected;
      }).catchError((error) {
        toast(error.toString());
        setState(() {
          appStore.isLoading = false;
        });
        return returnExpected;
      });
    }

// API calling for remove cart
    Future removeToCartApi(proId, {returnExpected = false}) async {
      if (!await isLoggedIn()) {
        //Kashif --start
        if (!isFirst) {
          await _createInterstitialAd();
          print('interstitial ad now is $interstitialAd');
          if (interstitialAd != null) {
            interstitialAd!.show();
            isFirst = true;
          }
        } else {
          isFirst = false;
        }
        //Kashif --end
        SignInScreen().launch(context);
        return;
      }

      var request = {"pro_id": proId};

      await removeCartItem(request).then((res) {
        toast(appLocalization!.translate('msg_remove_cart'));
        isAddedToCart = false;
        appStore.decrement();
        init();
        setState(() {});
        return returnExpected;
      }).catchError((error) {
        toast(error.toString());
        setState(() {});
        return returnExpected;
      });
    }

    void checkCart({int? proID, bool isAddCart = false}) async {
      if (!await isGuestUser() && await isLoggedIn()) {
        if (isAddCart) {
          removeToCartApi(
              proID.toString().isEmptyOrNull ? mainProduct!.id : proID);
        } else {
          addToCartApi(
              proID.toString().isEmptyOrNull ? mainProduct!.id : proID, 1);
        }
      } else {
        isAddCart = !isAddCart;
        List<String?> mList = [];
        mainProduct!.images.forEachIndexed((element, index) {
          mList.add(element.src);
        });
        CartModel mCartModel = CartModel();
        mCartModel.name = mainProduct!.name;
        mCartModel.proId =
            proID.toString().isEmptyOrNull ? mainProduct!.id : proID;
        mCartModel.onSale = mainProduct!.onSale;
        mCartModel.salePrice = mainProduct!.salePrice;
        mCartModel.regularPrice = mainProduct!.regularPrice;
        mCartModel.price = mainProduct!.price;
        mCartModel.gallery = mList.cast<String>();
        mCartModel.quantity = "1";
        mCartModel.stockQuantity = "1";
        mCartModel.stockStatus = "";
        mCartModel.thumbnail = "";
        mCartModel.full = mainProduct!.images![0].src;
        mCartModel.cartId = mainProduct!.id.toString();
        mCartModel.sku = "";
        mCartModel.createdAt = "";
        if (isAddCart == false) {
          appStore.decrement();
          toast(appLocalization!.translate('msg_remove_cart'));
          appStore.removeFromCartList(mCartModel);
        } else {
          appStore.increment();
          toast(appLocalization!.translate('msg_add_cart'));
          appStore.addToCartList(mCartModel);
        }
        setState(() {});
      }
    }

    Widget mUpcomingSale() {
      if (mainProduct != null) {
        if (mainProduct!.dateOnSaleFrom != "") {
          return Column(
            children: [
              Divider(
                thickness: 6,
                color: appStore.isDarkMode!
                    ? white.withOpacity(0.2)
                    : Theme.of(context).textTheme.headline4!.color,
              ),
              Container(
                margin:
                    EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
                width: context.width(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(ic_offer,
                            height: 25,
                            width: 25,
                            color: textSecondaryColorGlobal)
                        .paddingTop(4),
                    16.width,
                    createRichText(list: [
                      TextSpan(
                          text: appLocalization!
                                  .translate('lbl_sale_start_from')! +
                              " ",
                          style: secondaryTextStyle()),
                      TextSpan(
                          text: mainProduct!.dateOnSaleFrom! + " ",
                          style: boldTextStyle(color: primaryColor!)),
                      TextSpan(
                          text: appLocalization.translate('lbl_to')! + " ",
                          style: secondaryTextStyle()),
                      TextSpan(
                          text: mainProduct!.dateOnSaleTo! + ". ",
                          style: boldTextStyle(color: primaryColor!)),
                      TextSpan(
                          text: appLocalization.translate('lbl_nearing_sale')!,
                          style: secondaryTextStyle()),
                    ]).expand(),
                  ],
                ),
              ),
            ],
          );
        } else {
          return SizedBox();
        }
      } else {
        return SizedBox();
      }
    }

    Widget _review() {
      return mReviewModel.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appLocalization!.translate("lbl_customer_review")!,
                      style: boldTextStyle(),
                    ),
                    Text(appLocalization.translate("lbl_view_all")!,
                            style: boldTextStyle(color: primaryColor))
                        .onTap(() async {
                      //Kashif --start
                      if (!isFirst) {
                        await _createInterstitialAd();
                        print('interstitial ad now is $interstitialAd');
                        if (interstitialAd != null) {
                          interstitialAd!.show();
                          isFirst = true;
                        }
                      } else {
                        isFirst = false;
                      }
                      //Kashif --end
                      final double? result =
                          await ReviewScreen(mProductId: mainProduct!.id)
                              .launch(context);
                      if (result == null) {
                        rating = rating;
                        setState(() {});
                      } else {
                        rating = result;
                        setState(() {});
                      }
                    }).visible(mainProduct!.reviewsAllowed == true)
                  ],
                )
                    .paddingOnly(top: 8, left: 16, right: 16)
                    .visible(mReviewModel.isNotEmpty),
                ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                  padding: EdgeInsets.all(16),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: mReviewModel.length >= 3 ? 3 : mReviewModel.length,
                  itemBuilder: (context, index) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        mProfileImage!.isNotEmpty
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage(mProfileImage.validate()),
                                radius: 25)
                            : CircleAvatar(
                                backgroundImage:
                                    Image.asset(User_Profile).image,
                                radius: 25,
                              ),
                        16.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mReviewModel[index].reviewer!,
                                style: boldTextStyle()),
                            2.height,
                            Text(
                                reviewConvertDate(
                                    mReviewModel[index].dateCreated),
                                style: secondaryTextStyle()),
                            8.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 6, right: 6, top: 2, bottom: 2),
                                  decoration: BoxDecoration(
                                      color: mReviewModel[index].rating == 1
                                          ? primaryColor!.withOpacity(0.45)
                                          : mReviewModel[index].rating == 2
                                              ? yellowColor.withOpacity(0.45)
                                              : mReviewModel[index].rating == 3
                                                  ? yellowColor
                                                      .withOpacity(0.45)
                                                  : Color(0xFF66953A)
                                                      .withOpacity(0.45),
                                      borderRadius: radius()),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                          mReviewModel[index].rating.toString(),
                                          style: primaryTextStyle(
                                              color: whiteColor, size: 12)),
                                      2.width,
                                      Icon(Icons.star_border,
                                          size: 12, color: whiteColor)
                                    ],
                                  ),
                                ),
                                6.width,
                                Text(
                                        parseHtmlString(mReviewModel[index]
                                            .review
                                            .toString()),
                                        style: primaryTextStyle())
                                    .expand(),
                              ],
                            ),
                          ],
                        ).expand(),
                      ],
                    ).paddingOnly(top: 4, bottom: 4);
                  },
                )
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    appLocalization!.translate("lbl_view_all_customer_review")!,
                    style: boldTextStyle()),
                Icon(Icons.chevron_right),
              ],
            ).onTap(() async {
              //Kashif --start
              if (!isFirst) {
                await _createInterstitialAd();
                print('interstitial ad now is $interstitialAd');
                if (interstitialAd != null) {
                  interstitialAd!.show();
                  isFirst = true;
                }
              } else {
                isFirst = false;
              }
              //Kashif --end
              ReviewScreen(mProductId: mainProduct!.id).launch(context);
            }).paddingOnly(bottom: 12, top: 12, left: 16, right: 12);
    }

    Widget upSaleProductList(List<UpsellId> product) {
      return Container(
        decoration: boxDecorationWithRoundedCorners(
            backgroundColor: primaryColor!.withOpacity(0.07),
            borderRadius: radius(0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            16.height,
            Text(
              builderResponse.dashboard!.youMayAlsoLike!.title!,
              style: boldTextStyle(),
            ).paddingLeft(spacing_standard_new.toDouble()),
            HorizontalList(
              padding: EdgeInsets.only(right: 16),
              itemCount: product.length,
              itemBuilder: (context, i) {
                return Container(
                  width: 160,
                  decoration: boxDecorationRoundedWithShadow(
                      defaultRadius.toInt(),
                      backgroundColor: Theme.of(context).cardColor),
                  margin: EdgeInsets.fromLTRB(16, 16, 0, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: boxDecorationWithRoundedCorners(
                            borderRadius: radius(),
                            backgroundColor:
                                Theme.of(context).colorScheme.background),
                        child: commonCacheImageWidget(
                                product[i].images!.first.src,
                                height: 150,
                                width: 160,
                                fit: BoxFit.cover)
                            .cornerRadiusWithClipRRectOnly(
                                topRight: defaultRadius.toInt(),
                                topLeft: defaultRadius.toInt()),
                      ),
                      spacing_control.height,
                      Text(product[i].name!,
                              style: primaryTextStyle(size: textSizeSMedium),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)
                          .paddingOnly(right: 6, left: 10),
                      spacing_standard.height,
                      Row(
                        children: [
                          PriceWidget(
                            price: product[i].salePrice.toString().isNotEmpty
                                ? product[i].salePrice.toString()
                                : product[i].price.toString(),
                            size: 14,
                            color: primaryColor,
                          ),
                          4.width,
                          PriceWidget(
                                  price: product[i].regularPrice.toString(),
                                  size: 12,
                                  isLineThroughEnabled: true,
                                  color: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .color)
                              .visible(
                                  product[i].salePrice.toString().isNotEmpty),
                        ],
                      ).paddingLeft(10),
                      10.height,
                    ],
                  ),
                ).onTap(() async {
                  //Kashif --start
                  if (!isFirst) {
                    await _createInterstitialAd();
                    print('interstitial ad now is $interstitialAd');
                    if (interstitialAd != null) {
                      interstitialAd!.show();
                      isFirst = true;
                    }
                  } else {
                    isFirst = false;
                  }
                  //Kashif --end
                  if (builderResponse.productdetailview!.layout ==
                      'productDetail1') {
                    // //Kashif --start
                    // if (!isFirst) {
                    //   await _createInterstitialAd();
                    //   print('interstitial ad now is $interstitialAd');
                    //   if (interstitialAd != null) {
                    //     interstitialAd!.show();
                    //     isFirst = true;
                    //   }
                    // } else {
                    //   isFirst = false;
                    // }
                    // //Kashif --end
                    ProductDetailScreen1(mProId: product[i].id).launch(context);
                  } else if (builderResponse.productdetailview!.layout ==
                      'productDetail2') {
                    // //Kashif --start
                    // await _createInterstitialAd();
                    // print('interstitial ad now is $interstitialAd');
                    // if (interstitialAd != null) {
                    //   interstitialAd!.show();
                    // }
                    // //Kashif --end
                    ProductDetailScreen2(mProId: product[i].id).launch(context);
                  } else {
                    // //Kashif --start
                    // await _createInterstitialAd();
                    // print('interstitial ad now is $interstitialAd');
                    // if (interstitialAd != null) {
                    //   interstitialAd!.show();
                    // }
                    // //Kashif --end
                    ProductDetailScreen3(mProId: product[i].id).launch(context);
                  }
                });
              },
            )
          ],
        ),
      );
    }

    //Group
    Widget mGroupAttribute(List<ProductDetailResponse> product) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            appLocalization!.translate('lbl_product_include')!,
            style: boldTextStyle(),
          ).paddingOnly(left: 16, top: spacing_standard.toDouble()),
          8.height,
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: product.length,
              padding: EdgeInsets.only(left: 8, right: 8),
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () async {
                    //Kashif --start
                    if (!isFirst) {
                      await _createInterstitialAd();
                      print('interstitial ad now is $interstitialAd');
                      if (interstitialAd != null) {
                        interstitialAd!.show();
                        isFirst = true;
                      }
                    } else {
                      isFirst = false;
                    }
                    //Kashif --end
                    if (builderResponse.productdetailview!.layout ==
                        'productDetail1') {
                      // //Kashif --start
                      // await _createInterstitialAd();
                      // if (interstitialAd != null) {
                      //   interstitialAd!.show();
                      // }
                      // //Kashif --end
                      ProductDetailScreen1(mProId: product[i].id)
                          .launch(context);
                    } else if (builderResponse.productdetailview!.layout ==
                        'productDetail2') {
                      // //Kashif --start
                      // await _createInterstitialAd();
                      // print('interstitial ad now is $interstitialAd');
                      // if (interstitialAd != null) {
                      //   interstitialAd!.show();
                      // }
                      // //Kashif --end
                      ProductDetailScreen2(mProId: product[i].id)
                          .launch(context);
                    } else {
                      // //Kashif --start
                      // await _createInterstitialAd();
                      // print('interstitial ad now is $interstitialAd');
                      // if (interstitialAd != null) {
                      //   interstitialAd!.show();
                      // }
                      // //Kashif --end
                      ProductDetailScreen3(mProId: product[i].id)
                          .launch(context);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: boxDecorationWithShadow(
                        borderRadius: radius(),
                        backgroundColor: context.scaffoldBackgroundColor),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        commonCacheImageWidget(
                          product[i].images![0].src,
                          height: 85,
                          width: 85,
                          fit: BoxFit.cover,
                        ).cornerRadiusWithClipRRect(defaultRadius),
                        4.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            8.height,
                            Text(
                              product[i].name!,
                              style: boldTextStyle(),
                            ).paddingOnly(
                                left: spacing_standard.toDouble(),
                                right: spacing_standard.toDouble()),
                            24.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    PriceWidget(
                                        price: product[i]
                                                .salePrice
                                                .toString()
                                                .validate()
                                                .isNotEmpty
                                            ? product[i].salePrice.toString()
                                            : product[i]
                                                .price
                                                .toString()
                                                .validate(),
                                        size: 14,
                                        color: Theme.of(context)
                                            .textTheme
                                            .subtitle2!
                                            .color),
                                    2.width,
                                    PriceWidget(
                                            price: product[i]
                                                .regularPrice
                                                .toString(),
                                            size: 12,
                                            isLineThroughEnabled: true,
                                            color: Theme.of(context)
                                                .textTheme
                                                .subtitle2!
                                                .color)
                                        .visible(product[i]
                                            .salePrice
                                            .toString()
                                            .isNotEmpty),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(8, 6, 8, 6),
                                  decoration: boxDecorationWithRoundedCorners(
                                      borderRadius: radius(),
                                      backgroundColor: product[i].inStock!
                                          ? primaryColor!
                                          : textSecondaryColorGlobal
                                              .withOpacity(0.3)),
                                  child: Text(
                                      product[i].inStock == true
                                          ? product[i].type == 'external'
                                              ? product[i].buttonText!
                                              : product[i].isAddedCart! == false
                                                  ? appLocalization
                                                      .translate(
                                                          'lbl_add_to_cart')!
                                                      .toUpperCase()
                                                  : appLocalization
                                                      .translate(
                                                          'lbl_remove_cart')!
                                                      .toUpperCase()
                                          : appLocalization
                                              .translate('lbl_sold_out')!
                                              .toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: boldTextStyle(
                                          color: white, size: 12)),
                                ).onTap(() async {
                                  if (product[i].inStock == true) {
                                    if (product[i].type == 'external') {
                                      //Kashif --start
                                      if (!isFirst) {
                                        await _createInterstitialAd();
                                        print(
                                            'interstitial ad now is $interstitialAd');
                                        if (interstitialAd != null) {
                                          interstitialAd!.show();
                                          isFirst = true;
                                        }
                                      } else {
                                        isFirst = false;
                                      }
                                      //Kashif --end
                                      ExternalProductScreen(
                                              mExternal_URL:
                                                  product[i].externalUrl,
                                              title: appLocalization.translate(
                                                  'lbl_external_product'))
                                          .launch(context);
                                    } else {
                                      checkCart(
                                          proID: product[i].id,
                                          isAddCart: product[i].isAddedCart!);
                                      setState(() {});
                                    }
                                  }
                                }),
                              ],
                            ).paddingOnly(left: 8, right: 8),
                          ],
                        ).expand()
                      ],
                    ),
                  ).paddingBottom(spacing_standard.toDouble()),
                );
              })
        ],
      );
    }

    final imgSlider = productDetailNew != null
        ? Container(
            height: 550,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView(
                  children: productImg1.map((i) {
                    return commonCacheImageWidget(i.toString(),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 500)
                        .onTap(() async {
                      //Kashif --start
                      if (!isFirst) {
                        await _createInterstitialAd();
                        print('interstitial ad now is $interstitialAd');
                        if (interstitialAd != null) {
                          interstitialAd!.show();
                          isFirst = true;
                        }
                      } else {
                        isFirst = false;
                      }
                      //Kashif --end
                      ProductImageScreen(mImgList: productDetailNew!.images)
                          .launch(context);
                    });
                  }).toList(),
                  controller: _pageController,
                  onPageChanged: (index) {
                    selectIndex = index;
                    setState(() {});
                  },
                ),
                AnimatedPositioned(
                  duration: Duration(seconds: 1),
                  bottom: 0,
                  child: DotIndicator(
                    pageController: _pageController,
                    pages: productImg1,
                    indicatorColor: primaryColor,
                    unselectedIndicatorColor: grey.withOpacity(0.6),
                    currentBoxShape: BoxShape.rectangle,
                    boxShape: BoxShape.rectangle,
                    borderRadius: radius(2),
                    currentBorderRadius: radius(3),
                    currentDotSize: 18,
                    currentDotWidth: 6,
                    dotSize: 6,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: boxDecorationWithRoundedCorners(
                      borderRadius: radius(),
                      backgroundColor: black.withOpacity(0.1),
                      border: Border.all(color: view_color),
                    ),
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                    margin: EdgeInsets.only(right: 16, top: 16),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: rating.toString() + " ",
                              style: secondaryTextStyle(size: 14)),
                          WidgetSpan(
                              child: Icon(Icons.star,
                                  size: 16, color: yellowColor)),
                        ],
                      ),
                    ),
                  ).onTap(() async {
                    _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        curve: Curves.easeOut,
                        duration: Duration(milliseconds: 300));
                  }),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: mainProduct!.inStock!
                      ? Container(
                          padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.6),
                          ),
                          child: Text(
                              appLocalization!.translate("lbl_in_stock")!,
                              style:
                                  boldTextStyle(color: Colors.white, size: 14)),
                        )
                      : Container(
                          padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.6),
                          ),
                          child: Text(
                              appLocalization!.translate("lbl_out_of_stock")!,
                              style:
                                  boldTextStyle(color: Colors.white, size: 14)),
                        ),
                ),
              ],
            ),
          )
        : SizedBox();

    void checkWishList() async {
      if (!await isLoggedIn()) {
        //Kashif --start
        if (!isFirst) {
          await _createInterstitialAd();
          print('interstitial ad now is $interstitialAd');
          if (interstitialAd != null) {
            interstitialAd!.show();
            isFirst = true;
          }
        } else {
          isFirst = false;
        }
        //Kashif --end
        SignInScreen().launch(context);
      } else if (!await isGuestUser() && await isLoggedIn()) {
        if (mainProduct!.isAddedWishList!) {
          removeWishListItem();
        } else
          addToWishList();
      } else {
        setState(() {
          mIsInWishList = !mIsInWishList;
          log("IsInWish" + mIsInWishList.toString());
          List<String?> mList = [];
          mainProduct!.images.forEachIndexed((element, index) {
            mList.add(element.src);
          });
          WishListResponse mWishListModel = WishListResponse();
          mWishListModel.name = mainProduct!.name;
          mWishListModel.proId = mainProduct!.id;
          mWishListModel.salePrice = mainProduct!.salePrice;
          mWishListModel.regularPrice = mainProduct!.regularPrice;
          mWishListModel.price = mainProduct!.price;
          mWishListModel.gallery = mList;
          mWishListModel.stockQuantity = 1;
          mWishListModel.thumbnail = "";
          mWishListModel.full = mainProduct!.images![0].src;
          mWishListModel.sku = "";
          mWishListModel.createdAt = "";
          if (mIsInWishList == true) {
            appStore.addToMyWishList(mWishListModel);
            log("wishlist: $mWishListModel");
            toast("Add to wishList");
          } else {
            appStore.removeFromMyWishList(mWishListModel);
            toast("Remove to wishList");
          }
          setState(() {});
        });
      }
    }

    // Check Wish list
    final mFavourite = mainProduct != null
        ? GestureDetector(
            onTap: () {
              checkWishList();
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.all(spacing_middle.toDouble()),
              decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(),
                  backgroundColor: Theme.of(context).cardTheme.color!,
                  border: Border.all(color: primaryColor!)),
              child: Icon(
                  mIsInWishList == true
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: primaryColor,
                  size: 20),
            ),
          ).visible(mainProduct!.isAddedWishList != null)
        : SizedBox();

    final mCartData = mainProduct != null
        ? GestureDetector(
            onTap: () async {
              if (mainProduct!.inStock == true) {
                if (mIsExternalProduct) {
                  //Kashif --start
                  if (!isFirst) {
                    await _createInterstitialAd();
                    print('interstitial ad now is $interstitialAd');
                    if (interstitialAd != null) {
                      interstitialAd!.show();
                      isFirst = true;
                    }
                  } else {
                    isFirst = false;
                  }
                  //Kashif --end
                  ExternalProductScreen(
                          mExternal_URL: mExternalUrl,
                          title: appLocalization!
                              .translate('lbl_external_product'))
                      .launch(context);
                } else {
                  checkCart(isAddCart: isAddedToCart);
                  setState(() {});
                }
              }
            },
            child: Container(
              padding: EdgeInsets.all(spacing_middle.toDouble()),
              decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(),
                  backgroundColor: mainProduct!.inStock!
                      ? primaryColor!
                      : textSecondaryColorGlobal.withOpacity(0.3)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    ic_bag,
                    height: 18,
                    width: 18,
                    color: white,
                  ).paddingBottom(4),
                  6.width,
                  Text(
                      mainProduct!.inStock == true
                          ? mainProduct!.type == 'external'
                              ? mainProduct!.buttonText!
                              : isAddedToCart == false
                                  ? appLocalization!
                                      .translate('lbl_add_to_cart')!
                                      .toUpperCase()
                                  : appLocalization!
                                      .translate('lbl_remove_cart')!
                                      .toUpperCase()
                          : appLocalization!
                              .translate('lbl_sold_out')!
                              .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: primaryTextStyle(
                        color: white,
                      )),
                ],
              ),
            ),
          )
        : SizedBox();

    final mPrice = mainProduct != null
        ? mainProduct!.onSale == true
            ? Row(
                children: [
                  PriceWidget(
                    price: productDetailNew!.salePrice.toString().isNotEmpty
                        ? productDetailNew!.salePrice.toString()
                        : double.parse(productDetailNew!.price.toString()),
                    size: 18,
                    color: primaryColor,
                  ),
                  PriceWidget(
                    price:
                        double.parse(productDetailNew!.regularPrice.toString()),
                    size: 14,
                    color: Theme.of(context).textTheme.subtitle1!.color,
                    isLineThroughEnabled: true,
                  ).paddingOnly(left: 4).visible(
                      productDetailNew!.salePrice.toString().isNotEmpty &&
                          productDetailNew!.onSale == true)
                ],
              )
            : PriceWidget(
                price: double.parse(productDetailNew!.price.toString()),
                size: 18,
                color: primaryColor,
              )
        : SizedBox();

    Widget mSavePrice() {
      if (mainProduct != null) {
        if (mainProduct!.onSale!) {
          var value = double.parse(productDetailNew!.regularPrice.toString()) -
              double.parse(productDetailNew!.price.toString());
          if (value > 0) {
            return Row(
              children: [
                Text('(', style: primaryTextStyle(color: Colors.green)),
                Text(appLocalization!.translate('lbl_you_saved')! + " ",
                    style: secondaryTextStyle(color: Colors.green)),
                PriceWidget(
                    price: value.toStringAsFixed(2),
                    size: textSizeSMedium.toDouble(),
                    color: Colors.green),
                Text(')', style: primaryTextStyle(color: Colors.green)),
              ],
            );
          } else {
            return SizedBox();
          }
        } else {
          return SizedBox();
        }
      } else {
        return SizedBox();
      }
    }

    Widget mExternalAttribute() {
      setPriceDetail();
      mIsExternalProduct = true;
      mExternalUrl = mainProduct!.externalUrl.toString();
      return SizedBox();
    }

    final body = mainProduct != null
        ? SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                productDetailNew!.images!.isNotEmpty ? imgSlider : SizedBox(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    Container(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(mainProduct!.name!,
                                      style: boldTextStyle(size: 18))
                                  .paddingOnly(left: 16, bottom: 4)
                                  .expand(),
                              if (mainProduct!.onSale == true)
                                FittedBox(
                                        child: Container(
                                  padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          bottomRight: Radius.circular(8))),
                                  child: Text(
                                      appLocalization!.translate('lbl_sale')!,
                                      style: boldTextStyle(
                                          color: Colors.white, size: 12)),
                                ).cornerRadiusWithClipRRectOnly(
                                            topLeft: 0, bottomLeft: 4))
                                    .paddingRight(16),
                            ],
                          ),
                          8.height,
                          Row(
                            children: [
                              mPrice,
                              mSavePrice()
                                  .paddingOnly(left: 4, bottom: 4)
                                  .expand(),
                              mDiscount().visible(productDetailNew!.salePrice
                                      .toString()
                                      .isNotEmpty &&
                                  productDetailNew!.onSale == true),
                            ],
                          )
                              .paddingOnly(left: 16, right: 16, bottom: 8)
                              .visible(mainProduct!.type != "grouped"),
                        ],
                      ),
                    ),

                    // Sale timer
                    if (mainProduct!.onSale!)
                      mainProduct!.dateOnSaleFrom!.isNotEmpty
                          ? mSpecialPrice(
                              appLocalization!.translate('lbl_special_msg'))
                          : SizedBox().visible(
                              mainProduct!.store!.shopName!.isNotEmpty),

                    // Upcoming sale
                    mUpcomingSale().visible(!mainProduct!.onSale!),

                    // Description
                    Divider(
                      thickness: 6,
                      color: appStore.isDarkMode!
                          ? white.withOpacity(0.2)
                          : Theme.of(context).textTheme.headline4!.color,
                    ).visible(mainProduct!.dateOnSaleFrom!.isEmpty ||
                        !mainProduct!.onSale!),
                    Text(appLocalization!.translate('hint_description')!,
                            style: boldTextStyle())
                        .paddingOnly(left: 16, right: 16, top: 8)
                        .visible(
                            mainProduct!.description.toString().isNotEmpty),
                    HtmlWidget(postContent: mainProduct!.description)
                        .paddingOnly(left: 8, right: 8)
                        .visible(
                            mainProduct!.description.toString().isNotEmpty),

                    // Short Description
                    Text(appLocalization.translate('lbl_short_description')!,
                            style: boldTextStyle())
                        .paddingOnly(left: 16, right: 16, top: 8)
                        .visible(mainProduct!.shortDescription
                            .toString()
                            .isNotEmpty),
                    HtmlWidget(postContent: mainProduct!.shortDescription)
                        .paddingOnly(left: 8, right: 8)
                        .visible(mainProduct!.shortDescription
                            .toString()
                            .isNotEmpty),

                    // Product Type
                    if (mainProduct!.type == "variable" ||
                        mainProduct!.type == "variation")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Divider(
                            thickness: 6,
                            color: appStore.isDarkMode!
                                ? white.withOpacity(0.2)
                                : Theme.of(context).textTheme.headline4!.color,
                          ),
                          Text(
                            appLocalization.translate('lbl_Available')!,
                            style: boldTextStyle(),
                          ).paddingOnly(left: 16, right: 16, top: 8, bottom: 4),
                          Wrap(
                            children: mProductOptions.map((e) {
                              int index = mProductOptions.indexOf(e);
                              return Container(
                                      margin: EdgeInsets.only(
                                          left: 8, top: 8, bottom: 8),
                                      padding: EdgeInsets.all(8),
                                      decoration:
                                          boxDecorationWithRoundedCorners(
                                              borderRadius: radius(),
                                              backgroundColor:
                                                  selectedOption == index
                                                      ? primaryColor!
                                                          .withOpacity(0.3)
                                                      : context.cardColor,
                                              border: Border.all(
                                                  width: 0.1,
                                                  color: selectedOption == index
                                                      ? primaryColor!
                                                          .withOpacity(0.3)
                                                      : textSecondaryColor)),
                                      child: Text(e!,
                                          style: secondaryTextStyle(
                                              size: 16,
                                              color: selectedOption == index
                                                  ? white
                                                  : textSecondaryColour)))
                                  .onTap(() {
                                setState(() {
                                  mSelectedVariation = e;
                                  selectedOption = index;
                                  mProducts.forEach((product) {
                                    if (mProductVariationsIds[index] ==
                                        product.id) {
                                      this.productDetailNew = product;
                                    }
                                  });
                                  setPriceDetail();
                                  mImage();
                                });
                              });
                            }).toList(),
                          ).paddingLeft(8)
                        ],
                      ).visible(mainProduct!.type!.isNotEmpty)
                    else if (mainProduct!.type == "grouped")
                      mGroupAttribute(product)
                    else if (mainProduct!.type == "simple")
                      Container()
                    else if (mainProduct!.type == "external")
                      Column(
                        children: [
                          mExternalAttribute(),
                        ],
                      )
                    else
                      mOtherAttribute(),

                    // Additional Information
                    Divider(
                      thickness: 6,
                      color: appStore.isDarkMode!
                          ? white.withOpacity(0.2)
                          : Theme.of(context).textTheme.headline4!.color,
                    ).visible(mainProduct!.attributes!.isNotEmpty),
                    Text(
                            appLocalization
                                .translate('lbl_additional_information')!,
                            style: boldTextStyle())
                        .paddingOnly(left: 16, bottom: 4, right: 16, top: 8)
                        .visible(mainProduct!.attributes!.isNotEmpty),
                    mSetAttribute()
                        .visible(mainProduct!.attributes!.isNotEmpty),

                    //Category
                    Divider(
                      thickness: 6,
                      color: appStore.isDarkMode!
                          ? white.withOpacity(0.2)
                          : Theme.of(context).textTheme.headline4!.color,
                    ).visible(mainProduct!.categories!.isNotEmpty),
                    Text(appLocalization.translate('lbl_category')!,
                            style: boldTextStyle())
                        .paddingOnly(left: 16, right: 16, top: 8, bottom: 4),
                    Wrap(
                      children: mainProduct!.categories!.map((e) {
                        return Container(
                          margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                          padding: EdgeInsets.all(8),
                          decoration: boxDecorationWithRoundedCorners(
                            borderRadius: radius(),
                            backgroundColor: appStore.isDarkMode!
                                ? white.withOpacity(0.2)
                                : Theme.of(context).colorScheme.background,
                          ),
                          child: Text(e.name!, style: secondaryTextStyle()),
                        ).onTap(() async {
                          //Kashif --start
                          if (!isFirst) {
                            await _createInterstitialAd();
                            print('interstitial ad now is $interstitialAd');
                            if (interstitialAd != null) {
                              interstitialAd!.show();
                              isFirst = true;
                            }
                          } else {
                            isFirst = false;
                          }
                          //Kashif --end
                          ViewAllScreen(e.name,
                                  isCategory: true, categoryId: e.id)
                              .launch(context);
                        });
                      }).toList(),
                    ).paddingOnly(
                        left: spacing_standard_new.toDouble(),
                        right: spacing_standard_new.toDouble()),

                    // Upsell
                    Divider(
                      thickness: 6,
                      color: appStore.isDarkMode!
                          ? white.withOpacity(0.2)
                          : Theme.of(context).textTheme.headline4!.color,
                    ).visible(mainProduct!.upSellId!.isNotEmpty),
                    if (mainProduct!.upSellIds!.isNotEmpty)
                      if (mainProduct!.upSellIds != null)
                        upSaleProductList(mainProduct!.upSellId!)
                            .visible(mainProduct!.upSellId!.isNotEmpty),

                    // Store
                    Divider(
                        thickness: 6,
                        color: appStore.isDarkMode!
                            ? white.withOpacity(0.2)
                            : Theme.of(context).textTheme.headline4!.color),
                    mainProduct!.store == null
                        ? Offstage()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  appLocalization
                                          .translate('txt_more_product')! +
                                      " " +
                                      mainProduct!.store!.shopName!,
                                  style: boldTextStyle()),
                              Icon(Icons.chevron_right),
                            ],
                          ).onTap(() async {
                            //Kashif --start
                            if (!isFirst) {
                              await _createInterstitialAd();
                              print('interstitial ad now is $interstitialAd');
                              if (interstitialAd != null) {
                                interstitialAd!.show();
                                isFirst = true;
                              }
                            } else {
                              isFirst = false;
                            }
                            //Kashif --end
                            VendorProfileScreen(
                                    mVendorId: mainProduct!.store!.id)
                                .launch(context);
                          }).paddingAll(12),

                    // Review
                    Divider(
                        thickness: 6,
                        color: appStore.isDarkMode!
                            ? white.withOpacity(0.2)
                            : Theme.of(context).textTheme.headline4!.color),
                    _review(),

                    // Payment info
                    Divider(
                        thickness: 6,
                        color: appStore.isDarkMode!
                            ? white.withOpacity(0.2)
                            : Theme.of(context).textTheme.headline4!.color),
                    Row(
                      children: [
                        Image.asset(ic_cod,
                            height: 30,
                            width: 30,
                            color: textSecondaryColorGlobal),
                        16.width,
                        Text(appLocalization.translate('txt_msg_payment')!,
                                style: secondaryTextStyle())
                            .expand(),
                      ],
                    ).paddingAll(12),
                    16.height
                  ],
                )
              ],
            ),
          )
        : SizedBox();

    return WillPopScope(
      onWillPop: () async {
        finish(context, mIsInWishList);
        log(mIsInWishList);
        return false;
      },
      child: SafeArea(
        top: isIos ? false : true,
        child: Scaffold(
          appBar: AppBar(
              elevation: 0,
              backgroundColor: appStore.isDarkMode! ? darkColor : primaryColor!,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: white),
                onPressed: () {
                  finish(context, mIsInWishList);
                },
              ),
              actions: [
                mCart(context, mIsLoggedIn, color: white),
              ],
              title: Text(mainProduct != null ? mainProduct!.name! : ' ',
                  style: boldTextStyle(
                      color: Colors.white, size: textSizeLargeMedium)),
              automaticallyImplyLeading: false),
          body: mView(
              mInternetConnection(
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: <Widget>[
                    mainProduct != null ? body : SizedBox(),
                    mProgress().center().visible(appStore.isLoading!),
                  ],
                ),
              ),
              context),
          bottomNavigationBar: Container(
            width: context.width(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Theme.of(context).hoverColor.withOpacity(0.8),
                    blurRadius: 15.0,
                    offset: Offset(0.0, 0.75)),
              ],
            ),
            child: Row(
              children: [
                mFavourite,
                6.width,
                mCartData.expand(),
              ],
            )
                .paddingOnly(
                    top: spacing_standard.toDouble(),
                    bottom: spacing_standard.toDouble(),
                    right: spacing_middle.toDouble(),
                    left: spacing_middle.toDouble())
                .visible(!mIsGroupedProduct),
          ).visible(mainProduct != null),
        ),
      ),
    );
  }
}
