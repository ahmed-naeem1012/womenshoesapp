
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:woobox/model/ProductResponse.dart';
import 'package:woobox/screens/VendorListScreen.dart';
import 'package:woobox/screens/VendorProfileScreen.dart';
import 'package:woobox/utils/app_widgets.dart';
import 'package:woobox/utils/colors.dart';
import 'package:woobox/utils/constants.dart';
import 'package:woobox/utils/images.dart';

import '../../../app_localizations.dart';
import '../../../main.dart';

Widget vendorList4(List<VendorResponse> product) {
  return ListView.builder(
    itemCount: product.length >= TOTAL_DASHBOARD_ITEM ? TOTAL_DASHBOARD_ITEM : product.length,
    physics: NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    padding: EdgeInsets.only(left: 8, right: 8),
    itemBuilder: (context, i) {
      return GestureDetector(
        onTap: () {
          VendorProfileScreen(mVendorId: product[i].id).launch(context);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [if (i % 2 == 0) getVendorWidget4even(product[i], context) else getVendorWidget4odd(product[i], context)],
        ).paddingBottom(8),
      );
    },
  );
}

Widget getVendorWidget4even(VendorResponse vendor, BuildContext context) {
  var appLocalization = AppLocalizations.of(context)!;
  String img = vendor.banner!.isNotEmpty ? vendor.banner.validate() : '';

  String? addressText = "";
  if (vendor.address != null) {
    if (vendor.address!.street_1 != null) {
      if (vendor.address!.street_1!.isNotEmpty && addressText.isEmpty) {
        addressText = vendor.address!.street_1;
      }
    }
    if (vendor.address!.street_2 != null) {
      if (vendor.address!.street_2!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.street_2;
        } else {
          addressText += ", " + vendor.address!.street_2!;
        }
      }
    }
    if (vendor.address!.city != null) {
      if (vendor.address!.city!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.city;
        } else {
          addressText += ", " + vendor.address!.city!;
        }
      }
    }

    if (vendor.address!.zip != null) {
      if (vendor.address!.zip!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.zip;
        } else {
          addressText += " - " + vendor.address!.zip!;
        }
      }
    }
    if (vendor.address!.state != null) {
      if (vendor.address!.state!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.state;
        } else {
          addressText += ", " + vendor.address!.state!;
        }
      }
    }
    if (vendor.address!.country != null) {
      if (!vendor.address!.country!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.country;
        } else {
          addressText += ", " + vendor.address!.country!;
        }
      }
    }
  }

  return Container(
    width: context.width(),
    height: 185,
    margin: EdgeInsets.all(4),
    decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt(), backgroundColor: Theme.of(context).cardTheme.color!),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
                width: 140, height: 200, child: Image.asset(ic_diwali_frame1, fit: BoxFit.fitHeight).cornerRadiusWithClipRRectOnly(topLeft: defaultRadius.toInt(), bottomLeft: defaultRadius.toInt())),
            Container(
              height: 150,
              width: 140,
              decoration: boxDecorationWithShadow(border: Border.all(color: white, width: 4), borderRadius: radius(0)),
              child: commonCacheImageWidget(img, fit: BoxFit.cover),
            ).center().paddingLeft(20),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vendor.storeName!.toUpperCase(), style: boldTextStyle(size: 18)),
            8.height,
            Text(
              addressText!.trim(),
              maxLines: 4,
              style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color),
            ),
            12.height,
            Row(
              children: [
                Icon(Icons.add, size: 12, color: textSecondaryColor.withOpacity(0.6)),
                4.width,
                Text(appLocalization.translate("lbl_explore")!, style: secondaryTextStyle(color: textSecondaryColor.withOpacity(0.6))),
              ],
            )
          ],
        ).paddingOnly(right: 8, left: 16).expand(),
      ],
    ),
  );
}

Widget getVendorWidget4odd(VendorResponse vendor, BuildContext context) {
  var appLocalization = AppLocalizations.of(context)!;
  String img = vendor.banner!.isNotEmpty ? vendor.banner.validate() : '';

  String? addressText = "";
  if (vendor.address != null) {
    if (vendor.address!.street_1 != null) {
      if (vendor.address!.street_1!.isNotEmpty && addressText.isEmpty) {
        addressText = vendor.address!.street_1;
      }
    }
    if (vendor.address!.street_2 != null) {
      if (vendor.address!.street_2!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.street_2;
        } else {
          addressText += ", " + vendor.address!.street_2!;
        }
      }
    }
    if (vendor.address!.city != null) {
      if (vendor.address!.city!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.city;
        } else {
          addressText += ", " + vendor.address!.city!;
        }
      }
    }

    if (vendor.address!.zip != null) {
      if (vendor.address!.zip!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.zip;
        } else {
          addressText += " - " + vendor.address!.zip!;
        }
      }
    }
    if (vendor.address!.state != null) {
      if (vendor.address!.state!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.state;
        } else {
          addressText += ", " + vendor.address!.state!;
        }
      }
    }
    if (vendor.address!.country != null) {
      if (!vendor.address!.country!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.country;
        } else {
          addressText += ", " + vendor.address!.country!;
        }
      }
    }
  }

  return Container(
    width: context.width(),
    height: 185,
    margin: EdgeInsets.all(4),
    decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt(), backgroundColor: Theme.of(context).cardTheme.color!),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vendor.storeName!.toUpperCase(), style: boldTextStyle(size: 18)),
            8.height,
            Text(
              addressText!.trim(),
              maxLines: 4,
              style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color),
            ),
            12.height,
            Row(
              children: [
                Icon(Icons.add, size: 12, color: textSecondaryColor.withOpacity(0.6)),
                4.width,
                Text(appLocalization.translate("lbl_explore")!, style: secondaryTextStyle(color: textSecondaryColor.withOpacity(0.6))),
              ],
            )
          ],
        ).paddingOnly(right: 8, left: 16).expand(),
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
                width: 140,
                height: 200,
                child: Image.asset(ic_diwali_frame6, fit: BoxFit.fitHeight).cornerRadiusWithClipRRectOnly(topRight: defaultRadius.toInt(), bottomRight: defaultRadius.toInt())),
            Container(
              height: 150,
              width: 140,
              decoration: boxDecorationWithShadow(border: Border.all(color: white, width: 4), borderRadius: radius(0)),
              child: commonCacheImageWidget(img, fit: BoxFit.fill),
            ).center().paddingRight(20),
          ],
        )
      ],
    ),
  );
}





Widget mVendorWidget4(BuildContext context, List<VendorResponse> mVendorModel, var title, var all, {size: textSizeMedium}) {
  return mVendorModel.isNotEmpty
      ? Column(
    children: [
      Container(
        margin: EdgeInsets.only(bottom: 16, top: 8),
        width: context.width(),
        decoration: boxDecorationWithRoundedCorners(borderRadius: radius(0), backgroundColor: context.cardColor),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(ic_diwali, fit: BoxFit.cover, width: 16, height: 16, color: primaryColor!),
                    16.width,
                    Text(
                      title,
                      style: GoogleFonts.kaushanScript(color: primaryColor!, fontSize: 22, letterSpacing: 0),
                    ),
                    16.width,
                    Image.asset(ic_diwali, fit: BoxFit.cover, width: 16, height: 16, color: primaryColor!),
                  ],
                ),
                ElevatedButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: white, size: 16),
                      4.width,
                      Text(all, style: GoogleFonts.alegreyaSc(color: white, fontSize: 16)),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    onPrimary: Colors.white,
                    primary: primaryColor!,
                    side: BorderSide(color: yellowColor, width: 1),
                    elevation: 1,
                    minimumSize: Size(110, 28),
                    shadowColor: Colors.teal,
                    shape: BeveledRectangleBorder(side: BorderSide(color: Colors.green, width: 2), borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    VendorListScreen().launch(context);
                  },
                ),
              ],
            )
          ],
        ),
      ).visible(mVendorModel.isNotEmpty),
      vendorList4(mVendorModel).paddingBottom(8)
    ],
  )
      : SizedBox();
}