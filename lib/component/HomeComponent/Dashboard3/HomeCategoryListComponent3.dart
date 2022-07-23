import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:woobox/app_localizations.dart';
import 'package:woobox/main.dart';
import 'package:woobox/model/CategoryData.dart';
import 'package:woobox/screens/ViewAllScreen.dart';
import 'package:woobox/utils/common.dart';
import 'package:woobox/utils/images.dart';

class HomeCategoryListComponent3 extends StatelessWidget {
  const HomeCategoryListComponent3({Key? key, required this.mCategoryModel}) : super(key: key);

  final List<Category> mCategoryModel;

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(height: 20, width: 5, color: appStore.isDarkMode! ? white : black),
            6.width,
            Text(appLocalization.translate("lbl_shop_by_category")!, style: GoogleFonts.arimo(color: appStore.isDarkMode! ? white : blackColor, fontSize: 20, fontWeight: FontWeight.bold)).center(),
          ],
        ).paddingOnly(top: 8, left: 12, bottom: 8),
        8.height,
        Container(
            color: appStore.isDarkMode! ? white.withOpacity(0.4) : primaryColor!.withOpacity(0.3),
            padding: EdgeInsets.all(4),
            child: Wrap(
              runSpacing: 4,
              spacing: 4,
              children: List.generate(
                mCategoryModel.length > 9 ? 9 : mCategoryModel.length,
                (index) {
                  return GestureDetector(
                    onTap: () {
                      ViewAllScreen(mCategoryModel[index].name, isCategory: true, categoryId: mCategoryModel[index].id).launch(context);
                    },
                    child: Container(
                      width: context.width() * .30,
                      height: 160,
                      decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, borderRadius: radius(0), border: Border.all(width: 0.1)),
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                  child: mCategoryModel[index].image != null
                                      ? CachedNetworkImage(imageUrl: mCategoryModel[index].image!.src.validate(), height: 120, fit: BoxFit.cover)
                                      : Image.asset(ic_placeholder_logo, height: 120, fit: BoxFit.cover)),
                              Positioned(
                                top: 116,
                                child: Container(
                                  height: 8,
                                  width: 30,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          8.height,
                          Container(
                            width: context.width() * 0.20,
                            margin: EdgeInsets.only(bottom: 4, top: 4),
                            child: Text(
                              parseHtmlString(mCategoryModel[index].name),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: primaryTextStyle(size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )).paddingOnly(left: 12),
      ],
    );
  }
}
