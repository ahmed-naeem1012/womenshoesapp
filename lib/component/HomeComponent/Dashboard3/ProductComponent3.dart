import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:woobox/app_localizations.dart';
import 'package:woobox/model/ProductResponse.dart';
import 'package:woobox/model/WishListResponse.dart';
import 'package:woobox/network/rest_apis.dart';
import 'package:woobox/screens/ProductDetail/ProductDetailScreen1.dart';
import 'package:woobox/screens/ProductDetail/ProductDetailScreen2.dart';
import 'package:woobox/screens/ProductDetail/ProductDetailScreen3.dart';
import 'package:woobox/screens/SignInScreen.dart';
import 'package:woobox/utils/app_widgets.dart';
import 'package:woobox/utils/colors.dart';
import 'package:woobox/utils/constants.dart';
import 'package:woobox/utils/images.dart';
import 'package:woobox/utils/shared_pref.dart';

import '../../../main.dart';

class ProductComponent3 extends StatefulWidget {
  static String tag = '/ProductComponent';
  final double? width;
  final ProductResponse? mProductModel;

  ProductComponent3({Key? key, this.width, this.mProductModel})
      : super(key: key);

  @override
  ProductComponent3State createState() => ProductComponent3State();
}

class ProductComponent3State extends State<ProductComponent3> {
  bool mIsInWishList = false;
  bool isAddedToCart = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void didChangeDependencies() {
    _createInterstitialAd();
    super.didChangeDependencies();
  }

  init() async {
    if (!await isGuestUser() && await isLoggedIn()) {
      if (widget.mProductModel!.isAddedWishList == false) {
        mIsInWishList = false;
      } else {
        mIsInWishList = true;
      }
    } else if (await isGuestUser()) {
      fetchPrefData();
    } else {}
  }

  void fetchPrefData() {
    if (appStore.mWishList.isNotEmpty) {
      appStore.mWishList.forEach((element) {
        if (element.proId == widget.mProductModel!.id) {
          mIsInWishList = true;
        }
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void checkLogin() async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    } else {
      setState(() {
        if (mIsInWishList == true)
          removeWishListItem();
        else
          addToWishList();
        mIsInWishList = !mIsInWishList;
      });
    }
  }

  void removeWishListItem() async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }
    await removeWishList({
      'pro_id': widget.mProductModel!.id,
    }).then((res) {
      if (!mounted) return;
      setState(() {
        toast(res[msg]);
        log("removeWishList" + mIsInWishList.toString());
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
    var request = {'pro_id': widget.mProductModel!.id};
    await addWishList(request).then((res) {
      if (!mounted) return;
      setState(() {
        toast(res[msg]);
        log("addToWishList" + mIsInWishList.toString());
        mIsInWishList = true;
      });
    }).catchError((error) {
      setState(() {
        toast(error.toString());
      });
    });
  }

  void removePrefData() async {
    if (!await isGuestUser()) {
      checkLogin();
    } else {
      mIsInWishList = !mIsInWishList;
      var mList = <String?>[];
      widget.mProductModel!.images.forEachIndexed((element, index) {
        mList.add(element.src);
      });
      WishListResponse mWishListModel = WishListResponse();
      mWishListModel.name = widget.mProductModel!.name;
      mWishListModel.proId = widget.mProductModel!.id;
      mWishListModel.salePrice = widget.mProductModel!.salePrice;
      mWishListModel.regularPrice = widget.mProductModel!.regularPrice;
      mWishListModel.price = widget.mProductModel!.price;
      mWishListModel.gallery = mList;
      mWishListModel.stockQuantity = 1;
      mWishListModel.thumbnail = "";
      mWishListModel.full = widget.mProductModel!.images![0].src;
      mWishListModel.sku = "";
      mWishListModel.createdAt = "";
      if (mIsInWishList != true) {
        appStore.removeFromMyWishList(mWishListModel);
      } else {
        appStore.addToMyWishList(mWishListModel);
      }
      setState(() {});
    }
  }

  InterstitialAd? interstitialAd;
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
    var appLocalization = AppLocalizations.of(context)!;
    var productWidth = MediaQuery.of(context).size.width;

    String? img = widget.mProductModel!.images!.isNotEmpty
        ? widget.mProductModel!.images!.first.src
        : '';

    return GestureDetector(
      onTap: () async {
        var result;
        if (builderResponse.productdetailview!.layout == 'productDetail1') {
          //Kashif --start
          await _createInterstitialAd();
          print('interstitial ad now is $interstitialAd');

          if (interstitialAd != null) {
            interstitialAd!.show();
          }
          //Kashif --end
          result = await ProductDetailScreen1(mProId: widget.mProductModel!.id)
              .launch(context);
        } else if (builderResponse.productdetailview!.layout ==
            'productDetail2') {
          //Kashif --start
          await _createInterstitialAd();
          print('interstitial ad now is $interstitialAd');
          if (interstitialAd != null) {
            interstitialAd!.show();
          }
          //Kashif --end
          result = await ProductDetailScreen2(mProId: widget.mProductModel!.id)
              .launch(context);
        } else {
          //Kashif --start
          await _createInterstitialAd();
          print('interstitial ad now is $interstitialAd');
          if (interstitialAd != null) {
            interstitialAd!.show();
          }
          //Kashif --end
          result = await ProductDetailScreen3(mProId: widget.mProductModel!.id)
              .launch(context);
        }
        if (result == null) {
          mIsInWishList = mIsInWishList;
          setState(() {});
        } else {
          mIsInWishList = result;
          setState(() {});
        }
      },
      child: Container(
        width: widget.width,
        decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt(),
            backgroundColor: Theme.of(context).cardTheme.color!),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topRight,
              children: [
                img.validate().isNotEmpty
                    ? commonCacheImageWidget(img.validate(),
                            height: 180, width: productWidth, fit: BoxFit.cover)
                        .cornerRadiusWithClipRRectOnly(
                            topLeft: defaultRadius.toInt(),
                            topRight: defaultRadius.toInt())
                    : commonCacheImageWidget(ic_placeHolder,
                            height: 180, width: productWidth, fit: BoxFit.cover)
                        .cornerRadiusWithClipRRectOnly(
                            topLeft: defaultRadius.toInt(),
                            topRight: defaultRadius.toInt()),
                mSale3(widget.mProductModel!,
                    appLocalization.translate('lbl_sale')!),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    margin: EdgeInsets.only(right: 4, top: 4),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: greyColor.withOpacity(0.6)),
                    child: mIsInWishList == false
                        ? Icon(Icons.favorite_border,
                            color: Theme.of(context).textTheme.subtitle2!.color,
                            size: 16)
                        : Icon(Icons.favorite, color: Colors.red, size: 16),
                  )
                      .visible(!widget.mProductModel!.type!.contains("grouped"))
                      .onTap(() {
                    removePrefData();
                  }),
                )
              ],
            ),
            Text(widget.mProductModel!.name,
                    style: primaryTextStyle(size: 14), maxLines: 1)
                .paddingOnly(top: 6, left: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PriceWidget(
                  price: widget.mProductModel!.onSale == true
                      ? widget.mProductModel!.salePrice.validate().isNotEmpty
                          ? double.parse(
                                  widget.mProductModel!.salePrice.toString())
                              .toStringAsFixed(2)
                          : double.parse(widget.mProductModel!.price.validate())
                              .toStringAsFixed(2)
                      : widget.mProductModel!.regularPrice!.isNotEmpty
                          ? double.parse(widget.mProductModel!.regularPrice
                                  .validate()
                                  .toString())
                              .toStringAsFixed(2)
                          : double.parse(widget.mProductModel!.price
                                  .validate()
                                  .toString())
                              .toStringAsFixed(2),
                  size: 14,
                  color: primaryColor,
                ).paddingOnly(left: 4),
                spacing_control.width,
                PriceWidget(
                  price:
                      widget.mProductModel!.regularPrice.validate().toString(),
                  size: 12,
                  isLineThroughEnabled: true,
                  color: Theme.of(context).textTheme.subtitle1!.color,
                ).expand().visible(
                    widget.mProductModel!.salePrice.validate().isNotEmpty &&
                        widget.mProductModel!.onSale == true),
                Container(
                  decoration: boxDecorationWithRoundedCorners(
                      borderRadius: radius(),
                      backgroundColor: context.cardColor,
                      border: Border.all(color: view_color)),
                  padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text:
                                widget.mProductModel!.ratingCount!.toString() +
                                    " ",
                            style: secondaryTextStyle(size: 14)),
                        WidgetSpan(
                            child:
                                Icon(Icons.star, size: 16, color: yellowColor)),
                      ],
                    ),
                  ),
                ).visible(widget.mProductModel!.ratingCount != 0),
              ],
            )
                .visible(!widget.mProductModel!.type!.contains("grouped"))
                .paddingOnly(bottom: 4, top: 4, left: 8, right: 4),
            4.height,
          ],
        ),
      ),
    );
  }
}
