import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      {'label': 'Password', 'value': _profileData['password'] ?? '', 'isSensitive': 'true'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(fontSize: 30)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, "/dashHome");
          },
        ),
        backgroundColor: Color(0xFF301C93),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              logo1, // Replace with your logo image path
              height: 100, // Set the desired height
              width: 150, // Set the desired width
            ),
            const SizedBox(height: 15),
            Text(
              _profileData['name'] ?? '',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: profileItems.length,
                itemBuilder: (context, index) {
                  final item = profileItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildDetailItem(
                      label: item['label']!,
                      value: item['value']!,
                      isSensitive: item['isSensitive'] == 'true',
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirm Logout'),
                      content: Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Dismiss the dialog
                          },
                          child: Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            AppSp().setIsLogged(false);
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text('Yes'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text("Logout"),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF301C93),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
            )

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_crash),
            label: 'Pickup',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_crash),
            label: 'Delivery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
        selectedItemColor: Color(0xFF301C93),
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        iconSize: 26.0,
      ),
    );
  }

  Widget _buildDetailItem({required String label, required String value, bool isSensitive = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color:  Color(0xFF301C93),
          ),
        ),
        SizedBox(height: 10),
        isSensitive
            ? Row(
          children: [
            Expanded(
              child: Text(
                _isPasswordVisible ? value : '•' * value.length, // Show password if visible, otherwise mask it
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility), // Toggle icon based on password visibility
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility
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
}







// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../../../utils/app_constant.dart';
// import '../../../utils/app_sp.dart';
// import '../../../utils/app_url.dart';
//
// class Profile extends StatefulWidget {
//   const Profile({super.key});
//
//   @override
//   State<Profile> createState() => _ProfileState();
// }
//
// class _ProfileState extends State<Profile> {
//   int _currentIndex = 4;
//
//   String tokenID = '';
//   String userToken = "";
//   String companyCode = "";
//   String userID = "";
//   Map<String, dynamic> _profileData = {};
//
//   bool _isPasswordVisible = false;
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
//     fetchProfileData(userToken, companyCode, userID);
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   void fetchProfileData(String userToken, String companyCode, String userID) async {
//     final response = await http.get(
//         Uri.parse('${AppUrls.profile}$userID${AppUrls.code_main}$companyCode'),
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer $userToken"
//         }
//     );
//     if (response.statusCode == 200) {
//       final responseData = json.decode(response.body);
//       setState(() {
//         _profileData = responseData;
//       });
//     } else {
//       print("Failed to fetch data: ${response.statusCode}");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<Map<String, String>> profileItems = [
//       {'label': 'Email', 'value': _profileData['email'] ?? ''},
//       {'label': 'Phone', 'value': _profileData['mobile']?.toString() ?? ''},
//       {'label': 'Gender', 'value': _profileData['gender'] ?? ''},
//       {'label': 'National Id', 'value': _profileData['nationalId'] ?? ''},
//       {'label': 'Place', 'value': _profileData['address'] ?? ''},
//       {'label': 'Password', 'value': _profileData['password'] ?? '', 'isSensitive': 'true'},
//     ];
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Profile", style: TextStyle(fontSize: 30)),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pushNamed(context, "/dashHome");
//           },
//         ),
//         backgroundColor: Color(0xFF301C93),
//       ),
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(40.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Image.asset(
//               logo1, // Replace with your logo image path
//               height: 100, // Set the desired height
//               width: 150, // Set the desired width
//             ),
//             const SizedBox(height: 15),
//             Text(
//               _profileData['name'] ?? '',
//               style: TextStyle(
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 5),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: profileItems.length,
//                 itemBuilder: (context, index) {
//                   final item = profileItems[index];
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: _buildDetailItem(
//                       label: item['label']!,
//                       value: item['value']!,
//                       isSensitive: item['isSensitive'] == 'true',
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 10,),
//             ElevatedButton(
//               onPressed: () {
//                 AppSp().setIsLogged(false);
//                 Navigator.pushReplacementNamed(context, '/login');
//               },
//               child: Text("Logout"),
//               style: ElevatedButton.styleFrom(
//                 primary: Color(0xFF301C93),
//                 padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                 textStyle: TextStyle(fontSize: 18),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.car_crash),
//             label: 'Pickup',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.car_crash),
//             label: 'Delivery',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.compare_arrows),
//             label: 'History',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Me',
//           ),
//         ],
//         selectedItemColor: Color(0xFF301C93),
//         selectedFontSize: 12.0,
//         unselectedFontSize: 12.0,
//         iconSize: 26.0,
//       ),
//     );
//   }
//
//   Widget _buildDetailItem({required String label, required String value, bool isSensitive = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           '$label:',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(width: 10),
//         isSensitive
//             ? Row(
//           children: [
//             Text(
//               _isPasswordVisible ? value : '•' * value.length, // Show password if visible, otherwise mask it
//               style: TextStyle(
//                 fontSize: 16,
//               ),
//             ),
//             IconButton(
//               icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility), // Toggle icon based on password visibility
//               onPressed: () {
//                 setState(() {
//                   _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility
//                 });
//               },
//             ),
//           ],
//         )
//             : Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//
//     switch (_currentIndex) {
//       case 0:
//         Navigator.pushReplacementNamed(context, '/dashHome');
//         break;
//       case 1:
//         Navigator.pushReplacementNamed(context, "/pickupOrderListing");
//         break;
//       case 2:
//         Navigator.pushReplacementNamed(context, "/delivery");
//         break;
//       case 3:
//         Navigator.pushReplacementNamed(context, '/history');
//         break;
//       case 4:
//         Navigator.pushReplacementNamed(context, '/profile');
//         break;
//     }
//   }
// }




// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../../../utils/app_constant.dart';
// import '../../../utils/app_sp.dart';
// import '../../../utils/app_url.dart';
//
// class Profile extends StatefulWidget {
//   const Profile({super.key});
//
//   @override
//   State<Profile> createState() => _ProfileState();
// }
//
// class _ProfileState extends State<Profile> {
//   int _currentIndex = 4;
//
//   String tokenID = '';
//   String userToken = "";
//   String companyCode = "";
//   String userID = "";
//   Map<String, dynamic> _profileData = {};
//
//   bool _isPasswordVisible = false;
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
//     fetchProfileData(userToken, companyCode, userID);
//
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   void fetchProfileData( String userToken, String companyCode, String userID) async {
//     final response = await http.get(
//         Uri.parse('${AppUrls.profile}$userID${AppUrls.code_main}$companyCode'),
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer $userToken"
//         }
//     );
//     if (response.statusCode == 200) {
//       final responseData = json.decode(response.body);
//       setState(() {
//         // Update the profile details with the fetched data
//         _profileData = responseData;
//       });
//     } else {
//       print("Failed to fetch data: ${response.statusCode}");
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return  Scaffold(
//       appBar: AppBar(title: Text("profile",style: TextStyle(fontSize: 30),),
//       leading: IconButton(icon: Icon(Icons.arrow_back),
//       onPressed: (){Navigator.pushNamed(context, "/dashHome");},),
//         backgroundColor: Color(0xFF301C93),),
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(40.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Image.asset(
//               logo1, // Replace with your logo image path
//               height: 100, // Set the desired height
//               width: 150, // Set the desired width
//             ),
//             const SizedBox(height: 15),
//             Text(
//               _profileData['name'] ?? '',
//               style: TextStyle(
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Row(
//                 children: const [
//                   ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             // Text Fields
//             Center(
//               child: Card(
//                 elevation: 5,
//                 margin: EdgeInsets.all(20),
//                 child: Container(
//                   padding: EdgeInsets.all(20),
//                   width: MediaQuery.of(context).size.width * 0.8,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Text(
//                       //   _profileData['name'] ?? '',
//                       //   style: TextStyle(
//                       //     fontSize: 25,
//                       //     fontWeight: FontWeight.bold,
//                       //   ),
//                       // ),
//                       SizedBox(height: 20),
//                       _buildDetailItem(label: 'Email', value: _profileData['email'] ?? ''),
//                       _buildDetailItem(label: 'Phone', value: _profileData['mobile']?.toString() ?? ''),
//                       _buildDetailItem(label: 'Gender', value: _profileData['gender'] ?? ''),
//                       _buildDetailItem(label: 'National Id', value: _profileData['nationalId'] ?? ''),
//                       _buildDetailItem(label: 'Place', value: _profileData['address'] ?? ''),
//                       _buildDetailItem(label: 'Password', value: _profileData['password'] ?? '', isSensitive: true),
//                       SizedBox(height: 20),
//                       ElevatedButton(onPressed:(){
//
//                         AppSp().setIsLogged(false);
//
//
//                         Navigator.pushReplacementNamed(context, '/login');
//                       }, child: Text("logout"),
//                       style: ElevatedButton.styleFrom(
//                         primary: Color(0xFF301C93),
//                         padding: EdgeInsets.symmetric(horizontal: 50,vertical: 15),
//                         textStyle: TextStyle(fontSize: 18)
//
//                       ),)
//
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//       ),
//       bottomNavigationBar:  BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.car_crash),
//             label: 'Pickup',
//           ),
//           BottomNavigationBarItem(
//             icon:Icon(Icons.car_crash),
//             label: 'Delivery',
//           ),
//           BottomNavigationBarItem(
//             icon:Icon(Icons.compare_arrows),
//             label: 'History',
//           ),
//           BottomNavigationBarItem(
//             icon:Icon(Icons.person),
//             label: 'Me',
//           ),
//         ],
//         selectedItemColor:Color(0xFF301C93),
//         selectedFontSize: 12.0,
//         unselectedFontSize: 12.0,
//         iconSize: 26.0,
//       ),
//     );
//   }
//
//   Widget _buildDetailItem({required String label, required String value, bool isSensitive = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           '$label:',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(width: 10),
//         isSensitive ? Row(
//           children: [
//             Text(
//               _isPasswordVisible ? value : "", // Show password if visible, otherwise mask it
//               style: TextStyle(
//                 fontSize: 16,
//               ),
//             ),
//             IconButton(
//               icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility), // Toggle icon based on password visibility
//               onPressed: () {
//                 setState(() {
//                   _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility
//                 });
//               },
//             ),
//           ],
//         ) : Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//           ),
//         ),
//       ],
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
//
//
// }