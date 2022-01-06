import 'package:epicshop/components/default_button.dart';
import 'package:epicshop/net/brain.dart';
import 'package:epicshop/net/data.dart';
import 'package:epicshop/net/net_helper.dart';
import 'package:epicshop/screens/home/home_screen.dart';
import 'package:epicshop/screens/login/login_popup.dart';
import 'package:epicshop/screens/profile/components/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zarinpal/zarinpal.dart';
import '../../constants.dart';
import '../../enums.dart';
import 'components/cart_card.dart';
import 'components/checkout_card.dart';

class CartScreen extends StatefulWidget {
  static String routeName = '/cart_screen';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Widget buyButton = ElevatedButton(onPressed: () {}, child: null);
  bool isLoggedIn = false;
  int amount = 0;
  int totalPrice = 0;
  bool showSpinner = false;

  /// _payment is for interact with online payment gateway.
  _payment(int amount) async {
    PaymentRequest _paymentRequest = PaymentRequest();

    _paymentRequest.setIsSandBox(true);
    _paymentRequest.setMerchantID("5f2bddbe-615e-11ea-a63b-000c295eb8fc");
    _paymentRequest.setAmount(amount);
    _paymentRequest.setCallbackURL("https://epicsite.ir/");
    _paymentRequest.setDescription("توضیحات پرداخت");

    String? _paymentUrl;

    ZarinPal().startPayment(_paymentRequest,
        (int? status, String? paymentGatewayUri) async {
      if (status == 100) _paymentUrl = paymentGatewayUri;
      await _launchInBrowser(_paymentUrl!); // launch URL in browser
    });

    ZarinPal()
        .verificationPayment("Status", "Authority Call back", _paymentRequest,
            (isPaymentSuccess, refID, paymentRequest) {
      if (isPaymentSuccess) {
        // Payment Is Success
        print("Success");
      } else {
        print("Error");
      }
    });
  }

  ///_launchInBrowser is for launch url in external Browser(chrome & etc.).
  Future<void> _launchInBrowser(String url) async {
    if (!await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    )) {
      throw 'Could not launch $url';
    }
  }

  isLogin() async {
    isLoggedIn = await NetworkHelper().wooCommerce.isCustomerLoggedIn();
    setState(() {});
    getBuyButton();
  }

  /// BuyButton /////////////////////////////////////////////////
  getBuyButton() {
    if (isLoggedIn) {
      if (Brain.isCustomerInfoFull) {
        buyButton = DefaultButton(
          color: Colors.green,
          text: 'تکمیل خرید',
          press: () {
            _payment(totalPrice);
          },
        );
      } else {
        buyButton = DefaultButton(
          color: Colors.blueGrey,
          text: "تکمیل خرید",
          press: () async {
            kShowToast(context,
                "برای تکمیل خرید ابتدا باید اطلاعات پروفایل خود را کامل کنید.");
            Navigator.pushNamed(context, EditProfileScreen.routeName);
          },
        );
      }
    } else {
      buyButton = DefaultButton(
          text: "پرداخت",
          press: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return LoginPopUp(
                    selectedScreen: Screen.cart,
                  );
                });
          });
    }
    setState(() {});
  }

  Future<bool?> _onBackPressed() async {
    Navigator.pushNamedAndRemoveUntil(
        context, HomeScreen.routeName, (_) => false);
    return true;
  }

  int changePrice(String price) {
    int changedPrice = int.parse(price);
    return changedPrice;
  }

  /// calculateTotalPrice is for calculate [totalPrice] and change it form String to Integer
  void calculateTotalPrice() {
    setState(() {
      totalPrice = 0;
    });
    for (int i = 0; i < context.watch<Data>().cartItem.length; i++) {
      for (int j = 0; j < Brain.publicProductList.length; j++) {
        if (Brain.publicProductList[j].name ==
                context.watch<Data>().cartItem[i].name ||
            Brain.publicProductList[j].id ==
                context.watch<Data>().cartItem[i].id) {
          context.read<Data>().setPrice(i, Brain.publicProductList![j].price!);
          var temp = changePrice(context.watch<Data>().cartItem[i].price!) *
              context.watch<Data>().cartItem[i].quantity!;
          totalPrice += temp;
        }
      }
    }
    setState(() {
      totalPrice;
    });
  }

  @override
  void initState() {
    super.initState();
    isLogin();
  }

  @override
  Widget build(BuildContext context) {
    calculateTotalPrice();

    /// WillPopScope helps developer to control Android BackButton
    return Consumer<Data>(builder: (context, data, child) {
      return WillPopScope(
        onWillPop: () async {
          bool? result = await _onBackPressed();
          if (result == null) {
            result = false;
          }
          return result;
        },
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                iconSize: 40.0,
                icon: Icon(Icons.arrow_left),
                onPressed: () {
                  Navigator.pop(context);
                  // Navigator.pushNamedAndRemoveUntil(
                  //     context, HomeScreen.routeName, (_) => false);
                },
              ),
              title: Center(
                child: Column(
                  children: [
                    Text(
                      "سبد خرید",
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      "${data.cartItem.length} محصول",
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                itemCount: data.cartItem.length,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  // cartItem will remove by customer from here
                  child: Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        var temp = changePrice(data.cartItem[index].price!) *
                            data.cartItem[index].quantity!;
                        totalPrice -= temp;
                        data.removeCartItem(data.cartItem[index]);
                      });
                    },
                    background: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFE6E6),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child:
                        CartCard(cartItem: data.cartItem[index], index: index),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: CheckoutCard(
              totalPrice: totalPrice,
              getButton: buyButton,
            ),
          ),
        ),
      );
    });
  }
}
///////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
