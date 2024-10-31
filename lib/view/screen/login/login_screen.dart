import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import '../../../firebase_options.dart';
import '../../../service/api_service.dart';
import '../../../utils/app_constant.dart';
import '../../../utils/app_sp.dart';
import '../notification/notication.dart';
import 'bloc/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscured=true;

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
        backgroundColor: Color(0xFFF9F9F9),
        body: SingleChildScrollView(

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                Image.asset(
                  logo1,
                  height: 80,
                  width: 80,
                ),
                SizedBox(height: 20),
                 Image.asset(
                        logo2,
                        height: 30,
                        width: 200,
                      ),


            SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35),
                    // child: Text(
                    //   // "Lorem ipsum has been the industry's standard dummy text ever since the",
                    //   style: TextStyle(
                    //     color: Color(0xFF8C8686),
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.bold,
                    //     fontFamily: GoogleFonts.openSans().fontFamily,
                    //   ),
                    // ),
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
                          color: Color(0xFF0D0140),
                          fontSize: 16,
                          fontFamily: GoogleFonts.dmSans().fontFamily,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: companyCodeController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter Company Code',
                            hintStyle: TextStyle(color: Colors.grey),
                            fillColor:
                                Color(0xFFFFFFFF), // Add background color here
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal:
                                    20.0), // Adjust content padding as needed
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(8.0),



                            ),
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
                        'Email',
                        style: TextStyle(
                          color: Color(0xFF0D0140),
                          fontSize: 16,
                          fontFamily: GoogleFonts.dmSans().fontFamily,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: usernameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter Email',
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 20.0), // Adjust content padding as needed
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                dividerH(),
                // Password text field with label
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 35),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         'Password',
                //         style: TextStyle(
                //           color: Color(0xFF0D0140),
                //           fontSize: 16,
                //           fontFamily: GoogleFonts.dmSans().fontFamily,
                //           fontWeight: FontWeight.w700,
                //         ),
                //       ),
                //       SizedBox(height: 5),
                //       Container(
                //         decoration: BoxDecoration(
                //           boxShadow: [
                //             BoxShadow(
                //               color: Colors.black.withOpacity(0.1),
                //               spreadRadius: 1,
                //               blurRadius: 3,
                //               offset: Offset(0, 1),
                //             ),
                //           ],
                //         ),
                //         child: TextField(
                //           controller: passwordController,
                //
                //           decoration: InputDecoration(
                //
                //             border: InputBorder.none,
                //             hintText: 'Enter Password',
                //             hintStyle: TextStyle(color: Colors.grey),
                //             fillColor:
                //                 Color(0xFFFFFFFF), // Add background color here
                //             filled: true,
                //             contentPadding: EdgeInsets.symmetric(
                //                 vertical: 20.0,
                //                 horizontal:
                //                     20.0), // Adjust content padding as needed
                //             enabledBorder: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.transparent),
                //               borderRadius: BorderRadius.circular(15.0),
                //
                //             ),
                //             focusedBorder: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.transparent),
                //               borderRadius: BorderRadius.circular(15.0),
                //
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: TextStyle(
                          color: Color(0xFF0D0140),
                          fontSize: 16,
                          fontFamily: GoogleFonts.dmSans().fontFamily,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: passwordController,
                          obscureText: _isObscured,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter Password',
                            hintStyle: TextStyle(color: Colors.grey),
                            fillColor: Color(0xFFFFFFFF), // Add background color here
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 20.0), // Adjust content padding as needed
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscured ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 15,),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontFamily: GoogleFonts.dmSans().fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D0140),
                      ),
                    ),
                  ),
                ),

             SizedBox(height: 5,),


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
                        padding: const EdgeInsets.all(37),
                    child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (companyCodeController.text.toString() == "") {
                          EasyLoading.showToast("Please fill CompanyCode");
                        }else if (usernameController.text.toString() == "") {
                          EasyLoading.showToast("Please fill username");
                        }
                        else if (passwordController.text.toString() == "") {
                          EasyLoading.showToast("Please fill password");
                        } else {
                          await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
                          PushNotification.init();
                          PushNotification.localNotiInit();

                         // FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
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
                        backgroundColor: Color(0xFF68188B),
                        padding: EdgeInsets.zero, // Remove default padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(8), // Border radius
                        ),
                      ),
                      child: Text(
                        'LOGIN',
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

              ],
            ),
          ),
        ),

    );
  }
}
