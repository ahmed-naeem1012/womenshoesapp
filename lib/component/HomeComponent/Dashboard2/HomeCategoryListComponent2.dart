import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:woobox/app_localizations.dart';
import 'package:woobox/main.dart';
import 'package:woobox/model/CategoryData.dart';
import 'package:woobox/screens/ViewAllScreen.dart';
import 'package:woobox/utils/colors.dart';
import 'package:woobox/utils/common.dart';
import 'package:woobox/utils/images.dart';

class HomeCategoryListComponent2 extends StatelessWidget {
  const HomeCategoryListComponent2({Key? key, required this.mCategoryModel}) : super(key: key);

  final List<Category> mCategoryModel;

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("#" + appLocalization.translate("lbl_categories")!, style: GoogleFonts.arimo(color: appStore.isDarkMode! ? white : blackColor, fontSize: 20, fontWeight: FontWeight.bold))
            .paddingOnly(top: 8, bottom: 8, left: 12, right: 6),
        8.height,
        Wrap(
          runSpacing: 12,
          children: List.generate(
            mCategoryModel.length > 9 ? 9 : mCategoryModel.length,
            (index) {
              return GestureDetector(
                onTap: () {
                  ViewAllScreen(mCategoryModel[index].name, isCategory: true, categoryId: mCategoryModel[index].id).launch(context);
                },
                child: Container(
                  height: 120,
                  decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt(), backgroundColor: context.cardColor),
                  child: Column(
                    children: [
                      Container(
                        width: context.width() * .26,
                        height: 80,
                        margin: EdgeInsets.all(6),
                        child: mCategoryModel[index].image != null
                            ? CircleAvatar(backgroundColor: context.cardColor, backgroundImage: NetworkImage(mCategoryModel[index].image!.src.validate()))
                            : CircleAvatar(backgroundColor: context.cardColor, backgroundImage: AssetImage(ic_placeholder_logo)),
                      ),
                      4.height,
                      Container(
                        width: context.width() * 0.20,
                        child: Text(
                          parseHtmlString(mCategoryModel[index].name),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: secondaryTextStyle(color: appStore.isDarkMode! ? white.withOpacity(0.6) : getColorFromHex(categoryColors[index % categoryColors.length], defaultColor: primaryColor!)),
                        ),
                      ),
                    ],
                  ),
                ).paddingOnly(left: 12),
              );
            },
          ),
        ),
      ],
    );
  }
}
