import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
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
  bool showDetails = false;
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

  // String selectedPaymentMethod = 'Credit Card'; // Initialize with default value
  String selectedPayment = "Cash";
  List<String> paymentOptions = ['Cash', 'Card','Tranfer'];

  static const List<String> list = <String>['One', 'Two', 'Three', 'Four'];
  String dropdownValue = list.first;


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

    companyCode = await appSp.getCompanyCode();

    LoggerUsername = await appSp.getUserName();
    await orderDetails(userToken,orderId);
    await fetchCustomerDiscount( deliveryCustomerId );

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
    final url = 'https://be.syswash.net/api/syswash/customerdetails/$cus_id?code=$companyCode';
    print(url);
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
        Uri.parse('https://be.syswash.net/api/syswash/order/$pickupOrderId?code=$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        }
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      processResponseData(responseData);
      final clothData = responseData['clothData'] as List<dynamic>;
      print(responseData);
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

    // Map<String, Map<String, dynamic>> clothMap = {};
    // Map<String, int> clothNameCount = {};
    //
    // clothdata_order_existing.forEach((cloth) {
    //   var clothName = cloth['clothName'];
    //   clothMap.putIfAbsent(clothName, () => cloth);
    //   clothNameCount[clothName] = (clothNameCount[clothName] ?? 0) + 1;
    // });
    //
    // // Convert the unique items map to a list for the ListView
    // List<Map<String, dynamic>> uniqueClothList = clothMap.values.toList();




    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,size: MediaQuery.of(context).size.width * 0.060),
          onPressed: () {
            Navigator.pushNamed(context, "/delivery");
          },
        ),
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                "Delivery Order",
                style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.050, color: Colors.black,
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
              // Add your settings action here
            },
          ),
        ],
        automaticallyImplyLeading: false, // Prevents the default leading widget space
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        // Wrap the entire page with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                decoration: BoxDecoration(
                  // color: Color(0xFFFFFFFF),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: customerDataList.isEmpty
                          ? Center(child: Text(''))
                          :
                      Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${responseData['customerName']} [${customerDataList[0]['cusCode']}]',

                                    style: TextStyle(
                                      color: Color(0xFF0B0B0B),
                                      fontWeight: FontWeight.w700,
                                      fontFamily: GoogleFonts.dmSans().fontFamily,
                                        fontSize:  MediaQuery.of(context).size.width * 0.040
                                    ),
                                  ),
                                  SizedBox(height: 5.0),

                                  Row(

                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Discount: ${customerDataList[0]['discount']
                                                  .toString()} %',
                                              style: TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontSize:  MediaQuery.of(context).size.width * 0.035,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: GoogleFonts.poppins().fontFamily
                                              ),
                                            ),
                                            // SizedBox(height: 5.0),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.phone_in_talk_sharp, color: Colors.black, size: 16.0),
                                                    SizedBox(width: 5.0),
                                                    Text(
                                                      "${responseData['customerPhno']}",
                                                      style: TextStyle(
                                                        fontSize:  MediaQuery.of(context).size.width * 0.038,
                                                        color: Color(0xFF0B0B0B),
                                                        fontWeight: FontWeight.w400,
                                                        fontFamily: GoogleFonts.dmSans().fontFamily,
                                                      ),
                                                    ),
                                                    SizedBox(width: 20.0),
                                                    Icon(Icons.location_on, color: Colors.black,
                                                      size:   MediaQuery.of(context).size.width * 0.035,),
                                                    SizedBox(width: 5.0),
                                                    Text(
                                                      "${responseData['customerAddress']}",
                                                      style: TextStyle(
                                                          fontSize:   MediaQuery.of(context).size.width * 0.035,
                                                          fontWeight: FontWeight.w400,
                                                          fontFamily: GoogleFonts.poppins().fontFamily
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                TextButton.icon(
                                                  style: TextButton.styleFrom(
                                                    padding: EdgeInsets.zero,
                                                    // maximumSize: Size(0,0),
                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      showDetails = !showDetails;
                                                    });
                                                  },

                                                  label: Text(
                                                    showDetails ? 'Close Details' : 'View Details',
                                                    style: TextStyle(color: Color(0xFF68188B,),
                                                        fontWeight: FontWeight.w600,
                                                        fontFamily: GoogleFonts.poppins().fontFamily,
                                                      fontSize:   MediaQuery.of(context).size.width * 0.035,
                                                    ),
                                                  ),
                                                  icon: Icon(
                                                    showDetails ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                                    color: Color(0xFF68188B,),
                                                  ),
                                                ),
                                              ],
                                            )
                                            // Row(
                                            //   children: [
                                            //     Icon(Icons.phone_in_talk_sharp, color: Colors.black, size: 16.0),
                                            //     SizedBox(width: 5.0),
                                            //     Text(
                                            //       "${responseData['customerPhno']}",
                                            //       style: TextStyle(
                                            //         fontSize: 13.0,
                                            //         color: Color(0xFF0B0B0B),
                                            //         fontWeight: FontWeight.w400,
                                            //         fontFamily: GoogleFonts.dmSans().fontFamily,
                                            //       ),
                                            //     ),
                                            //     SizedBox(width: 20.0),
                                            //     Icon(Icons.location_on, color: Colors.black, size: 16.0),
                                            //     SizedBox(width: 5.0),
                                            //     Text(
                                            //       "${responseData['customerAddress']}",
                                            //       style: TextStyle(
                                            //           fontSize: 13.0,
                                            //           fontWeight: FontWeight.w400,
                                            //           fontFamily: GoogleFonts.poppins().fontFamily
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),

                                          ],
                                        ),
                                      ),
                                      // TextButton.icon(
                                      //   onPressed: () {
                                      //     setState(() {
                                      //       showDetails = !showDetails;
                                      //     });
                                      //   },
                                      //
                                      //   label: Text(
                                      //     showDetails ? 'Close Details' : 'View Details',
                                      //     style: TextStyle(color: Color(0xFF68188B,),
                                      //         fontWeight: FontWeight.w600,
                                      //         fontFamily: GoogleFonts.poppins().fontFamily
                                      //     ),
                                      //   ),
                                      //   icon: Icon(
                                      //     showDetails ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                      //     color: Color(0xFF68188B,),
                                      //   ),
                                      // ),
                                    ],
                                  ),

                                ],
                              ),
                            ),
                          ),


                          // {customerId: 19, name: Hani, joinDate: 2024-06-08, email: , mobile: 66778900, streetNo: , villaNumber: , roomNo: , refNo: , cusCode: JL0019, area: Doha, hotel: , discount: 0.0, acType: MobileApp, deliveryType: PICKUP AND DELIVERY, openingBalance: 0.0, wallet: 0.0, cusPaidAmount: 0.0, cusBalance: 0.0, fragrance: , zone: , packingType: , starch: , trash: false}

                          if (showDetails)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
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
                                                'Area',
                                                style: TextStyle(
                                                  fontSize:   MediaQuery.of(context).size.width * 0.038,
                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                customerDataList[0]['area'] ?? '--',
                                                style: TextStyle(
                                                  fontSize:   MediaQuery.of(context).size.width * 0.042,
                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Hotel',
                                                style: TextStyle(
                                                  fontSize:   MediaQuery.of(context).size.width * 0.038,
                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                customerDataList[0]['hotel'] ?? '--',
                                                style: TextStyle(
                                                  fontSize:   MediaQuery.of(context).size.width * 0.042,
                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Street Name',
                                                style: TextStyle(
                                                  fontSize:   MediaQuery.of(context).size.width * 0.038,
                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                customerDataList[0]['streetNo'] ?? '--',
                                                style: TextStyle(
                                                  fontSize:   MediaQuery.of(context).size.width * 0.042,
                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // {customerId: 19, name: Hani, joinDate: 2024-06-08, email: , mobile: 66778900, streetNo: , villaNumber: , roomNo: , refNo: , cusCode: JL0019, area: Doha, hotel: , discount: 0.0, acType: MobileApp, deliveryType: PICKUP AND DELIVERY, openingBalance: 0.0, wallet: 0.0, cusPaidAmount: 0.0, cusBalance: 0.0, fragrance: , zone: , packingType: , starch: , trash: false}

                                    SizedBox(height: 25.0),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'House No',
                                                style: TextStyle(
                                                  fontSize:   MediaQuery.of(context).size.width * 0.038,
                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                customerDataList[0]['villaNumber'] ?? '--',
                                                style: TextStyle(
                                                  fontSize:   MediaQuery.of(context).size.width * 0.042,
                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Reference No',
                                                style: TextStyle(
                                                  fontSize:   MediaQuery.of(context).size.width * 0.038,
                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                customerDataList[0]['refNo'] ?? '--',
                                                style: TextStyle(
                                                  fontSize:   MediaQuery.of(context).size.width * 0.042,
                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Fragrence',
                                                style: TextStyle(
                                                  fontSize:   MediaQuery.of(context).size.width * 0.038,
                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                customerDataList[0]['fragrance'] ?? '--',
                                                style: TextStyle(
                                                  fontSize:   MediaQuery.of(context).size.width * 0.042,
                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 25.0),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Note',
                                                style: TextStyle(
                                                  fontSize:   MediaQuery.of(context).size.width * 0.038,
                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                "${responseData['notes']}",
                                                style: TextStyle(
                                                  fontSize:   MediaQuery.of(context).size.width * 0.042,
                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Remark',
                                                style: TextStyle(
                                                  fontSize:   MediaQuery.of(context).size.width * 0.038,
                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                "${responseData['remarks']}",
                                                style: TextStyle(
                                                  fontSize:   MediaQuery.of(context).size.width * 0.042,
                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [


                                            ],
                                          ),
                                        ),
                                      ],
                                    ),


                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),




                   ),
                  ],
                ),
              ),

              SizedBox(height: 5),
              Text(
                'Order Items',
                style: TextStyle(
                  fontSize:   MediaQuery.of(context).size.width * 0.045,
                  fontFamily: GoogleFonts.dmSans().fontFamily,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       'Order Items',
              //       style: TextStyle(
              //         fontSize: 18,
              //         fontFamily: GoogleFonts.openSans().fontFamily,
              //         fontWeight: FontWeight.bold,
              //         color: Color(0xFF301C93),
              //       ),
              //     ),
              //     // Text(
              //     //     "${responseData['totalAmount']}",
              //     //   style: TextStyle(
              //     //     fontSize: 25,
              //     //     fontFamily: GoogleFonts.openSans().fontFamily,
              //     //     fontWeight: FontWeight.bold,
              //     //     color: Color(0xFF301C93),
              //     //   ),
              //     // ),
              //   ],
              // ),
              // ListView.builder(
              //   padding: EdgeInsets.zero,
              //   shrinkWrap: true,
              //   itemCount: uniqueClothList.length,
              //   itemBuilder: (context, index) {
              //     var clothdata_order_existingx = clothdata_order_existing[clothdata_order_existing.length - 1 - index];
              //
              //     var clothItem = uniqueClothList[index];
              //     var clothName = clothItem['clothName'];
              //     var count = clothNameCount[clothName] ?? 0;
              //
              //
              //
              //     return Padding(
              //       padding: EdgeInsets.zero,
              //       child: Card(
              //
              //         child: ListTile(
              //          // contentPadding: EdgeInsets.zero,
              //           leading: Image.network(
              //             clothItem['clothImg'],
              //             fit: BoxFit.cover,
              //             errorBuilder: (context, error, stackTrace) {
              //               return Container(
              //                 width: 50,
              //                 height: 50,
              //                 color: Colors.grey,
              //                 child: Icon(
              //                   Icons.error,
              //                   color: Colors.red,
              //                 ),
              //               );
              //             },
              //           ),
              //           title: Text(
              //             '$clothName',
              //             style: TextStyle(
              //               fontFamily: GoogleFonts.openSans().fontFamily,
              //             ),
              //           ),
              //           subtitle: Text(
              //             clothItem['arabicName'],
              //             style: TextStyle(
              //               fontFamily: GoogleFonts.openSans().fontFamily,
              //             ),
              //           ),
              //
              //           trailing: Text(
              //             '${count > 1 ? count : ''}',
              //             style: TextStyle(
              //               fontFamily: GoogleFonts.openSans().fontFamily,
              //             ),
              //           ),
              //           // trailing: IconButton(
              //           //   icon: Icon(Icons.delete),
              //           //   onPressed: () {
              //           //     removeDataFromClothDate(index);
              //           //
              //           //   },
              //           // ),
              //         ),
              //       ),
              //     );
              //   },
              // ),


              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: clothdata_order_existing.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.zero,
                    child: Container(
                      decoration: BoxDecoration(
                          boxShadow: [
                      BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0.7,
                      blurRadius: 8,
                      offset: Offset(0, 1),
                    ),
                    ],
                  ),
                      child: Card(

                        child: ListTile(
                          leading: Image.network(
                            clothdata_order_existing[index]['clothImg'],
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
                            clothdata_order_existing[index]['service'],
                            style: TextStyle(
                              fontFamily: GoogleFonts.dmSans().fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize:MediaQuery.of(context).size.width * 0.035 ,
                            ),
                          ),
                          subtitle: Text(
                            clothdata_order_existing[index]['billing'],
                            style: TextStyle(
                              fontFamily: GoogleFonts.dmSans().fontFamily,
                              fontWeight: FontWeight.w700,
                                fontSize:MediaQuery.of(context).size.width * 0.030 ,
                              color: Color(0xFF68188B)
                            ),
                          ),

                          trailing: Text(
                            clothdata_order_existing[index]['qnty'].toString(),
                            style: TextStyle(
                              fontFamily: GoogleFonts.dmSans().fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize:MediaQuery.of(context).size.width * 0.035 ,
                            ),
                          ),

                        ),
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
                  padding: const EdgeInsets.all(13.0),
                  child: Row(
                    children: [



                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'QTY : $totalQty',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.dmSans().fontFamily,
                                    fontWeight: FontWeight.w700,
                                    fontSize:MediaQuery.of(context).size.width * 0.035 ,// Optional, for better emphasis
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Text(
                                  'AMOUNT :  ${responseData['totalAmount']}',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.dmSans().fontFamily,
                                    fontWeight: FontWeight.w700,
                                    fontSize:MediaQuery.of(context).size.width * 0.035 ,// Optional, for better emphasis
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),



                      SizedBox(width:8),

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
                                      height: 200,
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
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF68188B),
                                                  fontFamily:
                                                  GoogleFonts.dmSans()
                                                      .fontFamily,
                                                  fontSize:MediaQuery.of(context).size.width * 0.055 ,
                                                ),
                                              ),
                                              SizedBox(height: 25),
                                              Text(
                                                "Update The Product Status",
                                                style: TextStyle(
                                                  fontSize:MediaQuery.of(context).size.width * 0.045 ,
                                                  fontFamily:
                                                  GoogleFonts.dmSans()
                                                      .fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 25),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  // Expanded(
                                                  //   child: Container(
                                                  //     padding:
                                                  //     const EdgeInsets.all(
                                                  //         10.0),
                                                  //     height: 60,
                                                  //     decoration: BoxDecoration(
                                                  //       borderRadius:
                                                  //       BorderRadius
                                                  //           .circular(10.0),
                                                  //       color:
                                                  //       Color(0xFF301C93),
                                                  //     ),
                                                  //     child: TextButton(
                                                  //       onPressed: () {
                                                  //         showDialog(
                                                  //           context: context,
                                                  //           builder:
                                                  //               (BuildContext
                                                  //           context) {
                                                  //             return Dialog(
                                                  //               backgroundColor:
                                                  //               Color(
                                                  //                   0xFFEFEEF3),
                                                  //               shape:
                                                  //               RoundedRectangleBorder(
                                                  //                 borderRadius:
                                                  //                 BorderRadius
                                                  //                     .circular(
                                                  //                     15.0),
                                                  //               ),
                                                  //               child: Stack(
                                                  //                 children: [
                                                  //                   Container(
                                                  //                     width:
                                                  //                     400,
                                                  //                     height:
                                                  //                     450,
                                                  //                     child:
                                                  //
                                                  //                       Padding(
                                                  //                         padding: const EdgeInsets
                                                  //                             .all(
                                                  //                             30.0),
                                                  //                         child:
                                                  //                         Column(
                                                  //                           mainAxisAlignment:
                                                  //                           MainAxisAlignment.center,
                                                  //                           crossAxisAlignment:
                                                  //                           CrossAxisAlignment.start,
                                                  //                           children: [
                                                  //                             Text(
                                                  //                               'Pay Now',
                                                  //                               style: TextStyle(
                                                  //                                 fontWeight: FontWeight.bold,
                                                  //                                 color: Color(0xFF301C93),
                                                  //                                 fontFamily: GoogleFonts.openSans().fontFamily,
                                                  //                                 fontSize: 23.0,
                                                  //                               ),
                                                  //                             ),
                                                  //                             SizedBox(height: 25),
                                                  //                             Row(
                                                  //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  //                               children: [
                                                  //                                 Column(
                                                  //                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                                   children: [
                                                  //                                     Text(
                                                  //                                       "Order Number ",
                                                  //                                       style: TextStyle(
                                                  //                                         fontSize: 18,
                                                  //                                         fontFamily: GoogleFonts.openSans().fontFamily,
                                                  //                                         color: Colors.grey,
                                                  //                                       ),
                                                  //                                     ),
                                                  //                                     SizedBox(height: 10),
                                                  //                                     Text(
                                                  //                                       "${responseData['orderId']}",
                                                  //                                       style: TextStyle(
                                                  //                                         fontSize: 18,
                                                  //                                         fontFamily: GoogleFonts.openSans().fontFamily,
                                                  //                                       ),
                                                  //                                     ),
                                                  //                                   ],
                                                  //                                 ),
                                                  //                                 Column(
                                                  //                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                                   children: [
                                                  //                                     Text(
                                                  //                                       "Bill Amount ",
                                                  //                                       style: TextStyle(
                                                  //                                         fontSize: 18,
                                                  //                                         fontFamily: GoogleFonts.openSans().fontFamily,
                                                  //                                         color: Colors.grey,
                                                  //                                       ),
                                                  //                                     ),
                                                  //                                     SizedBox(height: 10),
                                                  //                                     Text(
                                                  //                                         "${responseData['totalAmount']}",
                                                  //                                       style: TextStyle(
                                                  //                                         fontSize: 18,
                                                  //                                         fontFamily: GoogleFonts.openSans().fontFamily,
                                                  //                                       ),
                                                  //                                     ),
                                                  //                                   ],
                                                  //                                 ),
                                                  //                               ],
                                                  //                             ),
                                                  //                             SizedBox(height: 5),
                                                  //                             Container(
                                                  //                                 padding: EdgeInsets.symmetric(horizontal: 12.0),
                                                  //                                 decoration: BoxDecoration(
                                                  //                                   color: Color(0xFFF9F9F9),
                                                  //                                   borderRadius: BorderRadius.circular(10.0),
                                                  //                                 ),
                                                  //                                 child:DropdownButton<String>(
                                                  //                                   value: dropdownValue,
                                                  //                                   icon: const Icon(Icons.arrow_downward),
                                                  //                                   elevation: 16,
                                                  //                                   style: const TextStyle(color: Colors.deepPurple),
                                                  //                                   underline: Container(
                                                  //                                     height: 2,
                                                  //                                     color: Colors.deepPurpleAccent,
                                                  //                                   ),
                                                  //                                   onChanged: (String? value) {
                                                  //                                     // This is called when the user selects an item.
                                                  //                                     setState(() {
                                                  //                                       dropdownValue = value!;
                                                  //                                     });
                                                  //                                   },
                                                  //                                   items: list.map<DropdownMenuItem<String>>((String value) {
                                                  //                                     return DropdownMenuItem<String>(
                                                  //                                       value: value,
                                                  //                                       child: Text(value),
                                                  //                                     );
                                                  //                                   }).toList(),
                                                  //                                 )
                                                  //
                                                  //                             ),
                                                  //                             // Column(
                                                  //                             //   crossAxisAlignment:
                                                  //                             //   CrossAxisAlignment
                                                  //                             //       .start,
                                                  //                             //   children: [
                                                  //                             //     Text(
                                                  //                             //       'Payment:',
                                                  //                             //       style: TextStyle(
                                                  //                             //         fontSize: 18,
                                                  //                             //         fontFamily: GoogleFonts.openSans().fontFamily,
                                                  //                             //         color: Colors.grey,
                                                  //                             //       ),
                                                  //                             //     ),
                                                  //                             //     SizedBox(height: 5),
                                                  //                             //     Container(
                                                  //                             //       padding: EdgeInsets
                                                  //                             //           .symmetric(
                                                  //                             //           horizontal:
                                                  //                             //           12.0),
                                                  //                             //       decoration:
                                                  //                             //       BoxDecoration(
                                                  //                             //         color:
                                                  //                             //         Color(0xFFF9F9F9),
                                                  //                             //         borderRadius:
                                                  //                             //         BorderRadius
                                                  //                             //             .circular(
                                                  //                             //             10.0),
                                                  //                             //       ),
                                                  //                             //       child: Column(
                                                  //                             //         children: paymentOptions.map((String value) {
                                                  //                             //           return RadioListTile<String>(
                                                  //                             //             title: Text(value),
                                                  //                             //             value: value,
                                                  //                             //             groupValue: selectedPayment,
                                                  //                             //             onChanged: (String? newValue) {
                                                  //                             //               setState(() {
                                                  //                             //                 selectedPayment = newValue!;
                                                  //                             //               });
                                                  //                             //             },
                                                  //                             //           );
                                                  //                             //         }).toList(),
                                                  //                             //       ),
                                                  //                             //     ),
                                                  //                             //     // Container(
                                                  //                             //     //   padding: EdgeInsets
                                                  //                             //     //       .symmetric(
                                                  //                             //     //       horizontal:
                                                  //                             //     //       12.0),
                                                  //                             //     //   decoration:
                                                  //                             //     //   BoxDecoration(
                                                  //                             //     //     color:
                                                  //                             //     //     Color(0xFFF9F9F9),
                                                  //                             //     //     borderRadius:
                                                  //                             //     //     BorderRadius
                                                  //                             //     //         .circular(
                                                  //                             //     //         10.0),
                                                  //                             //     //   ),
                                                  //                             //     //   child: DropdownButton<
                                                  //                             //     //       String>(
                                                  //                             //     //     isExpanded: true,
                                                  //                             //     //     value:
                                                  //                             //     //     selectedPayment,
                                                  //                             //     //     onChanged: (String?
                                                  //                             //     //     newValue) {
                                                  //                             //     //       setState(() {
                                                  //                             //     //         selectedPayment =
                                                  //                             //     //         newValue!;
                                                  //                             //     //       });
                                                  //                             //     //     },
                                                  //                             //     //     items: paymentOptions
                                                  //                             //     //         .map((String
                                                  //                             //     //     value) {
                                                  //                             //     //       return DropdownMenuItem<
                                                  //                             //     //           String>(
                                                  //                             //     //         value: value,
                                                  //                             //     //         child:
                                                  //                             //     //         Text(value),
                                                  //                             //     //       );
                                                  //                             //     //     }).toList(),
                                                  //                             //     //     hint: Text(
                                                  //                             //     //         'Select a payment type'),
                                                  //                             //     //   ),
                                                  //                             //     // ),
                                                  //                             //   ],
                                                  //                             // ),
                                                  //
                                                  //                             // DropdownButton<String>(
                                                  //                             //   items: <String>['Cash', 'Card', 'UPI transfer', ].map((String value) {
                                                  //                             //     return DropdownMenuItem<String>(
                                                  //                             //       value: value,
                                                  //                             //       child: Text(value),
                                                  //                             //     );
                                                  //                             //   }).toList(),
                                                  //                             //   onChanged: (_) {},
                                                  //                             // ),
                                                  //
                                                  //
                                                  //
                                                  //
                                                  //
                                                  //
                                                  //
                                                  //
                                                  //
                                                  //
                                                  //                             // TextField(
                                                  //                             //   decoration: InputDecoration(
                                                  //                             //     border: InputBorder.none,
                                                  //                             //     hintText: 'Amount',
                                                  //                             //     hintStyle: TextStyle(color: Color(0xFFC5C5C5)),
                                                  //                             //     fillColor: Color(0xFFF9F9F9),
                                                  //                             //     filled: true,
                                                  //                             //     contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                                                  //                             //     enabledBorder: OutlineInputBorder(
                                                  //                             //       borderSide: BorderSide(color: Colors.transparent),
                                                  //                             //       borderRadius: BorderRadius.circular(15.0),
                                                  //                             //     ),
                                                  //                             //     focusedBorder: OutlineInputBorder(
                                                  //                             //       borderSide: BorderSide(color: Colors.transparent),
                                                  //                             //       borderRadius: BorderRadius.circular(15.0),
                                                  //                             //     ),
                                                  //                             //   ),
                                                  //                             // ),
                                                  //                             SizedBox(height: 20),
                                                  //                             Row(
                                                  //                               mainAxisAlignment: MainAxisAlignment.end,
                                                  //                               children: [
                                                  //                                 Spacer(), // Push the button to the right
                                                  //                                 ElevatedButton(
                                                  //                                   onPressed: () {
                                                  //                                     print("Response Data: $responseData.['deliveryassgn'][0]['paymentstatus']");
                                                  //                                     print("${responseData['deliveryassgn'][0]['paymentstatus']}");
                                                  //                                     String paymentstatus = "${responseData['deliveryassgn'][0]['paymentstatus']}";
                                                  //
                                                  //                                     if (paymentstatus == 'Unpaid') {
                                                  //                                       paymentStatus_Changer("${responseData['deliveryassgn'][0]['deliveryassgnId']}");
                                                  //                                     } else {
                                                  //                                       EasyLoading.showToast("Payment Alrady Completed");
                                                  //                                     }
                                                  //                                   },
                                                  //                                   style: ElevatedButton.styleFrom(
                                                  //                                     backgroundColor: Color(0xFF1B1466),
                                                  //                                     padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0), // Adjust padding
                                                  //                                     shape: RoundedRectangleBorder(
                                                  //                                       borderRadius: BorderRadius.circular(10),
                                                  //                                     ),
                                                  //                                   ),
                                                  //                                   child: Text(
                                                  //                                     'Submit',
                                                  //                                     style: TextStyle(fontSize: 16, fontFamily: GoogleFonts.openSans().fontFamily, fontWeight: FontWeight.bold),
                                                  //                                   ),
                                                  //                                 ),
                                                  //                               ],
                                                  //                             ),
                                                  //                           ],
                                                  //                         ),
                                                  //                       ),
                                                  //
                                                  //                   ),
                                                  //                   Positioned(
                                                  //                     top: 0,
                                                  //                     right: 0,
                                                  //                     child:
                                                  //                     GestureDetector(
                                                  //                       onTap:
                                                  //                           () {
                                                  //                         Navigator.of(context)
                                                  //                             .pop();
                                                  //                       },
                                                  //                       child:
                                                  //                       CircleAvatar(
                                                  //                         radius:
                                                  //                         20.0,
                                                  //                         backgroundColor:
                                                  //                         Color(0xFF301C93),
                                                  //                         child: Icon(
                                                  //                             Icons.close,
                                                  //                             color: Colors.white,
                                                  //                             size: 30),
                                                  //                       ),
                                                  //                     ),
                                                  //                   ),
                                                  //                 ],
                                                  //               ),
                                                  //             );
                                                  //           },
                                                  //         );
                                                  //       },
                                                  //       child: Text(
                                                  //         'Pay Now',
                                                  //         style: TextStyle(
                                                  //           color: Colors.white,
                                                  //           fontFamily: GoogleFonts
                                                  //               .openSans()
                                                  //               .fontFamily,
                                                  //           fontSize: 10,
                                                  //         ),
                                                  //       ),
                                                  //     ),
                                                  //   ),
                                                  // ),



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
                                                        Color(0xFF00C05E),
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
                                                                child:
                                                                StatefulBuilder(
                                                                  builder: (BuildContext
                                                                  context,
                                                                      StateSetter
                                                                      setState) {
                                                                    return Stack(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                          400,
                                                                          height:
                                                                          330,
                                                                          child:
                                                                          Padding(
                                                                            padding:
                                                                            const EdgeInsets.all(30.0),
                                                                            child:
                                                                            Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  'Pay Now',
                                                                                  style: TextStyle(
                                                                                    fontWeight: FontWeight.w700,
                                                                                    color: Color(0xFF68188B),
                                                                                    fontFamily: GoogleFonts.dmSans().fontFamily,
                                                                                    fontSize:MediaQuery.of(context).size.width * 0.050 ,
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
                                                                                            fontSize:MediaQuery.of(context).size.width * 0.040 ,
                                                                                            fontFamily: GoogleFonts.dmSans().fontFamily,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Colors.grey,
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(height: 10),
                                                                                        Text(
                                                                                          "${responseData['orderId']}",
                                                                                          style:TextStyle(
                                                                                            fontSize:MediaQuery.of(context).size.width * 0.040 ,
                                                                                            fontFamily: GoogleFonts.poppins().fontFamily,
                                                                                            fontWeight: FontWeight.w600,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Text(
                                                                                          "Bill Amount ",
                                                                                          style: TextStyle(
                                                                                            fontSize:MediaQuery.of(context).size.width * 0.040 ,
                                                                                            fontFamily: GoogleFonts.dmSans().fontFamily,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Colors.grey,
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(height: 10),
                                                                                        Text(
                                                                                          "${responseData['totalAmount']}",
                                                                                          style: TextStyle(
                                                                                            fontSize:MediaQuery.of(context).size.width * 0.040 ,
                                                                                            fontFamily: GoogleFonts.poppins().fontFamily,
                                                                                              fontWeight: FontWeight.w600,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                SizedBox(height: 15),
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      'Payment:',
                                                                                      style: TextStyle(
                                                                                        fontSize:MediaQuery.of(context).size.width * 0.040 ,
                                                                                        fontFamily: GoogleFonts.dmSans().fontFamily,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        color: Colors.grey,
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(height: 5),
                                                                                    Container(
                                                                                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                                                                                      decoration: BoxDecoration(
                                                                                        color: Color(0xFFF9F9F9),
                                                                                        borderRadius: BorderRadius.circular(10.0),
                                                                                      ),
                                                                                      child: DropdownButton<String>(
                                                                                        isExpanded: true,
                                                                                        value: selectedPayment,
                                                                                        onChanged: (String? newValue) {
                                                                                          setState(() {
                                                                                            selectedPayment = newValue!;
                                                                                          });
                                                                                        },
                                                                                        items: paymentOptions.map((String value) {
                                                                                          return DropdownMenuItem<String>(
                                                                                            value: value,
                                                                                            child: Text(value),
                                                                                          );
                                                                                        }).toList(),
                                                                                        hint: Text('Select a payment type'),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                SizedBox(height: 20),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                                  children: [
                                                                                    Spacer(),
                                                                                    ElevatedButton(
                                                                                      onPressed: () {
                                                                                        print("Response Data: $responseData.['deliveryassgn'][0]['paymentstatus']");
                                                                                        print("${responseData['deliveryassgn'][0]['paymentstatus']}");
                                                                                        String paymentstatus = "${responseData['deliveryassgn'][0]['paymentstatus']}";

                                                                                        if (paymentstatus == 'Unpaid') {
                                                                                          paymentStatus_Changer("${responseData['deliveryassgn'][0]['deliveryassgnId']}");
                                                                                        } else {
                                                                                          EasyLoading.showToast("Payment Already Completed");
                                                                                        }
                                                                                      },
                                                                                      style: ElevatedButton.styleFrom(
                                                                                        backgroundColor: Color(0xFF68188B),
                                                                                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        ),
                                                                                      ),
                                                                                      child: Text(
                                                                                        'Submit',
                                                                                        style: TextStyle(
                                                                                          fontSize:MediaQuery.of(context).size.width * 0.040 ,
                                                                                          fontFamily: GoogleFonts.dmSans().fontFamily,
                                                                                          fontWeight: FontWeight.w700,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                          top:
                                                                          8,
                                                                          right:
                                                                          8,
                                                                          child:
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child:
                                                                            CircleAvatar(
                                                                              radius: 15.0,
                                                                              backgroundColor: Color(0xFF000000),
                                                                              child: Icon(
                                                                                Icons.close,
                                                                                color: Colors.white,
                                                                                size: 25,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Text(
                                                          'Pay Now',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: GoogleFonts
                                                                .dmSans()
                                                                .fontFamily,
                                                            fontSize:MediaQuery.of(context).size.width * 0.025 ,
                                                            fontWeight: FontWeight.w700,
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
                                                        Color(0xFF68188B),
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
                                                        'Delivered  Unpaid',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily: GoogleFonts.dmSans().fontFamily,
                                                          fontSize:MediaQuery.of(context).size.width * 0.025 ,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                        // maxLines: 3,
                                                        // overflow: TextOverflow.ellipsis,
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
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: CircleAvatar(
                                          radius: 15.0,
                                          backgroundColor: Color(0xFF000000),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 25,
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
                          padding: const EdgeInsets.all(10.0),
                          primary: Color(0xFF68188B), // Background color
                          onPrimary: Colors.white, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(10), // Border radius
                          ),
                        ),
                        child: Text(
                          'Delivery now',
                          style: TextStyle(
                            fontFamily: GoogleFonts.dmSans().fontFamily,

                          ),
                        ),
                      ),

                      // Expanded(
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       // Text(
                      //       //   'ITEMS : $itemCount',
                      //       //   style: TextStyle(
                      //       //     fontSize: 13,
                      //       //     fontFamily: GoogleFonts.openSans().fontFamily,
                      //       //     fontWeight: FontWeight.bold,
                      //       //     color: Color(0xFF301C93),
                      //       //   ),
                      //       // ),
                      //       // SizedBox(width: 10),
                      //       Text(
                      //         'QTY : $totalQty',
                      //         style: TextStyle(
                      //           fontSize: 12,
                      //           fontFamily: GoogleFonts.openSans().fontFamily,
                      //           fontWeight: FontWeight.bold,
                      //           color: Color(0xFF301C93),
                      //         ),
                      //       ),
                      //       SizedBox(width: 10),
                      //       Text(
                      //         'AMOUNT :  ${responseData['totalAmount']}',
                      //         style: TextStyle(
                      //           fontSize: 12,
                      //           fontFamily: GoogleFonts.openSans().fontFamily,
                      //           fontWeight: FontWeight.bold,
                      //           color: Color(0xFF301C93),
                      //         ),
                      //       ),
                      //
                      //     ],
                      //   ),
                      // ),
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
          'https://be.syswash.net/api/syswash/deliverystatus/$deliveryassgnId?code=$companyCode'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $userToken"
      },
      body: jsonEncode({
        "deliveredDateTime": "$formateddate $formatedtime",
        "deliveryassgnId": deliveryassgnId,
        "status":"Delivered",
      }),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 200 ||
          responseData['data']['status'] == "Dispatch") {
        AppSp().setLastDelivery(deliveryassgnId.toString());
        EasyLoading.showToast("Delivery Completed Successfully");
        Navigator.pushNamed(
          context,
          "/delivery",
        );
      } else {
        EasyLoading.showToast("Something Wrong!!!!");
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> paymentStatus_Changer(String deliveryassgnId) async {

    print(formateddate);
    print(formatedtime);
    // print("deliveredDateTime": "$formateddate $formatedtime"')
    //


    var abcdata = {
      "deliveredDateTime": "$formateddate $formatedtime",
      "deliveryassgnId": deliveryassgnId,
      "status":"Delivered",
      "paymentstatus":"collected"
    };
    print(abcdata);


    final response = await http.put(
      Uri.parse('https://be.syswash.net/api/syswash/deliverystatus/$deliveryassgnId?code=$companyCode'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $userToken"
      },
      body: jsonEncode({
        "deliveredDateTime": "$formateddate $formatedtime",
        "deliveryassgnId": deliveryassgnId,
        "status":"Delivered",
        "paymentstatus":"collected",
        "paymentMode": "$selectedPayment"
      }),
    );
    if (response.statusCode == 200) {

      final responseData = json.decode(response.body);
      // if (responseData['status'] == 200) {
        EasyLoading.showToast("Payment collected");
        //AppSp().setLastDelivery(deliveryassgnId.toString());
      // Navigator.of(context).pop();
        Navigator.pushNamed(
          context,
          "/delivery",
        );
      // } else {
      //   EasyLoading.showToast("Something Wrong!!!!");
      // }
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
