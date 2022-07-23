import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:woobox/component/HomeComponent/Dashboard2/ProductComponent2.dart';
import 'package:woobox/main.dart';
import 'package:woobox/model/ProductResponse.dart';
import 'package:woobox/utils/constants.dart';
import 'package:woobox/utils/images.dart';

class DashboardComponent2 extends StatefulWidget {
  const DashboardComponent2({Key? key, required this.title, required this.subTitle, required this.product, required this.onTap}) : super(key: key);

  final String title, subTitle;
  final List<ProductResponse> product;
  final Function onTap;

  @override
  _DashboardComponent2State createState() => _DashboardComponent2State();
}

class _DashboardComponent2State extends State<DashboardComponent2> {
  Widget productList(List<ProductResponse> product) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: StaggeredGridView.countBuilder(
        scrollDirection: Axis.vertical,
        itemCount: product.length >= TOTAL_DASHBOARD_ITEM ? TOTAL_DASHBOARD_ITEM : product.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return ProductComponent2(mProductModel: product[i], width: context.width()).paddingAll(4);
        },
        crossAxisCount: 2,
        staggeredTileBuilder: (index) {
          return StaggeredTile.fit(1);
        },
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text("#" + widget.title, style: GoogleFonts.arimo(color: appStore.isDarkMode! ? white : blackColor, fontWeight: FontWeight.bold, fontSize: 20)),
                6.width,
                if (widget.title == builderResponse.dashboard!.spotLight!.title!)
                  Image.asset(ic_star, height: 20, width: 20)
                else if (widget.title == builderResponse.dashboard!.hotRightNow!.title!)
                  Image.asset(ic_hot, height: 20, width: 20)
                else if (widget.title == builderResponse.dashboard!.youMayAlsoLike!.title!)
                  Image.asset(ic_love, height: 20, width: 20)
                else
                  SizedBox()
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.subTitle, style: GoogleFonts.arimo(color: primaryColor, fontSize: 14)).onTap(() {
                  widget.onTap.call();
                }),
                Icon(
                  Icons.chevron_right,
                  color: primaryColor,
                  size: 18,
                )
              ],
            ).visible(widget.product.length >= TOTAL_DASHBOARD_ITEM),
          ],
        ).paddingOnly(left: 12, right: 6, bottom: 8, top: 8).visible(widget.product.isNotEmpty),
        productList(widget.product).visible(widget.product.isNotEmpty),
      ],
    );
  }
}
