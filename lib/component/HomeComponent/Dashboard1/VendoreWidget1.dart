import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:woobox/model/ProductResponse.dart';
import 'package:woobox/screens/VendorListScreen.dart';
import 'package:woobox/screens/VendorProfileScreen.dart';
import 'package:woobox/utils/app_widgets.dart';
import 'package:woobox/utils/constants.dart';
import 'package:woobox/utils/images.dart';

import '../../../app_localizations.dart';
import '../../../main.dart';

Widget mVendorWidget(BuildContext context, List<VendorResponse> mVendorModel, var title, var all, {size: textSizeMedium}) {
  return mVendorModel.isNotEmpty
      ? Column(
    children: [
      Container(
        margin: EdgeInsets.only(bottom: 8),
        width: context.width(),
        decoration: boxDecorationWithRoundedCorners(borderRadius: radius(0), backgroundColor: context.cardColor),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(ic_heading, fit: BoxFit.cover),
            Column(
              children: [
                Text(title, style: GoogleFonts.alegreyaSc(color: appStore.isDarkMode! ? white.withOpacity(0.7) : primaryColor!, fontSize: 22)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(all, style: GoogleFonts.alegreyaSc(fontSize: 16, color: textSecondaryColour)).onTap(() {
                      VendorListScreen().launch(context);
                    }),
                    Icon(Icons.chevron_right, color: textSecondaryColour, size: 20)
                  ],
                )
              ],
            )
          ],
        ).paddingOnly(top: 16, bottom: 16).visible(mVendorModel.isNotEmpty),
      ),
      8.height,
      vendorList(mVendorModel).paddingBottom(8)
    ],
  )
      : SizedBox();
}

Widget vendorList(List<VendorResponse> product) {
  return HorizontalList(
    itemCount: product.length,
    wrapAlignment: WrapAlignment.start,
    crossAxisAlignment: WrapCrossAlignment.start,
    padding: EdgeInsets.only(left: 8, right: 8),
    itemBuilder: (context, i) {
      return GestureDetector(
        onTap: () {
          VendorProfileScreen(mVendorId: product[i].id).launch(context);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getVendorWidget(product[i], context),
          ],
        ),
      );
    },
  );
}

Widget getVendorWidget(VendorResponse vendor, BuildContext context) {
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
    width: context.width() * 0.85,
    height: 200,
    margin: EdgeInsets.all(4),
    decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt(), backgroundColor: Theme.of(context).cardTheme.color!),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(width: 130, height: 200, child: Image.asset(ic_vendor_background, fit: BoxFit.fitHeight).cornerRadiusWithClipRRectOnly(topLeft: defaultRadius.toInt(), bottomLeft: defaultRadius.toInt())),
            Container(
              height: 150,
              width: 130,
              decoration: boxDecorationWithShadow(border: Border.all(color: white, width: 4), borderRadius: radius(0)),
              child: commonCacheImageWidget(img, fit: BoxFit.cover),
            ).center().paddingLeft(24),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vendor.storeName!, style: boldTextStyle(size: 18)),
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
        /*  Text(
          addressText!,
          maxLines: 2,
          style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color),
        ).paddingOnly(left: 8,right: 8,bottom: 4),*/
        /* commonCacheImageWidget(img, height: 130, width: width, fit: BoxFit.cover).cornerRadiusWithClipRRectOnly(bottomRight: 8,bottomLeft: 8),*/
      ],
    ),
  );
}