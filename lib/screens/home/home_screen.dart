import 'dart:io';
import 'package:epicshop/components/bottom_navigator_bar.dart';
import 'package:epicshop/net/brain.dart';
import 'package:epicshop/net/drawer.dart';
import 'package:epicshop/net/net_helper.dart';
import 'package:epicshop/net/offer_product_filter.dart';
import 'package:epicshop/screens/billing/billing_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:woocommerce/woocommerce.dart';
import '../../enums.dart';
import 'components/banner_slider.dart';
import 'components/category_box.dart';
import 'components/header.dart';
import 'components/offer_slider.dart';
import 'components/popular_product.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = '/';
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
//

class _HomeScreenState extends State<HomeScreen> {
  List<String> banner2() {
    List<String> banner1ImageList = [];
    List<WooProduct> bannerProduct = Brain.allProductList
        .where((element) => element.name == "banner2")
        .toList();
    if (bannerProduct.isEmpty)
      return banner1ImageList;
    else {
      for (int i = 0; i < bannerProduct[0].images.length; i++) {
        banner1ImageList.add(bannerProduct[0].images[i].src!);
      }
      return banner1ImageList;
    }
  }

  List<String> banner1() {
    List<String> banner1ImageList = [];
    List<WooProduct> bannerProduct = Brain.allProductList
        .where((element) => element.name == "banner1")
        .toList();
    if (bannerProduct.isEmpty)
      return banner1ImageList;
    else {
      for (int i = 0; i < bannerProduct[0].images.length; i++) {
        banner1ImageList.add(bannerProduct[0].images[i].src!);
      }
      return banner1ImageList;
    }
  }

  /// The onBackPressed is for Restrict Android backButton
  Future<bool?> onBackPressed() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('آیا میخواید از برنامه خارج شوید؟'),
            content: Text('برای خروج از برنامه دکمه بستن را بزنید.'),
            actions: <Widget>[
              TextButton(
                child: Text('لغو'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text('بستن'),
                onPressed: () {
                  exit(0);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    /// The SystemChrome.setPreferredOrientations is for Lock up Rotation Screen .
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    //takes all orders list when home page is building

    getOrders();

    //<---
    return WillPopScope(
      onWillPop: () async {
        bool? result = await onBackPressed();
        if (result == null) {
          result = false;
        }
        return result;
      },
      child: Scaffold(
        drawer: MyDrawer(),
        appBar: AppBar(
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(8, 30, 8, 8),
            child: Header(),
          ),
        ),
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            ///top header banner in very start
            bannerSlider(banner1()),
            CategoryBox(),
            //Brain.fiteredProducts.length > 0 ? OfferSlider() : Container(),
            OfferSlider(),
            SizedBox(
              height: 5,
            ),
            Column(
              children: [
                ...List.generate(Brain.HPCategoryProduct.length, (index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        PopularProducts(
                            catName: Brain.HPCategoryProduct[index]),
                        bannerSlider(banner2()),
                      ],
                    );
                  } else
                    return PopularProducts(
                        catName: Brain.HPCategoryProduct[index]);
                })
              ],
            ),

            //second banner in middle of the app
            // bannerSlider(banner2()),
            /* PopularProducts(
              catName: Brain.HPCategoryProduct[1],
            ),
            Divider(),
            PopularProducts(
              catName: Brain.HPCategoryProduct[2],
            ),
            Divider(),*/
          ]),
        ),
        bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
        // bottomNavigationBar: BottomNavigator(),
      ),
    );
  }
}

getOrders() async {
  NetworkHelper().getCustomer();
  bool isLoggedIn = await NetworkHelper().wooCommerce.isCustomerLoggedIn();
  if (isLoggedIn) {
    BillingScreen.allOrders = await NetworkHelper().wooCommerce.getOrders();
    BillingScreen.customerId =
        (await NetworkHelper().wooCommerce.fetchLoggedInUserId())!;
  }
}
