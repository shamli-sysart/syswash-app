///////////////// old home page  starting//////////////
// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:syswash/utils/app_constant.dart';
// import 'package:http/http.dart' as http;
// import '../../../utils/app_sp.dart';
// import '../../../utils/app_url.dart';
//
// import 'package:carousel_slider/carousel_slider.dart';
//
// class DashBoardScreen extends StatefulWidget {
//   const DashBoardScreen({super.key});
//
//   @override
//   State<DashBoardScreen> createState() => _DashBoardScreenState();
// }
//
// class _DashBoardScreenState extends State<DashBoardScreen> {
//   int _currentIndex = 0;
//   String tokenID = '';
//   String userToken = "";
//   String companyCode = "";
//   String userID = "";
//   String pickupitemCount = '';
//   String deliveritemCount = '';
//
//   String firebaseToken = "";
//
//   String driverID = "";
//
//   String refreshtoken = "";
//
//   String LoggerUsername = "";
//
//   @override
//   void initState() {
//     super.initState();
//     getUserToken();
//   }
//
//   Future<void> getUserToken() async {
//     AppSp appSp = AppSp();
//     userToken = await appSp.getToken();
//     companyCode = await appSp.getCompanyCode();
//     userID = await appSp.getUserID();
//
//     LoggerUsername = await appSp.getUserName();
//
//     fetchOrderListingData(userToken, companyCode, userID);
//     fetchDeliverListingData(userToken, companyCode, userID);
//
//
//     firebaseToken = await appSp.getFirebasetoken();
//     passFirebaseToken(firebaseToken,userToken, userID);
//
//     print('-------------------78563465836503457345875438654386304956345');
//     refreshtoken = await appSp.getRefreshtoken();
//     print(refreshtoken);
//     passRefreshToken(refreshtoken);
//     if (refreshtoken == '')
//     {
//       AppSp().setIsLogged(false);
//
//
//       Navigator.pushReplacementNamed(context, '/login');
//     }
//
//
//     print('-------------------78563465836503457345875438654386304956345');
//
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   void passRefreshToken(String refreshtoken) async {
//     try {
//       final response = await http.post(
//         Uri.parse('https://be.syswash.net/api/token/refresh/'),
//         body: {'refresh': refreshtoken},
//       );
//
//       if (response.statusCode == 200) {
//         Map<String, dynamic> data = json.decode(response.body);
//         String? accessToken = data['access'];
//         if (accessToken != null) {
//           setState(() {
//             AppSp().setToken(accessToken);
//             userToken = accessToken.toString();
//             print('Access token refreshed successfully: $userToken');
//           });
//         } else {
//           print('Error: No access token returned');
//           AppSp().setIsLogged(false);
//
//
//           Navigator.pushReplacementNamed(context, '/login');
//         }
//       } else {
//         print('Error: Failed to refresh token, status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         AppSp().setIsLogged(false);
//
//
//         Navigator.pushReplacementNamed(context, '/login');
//
//       }
//     } catch (e) {
//       print('Exception caught: $e');
//       AppSp().setIsLogged(false);
//
//
//       Navigator.pushReplacementNamed(context, '/login');
//     }
//   }
//
//
//   void passFirebaseToken(String firebaseToken, String userToken, String userID) async {
//     final response = await http.post(
//       Uri.parse('${AppUrls.driverdevicetoken}${AppUrls.code_main}$companyCode'),
//       headers: {
//         "Accept": "application/json",
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $userToken"
//       },
//       body: jsonEncode({
//         "driver_id": userID,
//         "device_token": firebaseToken,
//       }),
//     );
//     print('<<<>>>>>>>firebase');
//     print(firebaseToken);
//     if (response.statusCode == 200) {
//       print(response.body);
//       print('Passed SucessFully');
//     } else {
//       print("Failed to fetch data: ${response.body}");
//     }
//   }
//
//
//
//   void fetchOrderListingData( String userToken, String companyCode, String userID) async {
//     final response = await http.get(
//         Uri.parse('${AppUrls.pickuplist}$userID${AppUrls.code_main}$companyCode'),
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer $userToken"
//         }
//     );
//     if (response.statusCode == 200) {
//       List<dynamic> data = jsonDecode(response.body);
//       int itemCount = data.length;
//       setState(() {
//         pickupitemCount = itemCount.toString();
//       });
//     } else {
//       print("Failed to fetch data: ${response.statusCode}");
//     }
//   }
//
//   void fetchDeliverListingData( String userToken, String companyCode, String userID) async {
//     final response = await http.get(
//         Uri.parse('${AppUrls.deliverylist}$userID${AppUrls.code_main}$companyCode'),
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer $userToken"
//         }
//     );
//     if (response.statusCode == 200) {
//       List<dynamic> data = jsonDecode(response.body);
//       int itemCount = data.length;
//       setState(() {
//         deliveritemCount = itemCount.toString();
//       });
//     } else {
//       print("Failed to fetch data: ${response.statusCode}");
//     }
//   }
//   //slider
//   List imageList = [
//     {"id":1,"image_path":'assets/slider/sys.png'},
//     {"id":2,"image_path":'assets/slider/sys.png'},
//     {"id":3,"image_path":'assets/slider/sys.png'},
//   ];
//   final CarouselController carouselController = CarouselController();
//   int currentIndex = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return
//       WillPopScope(
//         onWillPop: () async {
//           return await showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text(
//                 'Are you sure...?',
//               ),
//               content: const Text(
//                 'Do you want to exit from the App',
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(false);
//                     SystemNavigator.pop();
//                     Future.delayed(const Duration(milliseconds: 1000), () {
//                       SystemChannels.platform
//                           .invokeMethod('SystemNavigator.pop');
//                     });
//                   },
//                   child: const Text(
//                     "YES",
//                     style: TextStyle(
//                       color: Colors.red,
//                     ),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(false);
//                   },
//                   child: const Text(
//                     "NO",
//                     style: TextStyle(
//                       color: Color(0xFF301C93),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//         child:
//         Scaffold(
//           backgroundColor: Color(0xFFEFEEF3),
//           body: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   //       Stack(children: [
//                   //         InkWell(
//                   //       onTap: (){
//                   //         print(currentIndex);
//                   // },
//                   //   child: CarouselSlider(
//                   //     items: imageList.map((item)=>Image.asset(item[
//                   //       'image_path'],
//                   //       fit: BoxFit.cover,
//                   //       width: double.infinity,
//                   //     ),
//                   //   ).toList(),
//                   //     carouselController: carouselController,
//                   //     options: CarouselOptions(
//                   //       scrollPhysics: BouncingScrollPhysics(),
//                   //       autoPlay: true,
//                   //       aspectRatio: 2,
//                   //       viewportFraction: 1,
//                   //       onPageChanged: (index, reason){
//                   //         setState(() {
//                   //           currentIndex=index;
//                   //         });
//                   //       },
//                   //     ),
//                   //   )
//                   // ),
//                   //   ],
//                   //       ),
//
//                   SizedBox(height: 30),
//
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         '$LoggerUsername',
//                         style: TextStyle(  color: Color(0xFF8C8686),
//                           fontFamily: GoogleFonts.openSans().fontFamily,
//                           fontSize: 20,
//                         ),
//                       ),
//                       // Text(firebaseToken),
//                       //
//
//
//                       IconButton(
//                         icon: Icon(Icons.notifications_outlined,
//                             size: 45, color: Color(0xFF301C93)),
//                         onPressed: () {
//                         },
//                       ),
//                     ],
//                   ),
//
//                   SizedBox(height: 2),
//                   Text(
//                     'SYSWASH',
//                     style: TextStyle(
//                         fontFamily: GoogleFonts.openSans().fontFamily,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF301C93)),
//                   ),
//                   SizedBox(height: 10,),
//                   Stack(children: [
//                     InkWell(
//                         onTap: (){
//                           print(currentIndex);
//                         },
//                         child: CarouselSlider(
//                           items: imageList.map((item)=>Image.asset(item[
//                           'image_path'],
//                             fit: BoxFit.cover,
//                             width: double.infinity,
//                           ),
//                           ).toList(),
//                           carouselController: carouselController,
//                           options: CarouselOptions(
//                             scrollPhysics: BouncingScrollPhysics(),
//                             autoPlay: true,
//                             aspectRatio: 2,
//                             viewportFraction: 1,
//                             onPageChanged: (index, reason){
//                               setState(() {
//                                 currentIndex=index;
//                               });
//                             },
//                           ),
//                         )
//                     ),
//                   ],
//                   ),
//                   dividerH(),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Flexible(
//                         child: Card(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(25.0),
//                           ),
//                           child: Container(
//                             width: MediaQuery.of(context).size.width * 0.5,
//                             height: MediaQuery.of(context).size.height * 0.14,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(20.0),
//                               color: Colors.orange,
//                             ),
//                             child: Stack(
//                               children: [
//                                 // Icon in top left corner
//                                 const Positioned(
//                                   top: 8,
//                                   left: 8,
//                                   child: Icon(
//                                     Icons.delivery_dining,
//                                     color: Colors.white,
//                                     size: 50,
//                                   ),
//                                 ),
//                                 // Text in the card (example)
//                                 const Positioned(
//                                   bottom: 20,
//                                   left: 20,
//                                   child: Text(
//                                     'Pickup',
//                                     style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                                 Positioned(
//                                   bottom: 15,
//                                   right: 20,
//                                   child: CircleAvatar(
//                                       radius:
//                                       20.0,
//                                       backgroundColor:Colors.white,
//                                       child:
//                                       Text(pickupitemCount,style: TextStyle(color: Colors.orange,fontSize: 14,fontWeight: FontWeight.bold),)
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       Flexible(
//                         child: Card(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(25.0),
//                           ),
//                           child: Container(
//                             width: MediaQuery.of(context).size.width * 0.5,
//                             height: MediaQuery.of(context).size.height * 0.14,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(20.0),
//                               color: Colors.deepPurpleAccent,
//                             ),
//                             child: Stack(
//                               children: [
//                                 // Icon in top left corner
//                                 Positioned(
//                                   top: 8,
//                                   left: 8,
//                                   child: Icon(
//                                     Icons.shopping_bag,
//                                     color: Colors.white,
//                                     size: 50,
//                                   ),
//                                 ),
//                                 // Text in the card (example)
//                                 Positioned(
//                                   bottom: 20,
//                                   left: 20,
//                                   child: Text(
//                                     'Delivery',
//                                     style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                                 Positioned(
//                                   bottom: 15,
//                                   right: 20,
//                                   child: CircleAvatar(
//                                       radius:
//                                       20.0,
//                                       backgroundColor:Colors.white,
//                                       child:
//                                       Text(deliveritemCount,
//                                         style: TextStyle(color: Colors.deepPurpleAccent,fontSize: 14,fontWeight: FontWeight.bold),)
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   dividerLH(),
//                   SizedBox(
//                     height: 130,
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.pushNamed(context, "/pickupOrderListing");
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Stack(
//                           fit: StackFit.expand,
//                           children: [
//                             // Image
//                             Container(
//                               decoration: BoxDecoration(
//                                 image: DecorationImage(
//                                   image: AssetImage(
//                                       homeImagePick),
//                                   fit: BoxFit.cover,
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//
//                             ),
//                             // Gradient
//                             Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12),
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [
//                                     Colors.transparent,
//                                     Colors.black.withOpacity(0.8),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               padding: EdgeInsets.all(20),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Text(
//                                     'Pickup Order',
//                                     style: TextStyle(
//                                       fontFamily: GoogleFonts.openSans().fontFamily,
//                                       fontSize: 25,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   Icon(Icons.arrow_forward, color: Colors.white),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   dividerH(),
//                   SizedBox(
//                     height: 130,
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.pushNamed(context, "/delivery");
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Stack(
//                           fit: StackFit.expand,
//                           children: [
//                             // Image
//                             Container(
//                               decoration: BoxDecoration(
//                                 image: DecorationImage(
//                                   image: AssetImage(
//                                       homeImageDelivery),
//                                   fit: BoxFit.cover,
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             // Gradient
//                             Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12),
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [
//                                     Colors.transparent,
//                                     Colors.black.withOpacity(0.8),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             // Content
//                             Container(
//                               padding: EdgeInsets.all(20),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Text(
//                                     'Delivery Order',
//                                     style: TextStyle(
//                                       fontFamily: GoogleFonts.openSans().fontFamily,
//                                       fontSize: 25,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   Icon(Icons.arrow_forward, color: Colors.white),
//                                 ],
//                               ),
//                             ),
//                             // TextField(
//                             //   controller: TextEditingController(text: firebaseToken),
//                             //   decoration: InputDecoration(
//                             //     labelText: 'Enter some text',
//                             //     border: OutlineInputBorder(),
//                             //   ),
//                             // ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           bottomNavigationBar:BottomNavigationBar(
//             currentIndex: _currentIndex,
//             onTap: _onItemTapped,
//             type: BottomNavigationBarType.fixed,
//             items: [
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.home, ),
//                 label: 'Home',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.car_crash,),
//                 label: 'Pickup',
//               ),
//               BottomNavigationBarItem(
//                 icon:Icon(Icons.car_crash, ),
//                 label: 'Delivery',
//               ),
//               BottomNavigationBarItem(
//                 icon:Icon(Icons.compare_arrows, ),
//                 label: 'History',
//               ),
//               BottomNavigationBarItem(
//                 icon:Icon(Icons.person, ),
//                 label: 'Me',
//               ),
//             ],
//             selectedItemColor:Color(0xFF301C93),
//             selectedFontSize:
//             12.0, // Adjust the font size for the selected item
//             unselectedFontSize:
//             12.0, // Adjust the font size for unselected items
//             iconSize: 26.0, // Adjust the icon size
//           ),
//         ),
//       );
//   }
//
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//
//     if (_currentIndex == 0) {
//       Navigator.pushReplacementNamed(context, '/dashHome');
//     } else if (_currentIndex == 1) {
//       Navigator.pushReplacementNamed(context, "/pickupOrderListing");
//     } else if (_currentIndex == 2) {
//       Navigator.pushReplacementNamed(context, "/delivery");
//     } else if (_currentIndex == 3) {
//       Navigator.pushReplacementNamed(context, '/history');
//     } else if (_currentIndex == 4) {
//       Navigator.pushReplacementNamed(context, '/profile');
//     }
//   }
// }



////////////oldhome page stop////////








//////  / / / / // / / newhomepage starting //////////



import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:syswash/utils/app_constant.dart';
import 'package:http/http.dart' as http;
import '../../../utils/app_sp.dart';
import '../../../utils/app_url.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  int _currentIndex = 0;
  String tokenID = '';
  String userToken = "";
  String companyCode = "";
  String userID = "";
  String pickupitemCount = '';
  String deliveritemCount = '';

  String firebaseToken = "";

  String driverID = "";

  String refreshtoken = "";

  String LoggerUsername = "";

  String orderTotalCount = '0';


  List<Map<String, dynamic>> pickupOrders = [];

  List<Map<String, dynamic>> deliveryOrders = [];

  List<Map<String, dynamic>> allOrders = [];


  // final List<String> deliveryOrders = [
  //   'Delivery Order 1',
  //   'Delivery Order 2',
  //   'Delivery Order 3',
  //   'Delivery Order 4',
  //   'Delivery Order 5',
  // ];

  @override
  void initState() {
    super.initState();
    getUserToken();
  }

  Future<void> getUserToken() async {
    AppSp appSp = AppSp();
    userToken = await appSp.getToken();
    companyCode = await appSp.getCompanyCode();
    userID = await appSp.getUserID();

    LoggerUsername = await appSp.getUserName();

    fetchOrderListingData(userToken, companyCode, userID);
    fetchDeliverListingData(userToken, companyCode, userID);

    fetchcountoftheTotalorder(userToken, companyCode, userID);


    firebaseToken = await appSp.getFirebasetoken();
    passFirebaseToken(firebaseToken, userToken, userID);

    print('-------------------78563465836503457345875438654386304956345');
    refreshtoken = await appSp.getRefreshtoken();
    print(refreshtoken);
    passRefreshToken(refreshtoken);
    if (refreshtoken == '') {
      AppSp().setIsLogged(false);

      Navigator.pushReplacementNamed(context, '/login');
    }

    print('-------------------78563465836503457345875438654386304956345');

    print("this is below in new data");


    print("end this data");





  }

  @override
  void dispose() {
    super.dispose();
  }

  void passRefreshToken(String refreshtoken) async {
    try {
      final response = await http.post(
        Uri.parse('https://be.syswash.net/api/token/refresh/'),
        body: {'refresh': refreshtoken},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        String? accessToken = data['access'];
        if (accessToken != null) {
          setState(() {
            AppSp().setToken(accessToken);
            userToken = accessToken.toString();
            print('Access token refreshed successfully: $userToken');
          });
        } else {
          print('Error: No access token returned');
          AppSp().setIsLogged(false);

          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        print(
            'Error: Failed to refresh token, status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        AppSp().setIsLogged(false);

        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('Exception caught: $e');
      AppSp().setIsLogged(false);

      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void passFirebaseToken(
      String firebaseToken, String userToken, String userID) async {
    final response = await http.post(
      Uri.parse('${AppUrls.driverdevicetoken}${AppUrls.code_main}$companyCode'),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken"
      },
      body: jsonEncode({
        "driver_id": userID,
        "device_token": firebaseToken,
      }),
    );
    print('<<<>>>>>>>firebase');
    print(firebaseToken);
    if (response.statusCode == 200) {
      print(response.body);
      print('Passed SucessFully');
    } else {
      print("Failed to fetch data: ${response.body}");
    }
  }



  void fetchcountoftheTotalorder(
      String userToken, String companyCode, String userID) async {
    print('${AppUrls.history}$userID${AppUrls.code_main}$companyCode');
    final response = await http.get(
        Uri.parse(
            '${AppUrls.history}$userID${AppUrls.code_main}$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        });

    print('get the respond');
    if (response.statusCode == 200) {

      final data = json.decode(response.body);

      int pickupCount = data['pickup'].length;
      int deliveryCount = data['delivery'].length;
      int totalCount = pickupCount + deliveryCount;

      setState(() {
        print("Pickup Orders: $pickupCount");
        print("Delivery Orders: $deliveryCount");
        print("Total Orders: $totalCount");

        orderTotalCount = totalCount.toString();
      });
    } else {
      print("Failed to fetch data: ${response.statusCode}");
    }
  }


  void letestAllOrders()async{
    print('xxxx this is an latest orders ');
    print(pickupOrders);
    print(deliveryOrders);
  }






  void fetchOrderListingData(
      String userToken, String companyCode, String userID) async {
    final response = await http.get(
        Uri.parse(
            '${AppUrls.pickuplist}$userID${AppUrls.code_main}$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        });
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      print("data res[pomse");
      print(response.body);

      // Filter out orders where pickupstatus is 'Received'
      List<dynamic> filteredData =
      data.where((item) => item['pickupstatus'] != 'Received').toList();

      // Sort the data by pickupDate in descending order
      filteredData.sort((a, b) => b['pickupDate'].compareTo(a['pickupDate']));

      // Take the latest 5 orders
      List<dynamic> latest5Orders = filteredData.take(5).toList();

      List<Map<String, dynamic>> newPickupOrders =
      latest5Orders.map<Map<String, dynamic>>((item) {
        return {
          'pickupassgnId': item['pickupassgnId'],
          'pickupDate': item['pickupDate'],
          'pickupCustomerName': item['pickupCustomerName'],
          'pickupCustomerId': item['pickupCustomerId'],
          'pickupCustomerArea': item['pickupCustomerArea'],
          'pickupOrderId': item['pickupOrderId'],
          'this':"pickup"
        };
      }).toList();

      int itemCount = data.length;
      setState(() {
        pickupitemCount = itemCount.toString();

        pickupOrders = newPickupOrders;

        print(pickupOrders);
        allOrders.addAll(newPickupOrders);
      });
    } else {
      print("Failed to fetch data: ${response.statusCode}");
    }
  }

  void fetchDeliverListingData(
      String userToken, String companyCode, String userID) async {
    final response = await http.get(
        Uri.parse(
            '${AppUrls.deliverylist}$userID${AppUrls.code_main}$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        });
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      print("drliveryyyyyyy");
      print(response.body);

      List<dynamic> filteredData = data.where((item) => item['status'] != 'Delivered').toList();

      // Sort the data by deliveryDate in descending order
      filteredData.sort((a, b) {
        DateTime dateA = DateTime.parse(a['deliveryDate']);
        DateTime dateB = DateTime.parse(b['deliveryDate']);
        return dateB.compareTo(dateA);
      });

      // Take the latest 5 delivered items
      List<dynamic> latest5Deliveries = filteredData.take(5).toList();

      // Extract the required fields
      List<Map<String, dynamic>> newDeliveryOrders = latest5Deliveries.map<Map<String, dynamic>>((item) {
        return {
          'deliveryassgnId': item['deliveryassgnId'],
          'deliveryDate': item['deliveryDate'],
          'deliveryCustomerName': item['deliveryCustomerName'],
          'deliveryCustomerArea': item['deliveryCustomerArea'],
          'deliveryCustomerId': item['deliveryCustomerId'],

          'deliveryInvoiceNo': item['deliveryInvoiceNo'],
          'this':"delivery"
        };
      }).toList();




      int itemCount = data.length;
      setState(() {
        deliveritemCount = itemCount.toString();
        deliveryOrders = newDeliveryOrders;
        allOrders.addAll(newDeliveryOrders);
      });
    } else {
      print("Failed to fetch data: ${response.statusCode}");
    }
  }

  //slider
  List imageList = [
    {"id": 1, "image_path": 'assets/slider/sys.png'},
    {"id": 2, "image_path": 'assets/slider/sys.png'},
    {"id": 3, "image_path": 'assets/slider/sys.png'},
  ];
  final CarouselController carouselController = CarouselController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Are you sure...?',
            ),
            content: const Text(
              'Do you want to exit from the App',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  SystemNavigator.pop();
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  });
                },
                child: const Text(
                  "YES",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text(
                  "NO",
                  style: TextStyle(
                    color: Color(0xFF301C93),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //       Stack(children: [
                  //         InkWell(
                  //       onTap: (){
                  //         print(currentIndex);
                  // },
                  //   child: CarouselSlider(
                  //     items: imageList.map((item)=>Image.asset(item[
                  //       'image_path'],
                  //       fit: BoxFit.cover,
                  //       width: double.infinity,
                  //     ),
                  //   ).toList(),
                  //     carouselController: carouselController,
                  //     options: CarouselOptions(
                  //       scrollPhysics: BouncingScrollPhysics(),
                  //       autoPlay: true,
                  //       aspectRatio: 2,
                  //       viewportFraction: 1,
                  //       onPageChanged: (index, reason){
                  //         setState(() {
                  //           currentIndex=index;
                  //         });
                  //       },
                  //     ),
                  //   )
                  // ),
                  //   ],
                  //       ),

                  SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hello, $LoggerUsername !',
                        style: TextStyle(
                          color: Color(0xFF000000),
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontSize: MediaQuery.of(context).size.width * 0.057,
                          fontWeight: FontWeight.w600,

                        ),
                      ),
                      // Text(firebaseToken),
                      //
                      Image.asset(bell,height: 35,width: 35,),
                      // Container(
                      //   height: 50,
                      //   width: 50,// Add padding of 10px
                      //   decoration: BoxDecoration(
                      //     color:  Color(0xFFE2E5F4), // Set background color to red
                      //     borderRadius: BorderRadius.circular(18), // Set border radius
                      //   ),
                      //   child: IconButton(
                      //     icon: Icon(Icons.notifications_none_rounded,
                      //         size: 20, color: Color(0xFF301C93)),
                      //     onPressed: () {},
                      //   ),
                      // )
                    ],
                  ),

                  // SizedBox(height: 2),
                  // Text(
                  //   'SYSWASH',
                  //   style: TextStyle(
                  //       fontFamily: GoogleFonts.openSans().fontFamily,
                  //       fontSize: 24,
                  //       fontWeight: FontWeight.bold,
                  //       color: Color(0xFF301C93)),
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  // Stack(
                  //   children: [
                  //     InkWell(
                  //         onTap: () {
                  //           print(currentIndex);
                  //         },
                  //         child: CarouselSlider(
                  //           items: imageList
                  //               .map(
                  //                 (item) => Image.asset(
                  //                   item['image_path'],
                  //                   fit: BoxFit.cover,
                  //                   width: double.infinity,
                  //                 ),
                  //               )
                  //               .toList(),
                  //           carouselController: carouselController,
                  //           options: CarouselOptions(
                  //             scrollPhysics: BouncingScrollPhysics(),
                  //             autoPlay: true,
                  //             aspectRatio: 2,
                  //             viewportFraction: 1,
                  //             onPageChanged: (index, reason) {
                  //               setState(() {
                  //                 currentIndex = index;
                  //               });
                  //             },
                  //           ),
                  //         )),
                  //   ],
                  // ),
                  // dividerH(),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Flexible(
                  //       child: Card(
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(25.0),
                  //         ),
                  //         child: Container(
                  //           width: MediaQuery.of(context).size.width * 0.5,
                  //           height: MediaQuery.of(context).size.height * 0.14,
                  //           decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(20.0),
                  //             color: Colors.orange,
                  //           ),
                  //           child: Stack(
                  //             children: [
                  //               // Icon in top left corner
                  //               const Positioned(
                  //                 top: 8,
                  //                 left: 8,
                  //                 child: Icon(
                  //                   Icons.delivery_dining,
                  //                   color: Colors.white,
                  //                   size: 50,
                  //                 ),
                  //               ),
                  //               // Text in the card (example)
                  //               const Positioned(
                  //                 bottom: 20,
                  //                 left: 20,
                  //                 child: Text(
                  //                   'Pickup',
                  //                   style: TextStyle(
                  //                       fontSize: 18,
                  //                       color: Colors.white,
                  //                       fontWeight: FontWeight.bold),
                  //                 ),
                  //               ),
                  //               Positioned(
                  //                 bottom: 15,
                  //                 right: 20,
                  //                 child: CircleAvatar(
                  //                     radius: 20.0,
                  //                     backgroundColor: Colors.white,
                  //                     child: Text(
                  //                       pickupitemCount,
                  //                       style: TextStyle(
                  //                           color: Colors.orange,
                  //                           fontSize: 14,
                  //                           fontWeight: FontWeight.bold),
                  //                     )),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     Flexible(
                  //       child: Card(
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(25.0),
                  //         ),
                  //         child: Container(
                  //           width: MediaQuery.of(context).size.width * 0.5,
                  //           height: MediaQuery.of(context).size.height * 0.14,
                  //           decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(20.0),
                  //             color: Colors.deepPurpleAccent,
                  //           ),
                  //           child: Stack(
                  //             children: [
                  //               // Icon in top left corner
                  //               Positioned(
                  //                 top: 8,
                  //                 left: 8,
                  //                 child: Icon(
                  //                   Icons.shopping_bag,
                  //                   color: Colors.white,
                  //                   size: 50,
                  //                 ),
                  //               ),
                  //               // Text in the card (example)
                  //               Positioned(
                  //                 bottom: 20,
                  //                 left: 20,
                  //                 child: Text(
                  //                   'Delivery',
                  //                   style: TextStyle(
                  //                       fontSize: 18,
                  //                       color: Colors.white,
                  //                       fontWeight: FontWeight.bold),
                  //                 ),
                  //               ),
                  //               Positioned(
                  //                 bottom: 15,
                  //                 right: 20,
                  //                 child: CircleAvatar(
                  //                     radius: 20.0,
                  //                     backgroundColor: Colors.white,
                  //                     child: Text(
                  //                       deliveritemCount,
                  //                       style: TextStyle(
                  //                           color: Colors.deepPurpleAccent,
                  //                           fontSize: 14,
                  //                           fontWeight: FontWeight.bold),
                  //                     )),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  //
                  // dividerLH(),
                  // SizedBox(
                  //   height: 130,
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       Navigator.pushNamed(context, "/pickupOrderListing");
                  //     },
                  //     child: Container(
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       child: Stack(
                  //         fit: StackFit.expand,
                  //         children: [
                  //           // Image
                  //           Container(
                  //             decoration: BoxDecoration(
                  //               image: DecorationImage(
                  //                 image: AssetImage(homeImagePick),
                  //                 fit: BoxFit.cover,
                  //               ),
                  //               borderRadius: BorderRadius.circular(12),
                  //             ),
                  //           ),
                  //           // Gradient
                  //           Container(
                  //             decoration: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(12),
                  //               gradient: LinearGradient(
                  //                 begin: Alignment.topCenter,
                  //                 end: Alignment.bottomCenter,
                  //                 colors: [
                  //                   Colors.transparent,
                  //                   Colors.black.withOpacity(0.8),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //           Container(
                  //             padding: EdgeInsets.all(20),
                  //             child: Row(
                  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //               crossAxisAlignment: CrossAxisAlignment.end,
                  //               children: [
                  //                 Text(
                  //                   'Pickup Order',
                  //                   style: TextStyle(
                  //                     fontFamily:
                  //                         GoogleFonts.openSans().fontFamily,
                  //                     fontSize: 25,
                  //                     fontWeight: FontWeight.bold,
                  //                     color: Colors.white,
                  //                   ),
                  //                 ),
                  //                 Icon(Icons.arrow_forward, color: Colors.white),
                  //               ],
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // dividerH(),
                  // SizedBox(
                  //   height: 130,
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       Navigator.pushNamed(context, "/delivery");
                  //     },
                  //     child: Container(
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       child: Stack(
                  //         fit: StackFit.expand,
                  //         children: [
                  //           // Image
                  //           Container(
                  //             decoration: BoxDecoration(
                  //               image: DecorationImage(
                  //                 image: AssetImage(homeImageDelivery),
                  //                 fit: BoxFit.cover,
                  //               ),
                  //               borderRadius: BorderRadius.circular(12),
                  //             ),
                  //           ),
                  //           // Gradient
                  //           Container(
                  //             decoration: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(12),
                  //               gradient: LinearGradient(
                  //                 begin: Alignment.topCenter,
                  //                 end: Alignment.bottomCenter,
                  //                 colors: [
                  //                   Colors.transparent,
                  //                   Colors.black.withOpacity(0.8),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //           // Content
                  //           Container(
                  //             padding: EdgeInsets.all(20),
                  //             child: Row(
                  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //               crossAxisAlignment: CrossAxisAlignment.end,
                  //               children: [
                  //                 Text(
                  //                   'Delivery Order',
                  //                   style: TextStyle(
                  //                     fontFamily:
                  //                         GoogleFonts.openSans().fontFamily,
                  //                     fontSize: 25,
                  //                     fontWeight: FontWeight.bold,
                  //                     color: Colors.white,
                  //                   ),
                  //                 ),
                  //                 Icon(Icons.arrow_forward, color: Colors.white),
                  //               ],
                  //             ),
                  //           ),
                  //
                  //           // TextField(
                  //           //   controller: TextEditingController(text: firebaseToken),
                  //           //   decoration: InputDecoration(
                  //           //     labelText: 'Enter some text',
                  //           //     border: OutlineInputBorder(),
                  //           //   ),
                  //           // ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // new design
                  Stack(
                    children: [
                      InkWell(
                          onTap: () {
                            print(currentIndex);
                          },
                          child: CarouselSlider(
                            items: imageList.map((item) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10.0), // Set the border radius here
                                child: Image.asset(
                                  item['image_path'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              );
                            }).toList(),
                            // items: imageList
                            //     .map(
                            //       (item) => Image.asset(
                            //     item['image_path'],
                            //     fit: BoxFit.cover,
                            //     width: double.infinity,
                            //   ),
                            // )
                            //     .toList(),
                            carouselController: carouselController,
                            options: CarouselOptions(
                              scrollPhysics: BouncingScrollPhysics(),
                              autoPlay: true,
                              aspectRatio: 2,
                              viewportFraction: 1,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  currentIndex = index;
                                });
                              },
                            ),

                          )



                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: imageList.asMap().entries.map((entry) {
                              return GestureDetector(
                                onTap: () => carouselController.animateToPage(entry.key),
                                child: Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.white)
                                        .withOpacity(currentIndex == entry.key ? 0.9 : 0.4),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),


                      // Positioned(
                      //   left: 155,
                      //   bottom: 10,
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: imageList.asMap().entries.map((entry) {
                      //       return GestureDetector(
                      //         onTap: () => carouselController.animateToPage(entry.key),
                      //         child: Container(
                      //           width: 8.0,
                      //           height: 8.0,
                      //           margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      //           decoration: BoxDecoration(
                      //             shape: BoxShape.circle,
                      //             color: (Theme.of(context).brightness == Brightness.dark
                      //                 ? Colors.white
                      //                 : Colors.white)
                      //                 .withOpacity(currentIndex == entry.key ? 0.9 : 0.4),
                      //           ),
                      //         ),
                      //       );
                      //     }).toList(),
                      //   ),
                      // ),
                    ],
                  ),

                  //
                  // Stack(
                  //   children: [
                  //     InkWell(
                  //         onTap: () {
                  //           print(currentIndex);
                  //         },
                  //         child: CarouselSlider(
                  //
                  //           items: imageList
                  //               .map(
                  //                 (item) => Image.asset(
                  //               item['image_path'],
                  //               fit: BoxFit.cover,
                  //               width: double.infinity,
                  //             ),
                  //           )
                  //               .toList(),
                  //           carouselController: carouselController,
                  //           options: CarouselOptions(
                  //             scrollPhysics: BouncingScrollPhysics(),
                  //             autoPlay: true,
                  //             aspectRatio: 2,
                  //             viewportFraction: 1,
                  //             onPageChanged: (index, reason) {
                  //               setState(() {
                  //                 currentIndex = index;
                  //               });
                  //             },
                  //           ),
                  //
                  //         ),
                  //
                  //
                  //       ),
                  //   ],
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.height * 0.13,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Color(0xFF68188B),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$orderTotalCount',
                                    style: TextStyle(
                                      fontFamily:GoogleFonts.dmSans().fontFamily,
                                      fontSize: 26,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Completed Order',
                                    style: TextStyle(
                                      fontFamily:GoogleFonts.dmSans().fontFamily,
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, "/pickupOrderListing");
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.7,
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: Color(0xFF5F02E7),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'PICKUP ORDER',
                                          style: TextStyle(
                                            fontFamily:GoogleFonts.dmSans().fontFamily,
                                            fontSize: MediaQuery.of(context).size.width * 0.028,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.1,
                                        ),
                                        Icon(Icons.arrow_forward, color: Colors.white, size: 24),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

// SizedBox(height: 5), // Space between the two cards

                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, "/delivery");
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.7,
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: Color(0xFFF38305),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'DELIVERY ORDER',
                                          style: TextStyle(
                                            fontFamily:GoogleFonts.dmSans().fontFamily,
                                            fontSize: MediaQuery.of(context).size.width * 0.028,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.08,
                                        ),
                                        Icon(Icons.arrow_forward, color: Colors.white, size: 24),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),


                  SizedBox(
                    height: 350,
                    child: DefaultTabController(
                      length: 3,
                      child: Column(
                        // Wrap the entire content in Column
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: [
                                // SizedBox(width: 150,),
                                Text(
                                  'Latest Orders',
                                  style: TextStyle(
                                    fontFamily:GoogleFonts.poppins().fontFamily,
                                    fontSize: MediaQuery.of(context).size.width * 0.035,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                 SizedBox(width: 50,),
                                // Expanded(
                                //   child: Text(
                                //     'Latest Orders',
                                //     style: TextStyle(
                                //       fontFamily:GoogleFonts.poppins().fontFamily,
                                //       fontSize: 16,
                                //       fontWeight: FontWeight.w500,
                                //     ),
                                //   ),
                                // ),
                                Expanded(
                                  child: TabBar(
                                    labelColor: Colors.white,
                                    unselectedLabelColor: Colors.black,
                                    indicatorColor: Colors.white,
                                    labelStyle: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.024,
                                        fontWeight: FontWeight.bold),
                                    unselectedLabelStyle: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.024,),
                                    indicator: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5), // Adjust as needed
                                        color: Color(0xFF5D5FEF)
                                    ),

                                    tabs: [
                                      Container(
                                        height: 20,
                                        child:  Tab(text: 'All'),),
                                      Container(
                                        height: 20,
                                        child:   Tab(text: 'Pickup'),),
                                      Container(
                                        height: 20,
                                        child:  Tab(text: 'Delivery'),),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                // All Orders List


                                ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: allOrders.length,
                                  itemBuilder: (context, index) {
                                    if (allOrders[index]['this'] == 'pickup') {
                                      // Ensure index is valid
                                      if (index < pickupOrders.length) {
                                        return Card(
                                          elevation: 0,
                                            color: Color(0xFFF9F9F9),
                                          child: ListTile(

                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                "/customer_details",
                                                arguments: {
                                                  'pickupassgnId': pickupOrders[index]['pickupassgnId'].toString(),
                                                  'pickupCustomerId':pickupOrders[index]['pickupCustomerId'].toString(),
                                                },
                                              );
                                            },
                                            leading: Image.asset(pick,height: 35,width: 35,),


                                            title: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(pickupOrders[index]['pickupCustomerName'],style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.040,
                                                    fontFamily: GoogleFonts.poppins().fontFamily,fontWeight: FontWeight.w500),),
                                                Text(pickupOrders[index]['pickupCustomerArea'],style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.040,
                                                fontFamily: GoogleFonts.poppins().fontFamily,fontWeight: FontWeight.w400)),
                                              ],
                                            ),
                                            subtitle: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFF38305),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    'Pickup',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: MediaQuery.of(context).size.width * 0.025,
                                                      fontFamily: GoogleFonts.poppins().fontFamily
                                                    ),
                                                  ),
                                                ),
                                                Text(pickupOrders[index]['pickupDate'],style: TextStyle( color: Color(0xFFEB0000), fontSize:MediaQuery.of(context).size.width * 0.030,
                                                    fontFamily: GoogleFonts.poppins().fontFamily,fontWeight: FontWeight.w400),),
                                              ],
                                            ),
                                          ),
                                        );
                                      } else {
                                        // Handle the case where index is out of range
                                        return Container(); // or any other placeholder
                                      }
                                    } else if (allOrders[index]['this'] == 'delivery') {
                                      // Ensure index is valid
                                      if (index < deliveryOrders.length) {
                                        return Card(
                                          elevation: 0,
                                          color: Color(0xFFF9F9F9),

                                          child: ListTile(


                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context,
                                                  "/customDetailsDelivery",
                                                  arguments:{
                                                    'deliveryInvoiceNo' : deliveryOrders[index]['deliveryInvoiceNo'].toString() ,
                                                    'deliveryCustomerId' : deliveryOrders[index]['deliveryCustomerId'].toString(),


                                                  }


                                              );
                                            },
                                            leading: Image.asset(wash,height: 35,width: 35,),

                                            title: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(deliveryOrders[index]['deliveryCustomerName'],style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.040,
                                                    fontFamily: GoogleFonts.poppins().fontFamily,fontWeight: FontWeight.w500),),
                                                Text(deliveryOrders[index]['deliveryCustomerArea'],style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.040,
                                                    fontFamily: GoogleFonts.poppins().fontFamily,fontWeight: FontWeight.w400),),
                                              ],
                                            ),
                                            subtitle: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF27AE60),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    'Delivery',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize:  MediaQuery.of(context).size.width * 0.025,
                                                        fontFamily: GoogleFonts.poppins().fontFamily
                                                      // fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Text(deliveryOrders[index]['deliveryDate'],style: TextStyle( color: Color(0xFFEB0000), fontSize: MediaQuery.of(context).size.width * 0.030,
                                                    fontFamily: GoogleFonts.poppins().fontFamily,fontWeight: FontWeight.w400), ),
                                              ],
                                            ),
                                          ),

                                        );
//                                         return Card(
//                                           elevation: 0,
//                                           color: Color(0xFFF9F9F9),
//
//                                             child: ListTile(
// contentPadding: EdgeInsets.zero,
//
//                                               onTap: () {
//                                                 Navigator.pushNamed(
//                                                     context,
//                                                     "/customDetailsDelivery",
//                                                     arguments:{
//                                                       'deliveryInvoiceNo' : deliveryOrders[index]['deliveryInvoiceNo'].toString() ,
//                                                       'deliveryCustomerId' : deliveryOrders[index]['deliveryCustomerId'].toString(),
//
//
//                                                     }
//
//
//                                                 );
//                                               },
//                                               leading: Image.asset(wash,height: 25,width: 25,),
//
//                                               title: Row(
//                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                 children: [
//                                                   Text(deliveryOrders[index]['deliveryCustomerName'],style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035,
//                                                       fontFamily: GoogleFonts.poppins().fontFamily,fontWeight: FontWeight.w500),),
//                                                   Text(deliveryOrders[index]['deliveryCustomerArea'],style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035,
//                                                   fontFamily: GoogleFonts.poppins().fontFamily,fontWeight: FontWeight.w400),),
//                                                 ],
//                                               ),
//                                               subtitle: Row(
//                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                 children: [
//                                                   Container(
//                                                     padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
//                                                     decoration: BoxDecoration(
//                                                       color: Color(0xFF27AE60),
//                                                       borderRadius: BorderRadius.circular(6),
//                                                     ),
//                                                     child: Text(
//                                                       'Delivery',
//                                                       style: TextStyle(
//                                                         color: Colors.white,
//                                                           fontWeight: FontWeight.w500,
//                                                           fontSize:  MediaQuery.of(context).size.width * 0.025,
//                                                           fontFamily: GoogleFonts.poppins().fontFamily
//                                                         // fontWeight: FontWeight.bold,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   Text(deliveryOrders[index]['deliveryDate'],style: TextStyle( color: Color(0xFFEB0000), fontSize: MediaQuery.of(context).size.width * 0.030,
//                                                       fontFamily: GoogleFonts.poppins().fontFamily,fontWeight: FontWeight.w400), ),
//                                                 ],
//                                               ),
//                                             ),
//
//                                         );
                                      } else {
                                        // Handle the case where index is out of range
                                        return Container(); // or any other placeholder
                                      }
                                    } else {
                                      // Handle the case where 'this' is neither 'pickup' nor 'delivery'
                                      return Container(); // or any other placeholder
                                    }
                                  },
                                ),







                                // Pickup Orders List
                                ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: pickupOrders.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      elevation: 0,
                                      color: Color(0xFFF9F9F9),
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            "/customer_details",
                                            arguments: {
                                              'pickupassgnId': pickupOrders[index]['pickupassgnId'].toString(),
                                              'pickupCustomerId':pickupOrders[index]['pickupCustomerId'].toString(),
                                            },
                                          );
                                        },
                                        leading: Image.asset(pick,height: 35,width: 35,),

                                        title: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(pickupOrders[index]
                                            ['pickupCustomerName'],style: TextStyle(fontSize: 14,
                                                fontFamily: GoogleFonts.poppins().fontFamily,fontWeight: FontWeight.w500),),
                                            Text(pickupOrders[index]
                                            ['pickupCustomerArea'],style: TextStyle(fontSize: 14,
                                                fontFamily: GoogleFonts.poppins().fontFamily,fontWeight: FontWeight.w400),),
                                          ],
                                        ),
                                        subtitle: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(''),
                                            Text(
                                                pickupOrders[index]['pickupDate'],style: TextStyle( color: Color(0xFFEB0000),fontSize: 12,
                                                fontFamily: GoogleFonts.poppins().fontFamily,fontWeight: FontWeight.w400),),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Delivery Orders List
                                ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: deliveryOrders.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      elevation: 0,
                                      color: Color(0xFFF9F9F9),
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context,
                                              "/customDetailsDelivery",
                                              arguments:{
                                                'deliveryInvoiceNo' : deliveryOrders[index]['deliveryInvoiceNo'].toString() ,
                                                'deliveryCustomerId' : deliveryOrders[index]['deliveryCustomerId'].toString(),

                                              }
                                          );
                                        },
                                        leading: Image.asset(wash,height: 35,width: 35,),

                                        title: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(deliveryOrders[index]['deliveryCustomerName'],style: TextStyle(fontSize: 14,
                                                fontFamily: GoogleFonts.poppins().fontFamily,fontWeight: FontWeight.w500),),
                                            Text(deliveryOrders[index]['deliveryCustomerArea'],style: TextStyle(fontSize: 14,
                                                fontFamily: GoogleFonts.poppins().fontFamily,fontWeight: FontWeight.w400),),
                                          ],
                                        ),
                                        subtitle: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(''),
                                            Text(
                                                deliveryOrders[index]['deliveryDate'],style: TextStyle( color: Color(0xFFEB0000),fontSize: 12,
                                                fontFamily: GoogleFonts.poppins().fontFamily,fontWeight: FontWeight.w400), ),
                                          ],
                                        ),
                                      ),




                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
        color: Color(0xFF68188B),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
          // color: Color(0xFF68188B),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
            child: GNav(
              backgroundColor: Color(0xFF68188B),
              color: Colors.white,
              activeColor: Color(0xFF68188B), // Set active color to black
              tabBackgroundColor: Colors.white,
              gap: 8,
              padding: EdgeInsets.all(3),
              selectedIndex: _currentIndex,
              onTabChange: (index) {
                setState(() {
                  _currentIndex = index;

                });
              },
              tabs: [
                GButton(
                  icon: Icons.home_outlined,
                  text: "Home",
                  padding: EdgeInsets.all(3),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/dashHome');
                  },// Set padding to 3
                ),
                GButton(
                  icon: Icons.delivery_dining_outlined,
                  text: "Pickup",
                  padding: EdgeInsets.all(3),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/pickupOrderListing');
                  },// Set padding to 3
                ),
                GButton(
                  icon: Icons.how_to_vote_outlined,
                  text: "Delivery",
                  padding: EdgeInsets.all(3),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/delivery');
                  },// Set padding to 3
                ),
                GButton(
                  icon: Icons.av_timer,
                  text: "History",
                  padding: EdgeInsets.all(3),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/history');
                  },// Set padding to 3
                ),
                GButton(
                  icon: Icons.perm_identity,
                  text: "Profile",
                  padding: EdgeInsets.all(3),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/profile');
                  },// Set padding to 3
                ),
              ],
            ),
          ),
        ),

        // bottomNavigationBar: Container(
        //   color:Color(0xFF68188B) ,
        //   child: Padding(
        //     padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 20),
        //     child: GNav(
        //       backgroundColor: Color(0xFF68188B),
        //       color:Colors.white,
        //       activeColor:Colors.white,
        //       tabBackgroundColor:Colors.white,
        //       gap:8,
        //      onTabChange:(index){
        //         print(index);
        //      }
        //      Padding(padding: EdgeInsets.all(16)),
        //      tabs:[
        //        GButton(icon:Icons.home_outlined,text: "Home",),
        //        GButton(icon:Icons.delivery_dining_outlined,text: "Pickup",),
        //        GButton(icon:Icons.local_shipping_outlined,text: "Delivery",),
        //        GButton(icon:Icons.av_timer,text: "History",),
        //        GButton(icon:Icons.perm_identity,text: "Profile",),
        //
        //      ]
        //     ),


        // bottomNavigationBar: BottomNavigationBar(
        //   currentIndex: _currentIndex,
        //   onTap: _onItemTapped,
        //   type: BottomNavigationBarType.fixed,
        //   items: [
        //     BottomNavigationBarItem(
        //       icon: Icon(
        //         Icons.home,
        //       ),
        //       label: 'Home',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(
        //         Icons.car_crash,
        //       ),
        //       label: 'Pickup',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(
        //         Icons.car_crash,
        //       ),
        //       label: 'Delivery',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(
        //         Icons.compare_arrows,
        //       ),
        //       label: 'History',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(
        //         Icons.person,
        //       ),
        //       label: 'Me',
        //     ),
        //   ],
        //   selectedItemColor: Color(0xFF301C93),
        //   selectedFontSize: 12.0, // Adjust the font size for the selected item
        //   unselectedFontSize: 12.0, // Adjust the font size for unselected items
        //   iconSize: 26.0, // Adjust the icon size
        // ),
      ),
    );
  }

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _currentIndex = index;
  //   });
  //
  //   if (_currentIndex == 0) {
  //     Navigator.pushReplacementNamed(context, '/dashHome');
  //   } else if (_currentIndex == 1) {
  //     Navigator.pushReplacementNamed(context, "/pickupOrderListing");
  //   } else if (_currentIndex == 2) {
  //     Navigator.pushReplacementNamed(context, "/delivery");
  //   } else if (_currentIndex == 3) {
  //     Navigator.pushReplacementNamed(context, '/history');
  //   } else if (_currentIndex == 4) {
  //     Navigator.pushReplacementNamed(context, '/profile');
  //   }
  // }
}

// /new home page stop//////























// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:syswash/utils/app_constant.dart';
// import 'package:http/http.dart' as http;
// import '../../../utils/app_sp.dart';
// import '../../../utils/app_url.dart';
//
// import 'package:carousel_slider/carousel_slider.dart';
//
// class DashBoardScreen extends StatefulWidget {
//   const DashBoardScreen({super.key});
//
//   @override
//   State<DashBoardScreen> createState() => _DashBoardScreenState();
// }
//
// class _DashBoardScreenState extends State<DashBoardScreen> {
//   int _currentIndex = 0;
//   String tokenID = '';
//   String userToken = "";
//   String companyCode = "";
//   String userID = "";
//   String pickupitemCount = '';
//   String deliveritemCount = '';
//
//   String firebaseToken = "";
//
//   String driverID = "";
//
//   String refreshtoken = "";
//
//   String LoggerUsername = "";
//
//   String orderTotalCount = '0';
//
//   final List<String> allOrders = [
//     'All Order 1',
//     'All Order 2',
//     'All Order 3',
//     'All Order 4',
//     'All Order 5',
//   ];
//
//   List<Map<String, dynamic>> pickupOrders = [];
//
//   List<Map<String, dynamic>> deliveryOrders = [];
//
//
//   // final List<String> deliveryOrders = [
//   //   'Delivery Order 1',
//   //   'Delivery Order 2',
//   //   'Delivery Order 3',
//   //   'Delivery Order 4',
//   //   'Delivery Order 5',
//   // ];
//
//   @override
//   void initState() {
//     super.initState();
//     getUserToken();
//   }
//
//   Future<void> getUserToken() async {
//     AppSp appSp = AppSp();
//     userToken = await appSp.getToken();
//     companyCode = await appSp.getCompanyCode();
//     userID = await appSp.getUserID();
//
//     LoggerUsername = await appSp.getUserName();
//
//     fetchOrderListingData(userToken, companyCode, userID);
//     fetchDeliverListingData(userToken, companyCode, userID);
//
//     fetchcountoftheTotalorder(userToken, companyCode, userID);
//
//
//     firebaseToken = await appSp.getFirebasetoken();
//     passFirebaseToken(firebaseToken, userToken, userID);
//
//     print('-------------------78563465836503457345875438654386304956345');
//     refreshtoken = await appSp.getRefreshtoken();
//     print(refreshtoken);
//     passRefreshToken(refreshtoken);
//     if (refreshtoken == '') {
//       AppSp().setIsLogged(false);
//
//       Navigator.pushReplacementNamed(context, '/login');
//     }
//
//     print('-------------------78563465836503457345875438654386304956345');
//
//     print("this is below in new data");
//
//
//     print("end this data");
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   void passRefreshToken(String refreshtoken) async {
//     try {
//       final response = await http.post(
//         Uri.parse('https://be.syswash.net/api/token/refresh/'),
//         body: {'refresh': refreshtoken},
//       );
//
//       if (response.statusCode == 200) {
//         Map<String, dynamic> data = json.decode(response.body);
//         String? accessToken = data['access'];
//         if (accessToken != null) {
//           setState(() {
//             AppSp().setToken(accessToken);
//             userToken = accessToken.toString();
//             print('Access token refreshed successfully: $userToken');
//           });
//         } else {
//           print('Error: No access token returned');
//           AppSp().setIsLogged(false);
//
//           Navigator.pushReplacementNamed(context, '/login');
//         }
//       } else {
//         print(
//             'Error: Failed to refresh token, status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         AppSp().setIsLogged(false);
//
//         Navigator.pushReplacementNamed(context, '/login');
//       }
//     } catch (e) {
//       print('Exception caught: $e');
//       AppSp().setIsLogged(false);
//
//       Navigator.pushReplacementNamed(context, '/login');
//     }
//   }
//
//   void passFirebaseToken(
//       String firebaseToken, String userToken, String userID) async {
//     final response = await http.post(
//       Uri.parse('${AppUrls.driverdevicetoken}${AppUrls.code_main}$companyCode'),
//       headers: {
//         "Accept": "application/json",
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $userToken"
//       },
//       body: jsonEncode({
//         "driver_id": userID,
//         "device_token": firebaseToken,
//       }),
//     );
//     print('<<<>>>>>>>firebase');
//     print(firebaseToken);
//     if (response.statusCode == 200) {
//       print(response.body);
//       print('Passed SucessFully');
//     } else {
//       print("Failed to fetch data: ${response.body}");
//     }
//   }
//
//
//
//   void fetchcountoftheTotalorder(
//       String userToken, String companyCode, String userID) async {
//     print('${AppUrls.history}$userID${AppUrls.code_main}$companyCode');
//     final response = await http.get(
//         Uri.parse(
//             '${AppUrls.history}$userID${AppUrls.code_main}$companyCode'),
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer $userToken"
//         });
//
//     print('get the respond');
//     if (response.statusCode == 200) {
//
//       final data = json.decode(response.body);
//
//       int pickupCount = data['pickup'].length;
//       int deliveryCount = data['delivery'].length;
//       int totalCount = pickupCount + deliveryCount;
//
//       setState(() {
//         print("Pickup Orders: $pickupCount");
//         print("Delivery Orders: $deliveryCount");
//         print("Total Orders: $totalCount");
//
//         orderTotalCount = totalCount.toString();
//       });
//     } else {
//       print("Failed to fetch data: ${response.statusCode}");
//     }
//   }
//
//
//
//
//
//
//
//
//
//   void fetchOrderListingData(
//       String userToken, String companyCode, String userID) async {
//     final response = await http.get(
//         Uri.parse(
//             '${AppUrls.pickuplist}$userID${AppUrls.code_main}$companyCode'),
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer $userToken"
//         });
//     if (response.statusCode == 200) {
//       List<dynamic> data = jsonDecode(response.body);
//
//       print("data res[pomse");
//       print(response.body);
//
//       // Filter out orders where pickupstatus is 'Received'
//       List<dynamic> filteredData =
//       data.where((item) => item['pickupstatus'] != 'Received').toList();
//
//       // Sort the data by pickupDate in descending order
//       filteredData.sort((a, b) => b['pickupDate'].compareTo(a['pickupDate']));
//
//       // Take the latest 5 orders
//       List<dynamic> latest5Orders = filteredData.take(5).toList();
//
//       List<Map<String, dynamic>> newPickupOrders =
//       latest5Orders.map<Map<String, dynamic>>((item) {
//         return {
//           'pickupassgnId': item['pickupassgnId'],
//           'pickupDate': item['pickupDate'],
//           'pickupCustomerName': item['pickupCustomerName'],
//           'pickupCustomerArea': item['pickupCustomerArea'],
//           'pickupOrderId': item['pickupOrderId']
//         };
//       }).toList();
//
//       int itemCount = data.length;
//       setState(() {
//         pickupitemCount = itemCount.toString();
//
//         pickupOrders = newPickupOrders;
//
//         print(pickupOrders);
//       });
//     } else {
//       print("Failed to fetch data: ${response.statusCode}");
//     }
//   }
//
//   void fetchDeliverListingData(
//       String userToken, String companyCode, String userID) async {
//     final response = await http.get(
//         Uri.parse(
//             '${AppUrls.deliverylist}$userID${AppUrls.code_main}$companyCode'),
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer $userToken"
//         });
//     if (response.statusCode == 200) {
//       List<dynamic> data = jsonDecode(response.body);
//
//       print("drliveryyyyyyy");
//       print(response.body);
//
//       List<dynamic> filteredData = data.where((item) => item['status'] != 'Delivered').toList();
//
//       // Sort the data by deliveryDate in descending order
//       filteredData.sort((a, b) {
//         DateTime dateA = DateTime.parse(a['deliveryDate']);
//         DateTime dateB = DateTime.parse(b['deliveryDate']);
//         return dateB.compareTo(dateA);
//       });
//
//       // Take the latest 5 delivered items
//       List<dynamic> latest5Deliveries = filteredData.take(5).toList();
//
//       // Extract the required fields
//       List<Map<String, dynamic>> newDeliveryOrders = latest5Deliveries.map<Map<String, dynamic>>((item) {
//         return {
//           'deliveryassgnId': item['deliveryassgnId'],
//           'deliveryDate': item['deliveryDate'],
//           'deliveryCustomerName': item['deliveryCustomerName'],
//           'deliveryCustomerArea': item['deliveryCustomerArea'],
//           'deliveryInvoiceNo': item['deliveryInvoiceNo']
//         };
//       }).toList();
//
//
//       int itemCount = data.length;
//       setState(() {
//         deliveritemCount = itemCount.toString();
//         deliveryOrders = newDeliveryOrders;
//       });
//     } else {
//       print("Failed to fetch data: ${response.statusCode}");
//     }
//   }
//
//   //slider
//   List imageList = [
//     {"id": 1, "image_path": 'assets/slider/sys.png'},
//     {"id": 2, "image_path": 'assets/slider/sys.png'},
//     {"id": 3, "image_path": 'assets/slider/sys.png'},
//   ];
//   final CarouselController carouselController = CarouselController();
//   int currentIndex = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         return await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text(
//               'Are you sure...?',
//             ),
//             content: const Text(
//               'Do you want to exit from the App',
//             ),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(false);
//                   SystemNavigator.pop();
//                   Future.delayed(const Duration(milliseconds: 1000), () {
//                     SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//                   });
//                 },
//                 child: const Text(
//                   "YES",
//                   style: TextStyle(
//                     color: Colors.red,
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(false);
//                 },
//                 child: const Text(
//                   "NO",
//                   style: TextStyle(
//                     color: Color(0xFF301C93),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//       child: Scaffold(
//         backgroundColor: Color(0xFFEFEEF3),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 //       Stack(children: [
//                 //         InkWell(
//                 //       onTap: (){
//                 //         print(currentIndex);
//                 // },
//                 //   child: CarouselSlider(
//                 //     items: imageList.map((item)=>Image.asset(item[
//                 //       'image_path'],
//                 //       fit: BoxFit.cover,
//                 //       width: double.infinity,
//                 //     ),
//                 //   ).toList(),
//                 //     carouselController: carouselController,
//                 //     options: CarouselOptions(
//                 //       scrollPhysics: BouncingScrollPhysics(),
//                 //       autoPlay: true,
//                 //       aspectRatio: 2,
//                 //       viewportFraction: 1,
//                 //       onPageChanged: (index, reason){
//                 //         setState(() {
//                 //           currentIndex=index;
//                 //         });
//                 //       },
//                 //     ),
//                 //   )
//                 // ),
//                 //   ],
//                 //       ),
//
//                 SizedBox(height: 30),
//
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '$LoggerUsername',
//                       style: TextStyle(
//                         color: Color(0xFF8C8686),
//                         fontFamily: GoogleFonts.openSans().fontFamily,
//                         fontSize: 20,
//                       ),
//                     ),
//                     // Text(firebaseToken),
//                     //
//
//                     IconButton(
//                       icon: Icon(Icons.notifications_outlined,
//                           size: 45, color: Color(0xFF301C93)),
//                       onPressed: () {},
//                     ),
//                   ],
//                 ),
//
//                 SizedBox(height: 2),
//                 Text(
//                   'SYSWASH',
//                   style: TextStyle(
//                       fontFamily: GoogleFonts.openSans().fontFamily,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF301C93)),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 // Stack(
//                 //   children: [
//                 //     InkWell(
//                 //         onTap: () {
//                 //           print(currentIndex);
//                 //         },
//                 //         child: CarouselSlider(
//                 //           items: imageList
//                 //               .map(
//                 //                 (item) => Image.asset(
//                 //                   item['image_path'],
//                 //                   fit: BoxFit.cover,
//                 //                   width: double.infinity,
//                 //                 ),
//                 //               )
//                 //               .toList(),
//                 //           carouselController: carouselController,
//                 //           options: CarouselOptions(
//                 //             scrollPhysics: BouncingScrollPhysics(),
//                 //             autoPlay: true,
//                 //             aspectRatio: 2,
//                 //             viewportFraction: 1,
//                 //             onPageChanged: (index, reason) {
//                 //               setState(() {
//                 //                 currentIndex = index;
//                 //               });
//                 //             },
//                 //           ),
//                 //         )),
//                 //   ],
//                 // ),
//                 // dividerH(),
//                 // Row(
//                 //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 //   children: [
//                 //     Flexible(
//                 //       child: Card(
//                 //         shape: RoundedRectangleBorder(
//                 //           borderRadius: BorderRadius.circular(25.0),
//                 //         ),
//                 //         child: Container(
//                 //           width: MediaQuery.of(context).size.width * 0.5,
//                 //           height: MediaQuery.of(context).size.height * 0.14,
//                 //           decoration: BoxDecoration(
//                 //             borderRadius: BorderRadius.circular(20.0),
//                 //             color: Colors.orange,
//                 //           ),
//                 //           child: Stack(
//                 //             children: [
//                 //               // Icon in top left corner
//                 //               const Positioned(
//                 //                 top: 8,
//                 //                 left: 8,
//                 //                 child: Icon(
//                 //                   Icons.delivery_dining,
//                 //                   color: Colors.white,
//                 //                   size: 50,
//                 //                 ),
//                 //               ),
//                 //               // Text in the card (example)
//                 //               const Positioned(
//                 //                 bottom: 20,
//                 //                 left: 20,
//                 //                 child: Text(
//                 //                   'Pickup',
//                 //                   style: TextStyle(
//                 //                       fontSize: 18,
//                 //                       color: Colors.white,
//                 //                       fontWeight: FontWeight.bold),
//                 //                 ),
//                 //               ),
//                 //               Positioned(
//                 //                 bottom: 15,
//                 //                 right: 20,
//                 //                 child: CircleAvatar(
//                 //                     radius: 20.0,
//                 //                     backgroundColor: Colors.white,
//                 //                     child: Text(
//                 //                       pickupitemCount,
//                 //                       style: TextStyle(
//                 //                           color: Colors.orange,
//                 //                           fontSize: 14,
//                 //                           fontWeight: FontWeight.bold),
//                 //                     )),
//                 //               ),
//                 //             ],
//                 //           ),
//                 //         ),
//                 //       ),
//                 //     ),
//                 //     Flexible(
//                 //       child: Card(
//                 //         shape: RoundedRectangleBorder(
//                 //           borderRadius: BorderRadius.circular(25.0),
//                 //         ),
//                 //         child: Container(
//                 //           width: MediaQuery.of(context).size.width * 0.5,
//                 //           height: MediaQuery.of(context).size.height * 0.14,
//                 //           decoration: BoxDecoration(
//                 //             borderRadius: BorderRadius.circular(20.0),
//                 //             color: Colors.deepPurpleAccent,
//                 //           ),
//                 //           child: Stack(
//                 //             children: [
//                 //               // Icon in top left corner
//                 //               Positioned(
//                 //                 top: 8,
//                 //                 left: 8,
//                 //                 child: Icon(
//                 //                   Icons.shopping_bag,
//                 //                   color: Colors.white,
//                 //                   size: 50,
//                 //                 ),
//                 //               ),
//                 //               // Text in the card (example)
//                 //               Positioned(
//                 //                 bottom: 20,
//                 //                 left: 20,
//                 //                 child: Text(
//                 //                   'Delivery',
//                 //                   style: TextStyle(
//                 //                       fontSize: 18,
//                 //                       color: Colors.white,
//                 //                       fontWeight: FontWeight.bold),
//                 //                 ),
//                 //               ),
//                 //               Positioned(
//                 //                 bottom: 15,
//                 //                 right: 20,
//                 //                 child: CircleAvatar(
//                 //                     radius: 20.0,
//                 //                     backgroundColor: Colors.white,
//                 //                     child: Text(
//                 //                       deliveritemCount,
//                 //                       style: TextStyle(
//                 //                           color: Colors.deepPurpleAccent,
//                 //                           fontSize: 14,
//                 //                           fontWeight: FontWeight.bold),
//                 //                     )),
//                 //               ),
//                 //             ],
//                 //           ),
//                 //         ),
//                 //       ),
//                 //     ),
//                 //   ],
//                 // ),
//                 //
//                 // dividerLH(),
//                 // SizedBox(
//                 //   height: 130,
//                 //   child: GestureDetector(
//                 //     onTap: () {
//                 //       Navigator.pushNamed(context, "/pickupOrderListing");
//                 //     },
//                 //     child: Container(
//                 //       decoration: BoxDecoration(
//                 //         borderRadius: BorderRadius.circular(12),
//                 //       ),
//                 //       child: Stack(
//                 //         fit: StackFit.expand,
//                 //         children: [
//                 //           // Image
//                 //           Container(
//                 //             decoration: BoxDecoration(
//                 //               image: DecorationImage(
//                 //                 image: AssetImage(homeImagePick),
//                 //                 fit: BoxFit.cover,
//                 //               ),
//                 //               borderRadius: BorderRadius.circular(12),
//                 //             ),
//                 //           ),
//                 //           // Gradient
//                 //           Container(
//                 //             decoration: BoxDecoration(
//                 //               borderRadius: BorderRadius.circular(12),
//                 //               gradient: LinearGradient(
//                 //                 begin: Alignment.topCenter,
//                 //                 end: Alignment.bottomCenter,
//                 //                 colors: [
//                 //                   Colors.transparent,
//                 //                   Colors.black.withOpacity(0.8),
//                 //                 ],
//                 //               ),
//                 //             ),
//                 //           ),
//                 //           Container(
//                 //             padding: EdgeInsets.all(20),
//                 //             child: Row(
//                 //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 //               crossAxisAlignment: CrossAxisAlignment.end,
//                 //               children: [
//                 //                 Text(
//                 //                   'Pickup Order',
//                 //                   style: TextStyle(
//                 //                     fontFamily:
//                 //                         GoogleFonts.openSans().fontFamily,
//                 //                     fontSize: 25,
//                 //                     fontWeight: FontWeight.bold,
//                 //                     color: Colors.white,
//                 //                   ),
//                 //                 ),
//                 //                 Icon(Icons.arrow_forward, color: Colors.white),
//                 //               ],
//                 //             ),
//                 //           ),
//                 //         ],
//                 //       ),
//                 //     ),
//                 //   ),
//                 // ),
//                 // dividerH(),
//                 // SizedBox(
//                 //   height: 130,
//                 //   child: GestureDetector(
//                 //     onTap: () {
//                 //       Navigator.pushNamed(context, "/delivery");
//                 //     },
//                 //     child: Container(
//                 //       decoration: BoxDecoration(
//                 //         borderRadius: BorderRadius.circular(12),
//                 //       ),
//                 //       child: Stack(
//                 //         fit: StackFit.expand,
//                 //         children: [
//                 //           // Image
//                 //           Container(
//                 //             decoration: BoxDecoration(
//                 //               image: DecorationImage(
//                 //                 image: AssetImage(homeImageDelivery),
//                 //                 fit: BoxFit.cover,
//                 //               ),
//                 //               borderRadius: BorderRadius.circular(12),
//                 //             ),
//                 //           ),
//                 //           // Gradient
//                 //           Container(
//                 //             decoration: BoxDecoration(
//                 //               borderRadius: BorderRadius.circular(12),
//                 //               gradient: LinearGradient(
//                 //                 begin: Alignment.topCenter,
//                 //                 end: Alignment.bottomCenter,
//                 //                 colors: [
//                 //                   Colors.transparent,
//                 //                   Colors.black.withOpacity(0.8),
//                 //                 ],
//                 //               ),
//                 //             ),
//                 //           ),
//                 //           // Content
//                 //           Container(
//                 //             padding: EdgeInsets.all(20),
//                 //             child: Row(
//                 //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 //               crossAxisAlignment: CrossAxisAlignment.end,
//                 //               children: [
//                 //                 Text(
//                 //                   'Delivery Order',
//                 //                   style: TextStyle(
//                 //                     fontFamily:
//                 //                         GoogleFonts.openSans().fontFamily,
//                 //                     fontSize: 25,
//                 //                     fontWeight: FontWeight.bold,
//                 //                     color: Colors.white,
//                 //                   ),
//                 //                 ),
//                 //                 Icon(Icons.arrow_forward, color: Colors.white),
//                 //               ],
//                 //             ),
//                 //           ),
//                 //
//                 //           // TextField(
//                 //           //   controller: TextEditingController(text: firebaseToken),
//                 //           //   decoration: InputDecoration(
//                 //           //     labelText: 'Enter some text',
//                 //           //     border: OutlineInputBorder(),
//                 //           //   ),
//                 //           // ),
//                 //         ],
//                 //       ),
//                 //     ),
//                 //   ),
//                 // ),
//
//                 // new design
//
//
//                 Stack(
//                   children: [
//                     InkWell(
//                         onTap: () {
//                           print(currentIndex);
//                         },
//                         child: CarouselSlider(
//                           items: imageList
//                               .map(
//                                 (item) => Image.asset(
//                               item['image_path'],
//                               fit: BoxFit.cover,
//                               width: double.infinity,
//                             ),
//                           )
//                               .toList(),
//                           carouselController: carouselController,
//                           options: CarouselOptions(
//                             scrollPhysics: BouncingScrollPhysics(),
//                             autoPlay: true,
//                             aspectRatio: 2,
//                             viewportFraction: 1,
//                             onPageChanged: (index, reason) {
//                               setState(() {
//                                 currentIndex = index;
//                               });
//                             },
//                           ),
//                         )),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Flexible(
//                       child: Card(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         child: Container(
//                           width: MediaQuery.of(context).size.width * 0.5,
//                           height: MediaQuery.of(context).size.height * 0.13,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8.0),
//                             color: Colors.deepPurple,
//                           ),
//                           child: Stack(
//                             children: [ Positioned(
//                               bottom: 35,
//                               left: 22,
//                               child: Text(
//                                 '$orderTotalCount\nCompleted Order',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     Flexible(
//                       child: Column(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.pushNamed(context, "/pickupOrderListing");
//                             },
//                             child:Card(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               child: Container(
//                                 width: MediaQuery.of(context).size.width * 0.7,
//                                 height: MediaQuery.of(context).size.height * 0.06,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                   color: Colors.deepPurple,
//                                 ),
//                                 child: Stack(
//                                   children: [
//                                     Positioned(
//                                       bottom: 20,
//                                       left: 20,
//                                       child: Row(
//                                         mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(
//                                             'Pickup Order',
//                                             style: TextStyle(
//                                               fontSize: 15,
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             width: 35,
//                                           ),
//                                           Icon(Icons.arrow_forward,
//                                               color: Colors.white, size: 24),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           // SizedBox(height: 5), // Space between the two cards
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.pushNamed(context, "/delivery");
//                             },
//                             child:Card(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//
//                               child: Container(
//                                 width: MediaQuery.of(context).size.width * 0.7,
//                                 height: MediaQuery.of(context).size.height * 0.06,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                   color: Colors.orange,
//                                 ),
//                                 child: Stack(
//                                   children: [
//                                     Positioned(
//                                       bottom: 20,
//                                       left: 20,
//                                       child: Row(
//                                         mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(
//                                             'Delivery Order',
//                                             style: TextStyle(
//                                               fontSize: 15,
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             width: 35,
//                                           ),
//                                           Icon(Icons.arrow_forward,
//                                               color: Colors.white, size: 24),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 400,
//                   child: DefaultTabController(
//                     length: 3,
//                     child: Column(
//                       // Wrap the entire content in Column
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   'Latest Orders',
//                                   style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: TabBar(
//                                   labelColor: Colors.black,
//                                   unselectedLabelColor: Colors.grey,
//                                   indicatorColor: Colors.white,
//                                   labelStyle: TextStyle(
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold),
//                                   unselectedLabelStyle: TextStyle(fontSize: 10),
//                                   tabs: [
//                                     Tab(
//                                       text: 'All',
//                                     ),
//                                     Tab(text: 'Pickup'),
//                                     Tab(text: 'Delivery'),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           child: TabBarView(
//                             children: [
//                               // All Orders List
//                               ListView.builder(
//                                 itemCount: allOrders.length,
//                                 itemBuilder: (context, index) {
//                                   return Card(
//                                     child: ListTile(
//                                       title: Text(allOrders[index]),
//                                     ),
//                                   );
//                                 },
//                               ),
//                               // Pickup Orders List
//                               ListView.builder(
//                                 itemCount: pickupOrders.length,
//                                 itemBuilder: (context, index) {
//                                   return Card(
//                                     child: ListTile(
//                                       title: Row(
//                                         mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(pickupOrders[index]
//                                           ['pickupCustomerName']),
//                                           Text(pickupOrders[index]
//                                           ['pickupCustomerArea']),
//                                         ],
//                                       ),
//                                       subtitle: Row(
//                                         mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(''),
//                                           Text(
//                                               pickupOrders[index]['pickupDate'] ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                               // Delivery Orders List
//                               ListView.builder(
//                                 itemCount: deliveryOrders.length,
//                                 itemBuilder: (context, index) {
//                                   return Card(
//
//                                     child: ListTile(
//                                       title: Row(
//                                         mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(deliveryOrders[index]['deliveryCustomerName']),
//                                           Text(deliveryOrders[index]['deliveryCustomerArea']),
//                                         ],
//                                       ),
//                                       subtitle: Row(
//                                         mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(''),
//                                           Text(
//                                               deliveryOrders[index]['deliveryDate'] ),
//                                         ],
//                                       ),
//                                     ),
//
//
//
//
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: _onItemTapped,
//           type: BottomNavigationBarType.fixed,
//           items: [
//             BottomNavigationBarItem(
//               icon: Icon(
//                 Icons.home,
//               ),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(
//                 Icons.car_crash,
//               ),
//               label: 'Pickup',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(
//                 Icons.car_crash,
//               ),
//               label: 'Delivery',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(
//                 Icons.compare_arrows,
//               ),
//               label: 'History',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(
//                 Icons.person,
//               ),
//               label: 'Me',
//             ),
//           ],
//           selectedItemColor: Color(0xFF301C93),
//           selectedFontSize: 12.0, // Adjust the font size for the selected item
//           unselectedFontSize: 12.0, // Adjust the font size for unselected items
//           iconSize: 26.0, // Adjust the icon size
//         ),
//       ),
//     );
//   }
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//
//     if (_currentIndex == 0) {
//       Navigator.pushReplacementNamed(context, '/dashHome');
//     } else if (_currentIndex == 1) {
//       Navigator.pushReplacementNamed(context, "/pickupOrderListing");
//     } else if (_currentIndex == 2) {
//       Navigator.pushReplacementNamed(context, "/delivery");
//     } else if (_currentIndex == 3) {
//       Navigator.pushReplacementNamed(context, '/history');
//     } else if (_currentIndex == 4) {
//       Navigator.pushReplacementNamed(context, '/profile');
//     }
//   }
// }
//
//
// // import 'dart:convert';
// //
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:syswash/utils/app_constant.dart';
// // import 'package:http/http.dart' as http;
// // import '../../../utils/app_sp.dart';
// // import '../../../utils/app_url.dart';
// //
// // import 'package:carousel_slider/carousel_slider.dart';
// //
// // class DashBoardScreen extends StatefulWidget {
// //   const DashBoardScreen({super.key});
// //
// //   @override
// //   State<DashBoardScreen> createState() => _DashBoardScreenState();
// // }
// //
// // class _DashBoardScreenState extends State<DashBoardScreen> {
// //   int _currentIndex = 0;
// //   String tokenID = '';
// //   String userToken = "";
// //   String companyCode = "";
// //   String userID = "";
// //   String pickupitemCount = '';
// //   String deliveritemCount = '';
// //
// //   String firebaseToken = "";
// //
// //   String driverID = "";
// //
// //   String refreshtoken = "";
// //
// //   String LoggerUsername = "";
// //
// //   final List<String> allOrders = [
// //     'All Order 1',
// //     'All Order 2',
// //     'All Order 3',
// //     'All Order 4',
// //     'All Order 5',
// //   ];
// //
// //   List<Map<String, dynamic>> pickupOrders = [];
// //
// //   List<Map<String, dynamic>> deliveryOrders = [];
// //
// //
// //   // final List<String> deliveryOrders = [
// //   //   'Delivery Order 1',
// //   //   'Delivery Order 2',
// //   //   'Delivery Order 3',
// //   //   'Delivery Order 4',
// //   //   'Delivery Order 5',
// //   // ];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     getUserToken();
// //   }
// //
// //   Future<void> getUserToken() async {
// //     AppSp appSp = AppSp();
// //     userToken = await appSp.getToken();
// //     companyCode = await appSp.getCompanyCode();
// //     userID = await appSp.getUserID();
// //
// //     LoggerUsername = await appSp.getUserName();
// //
// //     fetchOrderListingData(userToken, companyCode, userID);
// //     fetchDeliverListingData(userToken, companyCode, userID);
// //
// //     firebaseToken = await appSp.getFirebasetoken();
// //     passFirebaseToken(firebaseToken, userToken, userID);
// //
// //     print('-------------------78563465836503457345875438654386304956345');
// //     refreshtoken = await appSp.getRefreshtoken();
// //     print(refreshtoken);
// //     passRefreshToken(refreshtoken);
// //     if (refreshtoken == '') {
// //       AppSp().setIsLogged(false);
// //
// //       Navigator.pushReplacementNamed(context, '/login');
// //     }
// //
// //     print('-------------------78563465836503457345875438654386304956345');
// //
// //     print("this is below in new data");
// //
// //     print("end this data");
// //   }
// //
// //   @override
// //   void dispose() {
// //     super.dispose();
// //   }
// //
// //   void passRefreshToken(String refreshtoken) async {
// //     try {
// //       final response = await http.post(
// //         Uri.parse('https://be.syswash.net/api/token/refresh/'),
// //         body: {'refresh': refreshtoken},
// //       );
// //
// //       if (response.statusCode == 200) {
// //         Map<String, dynamic> data = json.decode(response.body);
// //         String? accessToken = data['access'];
// //         if (accessToken != null) {
// //           setState(() {
// //             AppSp().setToken(accessToken);
// //             userToken = accessToken.toString();
// //             print('Access token refreshed successfully: $userToken');
// //           });
// //         } else {
// //           print('Error: No access token returned');
// //           AppSp().setIsLogged(false);
// //
// //           Navigator.pushReplacementNamed(context, '/login');
// //         }
// //       } else {
// //         print(
// //             'Error: Failed to refresh token, status code: ${response.statusCode}');
// //         print('Response body: ${response.body}');
// //         AppSp().setIsLogged(false);
// //
// //         Navigator.pushReplacementNamed(context, '/login');
// //       }
// //     } catch (e) {
// //       print('Exception caught: $e');
// //       AppSp().setIsLogged(false);
// //
// //       Navigator.pushReplacementNamed(context, '/login');
// //     }
// //   }
// //
// //   void passFirebaseToken(
// //       String firebaseToken, String userToken, String userID) async {
// //     final response = await http.post(
// //       Uri.parse('${AppUrls.driverdevicetoken}${AppUrls.code_main}$companyCode'),
// //       headers: {
// //         "Accept": "application/json",
// //         "Content-Type": "application/json",
// //         "Authorization": "Bearer $userToken"
// //       },
// //       body: jsonEncode({
// //         "driver_id": userID,
// //         "device_token": firebaseToken,
// //       }),
// //     );
// //     print('<<<>>>>>>>firebase');
// //     print(firebaseToken);
// //     if (response.statusCode == 200) {
// //       print(response.body);
// //       print('Passed SucessFully');
// //     } else {
// //       print("Failed to fetch data: ${response.body}");
// //     }
// //   }
// //
// //   void fetchOrderListingData(
// //       String userToken, String companyCode, String userID) async {
// //     final response = await http.get(
// //         Uri.parse(
// //             '${AppUrls.pickuplist}$userID${AppUrls.code_main}$companyCode'),
// //         headers: {
// //           "Accept": "application/json",
// //           "Authorization": "Bearer $userToken"
// //         });
// //     if (response.statusCode == 200) {
// //       List<dynamic> data = jsonDecode(response.body);
// //
// //       print("data res[pomse");
// //       print(response.body);
// //
// //       // Filter out orders where pickupstatus is 'Received'
// //       List<dynamic> filteredData =
// //           data.where((item) => item['pickupstatus'] != 'Received').toList();
// //
// //       // Sort the data by pickupDate in descending order
// //       filteredData.sort((a, b) => b['pickupDate'].compareTo(a['pickupDate']));
// //
// //       // Take the latest 5 orders
// //       List<dynamic> latest5Orders = filteredData.take(5).toList();
// //
// //       List<Map<String, dynamic>> newPickupOrders =
// //           latest5Orders.map<Map<String, dynamic>>((item) {
// //         return {
// //           'pickupassgnId': item['pickupassgnId'],
// //           'pickupDate': item['pickupDate'],
// //           'pickupCustomerName': item['pickupCustomerName'],
// //           'pickupCustomerArea': item['pickupCustomerArea'],
// //           'pickupOrderId': item['pickupOrderId']
// //         };
// //       }).toList();
// //
// //       int itemCount = data.length;
// //       setState(() {
// //         pickupitemCount = itemCount.toString();
// //
// //         pickupOrders = newPickupOrders;
// //
// //         print(pickupOrders);
// //       });
// //     } else {
// //       print("Failed to fetch data: ${response.statusCode}");
// //     }
// //   }
// //
// //   void fetchDeliverListingData(
// //       String userToken, String companyCode, String userID) async {
// //     final response = await http.get(
// //         Uri.parse(
// //             '${AppUrls.deliverylist}$userID${AppUrls.code_main}$companyCode'),
// //         headers: {
// //           "Accept": "application/json",
// //           "Authorization": "Bearer $userToken"
// //         });
// //     if (response.statusCode == 200) {
// //       List<dynamic> data = jsonDecode(response.body);
// //
// //       print("drliveryyyyyyy");
// //       print(response.body);
// //
// //       List<dynamic> filteredData = data.where((item) => item['status'] != 'Delivered').toList();
// //
// //       // Sort the data by deliveryDate in descending order
// //       filteredData.sort((a, b) {
// //         DateTime dateA = DateTime.parse(a['deliveryDate']);
// //         DateTime dateB = DateTime.parse(b['deliveryDate']);
// //         return dateB.compareTo(dateA);
// //       });
// //
// //       // Take the latest 5 delivered items
// //       List<dynamic> latest5Deliveries = filteredData.take(5).toList();
// //
// //       // Extract the required fields
// //       List<Map<String, dynamic>> newDeliveryOrders = latest5Deliveries.map<Map<String, dynamic>>((item) {
// //         return {
// //           'deliveryassgnId': item['deliveryassgnId'],
// //           'deliveryDate': item['deliveryDate'],
// //           'deliveryCustomerName': item['deliveryCustomerName'],
// //           'deliveryCustomerArea': item['deliveryCustomerArea'],
// //           'deliveryInvoiceNo': item['deliveryInvoiceNo']
// //         };
// //       }).toList();
// //
// //
// //       int itemCount = data.length;
// //       setState(() {
// //         deliveritemCount = itemCount.toString();
// //         deliveryOrders = newDeliveryOrders;
// //       });
// //     } else {
// //       print("Failed to fetch data: ${response.statusCode}");
// //     }
// //   }
// //
// //   //slider
// //   List imageList = [
// //     {"id": 1, "image_path": 'assets/slider/sys.png'},
// //     {"id": 2, "image_path": 'assets/slider/sys.png'},
// //     {"id": 3, "image_path": 'assets/slider/sys.png'},
// //   ];
// //   final CarouselController carouselController = CarouselController();
// //   int currentIndex = 0;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return WillPopScope(
// //       onWillPop: () async {
// //         return await showDialog(
// //           context: context,
// //           builder: (context) => AlertDialog(
// //             title: const Text(
// //               'Are you sure...?',
// //             ),
// //             content: const Text(
// //               'Do you want to exit from the App',
// //             ),
// //             actions: <Widget>[
// //               TextButton(
// //                 onPressed: () {
// //                   Navigator.of(context).pop(false);
// //                   SystemNavigator.pop();
// //                   Future.delayed(const Duration(milliseconds: 1000), () {
// //                     SystemChannels.platform.invokeMethod('SystemNavigator.pop');
// //                   });
// //                 },
// //                 child: const Text(
// //                   "YES",
// //                   style: TextStyle(
// //                     color: Colors.red,
// //                   ),
// //                 ),
// //               ),
// //               TextButton(
// //                 onPressed: () {
// //                   Navigator.of(context).pop(false);
// //                 },
// //                 child: const Text(
// //                   "NO",
// //                   style: TextStyle(
// //                     color: Color(0xFF301C93),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //       child: Scaffold(
// //         backgroundColor: Color(0xFFEFEEF3),
// //         body: Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: SingleChildScrollView(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 //       Stack(children: [
// //                 //         InkWell(
// //                 //       onTap: (){
// //                 //         print(currentIndex);
// //                 // },
// //                 //   child: CarouselSlider(
// //                 //     items: imageList.map((item)=>Image.asset(item[
// //                 //       'image_path'],
// //                 //       fit: BoxFit.cover,
// //                 //       width: double.infinity,
// //                 //     ),
// //                 //   ).toList(),
// //                 //     carouselController: carouselController,
// //                 //     options: CarouselOptions(
// //                 //       scrollPhysics: BouncingScrollPhysics(),
// //                 //       autoPlay: true,
// //                 //       aspectRatio: 2,
// //                 //       viewportFraction: 1,
// //                 //       onPageChanged: (index, reason){
// //                 //         setState(() {
// //                 //           currentIndex=index;
// //                 //         });
// //                 //       },
// //                 //     ),
// //                 //   )
// //                 // ),
// //                 //   ],
// //                 //       ),
// //
// //                 SizedBox(height: 30),
// //
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Text(
// //                       '$LoggerUsername',
// //                       style: TextStyle(
// //                         color: Color(0xFF8C8686),
// //                         fontFamily: GoogleFonts.openSans().fontFamily,
// //                         fontSize: 20,
// //                       ),
// //                     ),
// //                     // Text(firebaseToken),
// //                     //
// //
// //                     IconButton(
// //                       icon: Icon(Icons.notifications_outlined,
// //                           size: 45, color: Color(0xFF301C93)),
// //                       onPressed: () {},
// //                     ),
// //                   ],
// //                 ),
// //
// //                 SizedBox(height: 2),
// //                 Text(
// //                   'SYSWASH',
// //                   style: TextStyle(
// //                       fontFamily: GoogleFonts.openSans().fontFamily,
// //                       fontSize: 24,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF301C93)),
// //                 ),
// //                 SizedBox(
// //                   height: 10,
// //                 ),
// //                 // Stack(
// //                 //   children: [
// //                 //     InkWell(
// //                 //         onTap: () {
// //                 //           print(currentIndex);
// //                 //         },
// //                 //         child: CarouselSlider(
// //                 //           items: imageList
// //                 //               .map(
// //                 //                 (item) => Image.asset(
// //                 //                   item['image_path'],
// //                 //                   fit: BoxFit.cover,
// //                 //                   width: double.infinity,
// //                 //                 ),
// //                 //               )
// //                 //               .toList(),
// //                 //           carouselController: carouselController,
// //                 //           options: CarouselOptions(
// //                 //             scrollPhysics: BouncingScrollPhysics(),
// //                 //             autoPlay: true,
// //                 //             aspectRatio: 2,
// //                 //             viewportFraction: 1,
// //                 //             onPageChanged: (index, reason) {
// //                 //               setState(() {
// //                 //                 currentIndex = index;
// //                 //               });
// //                 //             },
// //                 //           ),
// //                 //         )),
// //                 //   ],
// //                 // ),
// //                 // dividerH(),
// //                 // Row(
// //                 //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 //   children: [
// //                 //     Flexible(
// //                 //       child: Card(
// //                 //         shape: RoundedRectangleBorder(
// //                 //           borderRadius: BorderRadius.circular(25.0),
// //                 //         ),
// //                 //         child: Container(
// //                 //           width: MediaQuery.of(context).size.width * 0.5,
// //                 //           height: MediaQuery.of(context).size.height * 0.14,
// //                 //           decoration: BoxDecoration(
// //                 //             borderRadius: BorderRadius.circular(20.0),
// //                 //             color: Colors.orange,
// //                 //           ),
// //                 //           child: Stack(
// //                 //             children: [
// //                 //               // Icon in top left corner
// //                 //               const Positioned(
// //                 //                 top: 8,
// //                 //                 left: 8,
// //                 //                 child: Icon(
// //                 //                   Icons.delivery_dining,
// //                 //                   color: Colors.white,
// //                 //                   size: 50,
// //                 //                 ),
// //                 //               ),
// //                 //               // Text in the card (example)
// //                 //               const Positioned(
// //                 //                 bottom: 20,
// //                 //                 left: 20,
// //                 //                 child: Text(
// //                 //                   'Pickup',
// //                 //                   style: TextStyle(
// //                 //                       fontSize: 18,
// //                 //                       color: Colors.white,
// //                 //                       fontWeight: FontWeight.bold),
// //                 //                 ),
// //                 //               ),
// //                 //               Positioned(
// //                 //                 bottom: 15,
// //                 //                 right: 20,
// //                 //                 child: CircleAvatar(
// //                 //                     radius: 20.0,
// //                 //                     backgroundColor: Colors.white,
// //                 //                     child: Text(
// //                 //                       pickupitemCount,
// //                 //                       style: TextStyle(
// //                 //                           color: Colors.orange,
// //                 //                           fontSize: 14,
// //                 //                           fontWeight: FontWeight.bold),
// //                 //                     )),
// //                 //               ),
// //                 //             ],
// //                 //           ),
// //                 //         ),
// //                 //       ),
// //                 //     ),
// //                 //     Flexible(
// //                 //       child: Card(
// //                 //         shape: RoundedRectangleBorder(
// //                 //           borderRadius: BorderRadius.circular(25.0),
// //                 //         ),
// //                 //         child: Container(
// //                 //           width: MediaQuery.of(context).size.width * 0.5,
// //                 //           height: MediaQuery.of(context).size.height * 0.14,
// //                 //           decoration: BoxDecoration(
// //                 //             borderRadius: BorderRadius.circular(20.0),
// //                 //             color: Colors.deepPurpleAccent,
// //                 //           ),
// //                 //           child: Stack(
// //                 //             children: [
// //                 //               // Icon in top left corner
// //                 //               Positioned(
// //                 //                 top: 8,
// //                 //                 left: 8,
// //                 //                 child: Icon(
// //                 //                   Icons.shopping_bag,
// //                 //                   color: Colors.white,
// //                 //                   size: 50,
// //                 //                 ),
// //                 //               ),
// //                 //               // Text in the card (example)
// //                 //               Positioned(
// //                 //                 bottom: 20,
// //                 //                 left: 20,
// //                 //                 child: Text(
// //                 //                   'Delivery',
// //                 //                   style: TextStyle(
// //                 //                       fontSize: 18,
// //                 //                       color: Colors.white,
// //                 //                       fontWeight: FontWeight.bold),
// //                 //                 ),
// //                 //               ),
// //                 //               Positioned(
// //                 //                 bottom: 15,
// //                 //                 right: 20,
// //                 //                 child: CircleAvatar(
// //                 //                     radius: 20.0,
// //                 //                     backgroundColor: Colors.white,
// //                 //                     child: Text(
// //                 //                       deliveritemCount,
// //                 //                       style: TextStyle(
// //                 //                           color: Colors.deepPurpleAccent,
// //                 //                           fontSize: 14,
// //                 //                           fontWeight: FontWeight.bold),
// //                 //                     )),
// //                 //               ),
// //                 //             ],
// //                 //           ),
// //                 //         ),
// //                 //       ),
// //                 //     ),
// //                 //   ],
// //                 // ),
// //                 //
// //                 // dividerLH(),
// //                 // SizedBox(
// //                 //   height: 130,
// //                 //   child: GestureDetector(
// //                 //     onTap: () {
// //                 //       Navigator.pushNamed(context, "/pickupOrderListing");
// //                 //     },
// //                 //     child: Container(
// //                 //       decoration: BoxDecoration(
// //                 //         borderRadius: BorderRadius.circular(12),
// //                 //       ),
// //                 //       child: Stack(
// //                 //         fit: StackFit.expand,
// //                 //         children: [
// //                 //           // Image
// //                 //           Container(
// //                 //             decoration: BoxDecoration(
// //                 //               image: DecorationImage(
// //                 //                 image: AssetImage(homeImagePick),
// //                 //                 fit: BoxFit.cover,
// //                 //               ),
// //                 //               borderRadius: BorderRadius.circular(12),
// //                 //             ),
// //                 //           ),
// //                 //           // Gradient
// //                 //           Container(
// //                 //             decoration: BoxDecoration(
// //                 //               borderRadius: BorderRadius.circular(12),
// //                 //               gradient: LinearGradient(
// //                 //                 begin: Alignment.topCenter,
// //                 //                 end: Alignment.bottomCenter,
// //                 //                 colors: [
// //                 //                   Colors.transparent,
// //                 //                   Colors.black.withOpacity(0.8),
// //                 //                 ],
// //                 //               ),
// //                 //             ),
// //                 //           ),
// //                 //           Container(
// //                 //             padding: EdgeInsets.all(20),
// //                 //             child: Row(
// //                 //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 //               crossAxisAlignment: CrossAxisAlignment.end,
// //                 //               children: [
// //                 //                 Text(
// //                 //                   'Pickup Order',
// //                 //                   style: TextStyle(
// //                 //                     fontFamily:
// //                 //                         GoogleFonts.openSans().fontFamily,
// //                 //                     fontSize: 25,
// //                 //                     fontWeight: FontWeight.bold,
// //                 //                     color: Colors.white,
// //                 //                   ),
// //                 //                 ),
// //                 //                 Icon(Icons.arrow_forward, color: Colors.white),
// //                 //               ],
// //                 //             ),
// //                 //           ),
// //                 //         ],
// //                 //       ),
// //                 //     ),
// //                 //   ),
// //                 // ),
// //                 // dividerH(),
// //                 // SizedBox(
// //                 //   height: 130,
// //                 //   child: GestureDetector(
// //                 //     onTap: () {
// //                 //       Navigator.pushNamed(context, "/delivery");
// //                 //     },
// //                 //     child: Container(
// //                 //       decoration: BoxDecoration(
// //                 //         borderRadius: BorderRadius.circular(12),
// //                 //       ),
// //                 //       child: Stack(
// //                 //         fit: StackFit.expand,
// //                 //         children: [
// //                 //           // Image
// //                 //           Container(
// //                 //             decoration: BoxDecoration(
// //                 //               image: DecorationImage(
// //                 //                 image: AssetImage(homeImageDelivery),
// //                 //                 fit: BoxFit.cover,
// //                 //               ),
// //                 //               borderRadius: BorderRadius.circular(12),
// //                 //             ),
// //                 //           ),
// //                 //           // Gradient
// //                 //           Container(
// //                 //             decoration: BoxDecoration(
// //                 //               borderRadius: BorderRadius.circular(12),
// //                 //               gradient: LinearGradient(
// //                 //                 begin: Alignment.topCenter,
// //                 //                 end: Alignment.bottomCenter,
// //                 //                 colors: [
// //                 //                   Colors.transparent,
// //                 //                   Colors.black.withOpacity(0.8),
// //                 //                 ],
// //                 //               ),
// //                 //             ),
// //                 //           ),
// //                 //           // Content
// //                 //           Container(
// //                 //             padding: EdgeInsets.all(20),
// //                 //             child: Row(
// //                 //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 //               crossAxisAlignment: CrossAxisAlignment.end,
// //                 //               children: [
// //                 //                 Text(
// //                 //                   'Delivery Order',
// //                 //                   style: TextStyle(
// //                 //                     fontFamily:
// //                 //                         GoogleFonts.openSans().fontFamily,
// //                 //                     fontSize: 25,
// //                 //                     fontWeight: FontWeight.bold,
// //                 //                     color: Colors.white,
// //                 //                   ),
// //                 //                 ),
// //                 //                 Icon(Icons.arrow_forward, color: Colors.white),
// //                 //               ],
// //                 //             ),
// //                 //           ),
// //                 //
// //                 //           // TextField(
// //                 //           //   controller: TextEditingController(text: firebaseToken),
// //                 //           //   decoration: InputDecoration(
// //                 //           //     labelText: 'Enter some text',
// //                 //           //     border: OutlineInputBorder(),
// //                 //           //   ),
// //                 //           // ),
// //                 //         ],
// //                 //       ),
// //                 //     ),
// //                 //   ),
// //                 // ),
// //
// //                 // new design
// //
// //
// //                 Stack(
// //                   children: [
// //                     InkWell(
// //                         onTap: () {
// //                           print(currentIndex);
// //                         },
// //                         child: CarouselSlider(
// //                           items: imageList
// //                               .map(
// //                                 (item) => Image.asset(
// //                                   item['image_path'],
// //                                   fit: BoxFit.cover,
// //                                   width: double.infinity,
// //                                 ),
// //                               )
// //                               .toList(),
// //                           carouselController: carouselController,
// //                           options: CarouselOptions(
// //                             scrollPhysics: BouncingScrollPhysics(),
// //                             autoPlay: true,
// //                             aspectRatio: 2,
// //                             viewportFraction: 1,
// //                             onPageChanged: (index, reason) {
// //                               setState(() {
// //                                 currentIndex = index;
// //                               });
// //                             },
// //                           ),
// //                         )),
// //                   ],
// //                 ),
// //                 SizedBox(
// //                   height: 10,
// //                 ),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.start,
// //                   children: [
// //                     Flexible(
// //                       child: Card(
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(8.0),
// //                         ),
// //                         child: Container(
// //                           width: MediaQuery.of(context).size.width * 0.5,
// //                           height: MediaQuery.of(context).size.height * 0.13,
// //                           decoration: BoxDecoration(
// //                             borderRadius: BorderRadius.circular(8.0),
// //                             color: Colors.deepPurple,
// //                           ),
// //                           child: Stack(
// //                             children: const [
// //                               Positioned(
// //                                 bottom: 35,
// //                                 left: 22,
// //                                 child: Text(
// //                                   '150\nCompleted Order',
// //                                   style: TextStyle(
// //                                     fontSize: 18,
// //                                     color: Colors.white,
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     Flexible(
// //                       child: Column(
// //                         children: [
// //                           GestureDetector(
// //                             onTap: () {
// //                               Navigator.pushNamed(context, "/pickupOrderListing");
// //                             },
// //                             child:Card(
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(8.0),
// //                             ),
// //                             child: Container(
// //                               width: MediaQuery.of(context).size.width * 0.7,
// //                               height: MediaQuery.of(context).size.height * 0.06,
// //                               decoration: BoxDecoration(
// //                                 borderRadius: BorderRadius.circular(8.0),
// //                                 color: Colors.deepPurple,
// //                               ),
// //                               child: Stack(
// //                                 children: [
// //                                   Positioned(
// //                                     bottom: 20,
// //                                     left: 20,
// //                                     child: Row(
// //                                       mainAxisAlignment:
// //                                           MainAxisAlignment.spaceBetween,
// //                                       children: [
// //                                         Text(
// //                                           'Pickup Order',
// //                                           style: TextStyle(
// //                                             fontSize: 15,
// //                                             color: Colors.white,
// //                                             fontWeight: FontWeight.bold,
// //                                           ),
// //                                         ),
// //                                         SizedBox(
// //                                           width: 35,
// //                                         ),
// //                                         Icon(Icons.arrow_forward,
// //                                             color: Colors.white, size: 24),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //     ),
// //                           // SizedBox(height: 5), // Space between the two cards
// //                           GestureDetector(
// //                           onTap: () {
// //                           Navigator.pushNamed(context, "/delivery");
// //                           },
// //                           child:Card(
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(8.0),
// //                             ),
// //
// //                             child: Container(
// //                               width: MediaQuery.of(context).size.width * 0.7,
// //                               height: MediaQuery.of(context).size.height * 0.06,
// //                               decoration: BoxDecoration(
// //                                 borderRadius: BorderRadius.circular(8.0),
// //                                 color: Colors.orange,
// //                               ),
// //                               child: Stack(
// //                                 children: [
// //                                   Positioned(
// //                                     bottom: 20,
// //                                     left: 20,
// //                                     child: Row(
// //                                       mainAxisAlignment:
// //                                           MainAxisAlignment.spaceBetween,
// //                                       children: [
// //                                         Text(
// //                                           'Delivery Order',
// //                                           style: TextStyle(
// //                                             fontSize: 15,
// //                                             color: Colors.white,
// //                                             fontWeight: FontWeight.bold,
// //                                           ),
// //                                         ),
// //                                         SizedBox(
// //                                           width: 35,
// //                                         ),
// //                                         Icon(Icons.arrow_forward,
// //                                             color: Colors.white, size: 24),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 SizedBox(
// //                   height: 400,
// //                   child: DefaultTabController(
// //                     length: 3,
// //                     child: Column(
// //                       // Wrap the entire content in Column
// //                       children: [
// //                         Padding(
// //                           padding: const EdgeInsets.all(8.0),
// //                           child: Row(
// //                             children: [
// //                               Expanded(
// //                                 child: Text(
// //                                   'Latest Orders',
// //                                   style: TextStyle(
// //                                     fontSize: 20,
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                               ),
// //                               Expanded(
// //                                 child: TabBar(
// //                                   labelColor: Colors.black,
// //                                   unselectedLabelColor: Colors.grey,
// //                                   indicatorColor: Colors.white,
// //                                   labelStyle: TextStyle(
// //                                       fontSize: 10,
// //                                       fontWeight: FontWeight.bold),
// //                                   unselectedLabelStyle: TextStyle(fontSize: 10),
// //                                   tabs: [
// //                                     Tab(
// //                                       text: 'All',
// //                                     ),
// //                                     Tab(text: 'Pickup'),
// //                                     Tab(text: 'Delivery'),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                         Expanded(
// //                           child: TabBarView(
// //                             children: [
// //                               // All Orders List
// //                               ListView.builder(
// //                                 itemCount: allOrders.length,
// //                                 itemBuilder: (context, index) {
// //                                   return Card(
// //                                     child: ListTile(
// //                                       title: Text(allOrders[index]),
// //                                     ),
// //                                   );
// //                                 },
// //                               ),
// //                               // Pickup Orders List
// //                               ListView.builder(
// //                                 itemCount: pickupOrders.length,
// //                                 itemBuilder: (context, index) {
// //                                   return Card(
// //                                     child: ListTile(
// //                                       title: Row(
// //                                         mainAxisAlignment:
// //                                             MainAxisAlignment.spaceBetween,
// //                                         children: [
// //                                           Text(pickupOrders[index]
// //                                               ['pickupCustomerName']),
// //                                           Text(pickupOrders[index]
// //                                               ['pickupCustomerArea']),
// //                                         ],
// //                                       ),
// //                                       subtitle: Row(
// //                                         mainAxisAlignment:
// //                                             MainAxisAlignment.spaceBetween,
// //                                         children: [
// //                                           Text(''),
// //                                           Text(
// //                                               pickupOrders[index]['pickupDate'] ),
// //                                         ],
// //                                       ),
// //                                     ),
// //                                   );
// //                                 },
// //                               ),
// //                               // Delivery Orders List
// //                               ListView.builder(
// //                                 itemCount: deliveryOrders.length,
// //                                 itemBuilder: (context, index) {
// //                                   return Card(
// //
// //                                     child: ListTile(
// //                                       title: Row(
// //                                         mainAxisAlignment:
// //                                         MainAxisAlignment.spaceBetween,
// //                                         children: [
// //                                           Text(deliveryOrders[index]['deliveryCustomerName']),
// //                                           Text(deliveryOrders[index]['deliveryCustomerArea']),
// //                                         ],
// //                                       ),
// //                                       subtitle: Row(
// //                                         mainAxisAlignment:
// //                                         MainAxisAlignment.spaceBetween,
// //                                         children: [
// //                                           Text(''),
// //                                           Text(
// //                                               deliveryOrders[index]['deliveryDate'] ),
// //                                         ],
// //                                       ),
// //                                     ),
// //
// //
// //
// //
// //                                   );
// //                                 },
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //         bottomNavigationBar: BottomNavigationBar(
// //           currentIndex: _currentIndex,
// //           onTap: _onItemTapped,
// //           type: BottomNavigationBarType.fixed,
// //           items: [
// //             BottomNavigationBarItem(
// //               icon: Icon(
// //                 Icons.home,
// //               ),
// //               label: 'Home',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(
// //                 Icons.car_crash,
// //               ),
// //               label: 'Pickup',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(
// //                 Icons.car_crash,
// //               ),
// //               label: 'Delivery',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(
// //                 Icons.compare_arrows,
// //               ),
// //               label: 'History',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(
// //                 Icons.person,
// //               ),
// //               label: 'Me',
// //             ),
// //           ],
// //           selectedItemColor: Color(0xFF301C93),
// //           selectedFontSize: 12.0, // Adjust the font size for the selected item
// //           unselectedFontSize: 12.0, // Adjust the font size for unselected items
// //           iconSize: 26.0, // Adjust the icon size
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void _onItemTapped(int index) {
// //     setState(() {
// //       _currentIndex = index;
// //     });
// //
// //     if (_currentIndex == 0) {
// //       Navigator.pushReplacementNamed(context, '/dashHome');
// //     } else if (_currentIndex == 1) {
// //       Navigator.pushReplacementNamed(context, "/pickupOrderListing");
// //     } else if (_currentIndex == 2) {
// //       Navigator.pushReplacementNamed(context, "/delivery");
// //     } else if (_currentIndex == 3) {
// //       Navigator.pushReplacementNamed(context, '/history');
// //     } else if (_currentIndex == 4) {
// //       Navigator.pushReplacementNamed(context, '/profile');
// //     }
// //   }
// // }
