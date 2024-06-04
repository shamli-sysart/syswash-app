import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syswash/utils/app_constant.dart';
import 'package:http/http.dart' as http;
import '../../../utils/app_sp.dart';
import '../../../utils/app_url.dart';

import 'package:carousel_slider/carousel_slider.dart';

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


    firebaseToken = await appSp.getFirebasetoken();
    passFirebaseToken(firebaseToken,userToken, userID);

    print('-------------------78563465836503457345875438654386304956345');
    refreshtoken = await appSp.getRefreshtoken();
    print(refreshtoken);
    passRefreshToken(refreshtoken);
    if (refreshtoken == '')
      {
        AppSp().setIsLogged(false);


        Navigator.pushReplacementNamed(context, '/login');
      }


    print('-------------------78563465836503457345875438654386304956345');

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
        print('Error: Failed to refresh token, status code: ${response.statusCode}');
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


  void passFirebaseToken(String firebaseToken, String userToken, String userID) async {
    final response = await http.post(
        Uri.parse('${AppUrls.driverdevicetoken}${AppUrls.code_main}$companyCode'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $userToken"
      },
      body: jsonEncode({
        "driver_id": userID,
        "device_token": firebaseToken,
      }),
    );
    if (response.statusCode == 200) {
      print('Passed SucessFully');
    } else {
      print("Failed to fetch data: ${response.body}");
    }
  }



  void fetchOrderListingData( String userToken, String companyCode, String userID) async {
    final response = await http.get(
        Uri.parse('${AppUrls.pickuplist}$userID${AppUrls.code_main}$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        }
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      int itemCount = data.length;
      setState(() {
        pickupitemCount = itemCount.toString();
      });
    } else {
      print("Failed to fetch data: ${response.statusCode}");
    }
  }

  void fetchDeliverListingData( String userToken, String companyCode, String userID) async {
    final response = await http.get(
        Uri.parse('${AppUrls.deliverylist}$userID${AppUrls.code_main}$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        }
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      int itemCount = data.length;
      setState(() {
        deliveritemCount = itemCount.toString();
      });
    } else {
      print("Failed to fetch data: ${response.statusCode}");
    }
  }
  //slider
  List imageList = [
    {"id":1,"image_path":'assets/slider/sys.png'},
    {"id":2,"image_path":'assets/slider/sys.png'},
    {"id":3,"image_path":'assets/slider/sys.png'},
  ];
  final CarouselController carouselController = CarouselController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
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
                  SystemChannels.platform
                      .invokeMethod('SystemNavigator.pop');
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
    child:
    Scaffold(
      backgroundColor: Color(0xFFEFEEF3),
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
                    '$LoggerUsername',
                    style: TextStyle(  color: Color(0xFF8C8686),
                      fontFamily: GoogleFonts.openSans().fontFamily,
                      fontSize: 20,
                    ),
                  ),
                  // Text(firebaseToken),
                  //


                  IconButton(
                    icon: Icon(Icons.notifications_outlined,
                        size: 45, color: Color(0xFF301C93)),
                    onPressed: () {
                    },
                  ),
                ],
              ),

              SizedBox(height: 2),
              Text(
                'Welcome back',
                style: TextStyle(
                    fontFamily: GoogleFonts.openSans().fontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF301C93)),
              ),
              SizedBox(height: 10,),
              Stack(children: [
                InkWell(
                    onTap: (){
                      print(currentIndex);
                    },
                    child: CarouselSlider(
                      items: imageList.map((item)=>Image.asset(item[
                      'image_path'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      ).toList(),
                      carouselController: carouselController,
                      options: CarouselOptions(
                        scrollPhysics: BouncingScrollPhysics(),
                        autoPlay: true,
                        aspectRatio: 2,
                        viewportFraction: 1,
                        onPageChanged: (index, reason){
                          setState(() {
                            currentIndex=index;
                          });
                        },
                      ),
                    )
                ),
              ],
              ),
              dividerH(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.height * 0.14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.orange,
                        ),
                        child: Stack(
                          children: [
                            // Icon in top left corner
                            const Positioned(
                              top: 8,
                              left: 8,
                              child: Icon(
                                Icons.delivery_dining,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                            // Text in the card (example)
                            const Positioned(
                              bottom: 20,
                              left: 20,
                              child: Text(
                                'Pickup',
                                style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              right: 20,
                              child: CircleAvatar(
                                  radius:
                                  20.0,
                                  backgroundColor:Colors.white,
                                  child:
                                  Text(pickupitemCount,style: TextStyle(color: Colors.orange,fontSize: 14,fontWeight: FontWeight.bold),)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Flexible(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.height * 0.14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.deepPurpleAccent,
                        ),
                        child: Stack(
                          children: [
                            // Icon in top left corner
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Icon(
                                Icons.shopping_bag,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                            // Text in the card (example)
                            Positioned(
                              bottom: 20,
                              left: 20,
                              child: Text(
                                'Delivery',
                                style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                                right: 20,
                              child: CircleAvatar(
                                radius:
                                20.0,
                                backgroundColor:Colors.white,
                                child:
                              Text(deliveritemCount,
                                style: TextStyle(color: Colors.deepPurpleAccent,fontSize: 14,fontWeight: FontWeight.bold),)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              dividerLH(),
              SizedBox(
                height: 130,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/pickupOrderListing");
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  homeImagePick),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),

                        ),
                        // Gradient
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Pickup Order',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.openSans().fontFamily,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              dividerH(),
              SizedBox(
                height: 130,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/delivery");
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                 homeImageDelivery),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // Gradient
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                        // Content
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Delivery Order',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.openSans().fontFamily,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                        // TextField(
                        //   controller: TextEditingController(text: firebaseToken),
                        //   decoration: InputDecoration(
                        //     labelText: 'Enter some text',
                        //     border: OutlineInputBorder(),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
     bottomNavigationBar:BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_crash,),
            label: 'Pickup',
          ),
          BottomNavigationBarItem(
            icon:Icon(Icons.car_crash, ),
            label: 'Delivery',
          ),
          BottomNavigationBarItem(
            icon:Icon(Icons.compare_arrows, ),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon:Icon(Icons.person, ),
            label: 'Me',
          ),
        ],
        selectedItemColor:Color(0xFF301C93),
        selectedFontSize:
        12.0, // Adjust the font size for the selected item
        unselectedFontSize:
        12.0, // Adjust the font size for unselected items
        iconSize: 26.0, // Adjust the icon size
      ),
      ),
    );
  }


  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (_currentIndex == 0) {
      Navigator.pushReplacementNamed(context, '/dashHome');
    } else if (_currentIndex == 1) {
      Navigator.pushReplacementNamed(context, "/pickupOrderListing");
    } else if (_currentIndex == 2) {
      Navigator.pushReplacementNamed(context, "/delivery");
    } else if (_currentIndex == 3) {
      Navigator.pushReplacementNamed(context, '/history');
    } else if (_currentIndex == 4) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }
}
