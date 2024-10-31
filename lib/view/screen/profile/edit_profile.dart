import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import '../../../utils/app_sp.dart';
import '../../../utils/app_url.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  int _currentIndex = 4;

  String tokenID = '';
  String userToken = "";
  String companyCode = "";
  String userID = "";
  String password = "";
  Map<String, dynamic> _profileData = {};



  String? selectedGender;


  TextEditingController driverName = TextEditingController();
  TextEditingController driverEmail = TextEditingController();
  TextEditingController driverPhoneNo = TextEditingController();
  TextEditingController driverGender = TextEditingController();
  TextEditingController driverLocation = TextEditingController();

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

  void fetchProfileData(String userToken, String companyCode, String userID) async {
    final response = await http.get(
        Uri.parse('${AppUrls.profile}$userID${AppUrls.code_main}$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        }
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print(responseData);
      setState(() {
        _profileData = responseData;
        driverName.text = responseData['name'];
        driverEmail.text = responseData['email'];
        driverPhoneNo.text = responseData['mobile'].toString();
        driverLocation.text = responseData['address'];
        selectedGender = responseData['gender'];
        password = responseData['password'];
      });
    } else {
      print("Failed to fetch data: ${response.statusCode}");
    }
  }

  void updateProfile() async {
    var updateData = {
      "name": driverName.text,
      "email": driverEmail.text,
      "mobile": driverPhoneNo.text,
      "gender": selectedGender,
      "address": driverLocation.text,
      "password": password
    };

    final response = await http.put(
        Uri.parse('${AppUrls.profile}$userID${AppUrls.code_main}$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken",
          "Content-Type": "application/json"
        },
        body: json.encode(updateData)
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print("Profile updated successfully: $responseData");
      EasyLoading.showToast("Details Updated Successfully");
      Navigator.pushNamed(context, "/profile");
    } else {
      print("Failed to update data: ${response.statusCode}");
      EasyLoading.showToast("Error: ${response.statusCode}");
      Navigator.pushNamed(context, "/editProfile");
    }
  }
















  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              size: MediaQuery.of(context).size.width * 0.060,color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, "/profile");
          },
        ),
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                "Edit Profile",
                style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.055, color: Colors.black,
                    fontFamily: GoogleFonts.poppins().fontFamily,
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
              // updateProfile();
            },
          ),
        ],
        automaticallyImplyLeading: false, // Prevents the default leading widget space
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name:',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.040,
                              fontFamily: GoogleFonts.dmSans().fontFamily,
                              color: Color(0xFF150A33),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius:
                              BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: driverName,
                              style:TextStyle(fontSize:MediaQuery.of(context).size.width * 0.040 ,
                                fontFamily: GoogleFonts.dmSans().fontFamily,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF524B6B,),),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.0),

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),


                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email:',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.040,
                              fontFamily: GoogleFonts.dmSans().fontFamily,
                              color: Color(0xFF150A33),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius:
                              BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: driverEmail,
                              style:TextStyle(color: Color(0xFF524B6B),
                                fontSize:MediaQuery.of(context).size.width * 0.040 ,
                                fontFamily: GoogleFonts.dmSans().fontFamily,
                                fontWeight: FontWeight.w500,),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.0),

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),


                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone no',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.040,
                              fontFamily: GoogleFonts.dmSans().fontFamily,
                              color: Color(0xFF150A33),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius:
                              BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: driverPhoneNo,
                              style:TextStyle(color: Color(0xFF524B6B),
                                fontSize:MediaQuery.of(context).size.width * 0.040 ,
                                fontFamily: GoogleFonts.dmSans().fontFamily,
                                fontWeight: FontWeight.w500,),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    // Expanded(
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text(
                    //         'Gender',
                    //         style: TextStyle(
                    //           fontSize: 16,
                    //           fontFamily: GoogleFonts.dmSans().fontFamily,
                    //           color: Color(0xFF150A33),
                    //           fontWeight: FontWeight.w700,
                    //         ),
                    //       ),
                    //       SizedBox(height: 10),
                    //       Container(
                    //         padding: EdgeInsets.symmetric(
                    //             horizontal: 12.0),
                    //         decoration: BoxDecoration(
                    //           color: Color(0xFFFFFFFF),
                    //           borderRadius:
                    //           BorderRadius.circular(10.0),
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
                    //           // controller: pickupdate,
                    //           style:TextStyle(color: Color(0xFF524B6B)),
                    //           decoration: InputDecoration(
                    //             border: InputBorder.none,
                    //             contentPadding: EdgeInsets.symmetric(
                    //                 vertical: 15.0),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),







                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gender',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.040,
                              fontFamily: GoogleFonts.dmSans().fontFamily,
                              color: Color(0xFF150A33),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: DropdownButtonFormField<String>(
                              value: selectedGender,
                              items: ['Male', 'Female', 'Other']
                                  .map((label) => DropdownMenuItem(
                                child: Text(label),
                                value: label,
                              ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value;
                                });
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                              ),
                              style: TextStyle(color: Color(0xFF524B6B),
                                fontSize:MediaQuery.of(context).size.width * 0.040 ,
                                fontFamily: GoogleFonts.dmSans().fontFamily,
                                fontWeight: FontWeight.w500,),
                            ),
                          ),
                        ],
                      ),
                    ),






                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.040,
                              fontFamily: GoogleFonts.dmSans().fontFamily,
                              color: Color(0xFF150A33),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius:
                              BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: driverLocation,
                              style:TextStyle(color: Color(0xFF524B6B),
                                fontSize:MediaQuery.of(context).size.width * 0.040 ,
                                fontFamily: GoogleFonts.dmSans().fontFamily,
                                fontWeight: FontWeight.w500,),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.0),

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),


                  ],
                ),


                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        updateProfile();
                        // EasyLoading.showToast("Details Updated Successfully");
                        // Navigator.pushNamed(context, "/profile");
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
                        'SAVE',
                        style: TextStyle(
                            fontSize:MediaQuery.of(context).size.width * 0.040 ,
                            fontFamily: GoogleFonts.dmSans().fontFamily,
                            fontWeight: FontWeight.w700),
                      ),
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
                  Navigator.pushReplacementNamed(context, '/pickupOrderListing');
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
}
