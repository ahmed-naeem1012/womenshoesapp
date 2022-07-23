import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:woobox/model/CategoryData.dart';
import 'package:woobox/screens/ViewAllScreen.dart';
import 'package:woobox/utils/DashedCircle.dart';
import 'package:woobox/utils/common.dart';

import '../../../main.dart';

class HomeCategoryListComponent4 extends StatelessWidget {
  const HomeCategoryListComponent4({Key? key, required this.mCategoryModel})
      : super(key: key);

  final List<Category> mCategoryModel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 12,
      spacing: 10,
      children: List.generate(
        mCategoryModel.length > 12 ? 12 : mCategoryModel.length,
        (index) {
          return GestureDetector(
            onTap: () {
              ViewAllScreen(mCategoryModel[index].name,
                      isCategory: true, categoryId: mCategoryModel[index].id)
                  .launch(context);
            },
            child: Container(
              height: 120,
              width: context.width() * .20,
              child: Column(
                children: [
                  DashedCircle(
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 1, color: primaryColor!)),
                      child: CircleAvatar(
                        radius: 42.0,
                        backgroundImage: NetworkImage(
                          mCategoryModel[index].image!.src.validate(),
                        ),
                      ).paddingAll(1),
                    ),
                    color: Colors.deepOrangeAccent,
                  ),
                  4.height,
                  Text(
                    parseHtmlString(mCategoryModel[index].name),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: primaryTextStyle(),
                  ),
                ],
              ),
            ).paddingOnly(left: 12),
          );
        },
      ),
    );
  }
}
