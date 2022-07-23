import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:woobox/model/CategoryData.dart';
import 'package:woobox/screens/ViewAllScreen.dart';
import 'package:woobox/utils/app_widgets.dart';
import 'package:woobox/utils/common.dart';
import 'package:woobox/utils/images.dart';

// ignore: must_be_immutable
class CategoryListComponent extends StatefulWidget {
  static String tag = '/CategoryListComponent';
  List<Category> mCategoryModel;

  CategoryListComponent(this.mCategoryModel);

  @override
  CategoryListComponentState createState() => CategoryListComponentState();
}

class CategoryListComponentState extends State<CategoryListComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: widget.mCategoryModel.length,
      shrinkWrap: true,
      padding: EdgeInsets.all(12),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(top: 8, bottom: 8),
          alignment: Alignment.center,
          decoration: boxDecorationWithShadow(
              borderRadius: radius(),
              backgroundColor: context.scaffoldBackgroundColor),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration:
                    boxDecorationWithRoundedCorners(borderRadius: radius()),
                height: 150,
                width: context.width(),
                child: widget.mCategoryModel[index].image != null
                    ? commonCacheImageWidget(
                            widget.mCategoryModel[index].image!.src,
                            fit: BoxFit.cover)
                        .cornerRadiusWithClipRRect(defaultRadius)
                    : Image.asset(ic_placeholder_logo, fit: BoxFit.cover)
                        .cornerRadiusWithClipRRect(defaultRadius),
              ),
              Container(
                height: 150,
                decoration: boxDecorationWithShadow(
                  borderRadius: radius(),
                  backgroundColor: black.withOpacity(0.4),
                ),
              ),
              Text(
                parseHtmlString(widget.mCategoryModel[index].name),
                textAlign: TextAlign.start,
                style: boldTextStyle(size: 24, color: white.withOpacity(0.9)),
                maxLines: 2,
              ).paddingOnly(top: 10, bottom: 10, left: 8, right: 8)
            ],
          ),
        ).onTap(() {
          ViewAllScreen(widget.mCategoryModel[index].name,
                  isCategory: true, categoryId: widget.mCategoryModel[index].id)
              .launch(context);
        });
      },
    );
  }
}
