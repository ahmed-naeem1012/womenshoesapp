import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:woobox/model/ProductResponse.dart';
import 'package:woobox/screens/VendorListScreen.dart';
import 'package:woobox/screens/VendorProfileScreen.dart';
import 'package:woobox/utils/app_widgets.dart';
import 'package:woobox/utils/constants.dart';

import '../../../app_localizations.dart';
import '../../../main.dart';

Widget getVendorWidget2(VendorResponse vendor, BuildContext context) {
  String img = vendor.banner!.isNotEmpty ? vendor.banner.validate() : '';
  var appLocalization = AppLocalizations.of(context)!;

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
    width: context.width() * 0.95,
    height: 170,
    margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt(), backgroundColor: Theme.of(context).cardTheme.color!),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vendor.storeName!, style: boldTextStyle(size: 18)),
            8.height,
            Text(addressText!.trim(), maxLines: 4, style: secondaryTextStyle()),
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
        Container(
          height: 200,
          width: 150,
          decoration: boxDecorationWithShadow(border: Border.all(color: white, width: 4), borderRadius: radius()),
          child: commonCacheImageWidget(img, fit: BoxFit.cover).cornerRadiusWithClipRRect(defaultRadius),
        ),
      ],
    ),
  );
}

Widget vendorList2(List<VendorResponse> product) {
  return ListView.builder(
    itemCount: product.length,
    physics: NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    padding: EdgeInsets.only(left: 8, right: 8),
    itemBuilder: (context, i) {
      return GestureDetector(
        onTap: () {
          VendorProfileScreen(mVendorId: product[i].id).launch(context);
        },
        child: getVendorWidget2(product[i], context),
      );
    },
  );
}

Widget mVendorWidget2(BuildContext context, List<VendorResponse> mVendorModel, var title, var all, {size: textSizeMedium}) {
  return mVendorModel.isNotEmpty
      ? Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("#" + title, style: GoogleFonts.arimo(color: appStore.isDarkMode! ? white : black, fontWeight: FontWeight.bold, fontSize: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(all, style: GoogleFonts.arimo(fontSize: 14, color: primaryColor)).onTap(() {
                      VendorListScreen().launch(context);
                    }),
                    Icon(Icons.chevron_right, color: primaryColor, size: 18)
                  ],
                )
              ],
            ).paddingOnly(left: 12, right: 12).visible(mVendorModel.isNotEmpty),
            8.height,
            vendorList2(mVendorModel).paddingBottom(8)
          ],
        )
      : SizedBox();
}
