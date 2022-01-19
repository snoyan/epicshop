import 'package:epicshop/screens/billing/billing_screen.dart';
import 'package:epicshop/screens/cart/cart_screen.dart';
import 'package:epicshop/screens/home/search_resultPage.dart';
import 'package:epicshop/screens/product_detail/product_details.dart';
import 'package:flutter/cupertino.dart';
import 'net/welcome_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/components/edit_profile.dart';
import 'screens/profile/profile_screen.dart';

final Map<String, WidgetBuilder> routes = {
  HomeScreen.routeName: (context) => HomeScreen(),
  WelcomeScreen.routeName: (context) => WelcomeScreen(),
  ProfileScreen.routeName: (context) => ProfileScreen(),
  ProductDetail.routeName: (context) => ProductDetail(),
  // ProductDetail2.routeName: (context) => ProductDetail2(),
  CartScreen.routeName: (context) => CartScreen(),
  EditProfileScreen.routeName: (context) => EditProfileScreen(),
  BillingScreen.routeName: (context) => BillingScreen(),
  SearchResult.routeName: (context) => SearchResult(),
  // Brain.routeName: (context) => Brain(),
};
