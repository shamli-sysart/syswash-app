import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';
import '../../../../utils/app_constant.dart';
import 'package:http/http.dart' as http;

import '../../../../utils/app_sp.dart';

import 'package:geocoding/geocoding.dart' as geocoding; // Import geocoding package with an alias
import 'package:flutter_svg/flutter_svg.dart';
class CustomerDetailsDelivery extends StatefulWidget {
  final String? orderId;
  final String? deliveryCustomerId;
  const CustomerDetailsDelivery({super.key,this.orderId,this.deliveryCustomerId});

  @override
  State<CustomerDetailsDelivery> createState() => _CustomerDetailsDeliveryState();
}

class _CustomerDetailsDeliveryState extends State<CustomerDetailsDelivery> {
  int _currentIndex = 2;
  String orderId = '';
  String tokenID = '';
  String userToken = "";
  String companyCode = "";
  String userID = "";
  List<Map<String, dynamic>> clothdata_order_existing = [];
  late Map<String, dynamic> responseData = {};
  int totalQty = 0;
  int totalQty1 = 0;
  int itemCount = 0;

  String formatedtime = "";
  String LoggerUsername = "";
  String formateddate = "";


  List<dynamic> customerDataList = [];
  String  deliveryCustomerId = '';

  @override
  void initState() {
    super.initState();
    orderId = widget.orderId ?? '';
    deliveryCustomerId = widget.deliveryCustomerId ?? '';

    getUserToken();
    var currentTime = DateTime.now();
    formatedtime = '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';
    var currentDate = DateTime.now();
    formateddate =
    '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';

  }
  Future<void> getUserToken() async {
    AppSp appSp = AppSp();
    userToken = await appSp.getToken();
    await fetchCustomerDiscount( deliveryCustomerId );
    companyCode = await appSp.getCompanyCode();
    LoggerUsername = await appSp.getUserName();
    await orderDetails(userToken,orderId);

  }
  void processResponseData(Map<String, dynamic> responseData) {
    this.responseData = responseData;
    setState((){});
  }
  void updateCounts() {
    itemCount = clothdata_order_existing.length;
    totalQty1 = 0;
    for (var cloth in clothdata_order_existing) {
      totalQty1 += int.parse(cloth['qnty'].toString());
    }
    totalQty =  totalQty1;

  }

  void processClothData(List<dynamic> clothData) {
    List<Map<String, dynamic>> newClothData = [];
    for (final cloth in clothData) {

      Map<String, dynamic> clothDataMap = {
        "priceId": cloth['priceId'],
        "clothName": cloth['clothName'],
        "arabicName": utf8.decode(cloth['arabicName'].runes.toList()),
        "clothImg": cloth['clothImg'],
        "qnty": cloth['qnty'],
        "service": cloth['service'],
        "billing": cloth['billing']
      };
      // Add fetched cloth data to the list
      newClothData.add(clothDataMap);
    }

    setState(() {
      clothdata_order_existing.addAll(newClothData);
      updateCounts();
      });



  }
  Future<void> fetchCustomerDiscount(String cus_id) async {
    final url = 'https://be.syswash.net/api/syswash/customerdetails/$cus_id?code=A';
    try {
      final response = await http.get(Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        },);
      if (response.statusCode == 200) {
        final customerDetails = jsonDecode(response.body);

        // Assuming you have a state variable to store the discount
        setState(() {
          customerDataList.add(customerDetails);
        });

        print('Customer Data List: $customerDataList'); // Debug print
      } else {
        print('Failed to load customer details, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching customer details: $e');
    }
  }

  Future<void> orderDetails(String userToken, String pickupOrderId) async {
    final response = await http.get(
        Uri.parse('https://be.syswash.net/api/syswash/order/$pickupOrderId?code=A'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        }
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      processResponseData(responseData);
      final clothData = responseData['clothData'] as List<dynamic>;
      // print(clothData);
      processClothData(clothData);
    } else {
      throw Exception('Failed to load data');
    }
  }

//itoooo ivdeeeeeee

  Future<geocoding.Location?> _findLocation(String placeName) async {
    try {
      List<geocoding.Location> locations = await geocoding.locationFromAddress(placeName); // Use the alias for geocoding package
      if (locations.isNotEmpty) {
        return locations.first;
      } else {
        print('Location not found');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> showMapOptions(String placeName,String latitudex, String longitudex) async {
    try {
      final availableMaps = await MapLauncher.installedMaps;
      final String destination = placeName;
      final latitude = double.parse(latitudex);
      final longitude = double.parse(longitudex);

      if (availableMaps.isNotEmpty) {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: availableMaps.map((map) {
                  return ListTile(
                    onTap: () {
                      map.showDirections(
                        destination: Coords(latitude, longitude),
                        destinationTitle: destination,
                      );
                      Navigator.pop(context);
                    },
                    title: Text(map.mapName),
                    leading: SvgPicture.asset(
                      map.icon,
                      width: 32,
                      height: 32,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      } else {
        print('No map applications installed');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
















  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    Map<String, Map<String, dynamic>> clothMap = {};
    Map<String, int> clothNameCount = {};

    clothdata_order_existing.forEach((cloth) {
      var clothName = cloth['clothName'];
      clothMap.putIfAbsent(clothName, () => cloth);
      clothNameCount[clothName] = (clothNameCount[clothName] ?? 0) + 1;
    });

    // Convert the unique items map to a list for the ListView
    List<Map<String, dynamic>> uniqueClothList = clothMap.values.toList();




    return Scaffold(
      backgroundColor: Color(0xFFEFEEF3),
      body: SingleChildScrollView(
        // Wrap the entire page with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // CircleAvatar(
                      //   backgroundImage: AssetImage('assets/profile_image.jpg'),
                      //   radius: 30,
                      // ),
                      // SizedBox(
                      //     width: 10), // Adjust spacing between circle and text
                      Text(
                        "$LoggerUsername",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          fontFamily: GoogleFonts.openSans().fontFamily,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications_outlined,
                        size: 45, color: Color(0xFF301C93)),
                    onPressed: () {
                      // Add your onPressed logic here
                    },
                  ),
                ],
              ),
              // dividerLH(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Collect now',
                    style: TextStyle(
                      fontSize: 23,
                      fontFamily: GoogleFonts.openSans().fontFamily,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF301C93),
                    ),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.arrow_back_outlined,
                        size: 22, color: Color(0xFF301C93)),
                    label: Text('Back',

                        style: TextStyle(color: Color(0xFF301C93),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: GoogleFonts.openSans().fontFamily,)),
                    onPressed: () {
                      Navigator.pushNamed(context, "/delivery");
                    },
                  ),
                ],
              ),
             SizedBox(height: 5,),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(15),
                          // child: CircleAvatar(
                          //   radius: 30,
                          //   backgroundImage: AssetImage('assets/avatar.png'),
                          // ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${responseData['customerName']}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: GoogleFonts.openSans().fontFamily,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                "${responseData['customerPhno']}",
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Row(
                                children: [
                                  Icon(Icons.location_on,color: Colors.red, size: 16.0),

                                  SizedBox(width: 5.0),
                                  Text(
                                    "${responseData['customerAddress']}",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: GoogleFonts.openSans().fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: customerDataList.isEmpty
                          ? Center(child: Text(''))
                          : Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Customer code',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: GoogleFonts.openSans().fontFamily,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      customerDataList[0]['cusCode'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: GoogleFonts.openSans().fontFamily,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Area',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: GoogleFonts.openSans().fontFamily,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      customerDataList[0]['area'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: GoogleFonts.openSans().fontFamily,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hotel',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        fontFamily: GoogleFonts.openSans().fontFamily,
                                      ),
                                    ),
                                    Text(
                                      customerDataList[0]['hotel'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: GoogleFonts.openSans().fontFamily,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reference No',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      customerDataList[0]['refNo'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: GoogleFonts.openSans().fontFamily,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Street Name',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: GoogleFonts.openSans().fontFamily,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      customerDataList[0]['streetNo'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: GoogleFonts.openSans().fontFamily,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'House Number',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: GoogleFonts.openSans().fontFamily,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      customerDataList[0]['villaNumber'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Expanded(
                              //   flex: 1,
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       Text(
                              //         'Postal Code',
                              //         style: TextStyle(
                              //           fontSize: 13,
                              //           fontFamily: GoogleFonts.openSans().fontFamily,
                              //           color: Colors.grey,
                              //         ),
                              //       ),
                              //       Text(
                              //         "${responseData['customerReffrNo']}",
                              //         style: TextStyle(
                              //           fontSize: 14,
                              //           fontFamily: GoogleFonts.openSans().fontFamily,
                              //           fontWeight: FontWeight.bold,
                              //           color: Colors.black,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fragrance',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: GoogleFonts.openSans().fontFamily,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      customerDataList[0]['fragrance'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: GoogleFonts.openSans().fontFamily,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Expanded(
                              //   flex: 1,
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       Text(
                              //         'House Number',
                              //         style: TextStyle(
                              //           fontSize: 13,
                              //           fontFamily: GoogleFonts.openSans().fontFamily,
                              //           color: Colors.grey,
                              //         ),
                              //       ),
                              //       Text(
                              //         "${responseData['customerRoomNo']}",
                              //         style: TextStyle(
                              //           fontSize: 14,
                              //           fontWeight: FontWeight.bold,
                              //           color: Colors.black,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Discount',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: GoogleFonts.openSans().fontFamily,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '0.0',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: GoogleFonts.openSans().fontFamily,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Expanded(
                              //   flex: 1,
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       Text(
                              //         'Town',
                              //         style: TextStyle(
                              //           fontSize: 13,
                              //           fontFamily: GoogleFonts.openSans().fontFamily,
                              //           color: Colors.grey,
                              //         ),
                              //       ),
                              //       Text(
                              //         "${responseData['customerAddress']}",
                              //         style: TextStyle(
                              //           fontSize: 14,
                              //           fontFamily: GoogleFonts.openSans().fontFamily,
                              //           fontWeight: FontWeight.bold,
                              //           color: Colors.black,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Expanded(
                              //   flex: 1,
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       Text(
                              //         'Bill Amount',
                              //         style: TextStyle(
                              //           fontSize: 13,
                              //           fontFamily: GoogleFonts.openSans().fontFamily,
                              //           color: Colors.grey,
                              //         ),
                              //       ),
                              //       Text(
                              //         "${responseData['totalAmount']}",
                              //         style: TextStyle(
                              //           fontSize: 14,
                              //           fontFamily: GoogleFonts.openSans().fontFamily,
                              //           fontWeight: FontWeight.bold,
                              //           color: Colors.black,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                  onPressed: () async {






                                    final availableMaps = await MapLauncher.installedMaps;
                                    print(availableMaps);

                                    //_findLocation('koppam,pattambi');
                                    final coordinates = await _findLocation("${responseData['customerAddress']}");
                                    print('Latitude: ${coordinates?.latitude}, Longitude: ${coordinates?.longitude}');


                                    await showMapOptions( "${responseData['customerAddress']}", '${coordinates?.latitude}', '${coordinates?.longitude}');









                                  },

                                  style: ElevatedButton.styleFrom(
                                    primary:  Color(0xFF301C93),
                                    onPrimary: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Location',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: GoogleFonts.openSans().fontFamily,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // SizedBox(height: 10)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Items',
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: GoogleFonts.openSans().fontFamily,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF301C93),
                    ),
                  ),
                  Text(
                      "${responseData['totalAmount']}",
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: GoogleFonts.openSans().fontFamily,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF301C93),
                    ),
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: uniqueClothList.length,
                itemBuilder: (context, index) {
                  var clothdata_order_existingx = clothdata_order_existing[clothdata_order_existing.length - 1 - index];

                  var clothItem = uniqueClothList[index];
                  var clothName = clothItem['clothName'];
                  var count = clothNameCount[clothName] ?? 0;



                  return Padding(
                    padding:
                    EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    child: Card(
                      child: ListTile(
                        leading: Image.network(
                          clothItem['clothImg'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey,
                              child: Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            );
                          },
                        ),
                        title: Text(
                          '$clothName',
                          style: TextStyle(
                            fontFamily: GoogleFonts.openSans().fontFamily,
                          ),
                        ),
                        subtitle: Text(
                          clothItem['arabicName'],
                          style: TextStyle(
                            fontFamily: GoogleFonts.openSans().fontFamily,
                          ),
                        ),

                        trailing: Text(
                          '${count > 1 ? count : ''}',
                          style: TextStyle(
                            fontFamily: GoogleFonts.openSans().fontFamily,
                          ),
                        ),
                        // trailing: IconButton(
                        //   icon: Icon(Icons.delete),
                        //   onPressed: () {
                        //     removeDataFromClothDate(index);
                        //
                        //   },
                        // ),
                      ),
                    ),
                  );
                },
              ),

              // SizedBox(height: 5),
              // Small card at the bottom
              // Card(
              //   child: Padding(
              //     padding: const EdgeInsets.all(10.0),
              //     child: Row(
              //       children: [
              //         ElevatedButton(
              //           onPressed: () {
              //             showDialog(
              //               context: context,
              //               builder: (BuildContext context) {
              //                 return Dialog(
              //                   backgroundColor: Color(0xFFEFEEF3),
              //                   shape: RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(15.0),
              //                   ),
              //                   child: Stack(
              //                     children: [
              //                       Container(
              //                         width: 280,
              //                         height: 220,
              //                         child: SingleChildScrollView(
              //                           child: Padding(
              //                             padding: const EdgeInsets.all(30.0),
              //                             child: Column(
              //                               mainAxisAlignment: MainAxisAlignment.center,
              //                               crossAxisAlignment: CrossAxisAlignment.start,
              //                               children: [
              //                                 Text(
              //                                   'Status',
              //                                   style: TextStyle(
              //                                     fontWeight: FontWeight.bold,
              //                                     color: Color(0xFF301C93),
              //                                     fontFamily: GoogleFonts.openSans().fontFamily,
              //                                     fontSize: 26.0,
              //                                   ),
              //                                 ),
              //                                 SizedBox(height: 25),
              //                                 Text(
              //                                   "Update The Product Status",
              //                                   style: TextStyle(
              //                                     fontSize: 18,
              //                                     fontFamily: GoogleFonts.openSans().fontFamily,
              //                                   ),
              //                                 ),
              //                                 SizedBox(height: 25),
              //                                 Row(
              //                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                                   children: [
              //                                      // Add spacing between buttons
              //                                     Expanded(
              //                                       child: Container(
              //                                         padding: const EdgeInsets.all(10.0),
              //                                         height: 50,
              //                                         decoration: BoxDecoration(
              //                                           borderRadius: BorderRadius.circular(10.0),
              //                                           color: Color(0xFF301C93),
              //                                         ),
              //                                         child: TextButton(
              //                                           onPressed: () {
              //                                               // Debugging: Print the entire responseData to understand its structure and content
              //                                               print("Response Data: $responseData.['deliveryassgn'][0]['status']");
              //
              //
              //                                               print("${responseData['deliveryassgn'][0]['status']}");
              //                                               String status = "${responseData['deliveryassgn'][0]['status']}";
              //
              //                                               if (status == 'Assigned'){
              //                                                 statuscompleted("${responseData['deliveryassgn'][0]['deliveryassgnId']}");
              //                                               }else{
              //                                                 EasyLoading.showToast( "Already Assigned or Completed");
              //                                               }
              //
              //
              //                                           },
              //                                           child: Text(
              //                                             'Delivery Completed',
              //                                             style: TextStyle(
              //                                               color: Colors.white,
              //                                               fontFamily: GoogleFonts.openSans().fontFamily,
              //                                               fontSize: 10,
              //                                             ),
              //                                           ),
              //                                         ),
              //                                       ),
              //                                     ),
              //                                   ],
              //                                 ),
              //                               ],
              //
              //                             ),
              //                           ),
              //                         ),
              //                       ),
              //                       Positioned(
              //                         top: 0,
              //                         right: 0,
              //                         child: GestureDetector(
              //                           onTap: () {
              //                             Navigator.of(context).pop();
              //                           },
              //                           child: CircleAvatar(
              //                             radius: 20.0,
              //                             backgroundColor: Color(0xFF301C93),
              //                             child: Icon(Icons.close, color: Colors.white ,size: 30,),
              //                           ),
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                 );
              //               },
              //             );
              //
              //           },
              //           style: ElevatedButton.styleFrom(
              //             padding: const EdgeInsets.all(10.0),
              //             primary: Color(0xFF301C93), // Background color
              //             onPrimary: Colors.white, // Text color
              //             shape: RoundedRectangleBorder(
              //               borderRadius:
              //               BorderRadius.circular(10), // Border radius
              //             ),
              //           ),
              //           child: Text('Delivery now',style: TextStyle(  fontFamily: GoogleFonts.openSans().fontFamily,fontSize: 12),),
              //         ),
              //         SizedBox(width: 10),
              //         Expanded(
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Text(
              //                 'ITEMS : $itemCount',
              //                 style: TextStyle(
              //                   fontSize: 13,
              //                   fontFamily:
              //                   GoogleFonts.openSans().fontFamily,
              //                   fontWeight: FontWeight.bold,
              //                   color: Color(0xFF301C93),
              //                 ),
              //               ),
              //               SizedBox(width: 30),
              //               Text(
              //                 'QTY : $totalQty',
              //                 style: TextStyle(
              //                   fontSize: 13,
              //                   fontFamily:
              //                   GoogleFonts.openSans().fontFamily,
              //                   fontWeight: FontWeight.bold,
              //                   color: Color(0xFF301C93),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),


              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: Color(0xFFEFEEF3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 400,
                                      height: 220,
                                      child: SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.all(30.0),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Status',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF301C93),
                                                  fontFamily:
                                                  GoogleFonts.openSans()
                                                      .fontFamily,
                                                  fontSize: 26.0,
                                                ),
                                              ),
                                              SizedBox(height: 25),
                                              Text(
                                                "Update The Product Status",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily:
                                                  GoogleFonts.openSans()
                                                      .fontFamily,
                                                ),
                                              ),
                                              SizedBox(height: 25),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                      const EdgeInsets.all(
                                                          10.0),
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(10.0),
                                                        color:
                                                        Color(0xFF301C93),
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                            context) {
                                                              return Dialog(
                                                                backgroundColor:
                                                                Color(
                                                                    0xFFEFEEF3),
                                                                shape:
                                                                RoundedRectangleBorder(
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      15.0),
                                                                ),
                                                                child: Stack(
                                                                  children: [
                                                                    Container(
                                                                      width:
                                                                      400,
                                                                      height:
                                                                      220,
                                                                      child:
                                                                      SingleChildScrollView(
                                                                        child:
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              30.0),
                                                                          child:
                                                                          Column(
                                                                            mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                            crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                'Pay Now',
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.bold,
                                                                                  color: Color(0xFF301C93),
                                                                                  fontFamily: GoogleFonts.openSans().fontFamily,
                                                                                  fontSize: 23.0,
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 25),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                        "Order Number ",
                                                                                        style: TextStyle(
                                                                                          fontSize: 18,
                                                                                          fontFamily: GoogleFonts.openSans().fontFamily,
                                                                                          color: Colors.grey,
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(height: 10),
                                                                                      Text(
                                                                                        "${responseData['orderId']}",
                                                                                        style: TextStyle(
                                                                                          fontSize: 18,
                                                                                          fontFamily: GoogleFonts.openSans().fontFamily,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                        "Bill amount ",
                                                                                        style: TextStyle(
                                                                                          fontSize: 18,
                                                                                          fontFamily: GoogleFonts.openSans().fontFamily,
                                                                                          color: Colors.grey,
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(height: 10),
                                                                                      Text(
                                                                                          "${responseData['totalAmount']}",
                                                                                        style: TextStyle(
                                                                                          fontSize: 18,
                                                                                          fontFamily: GoogleFonts.openSans().fontFamily,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              // SizedBox(height: 20),
                                                                              // TextField(
                                                                              //   decoration: InputDecoration(
                                                                              //     border: InputBorder.none,
                                                                              //     hintText: 'Amount',
                                                                              //     hintStyle: TextStyle(color: Color(0xFFC5C5C5)),
                                                                              //     fillColor: Color(0xFFF9F9F9),
                                                                              //     filled: true,
                                                                              //     contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                                                                              //     enabledBorder: OutlineInputBorder(
                                                                              //       borderSide: BorderSide(color: Colors.transparent),
                                                                              //       borderRadius: BorderRadius.circular(15.0),
                                                                              //     ),
                                                                              //     focusedBorder: OutlineInputBorder(
                                                                              //       borderSide: BorderSide(color: Colors.transparent),
                                                                              //       borderRadius: BorderRadius.circular(15.0),
                                                                              //     ),
                                                                              //   ),
                                                                              // ),
                                                                              SizedBox(height: 20),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                children: [
                                                                                  Spacer(), // Push the button to the right
                                                                                  ElevatedButton(
                                                                                    onPressed: () {
                                                                                      print("Response Data: $responseData.['deliveryassgn'][0]['paymentstatus']");
                                                                                      print("${responseData['deliveryassgn'][0]['paymentstatus']}");
                                                                                      String paymentstatus = "${responseData['deliveryassgn'][0]['paymentstatus']}";

                                                                                      if (paymentstatus == 'pending') {
                                                                                        paymentStatus_Changer("${responseData['deliveryassgn'][0]['deliveryInvoiceNo']}");
                                                                                      } else {
                                                                                        EasyLoading.showToast("Payment Completed");
                                                                                      }
                                                                                    },
                                                                                    style: ElevatedButton.styleFrom(
                                                                                      backgroundColor: Color(0xFF1B1466),
                                                                                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0), // Adjust padding
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      ),
                                                                                    ),
                                                                                    child: Text(
                                                                                      'Submit',
                                                                                      style: TextStyle(fontSize: 16, fontFamily: GoogleFonts.openSans().fontFamily, fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                      top: 0,
                                                                      right: 0,
                                                                      child:
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child:
                                                                        CircleAvatar(
                                                                          radius:
                                                                          20.0,
                                                                          backgroundColor:
                                                                          Color(0xFF301C93),
                                                                          child: Icon(
                                                                              Icons.close,
                                                                              color: Colors.white,
                                                                              size: 30),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Text(
                                                          'Payment Now',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: GoogleFonts
                                                                .openSans()
                                                                .fontFamily,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                      10), // Add spacing between buttons
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                      const EdgeInsets.all(
                                                          10.0),
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(10.0),
                                                        color:
                                                        Color(0xFF301C93),
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          print(
                                                              "Response Data: $responseData.['deliveryassgn'][0]['status']");
                                                          print(
                                                              "${responseData['deliveryassgn'][0]['status']}");
                                                          String status =
                                                              "${responseData['deliveryassgn'][0]['status']}";

                                                          if (status ==
                                                              'Assigned') {
                                                            statuscompleted(
                                                                "${responseData['deliveryassgn'][0]['deliveryassgnId']}");
                                                          } else {
                                                            EasyLoading.showToast(
                                                                "Already Assigned or Completed");
                                                          }
                                                        },
                                                        child: Text(
                                                          'Completed',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: GoogleFonts
                                                                .openSans()
                                                                .fontFamily,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: CircleAvatar(
                                          radius: 20.0,
                                          backgroundColor: Color(0xFF301C93),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16.0),
                          primary: Color(0xFF301C93), // Background color
                          onPrimary: Colors.white, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(10), // Border radius
                          ),
                        ),
                        child: Text(
                          'Delivery now',
                          style: TextStyle(
                            fontFamily: GoogleFonts.openSans().fontFamily,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ITEMS : $itemCount',
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: GoogleFonts.openSans().fontFamily,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF301C93),
                              ),
                            ),
                            SizedBox(width: 30),
                            Text(
                              'QTY : $totalQty',
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: GoogleFonts.openSans().fontFamily,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF301C93),
                              ),
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
      bottomNavigationBar:  BottomNavigationBar(
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





  Future<void> statuscompleted(String deliveryassgnId) async {
    final response = await http.put(
      Uri.parse(
          'https://be.syswash.net/api/syswash/deliverystatus/$deliveryassgnId?code=A'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $userToken"
      },
      body: jsonEncode({
        "deliveredDateTime": formatedtime,
        "deliveryassgnId": deliveryassgnId,
        "status": "Dispatch",
        "paymentstatus":"collected"
      }),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 200 ||
          responseData['data']['status'] == "Dispatch") {
        EasyLoading.showToast("Success");
        Navigator.pushNamed(
          context,
          "/customDetailsDelivery",
          arguments: orderId,
        );
      } else {
        EasyLoading.showToast("Something Wrong!!!!");
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> paymentStatus_Changer(String deliveryassgnId) async {
    final response = await http.post(
      Uri.parse(
          'https://be.syswash.net/api/syswash/deliverypaymentdata?code=A'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $userToken"
      },
      body: jsonEncode({
        "deliveryInvoiceNo_id": deliveryassgnId,
        "deliveryDate": formateddate,
        "paymentstatus": "collected"
      }),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 200 ||
          responseData['data']['paymentstatus'] == "collected") {
        EasyLoading.showToast("Payment collected");
        Navigator.pushNamed(
          context,
          "/customDetailsDelivery",
          arguments: orderId,
        );
      } else {
        EasyLoading.showToast("Something Wrong!!!!");
      }
    } else {
      throw Exception('Failed to load data');
    }
  }



  //
  //
  // Future<void> statuscompleted(String deliveryassgnId) async {
  //   final response = await http.put(
  //     Uri.parse('https://be.syswash.net/api/syswash/deliverystatus/$deliveryassgnId?code=A'),
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Accept": "application/json",
  //       "Authorization": "Bearer $userToken"
  //     },
  //     body: jsonEncode({
  //       "deliveredDateTime": formatedtime,
  //       "deliveryassgnId": deliveryassgnId,
  //       "status":"Delivered",
  //       "paymentstatus":"collected"
  //     }),
  //   );
  //   if (response.statusCode == 200) {
  //     final responseData = json.decode(response.body);
  //     if (responseData['status'] == 200 || responseData['data']['status'] == "Dispatch") {
  //       AppSp().setLastDelivery(deliveryassgnId.toString());
  //       EasyLoading.showToast( "Delivery Completed");
  //       Navigator.pushNamed(
  //         context,
  //         "/delivery",
  //       );
  //     }else{
  //       EasyLoading.showToast( "Something Wrong!!!!");
  //     }
  //   } else {
  //     throw Exception('Failed to load data');
  //   }
  // }
  //
  //
  //
  // Future<void> paymentStatus_Changer(String deliveryassgnId) async {
  //   final response = await http.post(
  //     Uri.parse(
  //         'https://be.syswash.net/api/syswash/deliverypaymentdata?code=A'),
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Accept": "application/json",
  //       "Authorization": "Bearer $userToken"
  //     },
  //     body: jsonEncode({
  //       "deliveryInvoiceNo_id": deliveryassgnId,
  //       "deliveryDate": formateddate,
  //       "paymentstatus": "collected"
  //     }),
  //   );
  //   if (response.statusCode == 200) {
  //     final responseData = json.decode(response.body);
  //     if (responseData['status'] == 200 ||
  //         responseData['data']['paymentstatus'] == "collected") {
  //       EasyLoading.showToast("Successfully paid");
  //       Navigator.pushNamed(
  //         context,
  //         "/customDetailsDelivery",
  //         arguments: orderId,
  //       );
  //     } else {
  //       EasyLoading.showToast("Something Wrong!!!!");
  //     }
  //   } else {
  //     throw Exception('Failed to load data');
  //   }
  // }

}
