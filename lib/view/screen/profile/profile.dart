import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import '../../../utils/app_constant.dart';
import '../../../utils/app_sp.dart';
import '../../../utils/app_url.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _currentIndex = 4;

  TextEditingController cpass = TextEditingController();
  TextEditingController npass = TextEditingController();
  TextEditingController rpass = TextEditingController();

  String tokenID = '';
  String userToken = "";
  String companyCode = "";
  String userID = "";
  Map<String, dynamic> _profileData = {};

  bool _isPasswordVisible = false;

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

    fetchProfileData(userToken, companyCode, userID);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchProfileData(String userToken, String companyCode,
      String userID) async {
    final response = await http.get(
        Uri.parse('${AppUrls.profile}$userID${AppUrls.code_main}$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        }
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        _profileData = responseData;
      });
    } else {
      print("Failed to fetch data: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> profileItems = [
      {'label': 'Email', 'value': _profileData['email'] ?? ''},
      {'label': 'Phone', 'value': _profileData['mobile']?.toString() ?? ''},
      {'label': 'Gender', 'value': _profileData['gender'] ?? ''},
      // {'label': 'National Id', 'value': _profileData['nationalId'] ?? ''},
      {'label': 'Place', 'value': _profileData['address'] ?? ''},
      {
        'label': 'Password',
        'value': _profileData['password'] ?? '',
        'isSensitive': 'true'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: MediaQuery
              .of(context)
              .size
              .width * 0.060,),
          onPressed: () {
            Navigator.pushNamed(context, "/dashHome");
          },
        ),
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                "Profile",
                style: TextStyle(fontSize: MediaQuery
                    .of(context)
                    .size
                    .width * 0.055, color: Colors.black,
                    fontFamily: GoogleFonts
                        .poppins()
                        .fontFamily,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Add your settings action here
            },
          ),
        ],
        automaticallyImplyLeading: false, // Prevents the default leading widget space
      ),

      //   appBar: AppBar(
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back,color: Colors.black,),
      //     onPressed: () {
      //       Navigator.pushNamed(context, "/dashHome");
      //     },
      //   ),
      //   backgroundColor: Colors.white,
      //   title: Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Spacer(), // Add a spacer at the start
      //       Text("Profile", style: TextStyle(fontSize: 30,color: Colors.black)),
      //       Spacer(), // Add a spacer at the end
      //     ],
      //   ),
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back,color: Colors.black,),
      //     onPressed: () {
      //       Navigator.pushNamed(context, "/dashHome");
      //     },
      //   ),
      //   automaticallyImplyLeading: false, // Prevents the default leading widget space
      // ),
      backgroundColor: Color(0xFFFFFFFF),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                logo1, // Replace with your logo image path
                height: 80, // Set the desired height
                width: 100, // Set the desired width
              ),
              const SizedBox(height: 12),
              Text(
                _profileData['name'] ?? '',
                style: TextStyle(
                    fontSize: MediaQuery
                        .of(context)
                        .size
                        .width * 0.055,
                    fontWeight: FontWeight.w600,
                    fontFamily: GoogleFonts
                        .poppins()
                        .fontFamily,
                    color: Color(0xFF000000)
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, "/editProfile");
                },
                icon: Icon(Icons.edit_calendar_outlined, size: MediaQuery
                    .of(context)
                    .size
                    .width * 0.055, color: Color(0xFF68188B)),
                label: Text(
                  'Edit Profile',
                  style: TextStyle(color: Color(0xFF000000),
                    fontWeight: FontWeight.w600,
                    fontSize: MediaQuery
                        .of(context)
                        .size
                        .width * 0.040,
                    fontFamily: GoogleFonts
                        .poppins()
                        .fontFamily,),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFE2E5F4), // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 13),
                ),
              ),
              SizedBox(height: 10,),


              Card(
                color: Color(0xFFF9F9F9), // Full width card background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFE2E5F4), // Icon box background color
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.mail,
                          size: MediaQuery
                              .of(context)
                              .size
                              .width * 0.040,
                          color: Color(0xFF68188B), // Mail icon color
                        ),
                      ),
                      SizedBox(width: 20), // Space between icon box and text
                      Expanded(
                        child: Text(
                          _profileData['email'] ?? '',
                          style: TextStyle(
                            color: Color(0xFF000000),
                            fontSize: MediaQuery
                                .of(context)
                                .size
                                .width * 0.040,
                            fontWeight: FontWeight.w400,
                            fontFamily: GoogleFonts
                                .poppins()
                                .fontFamily,

                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                color: Color(0xFFF9F9F9), // Full width card background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFE2E5F4), // Icon box background color
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.phone_in_talk_sharp,
                          size: MediaQuery
                              .of(context)
                              .size
                              .width * 0.040,
                          color: Color(0xFF68188B), // Mail icon color
                        ),
                      ),
                      SizedBox(width: 20), // Space between icon box and text
                      Expanded(
                        child: Text(
                          _profileData['mobile']?.toString() ?? '',
                          style: TextStyle(
                            color: Color(0xFF000000),
                            fontSize: MediaQuery
                                .of(context)
                                .size
                                .width * 0.040,
                            fontWeight: FontWeight.w400,
                            fontFamily: GoogleFonts
                                .poppins()
                                .fontFamily,

                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                color: Color(0xFFF9F9F9), // Full width card background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFE2E5F4), // Icon box background color
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.person,
                          size: MediaQuery
                              .of(context)
                              .size
                              .width * 0.040,
                          color: Color(0xFF68188B), // Mail icon color
                        ),
                      ),
                      SizedBox(width: 20), // Space between icon box and text
                      Expanded(
                        child: Text(
                          _profileData['gender'] ?? '',
                          style: TextStyle(
                            color: Color(0xFF000000),
                            fontSize: MediaQuery
                                .of(context)
                                .size
                                .width * 0.040,
                            fontWeight: FontWeight.w400,
                            fontFamily: GoogleFonts
                                .poppins()
                                .fontFamily,

                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Card(
                color: Color(0xFFF9F9F9), // Full width card background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFE2E5F4), // Icon box background color
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.location_on_sharp,
                          size: MediaQuery
                              .of(context)
                              .size
                              .width * 0.040,
                          color: Color(0xFF68188B), // Mail icon color
                        ),
                      ),
                      SizedBox(width: 20), // Space between icon box and text
                      Expanded(
                        child: Text(
                          _profileData['address'] ?? '',
                          style: TextStyle(
                            color: Color(0xFF000000),
                            fontSize: MediaQuery
                                .of(context)
                                .size
                                .width * 0.040,
                            fontWeight: FontWeight.w400,
                            fontFamily: GoogleFonts
                                .poppins()
                                .fontFamily,

                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                color: Color(0xFFF9F9F9), // Full width card background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 0.0, top: 0),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFE2E5F4),
                            // Icon box background color
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.remove_red_eye,
                            size: MediaQuery
                                .of(context)
                                .size
                                .width * 0.040,
                            color: Color(0xFF68188B), // Mail icon color
                          ),
                        ),
                      ),
                      SizedBox(width: 20), // Space between icon box and text
                      Expanded(
                        child: Text(
                          '********',
                          style: TextStyle(
                            color: Color(0xFF000000),
                            fontSize: MediaQuery
                                .of(context)
                                .size
                                .width * 0.040,
                            fontWeight: FontWeight.w400,
                            fontFamily: GoogleFonts
                                .poppins()
                                .fontFamily,

                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_calendar_outlined,
                            size: MediaQuery
                                .of(context)
                                .size
                                .width * 0.040,
                            color: Color(0xFF68188B)),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Color(0xFFFFFFFF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                content: StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return Container(
                                      width: 400,
                                      height: 370,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  'Edit Password',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF150B3D),
                                                    fontFamily: GoogleFonts
                                                        .dmSans()
                                                        .fontFamily,
                                                    fontSize: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width * 0.050,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 20.0,
                                                    backgroundColor: Color(
                                                        0xFF000000),
                                                    child: Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 30,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                  'Current password:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width * 0.040,
                                                    fontFamily: GoogleFonts
                                                        .dmSans()
                                                        .fontFamily,
                                                    color: Color(0xFF150B3D),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12.0),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFFFFFFF),
                                                    borderRadius: BorderRadius
                                                        .circular(10.0),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        spreadRadius: 1,
                                                        blurRadius: 3,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  child: TextField(
                                                    controller: cpass,
                                                    style: TextStyle(
                                                      color: Color(0xFF524B6B),
                                                      fontSize: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width * 0.040,
                                                      fontFamily: GoogleFonts
                                                          .dmSans()
                                                          .fontFamily,
                                                      fontWeight: FontWeight
                                                          .w500,),
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding: EdgeInsets
                                                          .symmetric(
                                                          vertical: 15.0),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                  'New password:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width * 0.040,
                                                    fontFamily: GoogleFonts
                                                        .dmSans()
                                                        .fontFamily,
                                                    color: Color(0xFF150B3D),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12.0),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFFFFFFF),
                                                    borderRadius: BorderRadius
                                                        .circular(10.0),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        spreadRadius: 1,
                                                        blurRadius: 3,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  child: TextField(
                                                    controller: npass,
                                                    style: TextStyle(
                                                      color: Color(0xFF524B6B),
                                                      fontSize: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width * 0.040,
                                                      fontFamily: GoogleFonts
                                                          .dmSans()
                                                          .fontFamily,
                                                      fontWeight: FontWeight
                                                          .w500,),
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding: EdgeInsets
                                                          .symmetric(
                                                          vertical: 15.0),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                  'Re enter password:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width * 0.040,
                                                    fontFamily: GoogleFonts
                                                        .dmSans()
                                                        .fontFamily,
                                                    color: Color(0xFF150B3D),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12.0),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFFFFFFF),
                                                    borderRadius: BorderRadius
                                                        .circular(10.0),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        spreadRadius: 1,
                                                        blurRadius: 3,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  child: TextField(
                                                    controller: rpass,
                                                    style: TextStyle(
                                                      color: Color(0xFF524B6B),
                                                      fontSize: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width * 0.040,
                                                      fontFamily: GoogleFonts
                                                          .dmSans()
                                                          .fontFamily,
                                                      fontWeight: FontWeight
                                                          .w500,),

                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding: EdgeInsets
                                                          .symmetric(
                                                          vertical: 15.0),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Container(
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width * 0.3,
                                                  child: CupertinoButton(
                                                    onPressed: () {
                                                      Navigator.pushNamed(
                                                          context, "/profile");
                                                    },
                                                    color: Color(0xFFFED9CD),
                                                    padding: EdgeInsets
                                                        .symmetric(
                                                        vertical: 15.0),
                                                    borderRadius: BorderRadius
                                                        .circular(10.0),
                                                    child: Text(
                                                      'CLEAR',
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                        fontWeight: FontWeight
                                                            .bold,
                                                        fontSize: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width * 0.040,
                                                        letterSpacing: 2,
                                                        fontFamily: GoogleFonts
                                                            .dmSans()
                                                            .fontFamily,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width * 0.3,
                                                  child: CupertinoButton(
                                                    onPressed: () {
                                                      UpdateMypasword();



                                                    },
                                                    color: Color(0xFF68188B),
                                                    padding: EdgeInsets
                                                        .symmetric(
                                                        vertical: 15.0),
                                                    borderRadius: BorderRadius
                                                        .circular(10.0),
                                                    child: Text(
                                                      'SAVE',
                                                      style: TextStyle(
                                                        color: Color(
                                                            0xFFFFFFFF),
                                                        letterSpacing: 2,
                                                        fontWeight: FontWeight
                                                            .bold,
                                                        fontSize: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width * 0.040,
                                                        fontFamily: GoogleFonts
                                                            .dmSans()
                                                            .fontFamily,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),

                    ],
                  ),
                ),
              ),


              Card(
                color: Color(0xFFF9F9F9), // Full width card background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 0.0, top: 0),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFE2E5F4),
                            // Icon box background color
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.logout,
                            size: MediaQuery
                                .of(context)
                                .size
                                .width * 0.040,
                            color: Color(0xFF68188B), // Mail icon color
                          ),
                        ),
                      ),
                      SizedBox(width: 20), // Space between icon box and text
                      Expanded(
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Color(0xFF000000),
                            fontSize: MediaQuery
                                .of(context)
                                .size
                                .width * 0.040,
                            fontWeight: FontWeight.w400,
                            fontFamily: GoogleFonts
                                .poppins()
                                .fontFamily,

                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios,
                            size: MediaQuery
                                .of(context)
                                .size
                                .width * 0.040, color: Color(0xFF6E6F79)),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm Logout'),
                                content: Text(
                                    'Are you sure you want to logout?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Dismiss the dialog
                                    },
                                    child: Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      AppSp().setIsLogged(false);
                                      Navigator.pushReplacementNamed(
                                          context, '/login');
                                    },
                                    child: Text('Yes'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              //
              // SizedBox(height: 10,),
              // ElevatedButton(
              //   onPressed: () {
              //     showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return AlertDialog(
              //           title: Text('Confirm Logout'),
              //           content: Text('Are you sure you want to logout?'),
              //           actions: [
              //             TextButton(
              //               onPressed: () {
              //                 Navigator.of(context).pop(); // Dismiss the dialog
              //               },
              //               child: Text('No'),
              //             ),
              //             TextButton(
              //               onPressed: () {
              //                 AppSp().setIsLogged(false);
              //                 Navigator.pushReplacementNamed(context, '/login');
              //               },
              //               child: Text('Yes'),
              //             ),
              //           ],
              //         );
              //       },
              //     );
              //   },
              //   child: Text("Logout"),
              //   style: ElevatedButton.styleFrom(
              //     primary: Color(0xFF301C93),
              //     padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              //     textStyle: TextStyle(fontSize: 18),
              //   ),
              // )

              // ElevatedButton(
              //   onPressed: () {
              //     AppSp().setIsLogged(false);
              //     Navigator.pushReplacementNamed(context, '/login');
              //   },
              //   child: Text("Logout"),
              //   style: ElevatedButton.styleFrom(
              //     primary: Color(0xFF301C93),
              //     padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              //     textStyle: TextStyle(fontSize: 18),
              //   ),
              // ),
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            backgroundColor: Color(0xFF68188B),
            color: Colors.white,
            activeColor: Color(0xFF68188B),
            tabBackgroundColor: Colors.white,
            gap: 8,
            padding: EdgeInsets.all(3),
            selectedIndex: _currentIndex,
            onTabChange: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            // onTabChange: (index) {
            //   print(index);
            // },
            tabs: [
              GButton(
                icon: Icons.home_outlined,
                text: "Home",
                padding: EdgeInsets.all(3),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/dashHome');
                },
              ),
              GButton(
                icon: Icons.delivery_dining_outlined,
                text: "Pickup",
                padding: EdgeInsets.all(3),
                onPressed: () {
                  Navigator.pushReplacementNamed(
                      context, '/pickupOrderListing');
                },
              ),
              GButton(
                icon: Icons.how_to_vote_outlined,
                text: "Delivery",
                padding: EdgeInsets.all(3),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/delivery');
                },
              ),
              GButton(
                icon: Icons.av_timer,
                text: "History",
                padding: EdgeInsets.all(3),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/history');
                },
              ),
              GButton(
                icon: Icons.perm_identity,
                text: "Profile",
                padding: EdgeInsets.all(3),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/profile');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      {required String label, required String value, bool isSensitive = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF301C93),
          ),
        ),
        SizedBox(height: 10),
        isSensitive
            ? Row(
          children: [
            Expanded(
              child: Text(
                _isPasswordVisible ? value : '•' * value.length,
                // Show password if visible, otherwise mask it
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility),
              // Toggle icon based on password visibility
              onPressed: () {
                setState(() {
                  _isPasswordVisible =
                  !_isPasswordVisible; // Toggle password visibility
                });
              },
            ),
          ],
        )
            : Text(
          value,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (_currentIndex) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashHome');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, "/pickupOrderListing");
        break;
      case 2:
        Navigator.pushReplacementNamed(context, "/delivery");
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/history');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }


  void UpdateMypasword() async {
    var updateData = {
      "currentPass": cpass.text,
      "newPass": npass.text,
      "newConfPass": rpass.text
    };
    final response = await http.put(
        Uri.parse('${AppUrls.updatepass}$userID${AppUrls.code_main}$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken",
          "Content-Type": "application/json"
        },
        body: json.encode(updateData)
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      print("Password updated successfully: $responseData");

      // Check if 'error' exists and if it is a string
      if (responseData.containsKey('error') && responseData['error'] is String) {
        print('Error: ${responseData['error']}');
        // Optionally handle the error case here, e.g., show a dialog or toast
        EasyLoading.showToast("${responseData['error']}");
      } else {
        // If no error, proceed
        Navigator.of(context).pop();
        EasyLoading.showToast("Password Changed");
        Navigator.pushNamed(context, "/profile");
      }
    } else {
      // Handle other response statuses
      EasyLoading.showToast("Failed to update password");
    }


  }
}





