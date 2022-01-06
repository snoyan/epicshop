import 'package:epicshop/net/brain.dart';
import 'package:epicshop/net/data.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:woocommerce/woocommerce.dart';
import '../../../../constants.dart';

class CartCard extends StatefulWidget {
  CartCard({required this.cartItem, this.index});
  final WooCartItem cartItem;
  var index;

  @override
  State<CartCard> createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  late String price;
  late int total;
  void setPrice() {
    /// this loop take product price property and give it to cartItem with same name.
    for (int i = 0; i < context.watch<Data>().cartItem.length; i++) {
      for (int j = 0; j < Brain.publicProductList.length; j++) {
        if (Brain.publicProductList[j].id ==
            context.watch<Data>().cartItem[i].id) {
          price = Brain.publicProductList[j].price!;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    setPrice();
    total = int.parse(widget.cartItem.price!) * widget.cartItem.quantity!;

    //todo : cartCard
    return Card(
      child: GestureDetector(
        onTap: () {
          kShowToast(context, "برای حذف به سمت راست بکشید");
        },
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.15,
              child: Card(
                color: kBaseColor0,
                child: Image(
                  image:
                      NetworkImage(widget.cartItem.images![0].src!, scale: 1),
                ),
              ),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cartItem.name!,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  maxLines: 2,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text.rich(
                      TextSpan(
                        text: " تعداد: ${widget.cartItem.quantity}",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Column(
                      children: [
                        Text(
                          '  قیمت واحد:  ${kCheckPrice(widget.cartItem.price)} تومان ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: kPrimaryColor,
                          ),
                        ),
                        // Text(
                        //   '  قیمت کل:  ${kCheckPrice(total.toString())} تومان ',
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.w600,
                        //     color: kPrimaryColor,
                        //   ),
                        // )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
