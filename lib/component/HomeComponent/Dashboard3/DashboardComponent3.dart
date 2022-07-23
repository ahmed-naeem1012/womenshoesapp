import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:woobox/component/HomeComponent/Dashboard3/ProductComponent3.dart';
import 'package:woobox/main.dart';
import 'package:woobox/model/ProductResponse.dart';
import 'package:woobox/utils/constants.dart';

class DashboardComponent3 extends StatefulWidget {
  const DashboardComponent3(
      {Key? key,
      required this.title,
      required this.subTitle,
      required this.product,
      required this.onTap})
      : super(key: key);

  final String title, subTitle;
  final List<ProductResponse> product;
  final Function onTap;

  @override
  _DashboardComponent3State createState() => _DashboardComponent3State();
}

class _DashboardComponent3State extends State<DashboardComponent3> {
  Widget productList(List<ProductResponse> product) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: StaggeredGridView.countBuilder(
        scrollDirection: Axis.vertical,
        itemCount: product.length >= TOTAL_DASHBOARD_ITEM
            ? TOTAL_DASHBOARD_ITEM
            : product.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return ProductComponent3(
                  mProductModel: product[i], width: context.width())
              .paddingAll(4);
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
                Container(
                    height: 20,
                    width: 5,
                    color: appStore.isDarkMode! ? white : black),
                6.width,
                Text(widget.title,
                    style: GoogleFonts.arimo(
                        color: appStore.isDarkMode! ? white : blackColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.subTitle,
                        style: GoogleFonts.arimo(
                            color: primaryColor, fontSize: 14))
                    .onTap(() {
                  widget.onTap.call();
                }),
                Icon(Icons.chevron_right, color: primaryColor, size: 18)
              ],
            ).visible(widget.product.length >= TOTAL_DASHBOARD_ITEM),
          ],
        )
            .paddingOnly(left: 12, right: 6, bottom: 8, top: 8)
            .visible(widget.product.isNotEmpty),
        productList(widget.product).visible(widget.product.isNotEmpty),
      ],
    );
  }
}
