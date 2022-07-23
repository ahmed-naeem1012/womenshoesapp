import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:woobox/model/BlogListResponse.dart';
import 'package:woobox/screens/BlogDetailScreen.dart';
import 'package:woobox/utils/app_widgets.dart';
import 'package:woobox/utils/common.dart';
import 'package:woobox/utils/images.dart';

// ignore: must_be_immutable
class BlogListComponent extends StatefulWidget {
  static String tag = '/BlogListComponent';
  List<Blog> mBlogList;

  BlogListComponent(this.mBlogList);

  @override
  BlogListComponentState createState() => BlogListComponentState();
}

class BlogListComponentState extends State<BlogListComponent> {
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
    List<Blog> mBlogList = widget.mBlogList;
    return ListView.builder(
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      itemCount: mBlogList.length,
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 16, bottom: 16),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            log(mBlogList[index].iD);
            BlogDetailScreen(mId: mBlogList[index].iD).launch(context);
          },
          child: Container(
            height: 120,
            margin: EdgeInsets.only(bottom: 16),
            decoration: boxDecorationWithShadow(borderRadius: radiusOnly(bottomLeft: 8, topLeft: 8), backgroundColor: context.scaffoldBackgroundColor),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                mBlogList[index].image != null
                    ? commonCacheImageWidget(mBlogList[index].image, width: 130, fit: BoxFit.cover).cornerRadiusWithClipRRect(defaultRadius)
                    : Image.asset(ic_placeholder_logo, width: 130, fit: BoxFit.cover).cornerRadiusWithClipRRect(defaultRadius),
                10.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("fgfdgf", style: boldTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                    4.height,
                    Text(parseHtmlString("grtfyhtfr"), maxLines: 2, overflow: TextOverflow.ellipsis, style: secondaryTextStyle()).paddingRight(8),
                    Align(alignment: Alignment.bottomRight, child: Text("gdfgd", style: secondaryTextStyle())).paddingOnly(right: 16, top: 28)
                  ],
                ).paddingOnly(top: 10).expand(),
              ],
            ),
          ),
        );
      },
    );
  }
}
