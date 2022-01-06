import 'package:shared_preferences/shared_preferences.dart';
import 'package:woocommerce/woocommerce.dart';
import 'package:html/parser.dart';
import 'brain.dart';

/// site address and consumer key
const String baseUrl = "https://betashop.epicsite.ir/";
const String consumerKey = "ck_d2efa11e0f02e7d2df99f0f3c873a9f0088cc03f";
const String consumerSecret = "cs_9e08e8fa83e007e0689882853a9933fcce4fdcbb";

class NetworkHelper {
  WooCommerce wooCommerce = WooCommerce(
    baseUrl: baseUrl,
    consumerKey: consumerKey,
    consumerSecret: consumerSecret,
    isDebug: true,
  );

  /// the getProducts is here for get online Product from epicsite
  getProduct() async {
   
        Brain.allProductList = await NetworkHelper().wooCommerce.getProducts();
    for (int i = 0; i < Brain.allProductList.length; i++) {
      if (Brain.allProductList[i].status == 'publish') {
        Brain.publicProductList.add(Brain.allProductList[i]);
      }
    }
    Brain.productCategory =
        await NetworkHelper().wooCommerce.getProductCategories();
  }

  getCart() async {
    Brain.cartItem = await NetworkHelper().wooCommerce.getMyCartItems();
    // WelcomeScreen.myCart = await NetworkHelper().wooCommerce.getMyCart();
  }

  ///The parseHtmlString is here for convert htmlString to String
  String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;
    return parsedString;
  }

  /// the addToCart is for adding product to online cartItem
  addToCart() async {
    // check user is login or not . if user logged in add item to user cart.
    if (Brain.isLoggedIn) {
      for (var temp in Brain.cartItem) {
        Brain.cartItem.add(await NetworkHelper().wooCommerce.addToMyCart(
            itemId: temp.id.toString(), quantity: temp.quantity.toString()));

        print(
            '###################################################################');
        print(temp.id);
        print(
            '###################################################################');
      }
    }
  }

 late int id;

  /// the getCustomer is for get customer information.
  getCustomer() async {
    this.id = (await NetworkHelper().wooCommerce.fetchLoggedInUserId())!;
    Brain.customer = await NetworkHelper().wooCommerce.getCustomerById(id: id);
    if (Brain.customer.email != null && Brain.customer.email != "" &&
        Brain.customer.firstName != null && Brain.customer.firstName != "" &&
        Brain.customer.lastName != null && Brain.customer.lastName != "" &&
        Brain.customer.billing!.phone != null && Brain.customer.billing!.phone != "" &&
        Brain.customer.billing!.city != null && Brain.customer.billing!.city != "" &&
        Brain.customer.billing!.state != null && Brain.customer.billing!.state != "" &&
        Brain.customer.billing!.address1 != null && Brain.customer.billing!.address1 != "") {
      return Brain.isCustomerInfoFull = true;
    } else {
      return Brain.isCustomerInfoFull = false;
    }
  }
}
