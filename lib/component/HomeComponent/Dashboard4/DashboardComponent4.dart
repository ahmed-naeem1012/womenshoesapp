import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:woobox/model/ProductResponse.dart';
import 'package:woobox/utils/colors.dart';
import 'package:woobox/utils/constants.dart';
import 'package:woobox/utils/images.dart';

import 'ProductComponent4.dart';

class DashboardComponent4 extends StatefulWidget {
  const DashboardComponent4(
      {Key? key,
      required this.title,
      required this.subTitle,
      required this.product,
      required this.onTap,
      required this.color,
      required this.image})
      : super(key: key);

  final String title, subTitle, image;
  final Color color;
  final List<ProductResponse> product;
  final Function onTap;

  @override
  _DashboardComponent4State createState() => _DashboardComponent4State();
}

class _DashboardComponent4State extends State<DashboardComponent4> {
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
          return ProductComponent4(
                  mProductModel: product[i],
                  width: context.width(),
                  mImage: widget.image,
                  color: widget.color)
              .paddingAll(4);
        },
        crossAxisCount: 2,
        staggeredTileBuilder: (index) {
          return StaggeredTile.fit(1);
        },
        padding: EdgeInsets.zero,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 8),
          width: context.width(),
          decoration: boxDecorationWithRoundedCorners(
              borderRadius: radius(0), backgroundColor: context.cardColor),
          child: Stack(
            children: [
              Positioned(
                right: 24,
                top: 2,
                child: Image.asset(ic_diwali_icon3,
                    width: 24,
                    height: 24,
                    color: widget.color.withOpacity(0.5)),
              ),
              Positioned(
                right: 75,
                bottom: 2,
                child: Image.asset(ic_diwali_icon3,
                    width: 24,
                    height: 24,
                    color: widget.color.withOpacity(0.5)),
              ),
              Positioned(
                left: 70,
                bottom: 4,
                child: Image.asset(ic_diwali_icon3,
                    width: 24,
                    height: 24,
                    color: widget.color.withOpacity(0.5)),
              ),
              Positioned(
                left: 24,
                top: 4,
                child: Image.asset(ic_diwali_icon3,
                    width: 24,
                    height: 24,
                    color: widget.color.withOpacity(0.5)),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(ic_diwali,
                          fit: BoxFit.cover,
                          width: 16,
                          height: 16,
                          color: widget.color),
                      16.width,
                      Text(
                        widget.title.toUpperCase(),
                        style: GoogleFonts.kaushanScript(
                            color: widget.color,
                            fontSize: 22,
                            letterSpacing: 0),
                      ),
                      16.width,
                      Image.asset(ic_diwali,
                          fit: BoxFit.cover,
                          width: 16,
                          height: 16,
                          color: widget.color),
                    ],
                  ),
                  ElevatedButton(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: white, size: 16),
                        4.width,
                        Text(
                          widget.subTitle,
                          style: GoogleFonts.alegreyaSc(
                              color: white, fontSize: 16),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      onPrimary: Colors.white,
                      primary: widget.color,
                      side: BorderSide(color: yellowColor, width: 1),
                      elevation: 1,
                      minimumSize: Size(110, 28),
                      shadowColor: Colors.teal,
                      shape: BeveledRectangleBorder(
                          side: BorderSide(color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      widget.onTap.call();
                    },
                  ).visible(widget.product.length >= TOTAL_DASHBOARD_ITEM),
                ],
              )
            ],
          ).paddingOnly(top: 16).visible(widget.product.isNotEmpty),
        ),
        productList(widget.product).visible(widget.product.isNotEmpty),
      ],
    );
  }
}
