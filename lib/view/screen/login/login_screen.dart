import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import '../../../service/api_service.dart';
import '../../../utils/app_constant.dart';
import '../../../utils/app_sp.dart';
import 'bloc/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController companyCodeController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late LoginBloc loginBloc;

  @override
  void initState() {
    super.initState();
    loginBloc = LoginBloc(ApiService());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => loginBloc,
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xFFEFEEF3),
        body: SingleChildScrollView(

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Image.asset(
                  logo,
                  height: 200,
                  width: 200,
                ),
                // SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35),
                    child: Text(
                      'Sign In as Driver',
                      style: TextStyle(
                        fontFamily: GoogleFonts.openSans().fontFamily,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                dividerLH(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35),
                    child: Text(
                      "Lorem ipsum has been the industry's standard dummy text ever since the",
                      style: TextStyle(
                        color: Color(0xFF8C8686),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.openSans().fontFamily,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                // Username text field with label
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Company Code',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: GoogleFonts.openSans().fontFamily,
                        ),
                      ),
                      SizedBox(height: 5),
                      TextField(
                        controller: companyCodeController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Company Code',
                          hintStyle: TextStyle(color: Color(0xFFC5C5C5)),
                          fillColor:
                              Color(0xFFF9F9F9), // Add background color here
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal:
                                  20.0), // Adjust content padding as needed
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                dividerH(),
                // Username text field with label
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: GoogleFonts.openSans().fontFamily,
                        ),
                      ),
                      SizedBox(height: 5),
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Email',
                          hintStyle: TextStyle(color: Color(0xFFC5C5C5)),
                          fillColor:
                              Color(0xFFF9F9F9), // Add background color here
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal:
                                  20.0), // Adjust content padding as needed
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                dividerH(),
                // Password text field with label
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: GoogleFonts.openSans().fontFamily,
                        ),
                      ),
                      SizedBox(height: 5),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Password',
                          hintStyle: TextStyle(color: Color(0xFFC5C5C5)),
                          fillColor:
                              Color(0xFFF9F9F9), // Add background color here
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal:
                                  20.0), // Adjust content padding as needed
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                dividerLH(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontFamily: GoogleFonts.openSans().fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF271D72),
                      ),
                    ),
                  ),
                ),

                dividerLH(),


                BlocConsumer<LoginBloc, LoginState>(
                  listener: (context, state) {
                    if (state is LoginSuccessState) {
                      print('Working...login');
                      if (state.response.email == usernameController.text.toString()) {

                        EasyLoading.showToast( "LOGIN SUCCESS");

                        AppSp().setToken('${state.response.access}'.toString());
                        AppSp().setUserName('${state.response.username}'.toString());
                        AppSp().setUserEmail('${state.response.email}'.toString());
                        AppSp().setCompanyCode(companyCodeController.text.toString());
                        AppSp().setUserID('${state.response.id}'.toString());
                        AppSp().setIsLogged(true);
                        AppSp().setRefreshtoken('${state.response.refresh}'.toString());

                        try {
                          Navigator.pushNamed(context, "/dashHome");
                        } catch (e) {
                          print("Navigation error: $e");
                        }
                      } else {
                        EasyLoading.showToast("${state.response}");
                      }
                    }else{
                      EasyLoading.showToast("Invalid Credentials");
                    }


                  },
                  builder: (context, state) {
                    return               Padding(
                        padding: const EdgeInsets.all(35),
                    child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (companyCodeController.text.toString() == "") {
                          EasyLoading.showToast("Please fill CompanyCode");
                        }else if (usernameController.text.toString() == "") {
                          EasyLoading.showToast("Please fill username");
                        }
                        else if (passwordController.text.toString() == "") {
                          EasyLoading.showToast("Please fill password");
                        } else {
                          loginBloc.add(LoginApiEvent(
                            username: usernameController.text.toString(),
                            password: passwordController.text.toString(),
                            companycode:companyCodeController.text.toString(),
                            // tokenId: fireToken,
                            // deviceId: deviceId,
                          ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1B1466),
                        padding: EdgeInsets.zero, // Remove default padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(10), // Border radius
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: GoogleFonts.openSans().fontFamily,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    ),
                    );
                  },
                ),


                // Padding(
                //   padding: const EdgeInsets.all(35),
                //   child: SizedBox(
                //     width: double.infinity,
                //     height: 55,
                //     child: ElevatedButton(
                //       onPressed: () {
                //         Navigator.pushNamed(context, "/dashHome");
                //       },
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: Color(0xFF1B1466),
                //         padding: EdgeInsets.zero, // Remove default padding
                //         shape: RoundedRectangleBorder(
                //           borderRadius:
                //               BorderRadius.circular(10), // Border radius
                //         ),
                //       ),
                //       child: Text(
                //         'Submit',
                //         style: TextStyle(
                //             fontSize: 16,
                //             fontFamily: GoogleFonts.openSans().fontFamily,
                //             fontWeight: FontWeight.bold),
                //       ), // Add child widget for the button text
                //     ),
                //   ),
                // ),


              ],
            ),
          ),
        ),

    );
  }
}
