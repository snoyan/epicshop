import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:epicshop/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:epicshop/net/brain.dart';
import 'package:provider/src/provider.dart';
import 'package:woocommerce/models/product_category.dart';
import 'package:woocommerce/models/products.dart';
import '../constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'data.dart';
import 'net_helper.dart';
import 'dart:io';
import 'offer_product_filter.dart';

const spinkit = SpinKitDancingSquare(
  color: Colors.black,
  size: 50.0,
);

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);
  static String routeName = '/welcome';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool showSpinner = false;
  bool isActive = false;
  bool isTrying = false;
  List<WooProductCategory> category =[];
  List<WooProductCategory> category2 =[];

  /// this following function check " Is user device connected to network or not?"
  checkConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        setState(() {
          isTrying = false;
        });
        // context.read<Data>().setCartItems(await NetworkHelper().wooCommerce.getMyCartItems());
        Brain.allProductList = await NetworkHelper().wooCommerce.getProducts();
        for (int i = 0; i < Brain.allProductList.length; i++) {
          category = Brain.allProductList[i].categories;
          for(int c = 0 ;c < category.length ; c++){
            if (category2.every((item) => item.id != category[c].id)) {
              category2.add(category[c]);
            }


          }
          if (Brain.allProductList[i].status == 'publish') {
            Brain.publicProductList.add(Brain.allProductList[i]);
          }
        }

        Brain.productCategory =  category2;
        // Brain.productCategory =
        //     await NetworkHelper().wooCommerce.getProductCategories();
        // Brain.productDates = await getOfferProducts();
        //await getProductDates();
        HPCategoryProduct();

        Navigator.pushNamed(context, HomeScreen.routeName);
      }
    } on SocketException catch (_) {
      print('not connected');
      kShowToast(context, " اتصال به اینترت ندارید  \n دوباره تلاش کنید");
      setState(() {
        isTrying = true;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    checkConnection();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: kBaseColor1,
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/Background4.jpg'),
                fit: BoxFit.fill),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              AnimatedTextKit(animatedTexts: [
                TyperAnimatedText('مکانی برای رسیدن به خواسته هایتان!'),
                TyperAnimatedText('محبوب ترین فروشگاه در دل شما!'),
                TyperAnimatedText('برای عالی بودن کم هزینه کنید!'),
                TyperAnimatedText(
                    'می توانی بیشتر انتظار داشته باشی اما کمتر پرداخت کنی!'),
              ]),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'بتاشاپ',
                      cursor: '',
                      textStyle: const TextStyle(
                        fontSize: 50.0,
                        fontWeight: FontWeight.bold,
                      ),
                      speed: const Duration(milliseconds: 300),
                    ),
                  ],
                  totalRepeatCount: 4,
                  pause: const Duration(milliseconds: 1000),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      !isTrying
                          ? spinkit
                          : TryAgain(callBack: () {
                              checkConnection();
                            }),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// the TryAgain is create to show TryAgain button when device disconnected
class TryAgain extends StatelessWidget {
  TryAgain({required this.callBack});
  final VoidCallback callBack;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        children: [
          Text('تلاش مجدد'),
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: 40.0,
            ),
            onPressed: callBack,
          ),
        ],
      ),
      onTap: callBack,
    );
  }
}
