import 'package:epicshop/components/category_productCard.dart';
import 'package:epicshop/components/product_card.dart';
import 'package:epicshop/net/brain.dart';
import 'package:epicshop/net/net_helper.dart';
import 'package:flutter/material.dart';
import 'package:woocommerce/woocommerce.dart';

class ProductPage extends StatefulWidget {
  ProductPage({
    Key? key,
    this.catId,
    this.catName,
  }) : super(key: key);
  int? catId;
  String? catName;
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<WooProduct> product = [];

  getProducts() async {
    product = await filterProducts(Brain.publicProductList);
    setState(() {});
  }

  filterProducts(List<WooProduct> allproduct) async {
    for (int i = 0; i < allproduct.length; i++) {
      for (int j = 0; j < allproduct[i].categories.length; j++) {
        if (allproduct[i].categories[j].id == widget.catId) {
          product.add(allproduct[i]);
        }
      }
    }
    return product;
  }

  @override
  void initState() {
    super.initState();
    //You would want to use a feature builder instead.
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            iconSize: 40.0,
            icon: Icon(Icons.arrow_left),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            '${widget.catName}',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 1,
        ),
        body: Container(
          padding: EdgeInsets.only(right: 12),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 5,
            childAspectRatio: MediaQuery.of(context).size.width /
                (MediaQuery.of(context).size.height / 1.48),
            children: List.generate(
              product.length,
              (index) => Container(
                margin: EdgeInsets.only(
                  top: 8,
                ),
                //padding: EdgeInsets.only(left: 10),
                child: ProductCard(product: product[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
