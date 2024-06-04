import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:syswash/view/screen/dashboard/home_screen.dart';
import 'package:syswash/view/screen/login/login_screen.dart';

import '../../../../utils/app_sp.dart';

import '../../../utils/app_constant.dart';

import 'package:http/http.dart' as http;


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _State();
}

class _State extends State<SplashPage> {
  Future isLogged = AppSp().getIsLogged();
  late Future refresh;



  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () async {
      bool val = await AppSp().getIsLogged();
      refresh = AppSp().getRefreshtoken();



      if (val) {
        String? refreshToken = await AppSp().getRefreshtoken();
        http.Response response = await http.post(
          Uri.parse('https://be.syswash.net/api/token/refresh/'),
          body: {'refresh': refreshToken},
        );
        if (response.statusCode == 200) {
          Map<String, dynamic> data = json.decode(response.body);
          String? accessToken = data['access'];
          if (accessToken != null) {
            AppSp().setToken(accessToken);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashBoardScreen()),
            );
            return;
          }
        }

        Navigator.push(



            context, MaterialPageRoute(builder: (context) => DashBoardScreen()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEEF3),
      body: Center(
        child:Image.asset(logo,
          height: 200,
          width: 200,
        ) ,
      ),
    );
  }
}














// import 'dart:async';
//
// import 'package:flutter/material.dart';
//
// import 'package:syswash/view/screen/dashboard/home_screen.dart';
// import 'package:syswash/view/screen/login/login_screen.dart';
//
// import '../../../../utils/app_sp.dart';
//
// import '../../../utils/app_constant.dart';
//
//
//
//
// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});
//
//   @override
//   State<SplashPage> createState() => _State();
// }
//
// class _State extends State<SplashPage> {
//   Future isLogged = AppSp().getIsLogged();
//   @override
//   void initState() {
//     super.initState();
//     Timer(const Duration(seconds: 3), () async {
//       bool val = await AppSp().getIsLogged();
//       if (val) {
//         Navigator.push(
//             context, MaterialPageRoute(builder: (context) => DashBoardScreen()));
//       } else {
//         Navigator.push(
//             context, MaterialPageRoute(builder: (context) => LoginScreen()));
//       }
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFEFEEF3),
//       body: Center(
//         child:Image.asset(logo,
//           height: 200,
//           width: 200,
//         ) ,
//       ),
//     );
//   }
// }