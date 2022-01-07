import 'package:epicshop/components/custom_surfix_icon.dart';
import 'package:epicshop/components/default_button.dart';
import 'package:epicshop/components/form_error.dart';
import 'package:epicshop/net/net_helper.dart';
import 'package:epicshop/screens/cart/cart_screen.dart';
import 'package:epicshop/screens/home/home_screen.dart';
import 'package:epicshop/screens/profile/components/edit_profile.dart';
import 'package:epicshop/screens/sign_up/signup_popup.dart';
import 'package:flutter/material.dart';
import 'package:epicshop/net/brain.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart' show ModalProgressHUD;
import '../../constants.dart';
import '../../enums.dart';

class LoginPopUp extends StatefulWidget {
  const LoginPopUp({Key? key, required this.selectedScreen}) : super(key: key);
  final Screen selectedScreen;

  @override
  _LoginPopUpState createState() => _LoginPopUpState();
}

class _LoginPopUpState extends State<LoginPopUp> {
  final _formKey = GlobalKey<FormState>();
  bool showSpinner = false;
  late String email;
  late String userName;
  late String password;
  bool remember = false;
  final List<String> errors = [];

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error!);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
        errors.clear();
      });
  }

  /// screenChecker helps to check which screen should showing to user..
  void screenChecker(Screen selectedScreen) {
    if (selectedScreen == Screen.drawer) {
      navigateToScreen(HomeScreen.routeName);
    }
    if (selectedScreen == Screen.cart) {
      navigateToScreen(CartScreen.routeName);
    }
    if (selectedScreen == Screen.profile) {
      navigateToScreen(EditProfileScreen.routeName);
    }
  }

  /// navigateToScreen helps to navigate user to target screen
  void navigateToScreen(String routeName) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Brain(selectedRouteName: routeName)));
    kShowToast(context, "با موفقیت وارد حساب کاربری شدید");
  }
  // /// infoChecker helps to check user information is complete or not.
  // /// for transport to payment screen ,first user has to complete his/her information.
  // void infoChecker(String routeName) {
  //   if (Brain.customer.email != null && Brain.customer.email != "" && Brain.customer.firstName != null && Brain.customer.firstName != "" &&
  //       Brain.customer.lastName != null && Brain.customer.lastName != "" && Brain.customer.billing.phone != null && Brain.customer.billing.phone != "" &&
  //       Brain.customer.billing.city != null && Brain.customer.billing.city != "" && Brain.customer.billing.state != null && Brain.customer.billing.state != "" &&
  //       Brain.customer.billing.address1 != null && Brain.customer.billing.address1 != "") {
  //     Navigator.of(context).pop();
  //     }else{
  //       Navigator.of(context).pop();
  //       navigateToScreen(EditProfileScreen.routeName);
  //       kShowToast(context, "برای تکمیل خرید ابتدا باید اطلاعات پروفایل خود را کامل کنید.");
  //     }
  //
  // }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: AlertDialog(
        content: Container(
          height: 400.0,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                right: -40.0,
                top: -40.0,
                child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      child: Icon(Icons.close),
                      backgroundColor: Colors.red,
                    )),
              ),
              Scrollbar(
                isAlwaysShown: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        FormError(errors: errors),
                        SizedBox(height: 15.0),
                        buildUsernameFormField(),
                        SizedBox(height: 15.0),
                        buildPasswordFormField(),
                        SizedBox(height: 15.0),
                        Column(children: [
                          Row(children: [
                            Checkbox(
                                value: remember,
                                activeColor: kPrimaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    remember = value!;
                                  });
                                }),
                            Text("مرا به خاطر بسپار"),
                            Spacer(),
                          ]),
                        ]),
                        DefaultButton(
                          text: "ادامه",
                          width: 150.0,
                          press: () async {
                            removeError();
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              setState(() {
                                showSpinner = true;
                              });
                              try {
                                ///Login - Returns the access token on success.
                                await NetworkHelper().wooCommerce.loginCustomer(
                                    username: userName, password: password);
                                bool isLoggedIn = await NetworkHelper()
                                    .wooCommerce
                                    .isCustomerLoggedIn();

                                if (isLoggedIn) {
                                  setState(() {
                                    showSpinner = false;
                                  });
                                  screenChecker(widget.selectedScreen);
                                } else {
                                  setState(() {
                                    showSpinner = false;
                                  });
                                  Navigator.pop(context);
                                  kShowToast(
                                      context, "نام کاربری یا رمز اشتباه است");
                                }
                              } catch (e) {
                                print(e);
                              }
                            }
                          },
                        ),
                        SizedBox(height: 15.0),
                        GestureDetector(
                          onTap: () {},
                          /*() => Navigator.pushNamed(
                          context, ForgotPasswordScreen.routeName),*/
                          child: Text(
                            "فراموشی رمز عبور",
                            style:
                                TextStyle(decoration: TextDecoration.underline),
                          ),
                        ),
                        SizedBox(height: 15.0),
                        TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return SignupPopup(
                                    selectedScreen: widget.selectedScreen,
                                  );
                                },
                              );
                            },
                            child: Text('ثبت نام')),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } //Password field styles and builder

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => password = newValue!,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 4) {
          removeError(error: kShortPassError);
        }
        return null;
      },
      validator: (value) {
        password = value!;
        if (value!.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if (value.length < 4) {
          addError(error: kShortPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "رمز عبور",
        hintText: "رمز عبور را وارد کنید",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  //Username field styles and builder
  TextFormField buildUsernameFormField() {
    return TextFormField(
      onSaved: (newValue) => userName = newValue!,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kUsernameNullError);
        } else if (value.length >= 3) {
          removeError(error: kShortUserNameError);
        }
        return null;
      },
      validator: (value) {
        userName = value!;
        if (value!.isEmpty) {
          addError(error: kUsernameNullError);
          return "";
        } else if (value.length < 3) {
          addError(error: kShortUserNameError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "نام کاربری",
        hintText: "نام کاربری را وارد کنید",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }
}
