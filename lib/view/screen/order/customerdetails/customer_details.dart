import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syswash/service/api_service.dart';
import 'package:http/http.dart' as http;
import '../../../../utils/app_constant.dart';
import '../../../../utils/app_sp.dart';
import '../../../../utils/app_url.dart';
import 'bloc/customer_details_bloc.dart';
import 'package:geocoding/geocoding.dart' as geocoding; // Import geocoding package with an alias


class CustomerDetailsOrder extends StatefulWidget {



  @override
  State<CustomerDetailsOrder> createState() => _CustomerDetailsOrderState();
}

class _CustomerDetailsOrderState extends State<CustomerDetailsOrder> {
  bool showDetails = false;
  int _currentIndex = 1;
  late CustomerDetailsBloc _customerDetailsBloc;
  String tokenID = '';
  String userToken = "";
  String companyCode = "";
  String userID = "";

  String username_x = "";

  String pickupassgnId = '';
  String selectedService = "";
  List<String?> serviceNames = [];
  List<String?> serviceCodes = [];



  int PRICEID = 0;

  String ClothNameArabic = "";

  String ClothImage = "";

  List<Map<String, dynamic>> clothdate = [];
  List<Map<String, dynamic>> clothdata_order = [];
  List<Map<String, dynamic>> clothdata_order_existing = [];

  int totalQty = 0;
  int totalQty1 = 0;
  int totalQty2 = 0;
  int totalQty3 = 0;

  int itemCount = 0;

  String formatedtime = "";
  String formateddate = "";

  String passassignuserID = "";

  String _latitude = '';
  String _longitude = '';

  dynamic TheAlreadyprice = "";
  dynamic TheAlreadySubtotal = "";
  dynamic TheAlreadyPaidAmount = "";
  dynamic TheAlreadyDiscount = "";

  int customerDiscount = 0;

  List<dynamic> customerDataList = [];


  String pickupCustomerId = '';

  //pricelist:

  List<Map<String, dynamic>> priceListServiceCloth = [];
  late Map<String, dynamic> responseData = {};

  //String selectedServicexxx = "KAVYA";
  // List<String> clothNames = [];

  void filterClothNames(String selectedService) {
    clothNames.clear();
    for (var item in priceListServiceCloth) {
      if (item['serviceName'] == selectedService) {
        clothNames.add(item['clothType']);
      }
    }
  }

  void saveDataToClothDate(Map<String, dynamic> clothData) {
    int newQuantity;
    try {
      newQuantity = int.parse(clothData['qnty']);
    } catch (e) {
      print('Error parsing quantity: $e');
      return;
    }
    int index = clothdate.indexWhere((item) =>
    item['service'] == clothData['service'] &&
        item['billing'] == clothData['billing'] &&
        item['clothName'] == clothData['clothName']);

    if (index != -1) {
      setState(() {
        int existingQuantity;
        try {
          existingQuantity = int.parse(clothdate[index]['qnty']);
        } catch (e) {
          print('Error parsing existing quantity: $e');
          return;
        }
        clothdate[index]['qnty'] = (existingQuantity + newQuantity).toString();
        updateCounts();
      });
    } else {
      setState(() {
        clothData['qnty'] = newQuantity.toString();
        clothdate.add(clothData);
        updateCounts();
      });
    }
  }
  // void saveDataToClothDate(Map<String, dynamic> clothData) {
  //   setState(() {
  //     clothdate.add(clothData);
  //     updateCounts();
  //   });
  // }

  void removeDataFromClothDate(int index) {
    setState(() {
      clothdate.removeAt(index);
      updateCounts(); // Recalculate counts after removing an item
    });
  }

  void updateCounts() {
    itemCount = clothdate.length +
        clothdata_order.length +
        clothdata_order_existing.length;
    totalQty1 = 0;
    for (var cloth in clothdate) {
      totalQty1 += int.parse(cloth['qnty']);
    }
    totalQty2 = 0;
    for (var cloth in clothdata_order) {
      totalQty2 += int.parse(cloth['qnty'].toString());
    }
    totalQty3 = 0;
    for (var cloth in clothdata_order_existing) {
      totalQty3 += int.parse(cloth['qnty'].toString());
    }
    totalQty = totalQty1 + totalQty2 + totalQty3;
  }
  void processResponseData(Map<String, dynamic> responseData) {
    this.responseData = responseData;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    pickupassgnId = widget.pickupassgnId ?? '';
    pickupCustomerId = widget.pickupCustomerId ?? '';
    _customerDetailsBloc = CustomerDetailsBloc(ApiService());
    getUserToken();

    var currentTime = DateTime.now();
    formatedtime =
        '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';

    var currentDate = DateTime.now();
    formateddate =
        '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
  }

  Future<void> getUserToken() async {
    AppSp appSp = AppSp();
    userToken = await appSp.getToken();
    companyCode = await appSp.getCompanyCode();
    username_x = await appSp.getUserName();
    LoggerUsername = await appSp.getUserName();

    fetchServiceDetailsData(userToken, companyCode);
    fetchClouthDetailsData(userToken, companyCode);

    fetchPriceListDatas(userToken, companyCode);

    _customerDetailsBloc
        .add(CustomerDetailsApiEvent(userToken, companyCode, pickupassgnId));

    fetchCustomerDiscount(pickupCustomerId);
  }

  @override
  void dispose() {
    _customerDetailsBloc.close();
    super.dispose();
  }

  void fetchPriceListDatas(String userToken, String companyCode) async {
    final response = await http.get(
      Uri.parse('https://be.syswash.net/api/syswash/pricedetails?code=$companyCode'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $userToken"
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> responseData = jsonDecode(response.body);
      for (var data in responseData) {
        if (data is Map<String, dynamic>) {
          setState(() {
            priceListServiceCloth.add(data);
          });
        }
      }

      print("Price list data fetched successfully.");
    } else {
      print("Failed to fetch data: ${response.statusCode}");
    }
  }

  void fetchClouthDetailsData(String userToken, String companyCode) async {

    final response = await http.get(
        Uri.parse('${AppUrls.clothdetails}${AppUrls.code_main}$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        });
    if (response.statusCode == 200) {

      print(';;;;;;;;;;');
      print('${AppUrls.clothdetails}${AppUrls.code_main}$companyCode');
      print(response.body);
      print(';;;;;xxx;;;;;');

      List<Map<String, dynamic>> clothDataList = List<Map<String, dynamic>>.from(json.decode(response.body));
      setState(() {
        clothNames = clothDataList
            .map((clothData) => clothData['data']['clothName'] as String)
            .toList();
      });
    } else {
      print("Failed to fetch data: ${response.statusCode}");
    }
  }

  void fetchServiceDetailsData(String userToken, String companyCode) async {
    final response = await http.get(
        Uri.parse('${AppUrls.servicedetails}${AppUrls.code_main}$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        });
    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      // List<Map<String, String>> services = responseData.map((data) {
      //   return {
      //     'serviceName': data['serviceName'] as String,
      //     'serviceCode': data['serviceCode'] as String,
      //   };
      // }).toList();
      List<Map<String, String>> services = responseData.where((data) => data['posView'] == true).map((data) {
        return {
          'serviceName': data['serviceName'] as String,
          'serviceCode': data['serviceCode'] as String,
        };
      }).toList();


      print("fetchiing servicec is there >>>>>>>>");
      print(responseData);
      print(services);
      print("fetchiing servicec is top >>>>>>>>");



      setState(() {
        serviceNames =
            services.map((service) => service['serviceName']).toList();
        serviceCodes =
            services.map((service) => service['serviceCode']).toList();

        if (serviceNames.isNotEmpty) {
          selectedService = serviceNames[0]!;
        }
      });
    } else {
      print("Failed to fetch data: ${response.statusCode}");
    }
  }



  //fetch the slected servicec based clothes in new url api: https://be.syswash.net/api/syswash/pos/DRY CLEAN?&code=TRAIL

  void fetchServicesBasedClothList(String ServiceName_is) async {
    print('${AppUrls.fetchClothsbyServiceName}${ServiceName_is}?&code=$companyCode');
    final response = await http.get(
        Uri.parse('${AppUrls.fetchClothsbyServiceName}${ServiceName_is}?&code=$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        });
    if (response.statusCode == 200) {
       var responseData = json.decode(response.body);


       List<dynamic> clothDataList = responseData['data'];

      print("fetchiing servicec based cloths  is there >>>>>>>>");
      print(responseData);
      print(clothDataList);
      print("fetchiing servicec based cloth is top >>>>>>>>");


       setState(() {

         serviceBasedClothNames = clothDataList
             .map((clothData) => clothData['data']['clothType'] as String)
             .toList();
       });



    } else {
      print("Failed to fetch data: ${response.statusCode}");
    }
  }




















  // Fetch existing cloth data
  Future<void> OrderAlreadyExistClothdata(
      String userToken, String pickupOrderId) async {
    final response = await http.get(
        Uri.parse(
            'https://be.syswash.net/api/syswash/order/$pickupOrderId?code=$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      processResponseData(responseData);
      final clothData = responseData['clothData'] as List<dynamic>;
      //print(clothData);
      setState(() {
        TheAlreadyprice = responseData["totalAmount"];
        TheAlreadySubtotal = responseData["subTotal"];
        TheAlreadyPaidAmount = responseData["paidAmount"];
        TheAlreadyDiscount = responseData["discount"];
      });
      processClothData(clothData);
    } else {
      throw Exception('Failed to load data');
    }
  }

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







  Future<void> processClothData(List<dynamic> clothData) async {
    List<Map<String, dynamic>> newClothData = [];
    for (final cloth in clothData) {

      // final priceDetails = await fetchPriceDetails(cloth['priceId']);
      // double price = 0.0;
      // if (priceDetails != null) {
      //   if (selectedBilling == 'Express') {
      //     price = double.tryParse(priceDetails['xprice'].toString()) ?? 0.0;
      //   } else {
      //     price = double.tryParse(priceDetails['price'].toString()) ?? 0.0;
      //   }
      // }
      Map<String, dynamic> clothDataMap = {
        "qnty": cloth['qnty'],
        "unit": "PCS",
        "billing": cloth['billing'],
        "priceId": cloth['priceId'],
        "service": cloth['service'],
        "clothImg": cloth['clothImg'],
        "clothName": cloth['clothName'],
        "arabicName": utf8.decode(cloth['arabicName'].runes.toList()),
        "clothPrice":cloth['clothPrice']
      };
      newClothData.add(clothDataMap);
    }

    setState(() {
      clothdata_order_existing.addAll(newClothData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _customerDetailsBloc,
      child: BlocConsumer<CustomerDetailsBloc, CustomerDetailsState>(
        listener: (context, state) {
          if (state is LoadedState) {
            clothdata_order_existing.clear();
            if (state.response.pickupOrderId != null) {
              // print('-----');
              // print(state.response.pickupOrderId);
              // print('-----');
              OrderAlreadyExistClothdata(
                  userToken, state.response.pickupOrderId);
            }
          } else if (state is ErrorState) {
            // Handle error state
          } else if (state is UnAuthorizedState) {
            // Handle unauthorized state
          } else if (state is NoInternetState) {
            // Handle no internet state
          }
        },
        builder: (context, state) {
          if (state is LoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
            // return _buildShimmerLoading();
          } else if (state is LoadedState) {


            // Map<String, Map<String, dynamic>> clothMap = {};
            // Map<String, int> clothNameCount = {};
            //
            // clothdata_order_existing.forEach((cloth) {
            //   var clothName = cloth['clothName'];
            //   clothMap.putIfAbsent(clothName, () => cloth);
            //   clothNameCount[clothName] = (clothNameCount[clothName] ?? 0) + 1;
            // });


            //കാവ്യാ ചേച്ചി നിശിത തത്ത അപ്പ്രൂവ് തന്നതാണ് ഈ എഡിറ്റ്  13 ജൂൺ 2024 3:15  ണ്
            Map<String, Map> clothMap = {};
            Map<String, int> clothNameCount = {};

            clothdata_order_existing.forEach((cloth) {
              var clothName = cloth['clothName'];
              var service = cloth['service'];
              var billing = cloth['billing'];
              var key = '$clothName-$service-$billing';

              if (!clothMap.containsKey(key)) {
                clothMap[key] = cloth;
                clothNameCount[key] = 0;
              }
              clothNameCount[key] = (clothNameCount[key] ?? 0) + 1;
            });




            var pickupassgn = state.response.pickupassgn;

            var pickupassgn_id = state.response.pickupassgnId;

            if (pickupassgn != null && pickupassgn is List) {
              clothdata_order.clear();
              for (var item in pickupassgn) {
                var clothData = item.clothData;
                if (clothData != null && clothData is List) {
                  for (var clothItem in clothData) {
                    Map<String, dynamic> clothDataMap = {
                      "priceId": clothItem.priceId,
                      "clothName": clothItem.clothName,
                      "arabicName":
                          utf8.decode(clothItem.arabicName!.runes.toList()),
                      "clothImg": clothItem.clothImg,
                      "qnty": clothItem.qnty,
                      "service": clothItem.service,
                      "billing": clothItem.billing
                    };
                    clothdata_order.add(clothDataMap);
                  }
                } else {
                  print('clothData is null or not an array');
                }
              }
            } else {
              print('pickupassgn is null or not an array');
            }

            updateCounts();

            return Scaffold(
                appBar: AppBar(
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black,size: MediaQuery.of(context).size.width * 0.060,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, "/pickupOrderListing");
                  },
                ),
                backgroundColor: Colors.white,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "Pickup Order",
                        style: TextStyle(   fontSize:  MediaQuery.of(context).size.width * 0.050, color: Colors.black,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.white,
                     ),
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
                              // Row(
                              //   children: [
                              //     Padding(
                              //       padding: EdgeInsets.all(8),
                              //       // child: CircleAvatar(
                              //       //   radius: 30,
                              //       //   backgroundImage:
                              //       //       AssetImage('assets/avatar.png'),
                              //       // ),
                              //
                              //       child: Column(
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.start,
                              //         children: [
                              //           Text(
                              //             '${state.response.pickupCustomerName}',
                              //             style: TextStyle(
                              //               fontWeight: FontWeight.bold,
                              //               fontFamily:
                              //                   GoogleFonts.openSans().fontFamily,
                              //               fontSize: 16.0,
                              //             ),
                              //           ),
                              //           SizedBox(height: 5.0),
                              //           Text(
                              //             '${state.response.pickupCustomerPhno}',
                              //             style: TextStyle(
                              //               fontSize: 14.0,
                              //             ),
                              //           ),
                              //           SizedBox(height: 5.0),
                              //           Row(
                              //             children: [
                              //               Icon(Icons.location_on,color: Colors.red, size: 16.0),
                              //               SizedBox(width: 5.0),
                              //               Text(
                              //                 '${state.response.pickupCustomerArea}',
                              //                 style: TextStyle(
                              //                   fontSize: 14.0,
                              //                   fontFamily: GoogleFonts.openSans()
                              //                       .fontFamily,
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ],
                              // ),



                        // chngedcode

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
                                        '${state.response.pickupCustomerName} [ ${state.response.pickupCustomerCode}]',
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
                                                 'Discount: ${customerDataList[0]['discount'].toString()} %',
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
                                                    children:[
                                                      Row(
                                                        children: [
                                                          Icon(Icons.phone_in_talk_sharp, color: Colors.black, size: MediaQuery.of(context).size.width * 0.038,),
                                                          SizedBox(width: 5.0),
                                                          Text(
                                                            '${state.response.pickupCustomerPhno}',
                                                            style: TextStyle(
                                                              fontSize:  MediaQuery.of(context).size.width * 0.038,
                                                              color: Color(0xFF0B0B0B),
                                                              fontWeight: FontWeight.w400,
                                                              fontFamily: GoogleFonts.dmSans().fontFamily,
                                                            ),
                                                          ),
                                                          SizedBox(width: 20.0),
                                                          Icon(Icons.location_on, color: Colors.black, size:  MediaQuery.of(context).size.width * 0.035,),
                                                          SizedBox(width: 5.0),
                                                          Text(
                                                            '${state.response.pickupCustomerArea}',
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
                                                ),
                                                // Row(
                                                //   children: [
                                                //     Icon(Icons.phone_in_talk_sharp, color: Colors.black, size: 16.0),
                                                //     SizedBox(width: 5.0),
                                                //     Text(
                                                //       '${state.response.pickupCustomerPhno}',
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
                                                //       '${state.response.pickupCustomerArea}',
                                                //       style: TextStyle(
                                                //           fontSize:   MediaQuery.of(context).size.width * 0.030,
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
                                          //         fontFamily: GoogleFonts.poppins().fontFamily,
                                          //       fontSize:   MediaQuery.of(context).size.width * 0.030,
                                          //         ),
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

                                        SizedBox(height: 20.0),
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

                                        SizedBox(height: 20.0),
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
                                                     '${state.response.notes}' ?? '--',
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
                                                      fontSize: 14,
                                                      fontFamily: GoogleFonts.dmSans().fontFamily,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${state.response.remarks}' ?? '--',
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




                              // Padding(
                              //   padding: const EdgeInsets.all(20),
                              //   child: customerDataList.isEmpty
                              //       ? Center(child: Text(''))
                              //       : Column(
                              //     children: [
                              //       Row(
                              //         crossAxisAlignment:
                              //         CrossAxisAlignment.start,
                              //         children: [
                              //           Expanded(
                              //             flex: 1,
                              //             child: Column(
                              //               crossAxisAlignment:
                              //               CrossAxisAlignment.start,
                              //               children: [
                              //                 Text(
                              //                   '${state.response.pickupCustomerName}',
                              //                   style: TextStyle(
                              //                     fontWeight: FontWeight.bold,
                              //                     fontFamily:
                              //                     GoogleFonts.openSans().fontFamily,
                              //                     fontSize: 16.0,
                              //                   ),
                              //                 ),
                              //                 SizedBox(height: 5.0),
                              //                 Text(
                              //                   '${state.response.pickupCustomerPhno}',
                              //                   style: TextStyle(
                              //                     fontSize: 14.0,
                              //                   ),
                              //                 ),
                              //                 SizedBox(height: 5.0),
                              //                 SizedBox(height: 5.0),
                              //                 Row(
                              //                   children: [
                              //                     Icon(Icons.location_on,color: Colors.red, size: 16.0),
                              //                     SizedBox(width: 5.0),
                              //                     Text(
                              //                       '${state.response.pickupCustomerArea}',
                              //                       style: TextStyle(
                              //                         fontSize: 14.0,
                              //                         fontFamily: GoogleFonts.openSans()
                              //                             .fontFamily,
                              //                       ),
                              //                     ),
                              //                   ],
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //           Expanded(
                              //             flex: 1,
                              //             child: Column(
                              //               crossAxisAlignment:
                              //               CrossAxisAlignment.start,
                              //               children: [
                              //               ],
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //       SizedBox(height: 5),
                              //
                              //       Row(
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.start,
                              //         children: [
                              //           Expanded(
                              //             flex: 1,
                              //             child: Column(
                              //               crossAxisAlignment:
                              //                   CrossAxisAlignment.start,
                              //               children: [
                              //                 Text(
                              //                   'Customer code',
                              //                   style: TextStyle(
                              //                     fontSize: 14,
                              //                     fontFamily:
                              //                         GoogleFonts.openSans()
                              //                             .fontFamily,
                              //                     color: Colors.grey,
                              //                   ),
                              //                 ),
                              //                 Text(
                              //                   customerDataList[0]['cusCode'],
                              //                   style: TextStyle(
                              //                     fontSize: 16,
                              //                     fontFamily:
                              //                         GoogleFonts.openSans()
                              //                             .fontFamily,
                              //                     fontWeight: FontWeight.bold,
                              //                     color: Colors.black,
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //           Expanded(
                              //             flex: 1,
                              //             child: Column(
                              //               crossAxisAlignment:
                              //                   CrossAxisAlignment.start,
                              //               children: [
                              //                 Text(
                              //                   'Area',
                              //                   style: TextStyle(
                              //                     fontSize: 14,
                              //                     fontFamily:
                              //                         GoogleFonts.openSans()
                              //                             .fontFamily,
                              //                     color: Colors.grey,
                              //                   ),
                              //                 ),
                              //                 Text(
                              //                   customerDataList[0]['area'],
                              //                   style: TextStyle(
                              //                     fontSize: 16,
                              //                     fontWeight: FontWeight.bold,
                              //                     fontFamily:
                              //                         GoogleFonts.openSans()
                              //                             .fontFamily,
                              //                     color: Colors.black,
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //       SizedBox(height: 5),
                              //       Row(
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.start,
                              //         children: [
                              //           Expanded(
                              //             flex: 1,
                              //             child: Column(
                              //               crossAxisAlignment:
                              //                   CrossAxisAlignment.start,
                              //               children: [
                              //                 Text(
                              //                   'Hotel',
                              //                   style: TextStyle(
                              //                     fontSize: 14,
                              //                     color: Colors.grey,
                              //                     fontFamily:
                              //                         GoogleFonts.openSans()
                              //                             .fontFamily,
                              //                   ),
                              //                 ),
                              //                 Text(
                              //                   customerDataList[0]['hotel'],
                              //                   style: TextStyle(
                              //                     fontSize: 16,
                              //                     fontWeight: FontWeight.bold,
                              //                     fontFamily:
                              //                         GoogleFonts.openSans()
                              //                             .fontFamily,
                              //                     color: Colors.black,
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //           Expanded(
                              //             flex: 1,
                              //             child: Column(
                              //               crossAxisAlignment:
                              //                   CrossAxisAlignment.start,
                              //               children: [
                              //                 Text(
                              //                   'Reference No',
                              //                   style: TextStyle(
                              //                     fontSize: 14,
                              //                     color: Colors.grey,
                              //                   ),
                              //                 ),
                              //                 Text(
                              //                   customerDataList[0]['refNo'],
                              //                   style: TextStyle(
                              //                     fontSize: 16,
                              //                     fontWeight: FontWeight.bold,
                              //                     fontFamily:
                              //                         GoogleFonts.openSans()
                              //                             .fontFamily,
                              //                     color: Colors.black,
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //       SizedBox(height: 5),
                              //       Row(
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.start,
                              //         children: [
                              //           Expanded(
                              //             flex: 1,
                              //             child: Column(
                              //               crossAxisAlignment:
                              //                   CrossAxisAlignment.start,
                              //               children: [
                              //                 Text(
                              //                   'Street Name',
                              //                   style: TextStyle(
                              //                     fontSize: 14,
                              //                     fontFamily:
                              //                         GoogleFonts.openSans()
                              //                             .fontFamily,
                              //                     color: Colors.grey,
                              //                   ),
                              //                 ),
                              //                 Text(
                              //                   customerDataList[0]['streetNo'],
                              //                   style: TextStyle(
                              //                     fontSize: 16,
                              //                     fontFamily:
                              //                         GoogleFonts.openSans()
                              //                             .fontFamily,
                              //                     fontWeight: FontWeight.bold,
                              //                     color: Colors.black,
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //           Expanded(
                              //             flex: 1,
                              //             child: Column(
                              //               crossAxisAlignment:
                              //               CrossAxisAlignment.start,
                              //               children: [
                              //                 Text(
                              //                   'House Number',
                              //                   style: TextStyle(
                              //                     fontSize: 14,
                              //                     fontFamily:
                              //                     GoogleFonts.openSans()
                              //                         .fontFamily,
                              //                     color: Colors.grey,
                              //                   ),
                              //                 ),
                              //                 Text(
                              //                   customerDataList[0]['villaNumber'],
                              //                   style: TextStyle(
                              //                     fontSize: 16,
                              //                     fontWeight: FontWeight.bold,
                              //                     color: Colors.black,
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //           // Expanded(
                              //           //   flex: 1,
                              //           //   child: Column(
                              //           //     crossAxisAlignment:
                              //           //         CrossAxisAlignment.start,
                              //           //     children: [
                              //           //       Text(
                              //           //         'Postal Code',
                              //           //         style: TextStyle(
                              //           //           fontSize: 14,
                              //           //           fontFamily:
                              //           //               GoogleFonts.openSans()
                              //           //                   .fontFamily,
                              //           //           color: Colors.grey,
                              //           //         ),
                              //           //       ),
                              //           //       Text(
                              //           //         "${responseData['customerReffrNo']}",
                              //           //         style: TextStyle(
                              //           //           fontSize: 16,
                              //           //           fontFamily:
                              //           //               GoogleFonts.openSans()
                              //           //                   .fontFamily,
                              //           //           fontWeight: FontWeight.bold,
                              //           //           color: Colors.black,
                              //           //         ),
                              //           //       ),
                              //           //     ],
                              //           //   ),
                              //           // ),
                              //         ],
                              //       ),
                              //       SizedBox(height: 5),
                              //       Row(
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.start,
                              //         children: [
                              //           Expanded(
                              //             flex: 1,
                              //             child: Column(
                              //               crossAxisAlignment:
                              //               CrossAxisAlignment.start,
                              //               children: [
                              //                 Text(
                              //                   'Fragrance',
                              //                   style: TextStyle(
                              //                     fontSize: 14,
                              //                     fontFamily:
                              //                     GoogleFonts.openSans()
                              //                         .fontFamily,
                              //                     color: Colors.grey,
                              //                   ),
                              //                 ),
                              //                 Text(
                              //                   customerDataList[0]['fragrance'],
                              //                   style: TextStyle(
                              //                     fontSize: 16,
                              //                     fontFamily:
                              //                     GoogleFonts.openSans()
                              //                         .fontFamily,
                              //                     fontWeight: FontWeight.bold,
                              //                     color: Colors.black,
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //           // Expanded(
                              //           //   flex: 1,
                              //           //   child: Column(
                              //           //     crossAxisAlignment:
                              //           //         CrossAxisAlignment.start,
                              //           //     children: [
                              //           //       Text(
                              //           //         'House Number',
                              //           //         style: TextStyle(
                              //           //           fontSize: 14,
                              //           //           fontFamily:
                              //           //               GoogleFonts.openSans()
                              //           //                   .fontFamily,
                              //           //           color: Colors.grey,
                              //           //         ),
                              //           //       ),
                              //           //       Text(
                              //           //         "${responseData['customerRoomNo']}",
                              //           //         style: TextStyle(
                              //           //           fontSize: 16,
                              //           //           fontWeight: FontWeight.bold,
                              //           //           color: Colors.black,
                              //           //         ),
                              //           //       ),
                              //           //     ],
                              //           //   ),
                              //           // ),
                              //           Expanded(
                              //             flex: 1,
                              //             child: Column(
                              //               crossAxisAlignment:
                              //               CrossAxisAlignment.start,
                              //               children: [
                              //                 Text(
                              //                   'Discount',
                              //                   style: TextStyle(
                              //                     fontSize: 14,
                              //                     fontFamily:
                              //                     GoogleFonts.openSans()
                              //                         .fontFamily,
                              //                     color: Colors.grey,
                              //                   ),
                              //                 ),
                              //                 Text(
                              //                    customerDataList[0]['discount'].toString(),
                              //
                              //                   style: TextStyle(
                              //                     fontSize: 16,
                              //                     fontFamily:
                              //                     GoogleFonts.openSans()
                              //                         .fontFamily,
                              //                     fontWeight: FontWeight.bold,
                              //                     color: Colors.black,
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //
                              //
                              //           // Expanded(
                              //           //   flex: 1,
                              //           //   child: Column(
                              //           //     crossAxisAlignment:
                              //           //         CrossAxisAlignment.start,
                              //           //     children: [
                              //           //       Text(
                              //           //         'Town',
                              //           //         style: TextStyle(
                              //           //           fontSize: 14,
                              //           //           fontFamily:
                              //           //               GoogleFonts.openSans()
                              //           //                   .fontFamily,
                              //           //           color: Colors.grey,
                              //           //         ),
                              //           //       ),
                              //           //       Text(
                              //           //         "${responseData['customerAddress']}",
                              //           //         style: TextStyle(
                              //           //           fontSize: 16,
                              //           //           fontFamily:
                              //           //               GoogleFonts.openSans()
                              //           //                   .fontFamily,
                              //           //           fontWeight: FontWeight.bold,
                              //           //           color: Colors.black,
                              //           //         ),
                              //           //       ),
                              //           //     ],
                              //           //   ),
                              //           // ),
                              //         ],
                              //       ),
                              //       SizedBox(height: 5),
                              //       Row(
                              //         crossAxisAlignment: CrossAxisAlignment.start,
                              //         children: [
                              //           Expanded(
                              //             flex: 1,
                              //             child:     Column(
                              //               crossAxisAlignment: CrossAxisAlignment.start,
                              //               children: [
                              //                 Text(
                              //                   'Note',
                              //                   style: TextStyle(
                              //                     fontSize: 13,
                              //                     fontFamily: GoogleFonts.openSans().fontFamily,
                              //                     color: Colors.grey,
                              //                   ),
                              //                 ),
                              //                 Text(
                              //                   '${state.response.notes}',
                              //                   style: TextStyle(
                              //                     fontSize: 14,
                              //                     fontWeight: FontWeight.bold,
                              //                     fontFamily: GoogleFonts.openSans().fontFamily,
                              //                     color: Colors.black,
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //
                              //         ],
                              //       ),
                              //       SizedBox(height: 10),
                              //       Row(
                              //         crossAxisAlignment: CrossAxisAlignment.start,
                              //         children: [
                              //           Expanded(
                              //             flex: 1,
                              //             child:     Column(
                              //               crossAxisAlignment: CrossAxisAlignment.start,
                              //               children: [
                              //                 Text(
                              //                   'Remark',
                              //                   style: TextStyle(
                              //                     fontSize: 13,
                              //                     fontFamily: GoogleFonts.openSans().fontFamily,
                              //                     color: Colors.grey,
                              //                   ),
                              //                 ),
                              //                 Text(
                              //                     '${state.response.remarks}',
                              //                   style: TextStyle(
                              //                     fontSize: 14,
                              //                     fontWeight: FontWeight.bold,
                              //                     fontFamily: GoogleFonts.openSans().fontFamily,
                              //                     color: Colors.black,
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //
                              //         ],
                              //       ),
                              //       SizedBox(height: 10),
                              //       Row(
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.start,
                              //         children: [
                              //           // Expanded(
                              //           //   flex: 1,
                              //           //   child: Column(
                              //           //     crossAxisAlignment:
                              //           //     CrossAxisAlignment.start,
                              //           //     children: [
                              //           //       Text(
                              //           //         'Bill Amount',
                              //           //         style: TextStyle(
                              //           //           fontSize: 14,
                              //           //           fontFamily:
                              //           //           GoogleFonts.openSans()
                              //           //               .fontFamily,
                              //           //           color: Colors.grey,
                              //           //         ),
                              //           //       ),
                              //           //       Text(
                              //           //         "${responseData['totalAmount']}",
                              //           //         style: TextStyle(
                              //           //           fontSize: 16,
                              //           //           fontFamily:
                              //           //           GoogleFonts.openSans()
                              //           //               .fontFamily,
                              //           //           fontWeight: FontWeight.bold,
                              //           //           color: Colors.black,
                              //           //         ),
                              //           //       ),
                              //           //     ],
                              //           //   ),
                              //           // ),
                              //           Expanded(
                              //             flex: 1,
                              //             child: ElevatedButton(
                              //               onPressed: () async {
                              //               //   try {
                              //               //     EasyLoading.show(status: 'Loading...');
                              //               //     Location location = Location();
                              //               //     bool _serviceEnabled;
                              //               //     PermissionStatus _permissionGranted;
                              //               //     LocationData _locationData;
                              //               //
                              //               //     _serviceEnabled = await location.serviceEnabled();
                              //               //     if (!_serviceEnabled) {
                              //               //       _serviceEnabled = await location.requestService();
                              //               //       if (!_serviceEnabled) {
                              //               //         EasyLoading.showError('Location services are disabled.');
                              //               //         return;
                              //               //       }
                              //               //     }
                              //               //
                              //               //     _permissionGranted = await location.hasPermission();
                              //               //     if (_permissionGranted == PermissionStatus.denied) {
                              //               //       _permissionGranted = await location.requestPermission();
                              //               //       if (_permissionGranted != PermissionStatus.granted) {
                              //               //         EasyLoading.showError('Location permissions are denied.');
                              //               //         return;
                              //               //       }
                              //               //     }
                              //               //
                              //               //     _locationData = await location.getLocation();
                              //               //     // final destination = Uri.encodeComponent('${state.response.pickupCustomerArea}');
                              //               //     // final Uri uri = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=${_locationData.latitude},${_locationData.longitude}&destination=$destination');
                              //               //     final Uri uri = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=koppam&destination=pakara');
                              //               //
                              //               //     if (await canLaunch(uri.toString())) {
                              //               //       await launch(uri.toString());
                              //               //     } else {
                              //               //       EasyLoading.showError('Could not launch $uri');
                              //               //     }
                              //               //     EasyLoading.dismiss();
                              //               //   } catch (e) {
                              //               //     EasyLoading.showError('Error: $e');
                              //               //   }
                              //               //   try {
                              //               //     // Construct Google Maps URL with default location
                              //               //     final Uri uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=pakara');
                              //               //
                              //               //     // Launch Google Maps
                              //               //     if (await canLaunch(uri.toString())) {
                              //               //       await launch(uri.toString());
                              //               //     } else {
                              //               //       print('Could not launch $uri');
                              //               //     }
                              //               //   } catch (e) {
                              //               //     print('Error: $e');
                              //               //   }
                              //
                              //
                              //                 final availableMaps = await MapLauncher.installedMaps;
                              //                 print(availableMaps);
                              //
                              //                 //_findLocation('koppam,pattambi');
                              //                 // final coordinates = await _findLocation('${state.response.pickupCustomerArea}',);
                              //                 final coordinates = await _findLocation('zone ${customerDataList[0]["zone"]},villaNumber ${customerDataList[0]["villaNumber"]},streetNo ${customerDataList[0]["streetNo"]},area ${customerDataList[0]["area"]}');
                              //                 print('Latitude: ${coordinates?.latitude}, Longitude: ${coordinates?.longitude}');
                              //
                              //
                              //                 await showMapOptions('${state.response.pickupCustomerArea}', '${coordinates?.latitude}', '${coordinates?.longitude}');
                              //
                              //
                              //
                              //
                              //
                              //                 // try {
                              //                 //   final String destination = "Koppam"; // Specify the destination here
                              //                 //   final double latitude = 15.3505;
                              //                 //   final double longitude = 76.1567;
                              //                 //
                              //                 //   final url = "https://www.google.com/maps/dir/?api=1&destination=$destination&destination_place_id=$latitude,$longitude";
                              //                 //
                              //                 //   if (await canLaunch(url)) {
                              //                 //     await launch(url);
                              //                 //   } else {
                              //                 //     print('Could not launch $url');
                              //                 //   }
                              //                 // } catch (e) {
                              //                 //   print('Error: $e');
                              //                 // }
                              //
                              //                 },
                              //               // onPressed: (){
                              //               //   try{
                              //               //     var url = 'https://www.google.com/maps/dir/?api=1&destination=${state.response.pickupCustomerArea}';
                              //               //     print(url);
                              //               //     final Uri _url = Uri.parse(url);
                              //               //     launchUrl(_url);
                              //               //   }catch (_){
                              //               //     print('object');
                              //               //   }
                              //               // },
                              //
                              //               style: ElevatedButton.styleFrom(
                              //                 primary: Color(0xFF301C93),
                              //                 onPrimary: Colors.white,
                              //                 shape: RoundedRectangleBorder(
                              //                   borderRadius: BorderRadius.circular(8.0),
                              //                 ),
                              //               ),
                              //               child: Row(
                              //                 mainAxisAlignment: MainAxisAlignment.center,
                              //                 children: [
                              //                   Text(
                              //                     'Location',
                              //                     style: TextStyle(
                              //                       fontSize: 13,
                              //                       fontFamily: GoogleFonts.openSans().fontFamily,
                              //                       fontWeight: FontWeight.bold,
                              //                     ),
                              //                   ),
                              //                   SizedBox(width: 8),
                              //                   Icon(
                              //                     Icons.location_on,
                              //                     color: Colors.white,
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           ),
                              //           // Expanded(
                              //           //   flex: 1,
                              //           //   child: Column(
                              //           //     crossAxisAlignment:
                              //           //         CrossAxisAlignment.start,
                              //           //     children: [
                              //           //       Text(
                              //           //         'Bill Amount',
                              //           //         style: TextStyle(
                              //           //           fontSize: 14,
                              //           //           fontFamily:
                              //           //               GoogleFonts.openSans()
                              //           //                   .fontFamily,
                              //           //           color: Colors.grey,
                              //           //         ),
                              //           //       ),
                              //           //       Text(
                              //           //         '34',
                              //           //         style: TextStyle(
                              //           //           fontSize: 16,
                              //           //           fontFamily:
                              //           //               GoogleFonts.openSans()
                              //           //                   .fontFamily,
                              //           //           fontWeight: FontWeight.bold,
                              //           //           color: Colors.black,
                              //           //         ),
                              //           //       ),
                              //           //     ],
                              //           //   ),
                              //           // ),
                              //         ],
                              //       ),
                              //       // SizedBox(height: 5)
                              //     ],
                              //   ),
                              // ),
                        ),
                            ],
                        ),
                         ),


                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order Items',
                            style: TextStyle(
                              fontSize:   MediaQuery.of(context).size.width * 0.045,
                              fontFamily: GoogleFonts.dmSans().fontFamily,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF000000),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Color(0xFFEFEEF3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    content: StatefulBuilder(
                                      builder: (BuildContext context,
                                          StateSetter setState) {
                                        return Container(
                                          width: 400,
                                          height: 500,
                                          child: SingleChildScrollView(
                                            // child: Padding(
                                            //   padding:
                                            //       const EdgeInsets.all(30.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Add Items',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w700,
                                                          color: Color(0xFF150B3D),
                                                          fontFamily: GoogleFonts.dmSans().fontFamily,
                                                          fontSize:   MediaQuery.of(context).size.width * 0.050,
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: CircleAvatar(
                                                          radius: 20.0,
                                                          backgroundColor: Color(0xFF000000),
                                                          child: Icon(
                                                            Icons.close,
                                                            color: Colors.white,
                                                            size: MediaQuery.of(context).size.width * 0.060,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),



                                                  //this is new dropdown









                                                  SizedBox(height: 20),

                                                  SizedBox(height: 20),









                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Cloth Type:',
                                                        style:TextStyle(
                                                          fontWeight:
                                                          FontWeight.w700,
                                                          fontFamily: GoogleFonts
                                                              .dmSans()
                                                              .fontFamily,
                                                          fontSize:MediaQuery.of(context).size.width * 0.040 ,
                                                          color: Color(0xFF150B3D),

                                                        ),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    12.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFFF9F9F9),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        child: DropdownButton<String>(
                                                          isExpanded: true,
                                                          menuMaxHeight: 200.0,
                                                          value: selectedCloth,
                                                          onChanged: (String? newValue) {
                                                            setState(() {
                                                              selectedCloth = newValue;

                                                            });
                                                          },
                                                          items: clothNames.map<DropdownMenuItem<String>>((String value) {
                                                            return DropdownMenuItem<String>(
                                                              value: value,
                                                              child: Text(value),
                                                            );
                                                          }).toList(),
                                                          hint: Text('Select a cloth type'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  dividerH(),


                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'QTY:',
                                                        style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.w700,
                                                          fontFamily: GoogleFonts
                                                              .dmSans()
                                                              .fontFamily,
                                                          color: Color(0xFF150B3D),
                                                          fontSize:MediaQuery.of(context).size.width * 0.040 ,
                                                        ),
                                                      ),
                                                      SizedBox(height: 5),

                                                    ],
                                                  ),













                                                  // Column(
                                                  //   crossAxisAlignment:
                                                  //       CrossAxisAlignment
                                                  //           .start,
                                                  //   children: [
                                                  //     Text(
                                                  //       'QTY:',
                                                  //       style: TextStyle(
                                                  //         fontWeight:
                                                  //             FontWeight.bold,
                                                  //       ),
                                                  //     ),
                                                  //     SizedBox(height: 5),
                                                  //     TextField(
                                                  //       controller:
                                                  //           TextEditingController(
                                                  //               text: quantity),
                                                  //       onChanged: (value) {
                                                  //         quantity = value;
                                                  //       },
                                                  //       decoration:
                                                  //           InputDecoration(
                                                  //         filled: true,
                                                  //         fillColor:
                                                  //             Color(0xFFF9F9F9),
                                                  //         border:
                                                  //             OutlineInputBorder(
                                                  //           borderRadius:
                                                  //               BorderRadius
                                                  //                   .circular(
                                                  //                       10.0),
                                                  //         ),
                                                  //         hintText:
                                                  //             'Enter a quantity',
                                                  //         contentPadding:
                                                  //             EdgeInsets
                                                  //                 .symmetric(
                                                  //                     horizontal:
                                                  //                         12.0),
                                                  //       ),
                                                  //     ),
                                                  //   ],
                                                  // ),
                                                  dividerH(),


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
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Color(0xFF68188B), // Button background color
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 25),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    5), // Button border radius
                              ),
                            ),
                            child: Text(
                              'ADD ITEMS',
                              style: TextStyle(
                                fontSize:MediaQuery.of(context).size.width * 0.032 ,
                                fontFamily: GoogleFonts.dmSans().fontFamily,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),


                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                       padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: clothdate.length + clothdata_order.length + clothMap.length,
                        itemBuilder: (context, index) {
                          if (index < clothdate.length) {
                            var clothData = clothdate[index];
                            int quantity = int.tryParse(clothData['qnty'] ?? '') ?? 0; // Convert String to int

                            void incrementQuantity() {
                              setState(() {
                                quantity++;
                                clothData['qnty'] = quantity.toString(); // Convert back to String for storage
                              });
                            }

                            void decrementQuantity() {
                              setState(() {
                                if (quantity > 0) {
                                  quantity--;
                                  if (quantity == 0) {
                                    removeDataFromClothDate(index);
                                  } else {
                                    clothData['qnty'] = quantity.toString(); // Convert back to String for storage
                                  }
                                }
                              });
                            }

                            void removeItem() {
                              setState(() {
                                removeDataFromClothDate(index);
                              });
                            }

                            return Padding(
                             // padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
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
                                    contentPadding: EdgeInsets.zero,
                                    leading: Image.network(
                                      clothData['clothImg'],
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
                                    // title: Text(
                                    //   '${clothData['clothName']}',
                                    //   style: TextStyle(
                                    //     fontFamily: GoogleFonts.openSans().fontFamily,
                                    //     fontSize: 14,
                                    //   ),
                                    // ),
                                    title: Text(
                                      '${clothData['service']}, ${clothData['billing']}',
                                      style: TextStyle(
                                        fontFamily: GoogleFonts.dmSans().fontFamily,
                                        fontWeight: FontWeight.w700,
                                        fontSize:MediaQuery.of(context).size.width * 0.035 ,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove),
                                          onPressed: decrementQuantity,
                                          color: Color(0xFF68188B), // Set the color to red
                                        ),
                                        Text(
                                          '$quantity',
                                          style: TextStyle(
                                            fontFamily: GoogleFonts.dmSans().fontFamily,
                                            fontWeight: FontWeight.w700,
                                            fontSize:MediaQuery.of(context).size.width * 0.040 ,// Set font weight to bold
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add),
                                          onPressed: incrementQuantity,
                                          color: Color(0xFF68188B), // Set the color to red
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: removeItem,
                                          color: Colors.red, // Set the color to red
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else if (index < clothdate.length + clothdata_order.length) {
                            var clothdata_orders = clothdata_order[index - clothdate.length];
                           return Padding(
                             // padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
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
                                    contentPadding: EdgeInsets.zero,
                                   // contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0), // Adjusted contentPadding
                                    leading: Image.network(
                                      clothdata_orders['clothImg'],
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
                                    // title: Text(
                                    //   clothdata_order[index - clothdate.length]["clothName"],
                                    //   style: TextStyle(
                                    //     fontFamily: GoogleFonts.openSans().fontFamily,
                                    //   ),
                                    // ),
                                    title: Text(
                                      clothdata_orders['service'],
                                      style: TextStyle(
                                        fontFamily: GoogleFonts.dmSans().fontFamily,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Text(
                                      clothdata_orders['billing'],
                                      style: TextStyle(
                                        fontFamily: GoogleFonts.dmSans().fontFamily,
                                        fontSize: 14,
                                      ),
                                    ),
                                    // trailing: IconButton(
                                    //   icon: Icon(Icons.delete),
                                    //   onPressed: () {
                                    //     removeDataFromClothDate(index);
                                    //   },
                                    // ),
                                  ),
                                ),
                              ),
                            );

                          } else {
                            //കാവ്യാ ചേച്ചി നിശിത തത്ത അപ്പ്രൂവ് തന്നതാണ് ഈ എഡിറ്റ്  13 ജൂൺ 2024 3:15  ണ്
                            var cloth = clothMap.values.elementAt(index - clothdate.length - clothdata_order.length);
                            var clothName = cloth['clothName'];
                            var service = cloth['service'];
                            var billing = cloth['billing'];
                            var qnty = cloth['qnty'].toString();

                            var key = '$clothName-$service-$billing';
                            var count = clothNameCount[key] ?? 0;

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
                                      cloth['clothImg'],
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
                                      '$clothName ',
                                      style: TextStyle(
                                        fontFamily: GoogleFonts.dmSans().fontFamily,
                                          color: Color(0xFF150B3D),
                                          fontWeight: FontWeight.w700,
                                        fontSize:MediaQuery.of(context).size.width * 0.035 ,

                                      ),
                                    ),
                                    subtitle: Text(
                                      '$qnty QTY',
                                      style: TextStyle(
                                        fontFamily: GoogleFonts.dmSans().fontFamily,
                                        color: Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                        fontSize:MediaQuery.of(context).size.width * 0.030 ,

                                      ),
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          service,
                                          style: TextStyle(
                                            fontFamily: GoogleFonts.dmSans().fontFamily,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF000000),
                                            fontSize:MediaQuery.of(context).size.width * 0.035 ,// Optional, for better emphasis
                                          ),
                                        ),
                                        Text(
                                          billing,
                                          style: TextStyle(
                                            fontFamily: GoogleFonts.dmSans().fontFamily,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF68188B),
                                            fontSize:MediaQuery.of(context).size.width * 0.030 ,

                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );







                            // var cloth = clothMap.values.elementAt(index - clothdate.length - clothdata_order.length);
                            // var clothName = cloth['clothName'];
                            // var count = clothNameCount[clothName] ?? 0;
                            //
                            // return Padding(
                            //   //padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                            //   padding: EdgeInsets.zero,
                            //   child: Card(
                            //
                            //     child: ListTile(
                            //
                            //      // contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            //       leading: Image.network(
                            //         cloth['clothImg'],
                            //         fit: BoxFit.cover,
                            //         errorBuilder: (context, error, stackTrace) {
                            //           return Container(
                            //             width: 50,
                            //             height: 50,
                            //             color: Colors.grey,
                            //             child: Icon(
                            //               Icons.error,
                            //               color: Colors.red,
                            //             ),
                            //           );
                            //         },
                            //       ),
                            //       title: Text(
                            //         cloth['service'],
                            //         style: TextStyle(
                            //           fontFamily: GoogleFonts.openSans().fontFamily,
                            //         ),
                            //       ),
                            //       subtitle: Text(
                            //         cloth['billing'],
                            //         style: TextStyle(
                            //           fontFamily: GoogleFonts.openSans().fontFamily,
                            //         ),
                            //       ),
                            //       trailing: Text(
                            //         '${count > 1 ? count : ''}',
                            //         style: TextStyle(
                            //           fontFamily: GoogleFonts.openSans().fontFamily,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // );
                          }
                        },
                      ),


                      // ListView.builder(   setState(() {
                      //                       //         quantity++;
                      //                       //         clothData['qnty'] = quantity.toString(); // Convert back to String for storage
                      //                       //       });
                      //                       //     }
                      //                       //
                      //                       //     void decrementQuantity() {
                      //                       //       setState(() {
                      //                       //         if (quantity > 0) {
                      //                       //
                      //   shrinkWrap: true,
                      //   itemCount: clothdate.length,
                      //   itemBuilder: (context, index) {
                      //     var clothData = clothdate[index];
                      //     int quantity = int.tryParse(clothData['qnty'] ?? '') ?? 0; // Convert String to int
                      //
                      //     void incrementQuantity() {
                      //        quantity--;
                      //           if (quantity == 0) {
                      //             removeDataFromClothDate(index);
                      //           } else {
                      //             clothData['qnty'] = quantity.toString(); // Convert back to String for storage
                      //           }
                      //         }
                      //       });
                      //     }
                      //
                      //     void removeItem() {
                      //       setState(() {
                      //         removeDataFromClothDate(index);
                      //       });
                      //     }
                      //
                      //     return Padding(
                      //       padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      //       child: Card(
                      //         child: ListTile(
                      //           leading: Image.network(
                      //             clothData['clothImg'],
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
                      //             // '${clothData['clothName']}',
                      //             '${clothData['service']}, ${clothData['billing']}',
                      //             style: TextStyle(
                      //               fontFamily: GoogleFonts.openSans().fontFamily,
                      //                 fontSize: 14
                      //             ),
                      //           ),
                      //           // subtitle: Text(
                      //           //  // clothData['billing'],
                      //           //   //'${clothData['service']}, ${clothData['billing']}',
                      //           //   '',
                      //           //   style: TextStyle(
                      //           //     fontFamily: GoogleFonts.openSans().fontFamily,
                      //           //   ),
                      //           // ),
                      //           trailing: Row(
                      //             mainAxisSize: MainAxisSize.min,
                      //             children: [
                      //               IconButton(
                      //                 icon: Icon(Icons.remove),
                      //                 onPressed: decrementQuantity,
                      //                 color: Color(0xFF301C93), // Set the color to red
                      //               ),
                      //               Text(
                      //                 '$quantity',
                      //                 style: TextStyle(
                      //                   fontFamily: GoogleFonts.openSans().fontFamily,
                      //                   fontWeight: FontWeight.bold, // Set font weight to bold
                      //                 ),
                      //               ),
                      //               IconButton(
                      //                 icon: Icon(Icons.add),
                      //                 onPressed: incrementQuantity,
                      //                 color: Color(0xFF301C93), // Set the color to red
                      //               ),
                      //               IconButton(
                      //                 icon: Icon(Icons.delete),
                      //                 onPressed: removeItem,
                      //                 color: Colors.red, // Set the color to red
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),
                      //
                      // ListView.builder(
                      //   shrinkWrap: true,
                      //   itemCount: clothdata_order.length,
                      //   itemBuilder: (context, index) {
                      //     var clothdata_orders = clothdata_order[index];
                      //     return Padding(
                      //       padding: EdgeInsets.symmetric(
                      //           vertical: 0, horizontal: 0),
                      //       child: Card(
                      //         child: ListTile(
                      //           leading: Image.network(
                      //             clothdata_orders['clothImg'],
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
                      //           // title: Text(
                      //           //   clothdata_order[index]["clothName"],
                      //           //   style: TextStyle(
                      //           //     fontFamily:
                      //           //         GoogleFonts.openSans().fontFamily,
                      //           //   ),
                      //           // ),
                      //           title: Text(
                      //             clothdata_orders['billing'],
                      //             style: TextStyle(
                      //               fontFamily:
                      //                   GoogleFonts.openSans().fontFamily,
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
                      //
                      // ListView.builder(
                      //   shrinkWrap: true,
                      //   itemCount: clothMap.length,
                      //   itemBuilder: (context, index) {
                      //     var cloth = clothMap.values.elementAt(index);
                      //     var clothName = cloth['clothName'];
                      //     var count = clothNameCount[clothName] ?? 0;
                      //
                      //     return Padding(
                      //       padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      //       child: Card(
                      //         child: ListTile(
                      //           leading: Image.network(
                      //             cloth['clothImg'],
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
                      //             cloth['billing'],
                      //             style: TextStyle(
                      //               fontFamily: GoogleFonts.openSans().fontFamily,
                      //             ),
                      //           ),
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
                      //           //   },
                      //           // ),
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),



                      //clothdata_order_existing
                      // ListView.builder(
                      //   shrinkWrap: true,
                      //   itemCount: clothdata_order_existing.length,
                      //   itemBuilder: (context, index) {
                      //     var clothdata_order_existingx =
                      //         clothdata_order_existing[index];
                      //     return Padding(
                      //       padding: EdgeInsets.symmetric(
                      //           vertical: 0, horizontal: 0),
                      //       child: Card(
                      //         child: ListTile(
                      //           leading: Image.network(
                      //             clothdata_order_existingx['clothImg'],
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
                      //             clothdata_order_existingx["clothName"],
                      //             style: TextStyle(
                      //               fontFamily:
                      //                   GoogleFonts.openSans().fontFamily,
                      //             ),
                      //           ),
                      //           subtitle: Text(
                      //             clothdata_order_existingx['arabicName'],
                      //             style: TextStyle(
                      //               fontFamily:
                      //                   GoogleFonts.openSans().fontFamily,
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

                      // ListView.builder(
                      //   shrinkWrap: true,
                      //   // Important to add
                      //   physics: NeverScrollableScrollPhysics(),
                      //   // Prevent inner ListView from scrolling
                      //   itemCount: 5,
                      //   // Change this according to your data
                      //   itemBuilder: (context, index) {
                      //     return Padding(
                      //       padding: EdgeInsets.symmetric(
                      //           vertical: 5.0, horizontal: 10.0),
                      //       child: Card(
                      //         child: ListTile(
                      //           // leading: SizedBox(
                      //           //   width: 80,
                      //           //   child: Image.network(
                      //           //     'https://via.placeholder.com/150',
                      //           //     // Replace with your image URL
                      //           //     fit: BoxFit.cover,
                      //           //   ),
                      //           // ),
                      //           title: Text(
                      //             'Heading $index',
                      //             style: TextStyle(
                      //               fontFamily:
                      //                   GoogleFonts.openSans().fontFamily,
                      //             ),
                      //           ),
                      //           subtitle: Text(
                      //             'Subheading $index',
                      //             style: TextStyle(
                      //               fontFamily:
                      //                   GoogleFonts.openSans().fontFamily,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),

                      SizedBox(height: 15),
                      // Small card at the bottom

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
          } else if (state is LoadingState) {
            // return Center(
            //   child: CircularProgressIndicator(),
            // );
            return _buildShimmerLoading();
          } else {
            return _buildShimmerLoading();
          }
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          '$LoggerUsername',
                          style: TextStyle(
                              fontSize: 24,
                              fontFamily: GoogleFonts.openSans().fontFamily,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF000000)),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications_outlined,
                          size: 50, color: Color(0xFF301C93)),
                      onPressed: () {
                        // Add your onPressed logic here
                      },
                    ),
                  ],
                ),
                // Image.asset(
                //   logo,
                //   height: 90,
                //   width: 130,
                // ),

                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pickup Customer',
                      style: TextStyle(
                          fontSize: 24,
                          fontFamily: GoogleFonts.openSans().fontFamily,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF301C93)),
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.arrow_back_outlined,
                          size: 25, color: Color(0xFF301C93)),
                      label: Text('Back',
                          style: TextStyle(
                            color: Color(0xFF301C93),
                            fontSize: 20,
                            fontFamily: GoogleFonts.openSans().fontFamily,
                          )),
                      onPressed: () {
                        // Add your onPressed logic here
                      },
                    ),
                  ],
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  direction: ShimmerDirection.ltr,
                  child: Column(
                    children: [
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: const BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 3,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo (30%)
                              Container(
                                width: 480,
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: const BorderSide(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: Container(
                                height: MediaQuery.of(context).size.height / 8,
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Logo (30%)
                                    Container(
                                      width: 90,
                                    ),
                                  ],
                                ),
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
      ),
    );
  }

  Future<void> fetchCustomerDiscount(String cus_id) async {
    final url = 'https://be.syswash.net/api/syswash/customerdetails/$cus_id?code=$companyCode';
    try {
      final response = await http.get(Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        },);
      if (response.statusCode == 200) {
        final customerDetails = jsonDecode(response.body);
        int discount = customerDetails['discount'].toInt();
        // Assuming you have a state variable to store the discount
        print(customerDetails);

        customerDataList.add(customerDetails);
        setState(() {
          customerDiscount = discount;
        });

        print('Customer Discount: $discount');
      } else {
        print('Failed to load customer details');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchClothDetails(String clothname) async {
    final String apiUrl =
        'https://be.syswash.net/api/syswash/clothdetails?code=$companyCode';

    final response = await http.get(Uri.parse(apiUrl), headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $userToken"
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data.isNotEmpty) {
        for (var clothData in data) {
          if (clothData['data']['clothName'] == clothname) {
            return {
              'clothNameArabic': clothData['data']['clothNameArabic'],
              'clothImg': clothData['data']['clothImg']
            };
          }
        }

        throw Exception('No data available for the provided cloth name.');
      } else {
        throw Exception('No data available from the server.');
      }
    } else {
      throw Exception('Failed to load cloth details');
    }
  }

  Future<int> getPriceId(
    String selectedService,
    String selectedCloth,
  ) async {
    final String apiUrl =
        // 'https://be.syswash.net/api/syswash/pricedetails?code=A';

        '${AppUrls.pricedetails}${AppUrls.code_main}$companyCode';

    final response = await http.get(Uri.parse(apiUrl),
        headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $userToken"
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      //   print(data);
      final Map<String, dynamic> serviceData = data.firstWhere(
        (element) =>
            element['serviceName'] == selectedService &&
            element['clothType'] == selectedCloth,
        orElse: () => null,
      );

      if (serviceData != null) {
        // Assuming quantity selection influences which priceId to select
        return serviceData['priceId'];
      } else {
        throw Exception('Service or cloth type not found.');
      }
    } else {
      throw Exception('Failed to load data');
    }
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


  Future<void> postData() async {
    var pickupassgnIdNum = int.tryParse(pickupassgnId);

    // Convert 'qnty' strings to integers, keeping other fields unchanged
    List<Map<String, dynamic>> convertedClothData = clothdate.map((item) {
      var qntyInt = int.tryParse(item['qnty'] ?? '0') ?? 0;
      return {
        ...item,
        'qnty': qntyInt,
      };
    }).toList();

    // double subTotal = 0.0;
    // for (var cloth in convertedClothData) {
    //   final priceId = cloth['priceId'];
    //   final priceDetails = await fetchPriceDetails(priceId);
    //   print(priceDetails);
    //   if (priceDetails != null) {
    //     double price = double.parse(priceDetails['price']);
    //     cloth['price'] = price;
    //     subTotal += price;
    //     print(cloth['price']);
    //   }
    // }

    // double subTotal = 0.0;
    // for (var cloth in convertedClothData) {
    //   final priceId = cloth['priceId'];
    //   final priceDetails = await fetchPriceDetails(priceId);
    //
    //   if (priceDetails != null) {
    //     double price;
    //     if (cloth['billing'] == 'Express') {
    //       price = double.parse(priceDetails['xprice']);
    //     } else {
    //       price = double.parse(priceDetails['price']);
    //     }
    //
    //     int quantity = cloth['qnty'];
    //     double totalPriceForItem = price * quantity;
    //     //cloth['price'] = totalPriceForItem;
    //     subTotal += totalPriceForItem;
    //   }
    // }

    int subTotal = 0;
    for (var cloth in convertedClothData) {
      final priceId = cloth['priceId'];
      final priceDetails = await fetchPriceDetails(priceId);

      if (priceDetails != null) {
        int price;
        if (cloth['billing'] == 'Express') {
          price = (double.parse(priceDetails['xprice'])).round(); // Rounding the price
        } else {
          price = (double.parse(priceDetails['price'])).round(); // Rounding the price
        }

        int quantity = cloth['qnty'];
        int totalPriceForItem = price * quantity; // Calculating the total price as int
        //cloth['price'] = totalPriceForItem;
        subTotal += totalPriceForItem;
      }
    }

    print('Subtotal: $subTotal');



    print('xxxxxxxxxxxzxzxzxzxxzxzxzxzxerrrororoorororororoxxxxxxx');
    print(convertedClothData);


    var dataprint ={
      "pickupassgn_id": pickupassgnIdNum,
      "pickuporderTime": formatedtime,
      "quantity": totalQty,
      "subTotal": subTotal,
      "discount": customerDiscount,
      "totalAmount": (subTotal-customerDiscount),
      "paidAmount": 0.0,
      "balance": (subTotal-customerDiscount),
      "deliveryType": "PICKUP & DELIVERY",
      "accountType": "MobileApp",
      "clothData": convertedClothData,
    };

    print('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&$dataprint');

    var response = await http.Client().post(
      Uri.parse('https://be.syswash.net/api/syswash/pickuporder?code=$companyCode'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $userToken"
      },
      body: jsonEncode(dataprint),
    );

    if (response.statusCode == 200) {

      //chnage status

      final url = 'https://be.syswash.net/api/syswash/pickupstatus/$pickupassgnId?code=$companyCode';
      final response = await http.put(
          Uri.parse(url),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json", // Specify the content type as JSON
            "Authorization": "Bearer $userToken"
          },
          body: jsonEncode({"pickupstatus": "Received"})
      );

      if (response.statusCode == 200) {
        print('status_changed_success');
        EasyLoading.showToast("Data Added Successfull");
        clothdate.clear();
        Navigator.pushNamed(context, "/pickupOrderListing");
      } else {
        print('Failed to change status: ${response.body}');
      }




      //AppSp().setLastAddedItemOrder(pickupassgnId.toString());
      // EasyLoading.showToast("Data Added Successfull");
      // clothdate.clear();
      // Navigator.pushNamed(context, "/pickupOrderListing");
    } else {
      // If request failed, handle the error
      print('Failed to post data: ${response.statusCode}');
    }
  }





  Future<Map<String, dynamic>?> fetchPriceDetails(int priceId) async {
    final url = 'https://be.syswash.net/api/syswash/pricedetails/$priceId?code=$companyCode';
    try {
      final response = await http.get(Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        },);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load price details for priceId $priceId');
        return null;
      }
    } catch (e) {
      print('Error fetching price details for priceId $priceId: $e');
      return null;
    }
  }

  // Future<void> postData() async {
  //   var pickupassgnIdNum = int.tryParse(pickupassgnId);
  //
  //   // Convert 'qnty' strings to integers, keeping other fields unchanged
  //   List<Map<String, dynamic>> convertedClothData = clothdate.map((item) {
  //     var qntyInt = int.tryParse(item['qnty'] ?? '0') ?? 0;
  //     return {
  //       ...item,
  //       'qnty': qntyInt,
  //     };
  //   }).toList();
  //
  //   var response = await http.Client().post(
  //     Uri.parse('https://be.syswash.net/api/syswash/pickuporder?code=A'),
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Accept": "application/json",
  //       "Authorization": "Bearer $userToken"
  //     },
  //     body: jsonEncode({
  //       "pickupassgn_id": pickupassgnIdNum,
  //       "pickuporderTime": formatedtime,
  //       "quantity": totalQty,
  //       "subTotal": 0.0,
  //       "discount": 0.0,
  //       "totalAmount": 0.0,
  //       "paidAmount": 0.0,
  //       "balance": 0.0,
  //       "deliveryType": "PICKUP & DELIVERY",
  //       "accountType": "MobileApp",
  //       "clothData": convertedClothData, // Use the converted cloth data
  //     }),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     AppSp().setLastAddedItemOrder(pickupassgnId.toString());
  //     EasyLoading.showToast( "Data Added Successfull");
  //     clothdate.clear();
  //     Navigator.pushNamed(
  //         context,
  //         "/pickupOrderListing"
  //     );
  //   } else {
  //     // If request failed, handle the error
  //     print('Failed to post data: ${response.statusCode}');
  //   }
  // }


}
// import '../../../../utils/app_url.dart';
// import 'bloc/customer_details_bloc.dart';
//
// class CustomerDetailsOrder extends StatefulWidget {
//   final String? pickupassgnId;
//
//   const CustomerDetailsOrder({Key? key, this.pickupassgnId}) : super(key: key);
//
//   @override
//   State<CustomerDetailsOrder> createState() => _CustomerDetailsOrderState();
// }
//
// class _CustomerDetailsOrderState extends State<CustomerDetailsOrder> {
//   int _currentIndex = 1;
//   late CustomerDetailsBloc _customerDetailsBloc;
//   String tokenID = '';
//   String userToken = "";
//   String companyCode = "";
//   String userID = "";
//
//   String pickupassgnId = '';
//   String selectedService = "";
//   List<String?> serviceNames = [];
//   List<String?> serviceCodes = [];
//
//   List<String> clothNames = [];
//   String? selectedCloth;
//   String selectedServiceCode = "";
//
//   String quantity = "1";
//
//   String selectedBilling = "Express";
//   List<String> billingOptions = ['Express', 'Normal', 'Faster'];
//
//   int PRICEID = 0;
//
//   String ClothNameArabic = "";
//
//   String ClothImage = "";
//
//   List<Map<String, dynamic>> clothdate = [];
//   List<Map<String, dynamic>> clothdata_order = [];
//   List<Map<String, dynamic>> clothdata_order_existing = [];
//
//   int totalQty = 0;
//   int totalQty1 = 0;
//   int totalQty2 = 0;
//   int itemCount = 0;
//
//   String formatedtime = "";
//
//   String passassignuserID = "";
//
//   //pricelist:
//
//   List<Map<String, dynamic>> priceListServiceCloth = [];
//
//   //String selectedServicexxx = "KAVYA";
//   // List<String> clothNames = [];
//
//   void filterClothNames(String selectedService) {
//     clothNames.clear();
//     for (var item in priceListServiceCloth) {
//       if (item['serviceName'] == selectedService) {
//         clothNames.add(item['clothType']);
//       }
//     }
//   }
//
//   void saveDataToClothDate(Map<String, dynamic> clothData) {
//     setState(() {
//       clothdate.add(clothData);
//       updateCounts();
//     });
//   }
//
//   void removeDataFromClothDate(int index) {
//     setState(() {
//       clothdate.removeAt(index);
//       updateCounts(); // Recalculate counts after removing an item
//     });
//   }
//
//   void updateCounts() {
//     itemCount = clothdate.length + clothdata_order.length;
//     totalQty1 = 0;
//     for (var cloth in clothdate) {
//       totalQty1 += int.parse(cloth['qnty']);
//     }
//     totalQty2 = 0;
//     for (var cloth in clothdata_order) {
//       totalQty2 += int.parse(cloth['qnty'].toString());
//     }
//     totalQty = totalQty1 + totalQty2;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     pickupassgnId = widget.pickupassgnId ?? '';
//     _customerDetailsBloc = CustomerDetailsBloc(ApiService());
//     getUserToken();
//     var currentTime = DateTime.now();
//     formatedtime =
//         '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';
//   }
//
//   Future<void> getUserToken() async {
//     AppSp appSp = AppSp();
//     userToken = await appSp.getToken();
//     companyCode = await appSp.getCompanyCode();
//     fetchServiceDetailsData(userToken, companyCode);
//     fetchClouthDetailsData(userToken, companyCode);
//
//     fetchPriceListDatas(userToken, companyCode);
//
//     _customerDetailsBloc
//         .add(CustomerDetailsApiEvent(userToken, companyCode, pickupassgnId));
//   }
//
//   @override
//   void dispose() {
//     _customerDetailsBloc.close();
//     super.dispose();
//   }
//
//   void fetchPriceListDatas(String userToken, String companyCode) async {
//     final response = await http.get(
//       Uri.parse('https://be.syswash.net/api/syswash/pricedetails?code=A'),
//       headers: {
//         "Accept": "application/json",
//         "Authorization": "Bearer $userToken"
//       },
//     );
//
//     if (response.statusCode == 200) {
//       List<dynamic> responseData = jsonDecode(response.body);
//       for (var data in responseData) {
//         if (data is Map<String, dynamic>) {
//           setState(() {
//             priceListServiceCloth.add(data);
//           });
//         }
//       }
//
//       print("Price list data fetched successfully.");
//     } else {
//       print("Failed to fetch data: ${response.statusCode}");
//     }
//   }
//
//   void fetchClouthDetailsData(String userToken, String companyCode) async {
//     final response = await http.get(
//         Uri.parse('${AppUrls.clothdetails}${AppUrls.code_main}$companyCode'),
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer $userToken"
//         });
//     if (response.statusCode == 200) {
//       List<Map<String, dynamic>> clothDataList =
//           List<Map<String, dynamic>>.from(json.decode(response.body));
//       setState(() {
//         clothNames = clothDataList
//             .map((clothData) => clothData['data']['clothName'] as String)
//             .toList();
//       });
//     } else {
//       print("Failed to fetch data: ${response.statusCode}");
//     }
//   }
//
//   void fetchServiceDetailsData(String userToken, String companyCode) async {
//     final response = await http.get(
//         Uri.parse('${AppUrls.servicedetails}${AppUrls.code_main}$companyCode'),
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer $userToken"
//         });
//     if (response.statusCode == 200) {
//       List<dynamic> responseData = json.decode(response.body);
//       List<Map<String, String>> services = responseData.map((data) {
//         return {
//           'serviceName': data['serviceName'] as String,
//           'serviceCode': data['serviceCode'] as String,
//         };
//       }).toList();
//       setState(() {
//         serviceNames =
//             services.map((service) => service['serviceName']).toList();
//         serviceCodes =
//             services.map((service) => service['serviceCode']).toList();
//
//         if (serviceNames.isNotEmpty) {
//           selectedService = serviceNames[0]!;
//         }
//       });
//     } else {
//       print("Failed to fetch data: ${response.statusCode}");
//     }
//   }
//
//   // Fetch existing cloth data
//   Future<void> OrderAlreadyExistClothdata(
//       String userToken, String pickupOrderId) async {
//     final response = await http.get(
//         Uri.parse(
//             'https://be.syswash.net/api/syswash/order/$pickupOrderId?code=A'),
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer $userToken"
//         });
//
//     if (response.statusCode == 200) {
//       final responseData = json.decode(response.body);
//       final clothData = responseData['clothData'] as List<dynamic>;
//       //print(clothData);
//       processClothData(clothData);
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }
//
//   void processClothData(List<dynamic> clothData) {
//     List<Map<String, dynamic>> newClothData = [];
//     for (final cloth in clothData) {
//       Map<String, dynamic> clothDataMap = {
//         "priceId": cloth['priceId'],
//         "clothName": cloth['clothName'],
//         "arabicName": utf8.decode(cloth['arabicName'].runes.toList()),
//         "clothImg": cloth['clothImg'],
//         "qnty": cloth['qnty'],
//         "service": cloth['service'],
//         "billing": cloth['billing']
//       };
//       // Add fetched cloth data to the list
//       newClothData.add(clothDataMap);
//     }
//
//     setState(() {
//       clothdata_order_existing.addAll(newClothData);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => _customerDetailsBloc,
//       child: BlocConsumer<CustomerDetailsBloc, CustomerDetailsState>(
//         listener: (context, state) {
//           if (state is LoadedState) {
//             clothdata_order_existing.clear();
//             if (state.response.pickupOrderId != null) {
//               // print('-----');
//               // print(state.response.pickupOrderId);
//               // print('-----');
//               OrderAlreadyExistClothdata(
//                   userToken, state.response.pickupOrderId);
//             }
//           } else if (state is ErrorState) {
//             // Handle error state
//           } else if (state is UnAuthorizedState) {
//             // Handle unauthorized state
//           } else if (state is NoInternetState) {
//             // Handle no internet state
//           }
//         },
//         builder: (context, state) {
//           if (state is LoadingState) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//             // return _buildShimmerLoading();
//           } else if (state is LoadedState) {
//             //
//             var pickupassgn = state.response.pickupassgn;
//
//             var pickupassgn_id = state.response.pickupassgnId;
//
//             if (pickupassgn != null && pickupassgn is List) {
//               clothdata_order.clear();
//               for (var item in pickupassgn) {
//                 var clothData = item.clothData;
//                 if (clothData != null && clothData is List) {
//                   for (var clothItem in clothData) {
//                     Map<String, dynamic> clothDataMap = {
//                       "priceId": clothItem.priceId,
//                       "clothName": clothItem.clothName,
//                       "arabicName":
//                           utf8.decode(clothItem.arabicName!.runes.toList()),
//                       "clothImg": clothItem.clothImg,
//                       "qnty": clothItem.qnty,
//                       "service": clothItem.service,
//                       "billing": clothItem.billing
//                     };
//                     clothdata_order.add(clothDataMap);
//                   }
//                 } else {
//                   print('clothData is null or not an array');
//                 }
//               }
//             } else {
//               print('pickupassgn is null or not an array');
//             }
//
//             updateCounts();
//
//             return Scaffold(
//               backgroundColor: Color(0xFFEFEEF3),
//               body: SingleChildScrollView(
//                 // Wrap the entire page with SingleChildScrollView
//                 child: Padding(
//                   padding: const EdgeInsets.all(30),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 30),
//
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               // CircleAvatar(
//                               //   backgroundImage:
//                               //       AssetImage('assets/profile_image.jpg'),
//                               //   radius: 30,
//                               // ),
//                               SizedBox(width: 10),
//                               // Adjust spacing between circle and text
//                               Text(
//                                 'Taj Muhammed',
//                                 style: TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.normal,
//                                   fontFamily: GoogleFonts.openSans().fontFamily,
//                                   color: Color(0xFF000000),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.notifications_outlined,
//                                 size: 50, color: Color(0xFF301C93)),
//                             onPressed: () {
//                               // Add your onPressed logic here
//                             },
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Collect now',
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontFamily: GoogleFonts.openSans().fontFamily,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF301C93),
//                             ),
//                           ),
//                           TextButton.icon(
//                             icon: Icon(Icons.arrow_back_outlined,
//                                 size: 25, color: Color(0xFF301C93)),
//                             label: Text('Back',
//                                 style: TextStyle(
//                                   color: Color(0xFF301C93),
//                                   fontSize: 20,
//                                   fontFamily: GoogleFonts.openSans().fontFamily,
//                                 )),
//                             onPressed: () {
//                               Navigator.pushNamed(
//                                   context, "/pickupOrderListing");
//                               // Add your onPressed logic here
//                             },
//                           ),
//                         ],
//                       ),
//                       dividerLH(),
//                       Card(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Padding(
//                                   padding: EdgeInsets.all(20),
//                                   // child: CircleAvatar(
//                                   //   radius: 30,
//                                   //   backgroundImage:
//                                   //       AssetImage('assets/avatar.png'),
//                                   // ),
//
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         '${state.response.pickupCustomerName}',
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily:
//                                               GoogleFonts.openSans().fontFamily,
//                                           fontSize: 16.0,
//                                         ),
//                                       ),
//                                       SizedBox(height: 5.0),
//                                       Text(
//                                         '${state.response.pickupCustomerPhno}',
//                                         style: TextStyle(
//                                           fontSize: 14.0,
//                                         ),
//                                       ),
//                                       SizedBox(height: 5.0),
//                                       Row(
//                                         children: [
//                                           Icon(Icons.location_on, size: 16.0),
//                                           SizedBox(width: 5.0),
//                                           Text(
//                                             '${state.response.pickupCustomerArea}',
//                                             style: TextStyle(
//                                               fontSize: 14.0,
//                                               fontFamily: GoogleFonts.openSans()
//                                                   .fontFamily,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(20),
//                               child: Column(
//                                 children: [
//                                   Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Expanded(
//                                         flex: 1,
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'Created at',
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 fontFamily:
//                                                     GoogleFonts.openSans()
//                                                         .fontFamily,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                             Text(
//                                               '12-4-2033',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontFamily:
//                                                     GoogleFonts.openSans()
//                                                         .fontFamily,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       Expanded(
//                                         flex: 1,
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'Pickup',
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 fontFamily:
//                                                     GoogleFonts.openSans()
//                                                         .fontFamily,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                             Text(
//                                               '12-45-2039',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                                 fontFamily:
//                                                     GoogleFonts.openSans()
//                                                         .fontFamily,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 15),
//                                   Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Expanded(
//                                         flex: 1,
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'Drop off',
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 color: Colors.grey,
//                                                 fontFamily:
//                                                     GoogleFonts.openSans()
//                                                         .fontFamily,
//                                               ),
//                                             ),
//                                             Text(
//                                               '12-4-2033',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                                 fontFamily:
//                                                     GoogleFonts.openSans()
//                                                         .fontFamily,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       Expanded(
//                                         flex: 1,
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'Status',
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                             Text(
//                                               '${state.response.pickupstatus}',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                                 fontFamily:
//                                                     GoogleFonts.openSans()
//                                                         .fontFamily,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 15),
//                                   Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Expanded(
//                                         flex: 1,
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'Street',
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 fontFamily:
//                                                     GoogleFonts.openSans()
//                                                         .fontFamily,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                             Text(
//                                               'Akhilnrd',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontFamily:
//                                                     GoogleFonts.openSans()
//                                                         .fontFamily,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       Expanded(
//                                         flex: 1,
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'Postal Code',
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 fontFamily:
//                                                     GoogleFonts.openSans()
//                                                         .fontFamily,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                             Text(
//                                               '345673',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontFamily:
//                                                     GoogleFonts.openSans()
//                                                         .fontFamily,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 15),
//                                   Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Expanded(
//                                         flex: 1,
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'House Number',
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 fontFamily:
//                                                     GoogleFonts.openSans()
//                                                         .fontFamily,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                             Text(
//                                               '323',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       Expanded(
//                                         flex: 1,
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'Town',
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 fontFamily:
//                                                     GoogleFonts.openSans()
//                                                         .fontFamily,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                             Text(
//                                               'Quater',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontFamily:
//                                                     GoogleFonts.openSans()
//                                                         .fontFamily,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 15),
//                                   Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Expanded(
//                                         flex: 1,
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'Bill Amount',
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 fontFamily:
//                                                     GoogleFonts.openSans()
//                                                         .fontFamily,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                             Text(
//                                               '34',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontFamily:
//                                                     GoogleFonts.openSans()
//                                                         .fontFamily,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 15)
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 15),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Order Items',
//                             style: TextStyle(
//                               fontSize: 30,
//                               fontFamily: GoogleFonts.openSans().fontFamily,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF301C93),
//                             ),
//                           ),
//                           ElevatedButton(
//                             onPressed: () {
//                               showDialog(
//                                 context: context,
//                                 builder: (BuildContext context) {
//                                   return AlertDialog(
//                                     backgroundColor: Color(0xFFEFEEF3),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(15.0),
//                                     ),
//                                     content: StatefulBuilder(
//                                       builder: (BuildContext context,
//                                           StateSetter setState) {
//                                         return Container(
//                                           width: 400,
//                                           height: 550,
//                                           child: SingleChildScrollView(
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.all(30.0),
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     'Add Items',
//                                                     style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       color: Color(0xFF301C93),
//                                                       fontFamily:
//                                                           GoogleFonts.openSans()
//                                                               .fontFamily,
//                                                       fontSize: 23.0,
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 20),
//                                                   Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       Text(
//                                                         'Select Service:',
//                                                         style: TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           fontFamily: GoogleFonts
//                                                                   .openSans()
//                                                               .fontFamily,
//                                                         ),
//                                                       ),
//                                                       SizedBox(height: 5),
//                                                       Container(
//                                                         padding: EdgeInsets
//                                                             .symmetric(
//                                                                 horizontal:
//                                                                     12.0),
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           color:
//                                                               Color(0xFFF9F9F9),
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(
//                                                                       10.0),
//                                                         ),
//                                                         child: DropdownButton<
//                                                             String?>(
//                                                           isExpanded: true,
//                                                           onChanged: (String?
//                                                               newValue) {
//                                                             if (newValue !=
//                                                                 null) {
//                                                               setState(() {
//                                                                 selectedService =
//                                                                     newValue;
//                                                                 selectedServiceCode =
//                                                                     serviceCodes[
//                                                                         serviceNames
//                                                                             .indexOf(newValue)]!;
//                                                                 // print("Selected service: $selectedService, Code: $selectedServiceCode");
//                                                                 print(
//                                                                     '+++++++');
//                                                                 print(
//                                                                     selectedService);
//                                                                 print(
//                                                                     '+++++++');
//                                                                 filterClothNames(
//                                                                     selectedService);
//                                                               });
//                                                             }
//                                                           },
//                                                           value:
//                                                               selectedService,
//                                                           items: serviceNames.map<
//                                                                   DropdownMenuItem<
//                                                                       String?>>(
//                                                               (String? value) {
//                                                             return DropdownMenuItem<
//                                                                 String?>(
//                                                               value: value,
//                                                               child: Text(
//                                                                   value ?? ""),
//                                                             );
//                                                           }).toList(),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   SizedBox(height: 20),
//
//                                                   // DropdownButton<String>(
//                                                   //   value: clothNames.isNotEmpty ? clothNames[0] : null,
//                                                   //   onChanged: ( newValue) {
//                                                   //    print('newValue');
//                                                   //   },
//                                                   //   items: clothNames.map<DropdownMenuItem<String>>((String value) {
//                                                   //     return DropdownMenuItem<String>(
//                                                   //       value: value,
//                                                   //       child: Text(value), // Display cloth name as the dropdown item
//                                                   //     );
//                                                   //   }).toList(),
//                                                   // ),
//
//                                                   Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       Text(
//                                                         'Cloth Type:',
//                                                         style: TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           fontFamily: GoogleFonts
//                                                                   .openSans()
//                                                               .fontFamily,
//                                                         ),
//                                                       ),
//                                                       SizedBox(height: 5),
//                                                       Container(
//                                                         padding: EdgeInsets
//                                                             .symmetric(
//                                                                 horizontal:
//                                                                     12.0),
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           color:
//                                                               Color(0xFFF9F9F9),
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(
//                                                                       10.0),
//                                                         ),
//                                                         child: DropdownButton<
//                                                             String>(
//                                                           isExpanded: true,
//                                                           value: clothNames
//                                                                   .isNotEmpty
//                                                               ? clothNames[0]
//                                                               : null,
//                                                           onChanged: (String?
//                                                               newValue) {
//                                                             setState(() {
//                                                               selectedCloth =
//                                                                   newValue;
//                                                             });
//                                                           },
//                                                           items: clothNames.map<
//                                                               DropdownMenuItem<
//                                                                   String>>((String
//                                                               value) {
//                                                             return DropdownMenuItem<
//                                                                 String>(
//                                                               value: value,
//                                                               child: Text(
//                                                                   value), // Display cloth name as the dropdown item
//                                                             );
//                                                           }).toList(),
//                                                           hint: Text(
//                                                               'Select a cloth type'),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ), // Column(
//                                                   //   crossAxisAlignment:
//                                                   //       CrossAxisAlignment
//                                                   //           .start,
//                                                   //   children: [
//                                                   //     Text(
//                                                   //       'Cloth Type:',
//                                                   //       style: TextStyle(
//                                                   //         fontWeight:
//                                                   //             FontWeight.bold,
//                                                   //         fontFamily: GoogleFonts
//                                                   //                 .openSans()
//                                                   //             .fontFamily,
//                                                   //       ),
//                                                   //     ),
//                                                   //     SizedBox(height: 5),
//                                                   //     Container(
//                                                   //       padding: EdgeInsets
//                                                   //           .symmetric(
//                                                   //               horizontal:
//                                                   //                   12.0),
//                                                   //       decoration:
//                                                   //           BoxDecoration(
//                                                   //         color:
//                                                   //             Color(0xFFF9F9F9),
//                                                   //         borderRadius:
//                                                   //             BorderRadius
//                                                   //                 .circular(
//                                                   //                     10.0),
//                                                   //       ),
//                                                   //       child: DropdownButton<
//                                                   //           String>(
//                                                   //         isExpanded: true,
//                                                   //         value: selectedCloth,
//                                                   //         onChanged: (String?
//                                                   //             newValue) {
//                                                   //           setState(() {
//                                                   //             selectedCloth =
//                                                   //                 newValue;
//                                                   //           });
//                                                   //         },
//                                                   //         items: clothNames.map(
//                                                   //             (String value) {
//                                                   //           return DropdownMenuItem<
//                                                   //               String>(
//                                                   //             value: value,
//                                                   //             child:
//                                                   //                 Text(value),
//                                                   //           );
//                                                   //         }).toList(),
//                                                   //         hint: Text(
//                                                   //             'Select a cloth type'),
//                                                   //       ),
//                                                   //     ),
//                                                   //   ],
//                                                   // ),
//                                                   dividerH(),
//                                                   Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       Text(
//                                                         'QTY:',
//                                                         style: TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                         ),
//                                                       ),
//                                                       SizedBox(height: 5),
//                                                       TextField(
//                                                         controller:
//                                                             TextEditingController(
//                                                                 text: quantity),
//                                                         onChanged: (value) {
//                                                           quantity = value;
//                                                         },
//                                                         decoration:
//                                                             InputDecoration(
//                                                           filled: true,
//                                                           fillColor:
//                                                               Color(0xFFF9F9F9),
//                                                           border:
//                                                               OutlineInputBorder(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         10.0),
//                                                           ),
//                                                           hintText:
//                                                               'Enter a quantity',
//                                                           contentPadding:
//                                                               EdgeInsets
//                                                                   .symmetric(
//                                                                       horizontal:
//                                                                           12.0),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   dividerH(),
//                                                   Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       Text(
//                                                         'Billing:',
//                                                         style: TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           fontFamily: GoogleFonts
//                                                                   .openSans()
//                                                               .fontFamily,
//                                                         ),
//                                                       ),
//                                                       SizedBox(height: 5),
//                                                       Container(
//                                                         padding: EdgeInsets
//                                                             .symmetric(
//                                                                 horizontal:
//                                                                     12.0),
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           color:
//                                                               Color(0xFFF9F9F9),
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(
//                                                                       10.0),
//                                                         ),
//                                                         child: DropdownButton<
//                                                             String>(
//                                                           isExpanded: true,
//                                                           value:
//                                                               selectedBilling,
//                                                           onChanged: (String?
//                                                               newValue) {
//                                                             setState(() {
//                                                               selectedBilling =
//                                                                   newValue!;
//                                                             });
//                                                           },
//                                                           items: billingOptions
//                                                               .map((String
//                                                                   value) {
//                                                             return DropdownMenuItem<
//                                                                 String>(
//                                                               value: value,
//                                                               child:
//                                                                   Text(value),
//                                                             );
//                                                           }).toList(),
//                                                           hint: Text(
//                                                               'Select a billing type'),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   dividerH(),
//                                                   Container(
//                                                     padding:
//                                                         const EdgeInsets.all(5),
//                                                     width: double.infinity,
//                                                     // Full width
//                                                     decoration: BoxDecoration(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10.0),
//                                                       color: Color(0xFF301C93),
//                                                     ),
//                                                     child: TextButton(
//                                                       onPressed: () async {
//                                                         // if (state.response.pickupOrderId == null) {
//                                                         // print("Selected service: $selectedService");
//                                                         // print("Selected cloth: $selectedCloth");
//                                                         // print("Quantity: $quantity");
//
//                                                         // Define an async function to fetch the priceId
//                                                         Future<void>
//                                                             fetchPriceId() async {
//                                                           try {
//                                                             int priceId =
//                                                                 await getPriceId(
//                                                                     '$selectedService',
//                                                                     '$selectedCloth');
//                                                             setState(() {
//                                                               PRICEID = priceId;
//                                                             });
//                                                           } catch (e) {
//                                                             print('Error: $e');
//                                                           }
//                                                         }
//
//                                                         await fetchPriceId();
//
//                                                         try {
//                                                           Map<String, dynamic>
//                                                               clothDetails =
//                                                               await fetchClothDetails(
//                                                                   '$selectedCloth');
//                                                           String
//                                                               clothNameArabic =
//                                                               clothDetails[
//                                                                   'clothNameArabic'];
//                                                           String clothImg =
//                                                               clothDetails[
//                                                                   'clothImg'];
//                                                           setState(() {
//                                                             ClothNameArabic =
//                                                                 clothNameArabic;
//                                                             ClothImage =
//                                                                 clothImg;
//                                                           });
//                                                         } catch (e) {
//                                                           print(
//                                                               'Error fetching cloth details: $e');
//                                                         }
//
//                                                         //print('{"priceId": $PRICEID,"clothName": $selectedCloth,"arabicName": $ClothNameArabic,"clothImg": $ClothImage,"qnty": $quantity,"service": $selectedServiceCode,"billing": $selectedBilling }');
//
//                                                         // Print the data to be added to clothdate list
//                                                         Map<String, dynamic>
//                                                             clothData = {
//                                                           "priceId": PRICEID,
//                                                           "clothName":
//                                                               selectedCloth,
//                                                           "arabicName":
//                                                               ClothNameArabic,
//                                                           "clothImg":
//                                                               ClothImage,
//                                                           "qnty": quantity,
//                                                           "service":
//                                                               selectedServiceCode,
//                                                           "billing":
//                                                               selectedBilling
//                                                         };
//                                                         print(clothData);
//
//                                                         // Save data to clothdate list
//                                                         saveDataToClothDate(
//                                                             clothData);
//
//                                                         // Print a separator for readability
//                                                         print(
//                                                             '-------------------');
//                                                         print(
//                                                             clothdate); // Print the clothdate list
//                                                         print(
//                                                             '-------------------');
//
//                                                         // setState(() {
//                                                         //   selectedService = "";
//                                                         //
//                                                         //   quantity = "";
//                                                         //   selectedBilling = "Express";
//                                                         // });
//                                                         Navigator.of(context)
//                                                             .pop();
//                                                       },
//
//                                                       // },
//
//                                                       child: Text(
//                                                         'Submit',
//                                                         style: TextStyle(
//                                                           color: Colors.white,
//                                                           fontFamily: GoogleFonts
//                                                                   .openSans()
//                                                               .fontFamily,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                             style: TextButton.styleFrom(
//                               backgroundColor:
//                                   Color(0xFF301C93), // Button background color
//                               padding: EdgeInsets.symmetric(
//                                   vertical: 10, horizontal: 20),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(
//                                     15), // Button border radius
//                               ),
//                             ),
//                             child: Text(
//                               'ADD ITEMS',
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 fontFamily: GoogleFonts.openSans().fontFamily,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: clothdate.length,
//                         itemBuilder: (context, index) {
//                           var clothData = clothdate[index];
//                           return Padding(
//                             padding: EdgeInsets.symmetric(
//                                 vertical: 5.0, horizontal: 10.0),
//                             child: Card(
//                               child: ListTile(
//                                 leading: Image.network(
//                                   clothData['clothImg'],
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Container(
//                                       width: 50,
//                                       height: 50,
//                                       color: Colors.grey,
//                                       child: Icon(
//                                         Icons.error,
//                                         color: Colors.red,
//                                       ),
//                                     );
//                                   },
//                                 ),
//                                 title: Text(
//                                   clothData['clothName'],
//                                   style: TextStyle(
//                                     fontFamily:
//                                         GoogleFonts.openSans().fontFamily,
//                                   ),
//                                 ),
//                                 subtitle: Text(
//                                   clothData['arabicName'],
//                                   style: TextStyle(
//                                     fontFamily:
//                                         GoogleFonts.openSans().fontFamily,
//                                   ),
//                                 ),
//                                 trailing: IconButton(
//                                   icon: Icon(Icons.delete),
//                                   onPressed: () {
//                                     removeDataFromClothDate(index);
//                                   },
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//
//                       ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: clothdata_order.length,
//                         itemBuilder: (context, index) {
//                           var clothdata_orders = clothdata_order[index];
//                           return Padding(
//                             padding: EdgeInsets.symmetric(
//                                 vertical: 5.0, horizontal: 10.0),
//                             child: Card(
//                               child: ListTile(
//                                 leading: Image.network(
//                                   clothdata_orders['clothImg'],
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Container(
//                                       width: 50,
//                                       height: 50,
//                                       color: Colors.grey,
//                                       child: Icon(
//                                         Icons.error,
//                                         color: Colors.red,
//                                       ),
//                                     );
//                                   },
//                                 ),
//                                 title: Text(
//                                   clothdata_order[index]["clothName"],
//                                   style: TextStyle(
//                                     fontFamily:
//                                         GoogleFonts.openSans().fontFamily,
//                                   ),
//                                 ),
//                                 subtitle: Text(
//                                   clothdata_orders['arabicName'],
//                                   style: TextStyle(
//                                     fontFamily:
//                                         GoogleFonts.openSans().fontFamily,
//                                   ),
//                                 ),
//                                 // trailing: IconButton(
//                                 //   icon: Icon(Icons.delete),
//                                 //   onPressed: () {
//                                 //     removeDataFromClothDate(index);
//                                 //
//                                 //   },
//                                 // ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//
//                       //clothdata_order_existing
//                       ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: clothdata_order_existing.length,
//                         itemBuilder: (context, index) {
//                           var clothdata_order_existingx =
//                               clothdata_order_existing[index];
//                           return Padding(
//                             padding: EdgeInsets.symmetric(
//                                 vertical: 5.0, horizontal: 10.0),
//                             child: Card(
//                               child: ListTile(
//                                 leading: Image.network(
//                                   clothdata_order_existingx['clothImg'],
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Container(
//                                       width: 50,
//                                       height: 50,
//                                       color: Colors.grey,
//                                       child: Icon(
//                                         Icons.error,
//                                         color: Colors.red,
//                                       ),
//                                     );
//                                   },
//                                 ),
//                                 title: Text(
//                                   clothdata_order_existingx["clothName"],
//                                   style: TextStyle(
//                                     fontFamily:
//                                         GoogleFonts.openSans().fontFamily,
//                                   ),
//                                 ),
//                                 subtitle: Text(
//                                   clothdata_order_existingx['arabicName'],
//                                   style: TextStyle(
//                                     fontFamily:
//                                         GoogleFonts.openSans().fontFamily,
//                                   ),
//                                 ),
//                                 // trailing: IconButton(
//                                 //   icon: Icon(Icons.delete),
//                                 //   onPressed: () {
//                                 //     removeDataFromClothDate(index);
//                                 //
//                                 //   },
//                                 // ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//
//                       // ListView.builder(
//                       //   shrinkWrap: true,
//                       //   // Important to add
//                       //   physics: NeverScrollableScrollPhysics(),
//                       //   // Prevent inner ListView from scrolling
//                       //   itemCount: 5,
//                       //   // Change this according to your data
//                       //   itemBuilder: (context, index) {
//                       //     return Padding(
//                       //       padding: EdgeInsets.symmetric(
//                       //           vertical: 5.0, horizontal: 10.0),
//                       //       child: Card(
//                       //         child: ListTile(
//                       //           // leading: SizedBox(
//                       //           //   width: 80,
//                       //           //   child: Image.network(
//                       //           //     'https://via.placeholder.com/150',
//                       //           //     // Replace with your image URL
//                       //           //     fit: BoxFit.cover,
//                       //           //   ),
//                       //           // ),
//                       //           title: Text(
//                       //             'Heading $index',
//                       //             style: TextStyle(
//                       //               fontFamily:
//                       //                   GoogleFonts.openSans().fontFamily,
//                       //             ),
//                       //           ),
//                       //           subtitle: Text(
//                       //             'Subheading $index',
//                       //             style: TextStyle(
//                       //               fontFamily:
//                       //                   GoogleFonts.openSans().fontFamily,
//                       //             ),
//                       //           ),
//                       //         ),
//                       //       ),
//                       //     );
//                       //   },
//                       // ),
//
//                       SizedBox(height: 15),
//                       // Small card at the bottom
//                       Card(
//                         child: Padding(
//                           padding: const EdgeInsets.all(15.0),
//                           child: Row(
//                             children: [
//                               ElevatedButton(
//                                 onPressed: () {
//                                   print(
//                                       '{"pickupassgn_id": ${state.response.pickupassgnId},"pickuporderTime": $formatedtime,"quantity": $totalQty,"subTotal": 0.0, "discount": 0.0,"totalAmount": 0.0,"paidAmount": 0.0,"balance": 0.0,"deliveryType": "PICKUP & DELIVERY","accountType": "MobileApp","clothData":$clothdate}');
//
//                                   postData();
//
//                                   //   {
//                                   //     "pickupassgn_id": "67",
//                                   //   "pickuporderTime": "12:39",
//                                   //   "quantity": 2,
//                                   //   "subTotal": 2000.0,
//                                   //   "discount": 0.0,
//                                   //   "totalAmount": 3000.0,
//                                   //   "paidAmount": 0.0,
//                                   //   "balance": 300.0,
//                                   //   "deliveryType": "PICKUP & DELIVERY",
//                                   //   "accountType": "MobileApp",
//                                   //   "clothData": [
//                                   //   {
//                                   //   "priceId": 106,
//                                   //   "clothName": "T-SHIRT",
//                                   //   "arabicName": "بلوزة",
//                                   //   "clothPrice": "10.000",
//                                   //   "clothImg": "https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg",
//                                   //   "qnty": 1,
//                                   //   "service": "DC",
//                                   //   "billing": "Express"
//                                   //   },
//                                   //   {
//                                   //   "priceId": 106,
//                                   //   "clothName": "T-SHIRT",
//                                   //   "arabicName": "بلوزة",
//                                   //   "clothPrice": "5.000",
//                                   //   "clothImg": "https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg",
//                                   //   "qnty": 1,
//                                   //   "service": "DC",
//                                   //   "billing": "Normal"
//                                   //   }
//                                   //   ]
//                                   // }
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   padding: const EdgeInsets.all(16.0),
//                                   primary: Color(0xFF301C93),
//                                   // Background color
//                                   onPrimary: Colors.white,
//                                   // Text color
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(
//                                         10), // Border radius
//                                   ),
//                                 ),
//                                 child: Text(
//                                   'Collect now',
//                                   style: TextStyle(
//                                     fontFamily:
//                                         GoogleFonts.openSans().fontFamily,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 10),
//                               Expanded(
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       'ITEMS : $itemCount',
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontFamily:
//                                             GoogleFonts.openSans().fontFamily,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFF301C93),
//                                       ),
//                                     ),
//                                     SizedBox(width: 30),
//                                     Text(
//                                       'QTY : $totalQty',
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontFamily:
//                                             GoogleFonts.openSans().fontFamily,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFF301C93),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               bottomNavigationBar: BottomNavigationBar(
//                 currentIndex: _currentIndex,
//                 onTap: _onItemTapped,
//                 type: BottomNavigationBarType.fixed,
//                 items: [
//                   BottomNavigationBarItem(
//                     icon: Icon(
//                       Icons.home,
//                     ),
//                     label: 'Home',
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(
//                       Icons.car_crash,
//                     ),
//                     label: 'Pickup',
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(
//                       Icons.car_crash,
//                     ),
//                     label: 'Delivery',
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(
//                       Icons.compare_arrows,
//                     ),
//                     label: 'History',
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(
//                       Icons.person,
//                     ),
//                     label: 'Me',
//                   ),
//                 ],
//                 selectedItemColor: Color(0xFF301C93),
//                 selectedFontSize:
//                     12.0, // Adjust the font size for the selected item
//                 unselectedFontSize:
//                     12.0, // Adjust the font size for unselected items
//                 iconSize: 26.0, // Adjust the icon size
//               ),
//             );
//           } else if (state is LoadingState) {
//             // return Center(
//             //   child: CircularProgressIndicator(),
//             // );
//             return _buildShimmerLoading();
//           } else {
//             return _buildShimmerLoading();
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildShimmerLoading() {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 40),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         SizedBox(width: 10),
//                         Text(
//                           'Taj Muhammed',
//                           style: TextStyle(
//                               fontSize: 24,
//                               fontFamily: GoogleFonts.openSans().fontFamily,
//                               fontWeight: FontWeight.normal,
//                               color: Color(0xFF000000)),
//                         ),
//                       ],
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.notifications_outlined,
//                           size: 50, color: Color(0xFF301C93)),
//                       onPressed: () {
//                         // Add your onPressed logic here
//                       },
//                     ),
//                   ],
//                 ),
//                 // Image.asset(
//                 //   logo,
//                 //   height: 90,
//                 //   width: 130,
//                 // ),
//
//                 const SizedBox(height: 25),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Collect now',
//                       style: TextStyle(
//                           fontSize: 24,
//                           fontFamily: GoogleFonts.openSans().fontFamily,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF301C93)),
//                     ),
//                     TextButton.icon(
//                       icon: Icon(Icons.arrow_back_outlined,
//                           size: 25, color: Color(0xFF301C93)),
//                       label: Text('Back',
//                           style: TextStyle(
//                             color: Color(0xFF301C93),
//                             fontSize: 20,
//                             fontFamily: GoogleFonts.openSans().fontFamily,
//                           )),
//                       onPressed: () {
//                         // Add your onPressed logic here
//                       },
//                     ),
//                   ],
//                 ),
//                 Shimmer.fromColors(
//                   baseColor: Colors.grey[300]!,
//                   highlightColor: Colors.grey[100]!,
//                   direction: ShimmerDirection.ltr,
//                   child: Column(
//                     children: [
//                       Card(
//                         color: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15.0),
//                           side: const BorderSide(
//                             color: Colors.grey,
//                             width: 0.5,
//                           ),
//                         ),
//                         margin: const EdgeInsets.symmetric(vertical: 5),
//                         child: Container(
//                           height: MediaQuery.of(context).size.height / 3,
//                           padding: const EdgeInsets.all(16),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Logo (30%)
//                               Container(
//                                 width: 480,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       ListView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: 5,
//                         itemBuilder: (context, index) {
//                           return Padding(
//                             padding: const EdgeInsets.all(15.0),
//                             child: Card(
//                               color: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(15.0),
//                                 side: const BorderSide(
//                                   color: Colors.grey,
//                                   width: 0.5,
//                                 ),
//                               ),
//                               margin: const EdgeInsets.symmetric(vertical: 5),
//                               child: Container(
//                                 height: MediaQuery.of(context).size.height / 8,
//                                 padding: const EdgeInsets.all(16),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     // Logo (30%)
//                                     Container(
//                                       width: 90,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<Map<String, dynamic>> fetchClothDetails(String clothname) async {
//     final String apiUrl =
//         'https://be.syswash.net/api/syswash/clothdetails?code=A';
//
//     final response = await http.get(Uri.parse(apiUrl), headers: {
//       "Accept": "application/json",
//       "Authorization": "Bearer $userToken"
//     });
//
//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
//       if (data.isNotEmpty) {
//         for (var clothData in data) {
//           if (clothData['data']['clothName'] == clothname) {
//             return {
//               'clothNameArabic': clothData['data']['clothNameArabic'],
//               'clothImg': clothData['data']['clothImg']
//             };
//           }
//         }
//
//         throw Exception('No data available for the provided cloth name.');
//       } else {
//         throw Exception('No data available from the server.');
//       }
//     } else {
//       throw Exception('Failed to load cloth details');
//     }
//   }
//
//   Future<int> getPriceId(
//     String selectedService,
//     String selectedCloth,
//   ) async {
//     final String apiUrl =
//         // 'https://be.syswash.net/api/syswash/pricedetails?code=A';
//         '${AppUrls.pricedetails}${AppUrls.code_main}$companyCode';
//
//     final response = await http.get(Uri.parse(apiUrl), headers: {
//       "Accept": "application/json",
//       "Authorization": "Bearer $userToken"
//     });
//
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//
//       //   print(data);
//       final Map<String, dynamic> serviceData = data.firstWhere(
//         (element) =>
//             element['serviceName'] == selectedService &&
//             element['clothType'] == selectedCloth,
//         orElse: () => null,
//       );
//
//       if (serviceData != null) {
//         // Assuming quantity selection influences which priceId to select
//         return serviceData['priceId'];
//       } else {
//         throw Exception('Service or cloth type not found.');
//       }
//     } else {
//       throw Exception('Failed to load data');
//     }
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
//   Future<void> postData() async {
//     var pickupassgnIdNum = int.tryParse(pickupassgnId);
//
//     // Convert 'qnty' strings to integers, keeping other fields unchanged
//     List<Map<String, dynamic>> convertedClothData = clothdate.map((item) {
//       var qntyInt = int.tryParse(item['qnty'] ?? '0') ?? 0;
//       return {
//         ...item,
//         'qnty': qntyInt,
//       };
//     }).toList();
//
//     var response = await http.Client().post(
//       Uri.parse('https://be.syswash.net/api/syswash/pickuporder?code=A'),
//       headers: {
//         "Content-Type": "application/json",
//         "Accept": "application/json",
//         "Authorization": "Bearer $userToken"
//       },
//       body: jsonEncode({
//         "pickupassgn_id": pickupassgnIdNum,
//         "pickuporderTime": formatedtime,
//         "quantity": totalQty,
//         "subTotal": 0.0,
//         "discount": 0.0,
//         "totalAmount": 0.0,
//         "paidAmount": 0.0,
//         "balance": 0.0,
//         "deliveryType": "PICKUP & DELIVERY",
//         "accountType": "MobileApp",
//         "clothData": convertedClothData, // Use the converted cloth data
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       clothdate.clear();
//       Navigator.pushNamed(
//         context,
//         "/customer_details",
//         arguments: pickupassgnId,
//       );
//     } else {
//       // If request failed, handle the error
//       print('Failed to post data: ${response.statusCode}');
//     }
//   }
// }
//
//
//
//
//
// // import 'dart:convert';
// //
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:shimmer/shimmer.dart';
// // import 'package:syswash/service/api_service.dart';
// // import 'package:http/http.dart' as http;
// // import '../../../../utils/app_constant.dart';
// // import '../../../../utils/app_sp.dart';
// // import '../../../../utils/app_url.dart';
// // import 'bloc/customer_details_bloc.dart';
// //
// // class CustomerDetailsOrder extends StatefulWidget {
// //   final String? pickupassgnId;
// //
// //   const CustomerDetailsOrder({Key? key, this.pickupassgnId}) : super(key: key);
// //
// //   @override
// //   State<CustomerDetailsOrder> createState() => _CustomerDetailsOrderState();
// // }
// //
// // class _CustomerDetailsOrderState extends State<CustomerDetailsOrder> {
// //   int _currentIndex = 1;
// //   late CustomerDetailsBloc _customerDetailsBloc;
// //   String tokenID = '';
// //   String userToken = "";
// //   String companyCode = "";
// //   String userID = "";
// //
// //   String pickupassgnId = '';
// //   String selectedService = "";
// //   List<String?> serviceNames = [];
// //   List<String?> serviceCodes = [];
// //
// //   List<String> clothNames = [];
// //   String? selectedCloth;
// //   String selectedServiceCode = "";
// //
// //   String quantity = "1";
// //
// //   String selectedBilling = "Express";
// //   List<String> billingOptions = ['Express', 'Normal', 'Faster'];
// //
// //   int PRICEID = 0;
// //
// //   String ClothNameArabic = "";
// //
// //   String ClothImage = "";
// //
// //   List<Map<String, dynamic>> clothdate = [];
// //   List<Map<String, dynamic>> clothdata_order = [];
// //   int totalQty = 0;
// //   int totalQty1 = 0;
// //   int totalQty2 = 0;
// //   int itemCount = 0;
// //
// //   String formatedtime = "";
// //
// //   String passassignuserID = "";
// //
// //   void saveDataToClothDate(Map<String, dynamic> clothData) {
// //     setState(() {
// //       clothdate.add(clothData);
// //       updateCounts();
// //     });
// //   }
// //
// //   void removeDataFromClothDate(int index) {
// //     setState(() {
// //       clothdate.removeAt(index);
// //       updateCounts(); // Recalculate counts after removing an item
// //     });
// //   }
// //
// //   void updateCounts() {
// //     itemCount = clothdate.length + clothdata_order.length;
// //     totalQty1 = 0;
// //     for (var cloth in clothdate) {
// //       totalQty1 += int.parse(cloth['qnty']);
// //     }
// //     totalQty2 = 0;
// //     for (var cloth in clothdata_order) {
// //       totalQty2 += int.parse(cloth['qnty'].toString());
// //     }
// //     totalQty = totalQty1 + totalQty2;
// //   }
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     pickupassgnId = widget.pickupassgnId ?? '';
// //     _customerDetailsBloc = CustomerDetailsBloc(ApiService());
// //     getUserToken();
// //     var currentTime = DateTime.now();
// //     formatedtime =
// //         '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';
// //   }
// //
// //   Future<void> getUserToken() async {
// //     AppSp appSp = AppSp();
// //     userToken = await appSp.getToken();
// //     companyCode = await appSp.getCompanyCode();
// //     fetchServiceDetailsData(userToken, companyCode);
// //     fetchClouthDetailsData(userToken, companyCode);
// //
// //     _customerDetailsBloc
// //         .add(CustomerDetailsApiEvent(userToken, companyCode, pickupassgnId));
// //   }
// //
// //   @override
// //   void dispose() {
// //     _customerDetailsBloc.close();
// //     super.dispose();
// //   }
// //
// //   void fetchClouthDetailsData(String userToken, String companyCode) async {
// //     final response = await http.get(
// //         Uri.parse('${AppUrls.clothdetails}${AppUrls.code_main}$companyCode'),
// //         headers: {
// //           "Accept": "application/json",
// //           "Authorization": "Bearer $userToken"
// //         });
// //     if (response.statusCode == 200) {
// //       List<Map<String, dynamic>> clothDataList =
// //           List<Map<String, dynamic>>.from(json.decode(response.body));
// //       setState(() {
// //         clothNames = clothDataList
// //             .map((clothData) => clothData['data']['clothName'] as String)
// //             .toList();
// //       });
// //     } else {
// //       print("Failed to fetch data: ${response.statusCode}");
// //     }
// //   }
// //
// //   void fetchServiceDetailsData(String userToken, String companyCode) async {
// //     final response = await http.get(
// //         Uri.parse('${AppUrls.servicedetails}${AppUrls.code_main}$companyCode'),
// //         headers: {
// //           "Accept": "application/json",
// //           "Authorization": "Bearer $userToken"
// //         });
// //     if (response.statusCode == 200) {
// //       List<dynamic> responseData = json.decode(response.body);
// //       List<Map<String, String>> services = responseData.map((data) {
// //         return {
// //           'serviceName': data['serviceName'] as String,
// //           'serviceCode': data['serviceCode'] as String,
// //         };
// //       }).toList();
// //       setState(() {
// //         serviceNames =
// //             services.map((service) => service['serviceName']).toList();
// //         serviceCodes =
// //             services.map((service) => service['serviceCode']).toList();
// //
// //         if (serviceNames.isNotEmpty) {
// //           selectedService = serviceNames[0]!;
// //         }
// //       });
// //     } else {
// //       print("Failed to fetch data: ${response.statusCode}");
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return BlocProvider(
// //       create: (context) => _customerDetailsBloc,
// //       child: BlocConsumer<CustomerDetailsBloc, CustomerDetailsState>(
// //         listener: (context, state) {
// //           if (state is LoadedState) {
// //             print("Category List Response: ${state.response}");
// //           } else if (state is ErrorState) {
// //             // Handle error state
// //           } else if (state is UnAuthorizedState) {
// //             // Handle unauthorized state
// //           } else if (state is NoInternetState) {
// //             // Handle no internet state
// //           }
// //         },
// //         builder: (context, state) {
// //           if (state is LoadingState) {
// //             return Center(
// //               child: CircularProgressIndicator(),
// //             );
// //             // return _buildShimmerLoading();
// //           } else if (state is LoadedState) {
// //             var pickupassgn = state.response.pickupassgn;
// //
// //             var pickupassgn_id = state.response.pickupassgnId;
// //
// //             if (pickupassgn != null && pickupassgn is List) {
// //               clothdata_order.clear();
// //               for (var item in pickupassgn) {
// //                 var clothData = item.clothData;
// //                 if (clothData != null && clothData is List) {
// //                   for (var clothItem in clothData) {
// //                     Map<String, dynamic> clothDataMap = {
// //                       "priceId": clothItem.priceId,
// //                       "clothName": clothItem.clothName,
// //                       "arabicName":
// //                           utf8.decode(clothItem.arabicName!.runes.toList()),
// //                       "clothImg": clothItem.clothImg,
// //                       "qnty": clothItem.qnty,
// //                       "service": clothItem.service,
// //                       "billing": clothItem.billing
// //                     };
// //                     clothdata_order.add(clothDataMap);
// //                   }
// //                 } else {
// //                   print('clothData is null or not an array');
// //                 }
// //               }
// //             } else {
// //               print('pickupassgn is null or not an array');
// //             }
// //
// //             updateCounts();
// //
// //             return Scaffold(
// //               backgroundColor: Color(0xFFEFEEF3),
// //               body: SingleChildScrollView(
// //                 // Wrap the entire page with SingleChildScrollView
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(30),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       SizedBox(height: 30),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Row(
// //                             children: [
// //                               // CircleAvatar(
// //                               //   backgroundImage:
// //                               //       AssetImage('assets/profile_image.jpg'),
// //                               //   radius: 30,
// //                               // ),
// //                               SizedBox(width: 10),
// //                               // Adjust spacing between circle and text
// //                               Text(
// //                                 'Taj Muhammed',
// //                                 style: TextStyle(
// //                                   fontSize: 24,
// //                                   fontWeight: FontWeight.normal,
// //                                   fontFamily: GoogleFonts.openSans().fontFamily,
// //                                   color: Color(0xFF000000),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                           IconButton(
// //                             icon: Icon(Icons.notifications_outlined,
// //                                 size: 50, color: Color(0xFF301C93)),
// //                             onPressed: () {
// //                               // Add your onPressed logic here
// //                             },
// //                           ),
// //                         ],
// //                       ),
// //                       SizedBox(height: 10),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Text(
// //                             'Collect now',
// //                             style: TextStyle(
// //                               fontSize: 24,
// //                               fontFamily: GoogleFonts.openSans().fontFamily,
// //                               fontWeight: FontWeight.bold,
// //                               color: Color(0xFF301C93),
// //                             ),
// //                           ),
// //                           TextButton.icon(
// //                             icon: Icon(Icons.arrow_back_outlined,
// //                                 size: 25, color: Color(0xFF301C93)),
// //                             label: Text('Back',
// //                                 style: TextStyle(
// //                                   color: Color(0xFF301C93),
// //                                   fontSize: 20,
// //                                   fontFamily: GoogleFonts.openSans().fontFamily,
// //                                 )),
// //                             onPressed: () {
// //                               Navigator.pushNamed(
// //                                   context, "/pickupOrderListing");
// //                               // Add your onPressed logic here
// //                             },
// //                           ),
// //                         ],
// //                       ),
// //                       dividerLH(),
// //                       Card(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Row(
// //                               children: [
// //                                 Padding(
// //                                   padding: EdgeInsets.all(20),
// //                                   // child: CircleAvatar(
// //                                   //   radius: 30,
// //                                   //   backgroundImage:
// //                                   //       AssetImage('assets/avatar.png'),
// //                                   // ),
// //
// //                                   child: Column(
// //                                     crossAxisAlignment:
// //                                         CrossAxisAlignment.start,
// //                                     children: [
// //                                       Text(
// //                                         '${state.response.pickupCustomerName}',
// //                                         style: TextStyle(
// //                                           fontWeight: FontWeight.bold,
// //                                           fontFamily:
// //                                               GoogleFonts.openSans().fontFamily,
// //                                           fontSize: 16.0,
// //                                         ),
// //                                       ),
// //                                       SizedBox(height: 5.0),
// //                                       Text(
// //                                         '${state.response.pickupCustomerPhno}',
// //                                         style: TextStyle(
// //                                           fontSize: 14.0,
// //                                         ),
// //                                       ),
// //                                       SizedBox(height: 5.0),
// //                                       Row(
// //                                         children: [
// //                                           Icon(Icons.location_on, size: 16.0),
// //                                           SizedBox(width: 5.0),
// //                                           Text(
// //                                             '${state.response.pickupCustomerArea}',
// //                                             style: TextStyle(
// //                                               fontSize: 14.0,
// //                                               fontFamily: GoogleFonts.openSans()
// //                                                   .fontFamily,
// //                                             ),
// //                                           ),
// //                                         ],
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                             Padding(
// //                               padding: const EdgeInsets.all(20),
// //                               child: Column(
// //                                 children: [
// //                                   Row(
// //                                     crossAxisAlignment:
// //                                         CrossAxisAlignment.start,
// //                                     children: [
// //                                       Expanded(
// //                                         flex: 1,
// //                                         child: Column(
// //                                           crossAxisAlignment:
// //                                               CrossAxisAlignment.start,
// //                                           children: [
// //                                             Text(
// //                                               'Created at',
// //                                               style: TextStyle(
// //                                                 fontSize: 14,
// //                                                 fontFamily:
// //                                                     GoogleFonts.openSans()
// //                                                         .fontFamily,
// //                                                 color: Colors.grey,
// //                                               ),
// //                                             ),
// //                                             Text(
// //                                               '12-4-2033',
// //                                               style: TextStyle(
// //                                                 fontSize: 16,
// //                                                 fontFamily:
// //                                                     GoogleFonts.openSans()
// //                                                         .fontFamily,
// //                                                 fontWeight: FontWeight.bold,
// //                                                 color: Colors.black,
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                       ),
// //                                       Expanded(
// //                                         flex: 1,
// //                                         child: Column(
// //                                           crossAxisAlignment:
// //                                               CrossAxisAlignment.start,
// //                                           children: [
// //                                             Text(
// //                                               'Pickup',
// //                                               style: TextStyle(
// //                                                 fontSize: 14,
// //                                                 fontFamily:
// //                                                     GoogleFonts.openSans()
// //                                                         .fontFamily,
// //                                                 color: Colors.grey,
// //                                               ),
// //                                             ),
// //                                             Text(
// //                                               '12-45-2039',
// //                                               style: TextStyle(
// //                                                 fontSize: 16,
// //                                                 fontWeight: FontWeight.bold,
// //                                                 fontFamily:
// //                                                     GoogleFonts.openSans()
// //                                                         .fontFamily,
// //                                                 color: Colors.black,
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   SizedBox(height: 15),
// //                                   Row(
// //                                     crossAxisAlignment:
// //                                         CrossAxisAlignment.start,
// //                                     children: [
// //                                       Expanded(
// //                                         flex: 1,
// //                                         child: Column(
// //                                           crossAxisAlignment:
// //                                               CrossAxisAlignment.start,
// //                                           children: [
// //                                             Text(
// //                                               'Drop off',
// //                                               style: TextStyle(
// //                                                 fontSize: 14,
// //                                                 color: Colors.grey,
// //                                                 fontFamily:
// //                                                     GoogleFonts.openSans()
// //                                                         .fontFamily,
// //                                               ),
// //                                             ),
// //                                             Text(
// //                                               '12-4-2033',
// //                                               style: TextStyle(
// //                                                 fontSize: 16,
// //                                                 fontWeight: FontWeight.bold,
// //                                                 fontFamily:
// //                                                     GoogleFonts.openSans()
// //                                                         .fontFamily,
// //                                                 color: Colors.black,
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                       ),
// //                                       Expanded(
// //                                         flex: 1,
// //                                         child: Column(
// //                                           crossAxisAlignment:
// //                                               CrossAxisAlignment.start,
// //                                           children: [
// //                                             Text(
// //                                               'Status',
// //                                               style: TextStyle(
// //                                                 fontSize: 14,
// //                                                 color: Colors.grey,
// //                                               ),
// //                                             ),
// //                                             Text(
// //                                               '${state.response.pickupstatus}',
// //                                               style: TextStyle(
// //                                                 fontSize: 16,
// //                                                 fontWeight: FontWeight.bold,
// //                                                 fontFamily:
// //                                                     GoogleFonts.openSans()
// //                                                         .fontFamily,
// //                                                 color: Colors.black,
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   SizedBox(height: 15),
// //                                   Row(
// //                                     crossAxisAlignment:
// //                                         CrossAxisAlignment.start,
// //                                     children: [
// //                                       Expanded(
// //                                         flex: 1,
// //                                         child: Column(
// //                                           crossAxisAlignment:
// //                                               CrossAxisAlignment.start,
// //                                           children: [
// //                                             Text(
// //                                               'Street',
// //                                               style: TextStyle(
// //                                                 fontSize: 14,
// //                                                 fontFamily:
// //                                                     GoogleFonts.openSans()
// //                                                         .fontFamily,
// //                                                 color: Colors.grey,
// //                                               ),
// //                                             ),
// //                                             Text(
// //                                               'Akhilnrd',
// //                                               style: TextStyle(
// //                                                 fontSize: 16,
// //                                                 fontFamily:
// //                                                     GoogleFonts.openSans()
// //                                                         .fontFamily,
// //                                                 fontWeight: FontWeight.bold,
// //                                                 color: Colors.black,
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                       ),
// //                                       Expanded(
// //                                         flex: 1,
// //                                         child: Column(
// //                                           crossAxisAlignment:
// //                                               CrossAxisAlignment.start,
// //                                           children: [
// //                                             Text(
// //                                               'Postal Code',
// //                                               style: TextStyle(
// //                                                 fontSize: 14,
// //                                                 fontFamily:
// //                                                     GoogleFonts.openSans()
// //                                                         .fontFamily,
// //                                                 color: Colors.grey,
// //                                               ),
// //                                             ),
// //                                             Text(
// //                                               '345673',
// //                                               style: TextStyle(
// //                                                 fontSize: 16,
// //                                                 fontFamily:
// //                                                     GoogleFonts.openSans()
// //                                                         .fontFamily,
// //                                                 fontWeight: FontWeight.bold,
// //                                                 color: Colors.black,
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   SizedBox(height: 15),
// //                                   Row(
// //                                     crossAxisAlignment:
// //                                         CrossAxisAlignment.start,
// //                                     children: [
// //                                       Expanded(
// //                                         flex: 1,
// //                                         child: Column(
// //                                           crossAxisAlignment:
// //                                               CrossAxisAlignment.start,
// //                                           children: [
// //                                             Text(
// //                                               'House Number',
// //                                               style: TextStyle(
// //                                                 fontSize: 14,
// //                                                 fontFamily:
// //                                                     GoogleFonts.openSans()
// //                                                         .fontFamily,
// //                                                 color: Colors.grey,
// //                                               ),
// //                                             ),
// //                                             Text(
// //                                               '323',
// //                                               style: TextStyle(
// //                                                 fontSize: 16,
// //                                                 fontWeight: FontWeight.bold,
// //                                                 color: Colors.black,
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                       ),
// //                                       Expanded(
// //                                         flex: 1,
// //                                         child: Column(
// //                                           crossAxisAlignment:
// //                                               CrossAxisAlignment.start,
// //                                           children: [
// //                                             Text(
// //                                               'Town',
// //                                               style: TextStyle(
// //                                                 fontSize: 14,
// //                                                 fontFamily:
// //                                                     GoogleFonts.openSans()
// //                                                         .fontFamily,
// //                                                 color: Colors.grey,
// //                                               ),
// //                                             ),
// //                                             Text(
// //                                               'Quater',
// //                                               style: TextStyle(
// //                                                 fontSize: 16,
// //                                                 fontFamily:
// //                                                     GoogleFonts.openSans()
// //                                                         .fontFamily,
// //                                                 fontWeight: FontWeight.bold,
// //                                                 color: Colors.black,
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   SizedBox(height: 15),
// //                                   Row(
// //                                     crossAxisAlignment:
// //                                         CrossAxisAlignment.start,
// //                                     children: [
// //                                       Expanded(
// //                                         flex: 1,
// //                                         child: Column(
// //                                           crossAxisAlignment:
// //                                               CrossAxisAlignment.start,
// //                                           children: [
// //                                             Text(
// //                                               'Bill Amount',
// //                                               style: TextStyle(
// //                                                 fontSize: 14,
// //                                                 fontFamily:
// //                                                     GoogleFonts.openSans()
// //                                                         .fontFamily,
// //                                                 color: Colors.grey,
// //                                               ),
// //                                             ),
// //                                             Text(
// //                                               '34',
// //                                               style: TextStyle(
// //                                                 fontSize: 16,
// //                                                 fontFamily:
// //                                                     GoogleFonts.openSans()
// //                                                         .fontFamily,
// //                                                 fontWeight: FontWeight.bold,
// //                                                 color: Colors.black,
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   SizedBox(height: 15)
// //                                 ],
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       SizedBox(height: 15),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Text(
// //                             'Order Items',
// //                             style: TextStyle(
// //                               fontSize: 30,
// //                               fontFamily: GoogleFonts.openSans().fontFamily,
// //                               fontWeight: FontWeight.bold,
// //                               color: Color(0xFF301C93),
// //                             ),
// //                           ),
// //                           ElevatedButton(
// //                             onPressed: () {
// //                               showDialog(
// //                                 context: context,
// //                                 builder: (BuildContext context) {
// //                                   return AlertDialog(
// //                                     backgroundColor: Color(0xFFEFEEF3),
// //                                     shape: RoundedRectangleBorder(
// //                                       borderRadius: BorderRadius.circular(15.0),
// //                                     ),
// //                                     content: StatefulBuilder(
// //                                       builder: (BuildContext context,
// //                                           StateSetter setState) {
// //                                         return Container(
// //                                           width: 400,
// //                                           height: 550,
// //                                           child: SingleChildScrollView(
// //                                             child: Padding(
// //                                               padding:
// //                                                   const EdgeInsets.all(30.0),
// //                                               child: Column(
// //                                                 mainAxisAlignment:
// //                                                     MainAxisAlignment.center,
// //                                                 crossAxisAlignment:
// //                                                     CrossAxisAlignment.start,
// //                                                 children: [
// //                                                   Text(
// //                                                     'Add Items',
// //                                                     style: TextStyle(
// //                                                       fontWeight:
// //                                                           FontWeight.bold,
// //                                                       color: Color(0xFF301C93),
// //                                                       fontFamily:
// //                                                           GoogleFonts.openSans()
// //                                                               .fontFamily,
// //                                                       fontSize: 23.0,
// //                                                     ),
// //                                                   ),
// //                                                   SizedBox(height: 20),
// //                                                   Column(
// //                                                     crossAxisAlignment:
// //                                                         CrossAxisAlignment
// //                                                             .start,
// //                                                     children: [
// //                                                       Text(
// //                                                         'Select Service:',
// //                                                         style: TextStyle(
// //                                                           fontWeight:
// //                                                               FontWeight.bold,
// //                                                           fontFamily: GoogleFonts
// //                                                                   .openSans()
// //                                                               .fontFamily,
// //                                                         ),
// //                                                       ),
// //                                                       SizedBox(height: 5),
// //                                                       Container(
// //                                                         padding: EdgeInsets
// //                                                             .symmetric(
// //                                                                 horizontal:
// //                                                                     12.0),
// //                                                         decoration:
// //                                                             BoxDecoration(
// //                                                           color:
// //                                                               Color(0xFFF9F9F9),
// //                                                           borderRadius:
// //                                                               BorderRadius
// //                                                                   .circular(
// //                                                                       10.0),
// //                                                         ),
// //                                                         child: DropdownButton<
// //                                                             String?>(
// //                                                           isExpanded: true,
// //                                                           onChanged: (String?
// //                                                               newValue) {
// //                                                             if (newValue !=
// //                                                                 null) {
// //                                                               setState(() {
// //                                                                 selectedService =
// //                                                                     newValue;
// //                                                                 selectedServiceCode =
// //                                                                     serviceCodes[
// //                                                                         serviceNames
// //                                                                             .indexOf(newValue)]!;
// //                                                                 // print("Selected service: $selectedService, Code: $selectedServiceCode");
// //                                                                 print(
// //                                                                     '+++++++');
// //
// //                                                                 print(
// //                                                                     '+++++++');
// //                                                               });
// //                                                             }
// //                                                           },
// //                                                           value:
// //                                                               selectedService,
// //                                                           items: serviceNames.map<
// //                                                                   DropdownMenuItem<
// //                                                                       String?>>(
// //                                                               (String? value) {
// //                                                             return DropdownMenuItem<
// //                                                                 String?>(
// //                                                               value: value,
// //                                                               child: Text(
// //                                                                   value ?? ""),
// //                                                             );
// //                                                           }).toList(),
// //                                                         ),
// //                                                       ),
// //                                                     ],
// //                                                   ),
// //                                                   SizedBox(height: 20),
// //                                                   Column(
// //                                                     crossAxisAlignment:
// //                                                         CrossAxisAlignment
// //                                                             .start,
// //                                                     children: [
// //                                                       Text(
// //                                                         'Cloth Type:',
// //                                                         style: TextStyle(
// //                                                           fontWeight:
// //                                                               FontWeight.bold,
// //                                                           fontFamily: GoogleFonts
// //                                                                   .openSans()
// //                                                               .fontFamily,
// //                                                         ),
// //                                                       ),
// //                                                       SizedBox(height: 5),
// //                                                       Container(
// //                                                         padding: EdgeInsets
// //                                                             .symmetric(
// //                                                                 horizontal:
// //                                                                     12.0),
// //                                                         decoration:
// //                                                             BoxDecoration(
// //                                                           color:
// //                                                               Color(0xFFF9F9F9),
// //                                                           borderRadius:
// //                                                               BorderRadius
// //                                                                   .circular(
// //                                                                       10.0),
// //                                                         ),
// //                                                         child: DropdownButton<
// //                                                             String>(
// //                                                           isExpanded: true,
// //                                                           value: selectedCloth,
// //                                                           onChanged: (String?
// //                                                               newValue) {
// //                                                             setState(() {
// //                                                               selectedCloth =
// //                                                                   newValue;
// //                                                             });
// //                                                           },
// //                                                           items: clothNames.map(
// //                                                               (String value) {
// //                                                             return DropdownMenuItem<
// //                                                                 String>(
// //                                                               value: value,
// //                                                               child:
// //                                                                   Text(value),
// //                                                             );
// //                                                           }).toList(),
// //                                                           hint: Text(
// //                                                               'Select a cloth type'),
// //                                                         ),
// //                                                       ),
// //                                                     ],
// //                                                   ),
// //                                                   dividerH(),
// //                                                   Column(
// //                                                     crossAxisAlignment:
// //                                                         CrossAxisAlignment
// //                                                             .start,
// //                                                     children: [
// //                                                       Text(
// //                                                         'QTY:',
// //                                                         style: TextStyle(
// //                                                           fontWeight:
// //                                                               FontWeight.bold,
// //                                                         ),
// //                                                       ),
// //                                                       SizedBox(height: 5),
// //                                                       TextField(
// //                                                         controller:
// //                                                             TextEditingController(
// //                                                                 text: quantity),
// //                                                         onChanged: (value) {
// //                                                           quantity = value;
// //                                                         },
// //                                                         decoration:
// //                                                             InputDecoration(
// //                                                           filled: true,
// //                                                           fillColor:
// //                                                               Color(0xFFF9F9F9),
// //                                                           border:
// //                                                               OutlineInputBorder(
// //                                                             borderRadius:
// //                                                                 BorderRadius
// //                                                                     .circular(
// //                                                                         10.0),
// //                                                           ),
// //                                                           hintText:
// //                                                               'Enter a quantity',
// //                                                           contentPadding:
// //                                                               EdgeInsets
// //                                                                   .symmetric(
// //                                                                       horizontal:
// //                                                                           12.0),
// //                                                         ),
// //                                                       ),
// //                                                     ],
// //                                                   ),
// //                                                   dividerH(),
// //                                                   Column(
// //                                                     crossAxisAlignment:
// //                                                         CrossAxisAlignment
// //                                                             .start,
// //                                                     children: [
// //                                                       Text(
// //                                                         'Billing:',
// //                                                         style: TextStyle(
// //                                                           fontWeight:
// //                                                               FontWeight.bold,
// //                                                           fontFamily: GoogleFonts
// //                                                                   .openSans()
// //                                                               .fontFamily,
// //                                                         ),
// //                                                       ),
// //                                                       SizedBox(height: 5),
// //                                                       Container(
// //                                                         padding: EdgeInsets
// //                                                             .symmetric(
// //                                                                 horizontal:
// //                                                                     12.0),
// //                                                         decoration:
// //                                                             BoxDecoration(
// //                                                           color:
// //                                                               Color(0xFFF9F9F9),
// //                                                           borderRadius:
// //                                                               BorderRadius
// //                                                                   .circular(
// //                                                                       10.0),
// //                                                         ),
// //                                                         child: DropdownButton<
// //                                                             String>(
// //                                                           isExpanded: true,
// //                                                           value:
// //                                                               selectedBilling,
// //                                                           onChanged: (String?
// //                                                               newValue) {
// //                                                             setState(() {
// //                                                               selectedBilling =
// //                                                                   newValue!;
// //                                                             });
// //                                                           },
// //                                                           items: billingOptions
// //                                                               .map((String
// //                                                                   value) {
// //                                                             return DropdownMenuItem<
// //                                                                 String>(
// //                                                               value: value,
// //                                                               child:
// //                                                                   Text(value),
// //                                                             );
// //                                                           }).toList(),
// //                                                           hint: Text(
// //                                                               'Select a billing type'),
// //                                                         ),
// //                                                       ),
// //                                                     ],
// //                                                   ),
// //                                                   dividerH(),
// //                                                   Container(
// //                                                     padding:
// //                                                         const EdgeInsets.all(5),
// //                                                     width: double.infinity,
// //                                                     // Full width
// //                                                     decoration: BoxDecoration(
// //                                                       borderRadius:
// //                                                           BorderRadius.circular(
// //                                                               10.0),
// //                                                       color: Color(0xFF301C93),
// //                                                     ),
// //                                                     child: TextButton(
// //                                                       onPressed: () async {
// //                                                         // if (state.response.pickupOrderId == null) {
// //                                                         // print("Selected service: $selectedService");
// //                                                         // print("Selected cloth: $selectedCloth");
// //                                                         // print("Quantity: $quantity");
// //
// //                                                         // Define an async function to fetch the priceId
// //                                                         Future<void>
// //                                                             fetchPriceId() async {
// //                                                           try {
// //                                                             int priceId =
// //                                                                 await getPriceId(
// //                                                                     '$selectedService',
// //                                                                     '$selectedCloth');
// //                                                             setState(() {
// //                                                               PRICEID = priceId;
// //                                                             });
// //                                                           } catch (e) {
// //                                                             print('Error: $e');
// //                                                           }
// //                                                         }
// //
// //                                                         await fetchPriceId();
// //
// //                                                         try {
// //                                                           Map<String, dynamic>
// //                                                               clothDetails =
// //                                                               await fetchClothDetails(
// //                                                                   '$selectedCloth');
// //                                                           String
// //                                                               clothNameArabic =
// //                                                               clothDetails[
// //                                                                   'clothNameArabic'];
// //                                                           String clothImg =
// //                                                               clothDetails[
// //                                                                   'clothImg'];
// //                                                           setState(() {
// //                                                             ClothNameArabic =
// //                                                                 clothNameArabic;
// //                                                             ClothImage =
// //                                                                 clothImg;
// //                                                           });
// //                                                         } catch (e) {
// //                                                           print(
// //                                                               'Error fetching cloth details: $e');
// //                                                         }
// //
// //                                                         //print('{"priceId": $PRICEID,"clothName": $selectedCloth,"arabicName": $ClothNameArabic,"clothImg": $ClothImage,"qnty": $quantity,"service": $selectedServiceCode,"billing": $selectedBilling }');
// //
// //                                                         // Print the data to be added to clothdate list
// //                                                         Map<String, dynamic>
// //                                                             clothData = {
// //                                                           "priceId": PRICEID,
// //                                                           "clothName":
// //                                                               selectedCloth,
// //                                                           "arabicName":
// //                                                               ClothNameArabic,
// //                                                           "clothImg":
// //                                                               ClothImage,
// //                                                           "qnty": quantity,
// //                                                           "service":
// //                                                               selectedServiceCode,
// //                                                           "billing":
// //                                                               selectedBilling
// //                                                         };
// //                                                         print(clothData);
// //
// //                                                         // Save data to clothdate list
// //                                                         saveDataToClothDate(
// //                                                             clothData);
// //
// //                                                         // Print a separator for readability
// //                                                         print(
// //                                                             '-------------------');
// //                                                         print(
// //                                                             clothdate); // Print the clothdate list
// //                                                         print(
// //                                                             '-------------------');
// //
// //                                                         // setState(() {
// //                                                         //   selectedService = "";
// //                                                         //
// //                                                         //   quantity = "";
// //                                                         //   selectedBilling = "Express";
// //                                                         // });
// //                                                         Navigator.of(context)
// //                                                             .pop();
// //                                                       },
// //
// //                                                       // },
// //
// //                                                       child: Text(
// //                                                         'Submit',
// //                                                         style: TextStyle(
// //                                                           color: Colors.white,
// //                                                           fontFamily: GoogleFonts
// //                                                                   .openSans()
// //                                                               .fontFamily,
// //                                                         ),
// //                                                       ),
// //                                                     ),
// //                                                   ),
// //                                                 ],
// //                                               ),
// //                                             ),
// //                                           ),
// //                                         );
// //                                       },
// //                                     ),
// //                                   );
// //                                 },
// //                               );
// //                             },
// //                             style: TextButton.styleFrom(
// //                               backgroundColor:
// //                                   Color(0xFF301C93), // Button background color
// //                               padding: EdgeInsets.symmetric(
// //                                   vertical: 10, horizontal: 20),
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(
// //                                     15), // Button border radius
// //                               ),
// //                             ),
// //                             child: Text(
// //                               'ADD ITEMS',
// //                               style: TextStyle(
// //                                 fontSize: 15,
// //                                 fontFamily: GoogleFonts.openSans().fontFamily,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.white,
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //
// //                       ListView.builder(
// //                         shrinkWrap: true,
// //                         itemCount: clothdate.length,
// //                         itemBuilder: (context, index) {
// //                           var clothData = clothdate[index];
// //                           return Padding(
// //                             padding: EdgeInsets.symmetric(
// //                                 vertical: 5.0, horizontal: 10.0),
// //                             child: Card(
// //                               child: ListTile(
// //                                 leading: Image.network(
// //                                   clothData['clothImg'],
// //                                   fit: BoxFit.cover,
// //                                   errorBuilder: (context, error, stackTrace) {
// //                                     return Container(
// //                                       width: 50,
// //                                       height: 50,
// //                                       color: Colors.grey,
// //                                       child: Icon(
// //                                         Icons.error,
// //                                         color: Colors.red,
// //                                       ),
// //                                     );
// //                                   },
// //                                 ),
// //                                 title: Text(
// //                                   clothData['clothName'],
// //                                   style: TextStyle(
// //                                     fontFamily:
// //                                         GoogleFonts.openSans().fontFamily,
// //                                   ),
// //                                 ),
// //                                 subtitle: Text(
// //                                   clothData['arabicName'],
// //                                   style: TextStyle(
// //                                     fontFamily:
// //                                         GoogleFonts.openSans().fontFamily,
// //                                   ),
// //                                 ),
// //                                 trailing: IconButton(
// //                                   icon: Icon(Icons.delete),
// //                                   onPressed: () {
// //                                     removeDataFromClothDate(index);
// //                                   },
// //                                 ),
// //                               ),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                       ListView.builder(
// //                         shrinkWrap: true,
// //                         itemCount: clothdata_order.length,
// //                         itemBuilder: (context, index) {
// //                           var clothdata_orders = clothdata_order[index];
// //                           return Padding(
// //                             padding: EdgeInsets.symmetric(
// //                                 vertical: 5.0, horizontal: 10.0),
// //                             child: Card(
// //                               child: ListTile(
// //                                 leading: Image.network(
// //                                   clothdata_orders['clothImg'],
// //                                   fit: BoxFit.cover,
// //                                   errorBuilder: (context, error, stackTrace) {
// //                                     return Container(
// //                                       width: 50,
// //                                       height: 50,
// //                                       color: Colors.grey,
// //                                       child: Icon(
// //                                         Icons.error,
// //                                         color: Colors.red,
// //                                       ),
// //                                     );
// //                                   },
// //                                 ),
// //                                 title: Text(
// //                                   clothdata_orders['clothName'],
// //                                   style: TextStyle(
// //                                     fontFamily:
// //                                         GoogleFonts.openSans().fontFamily,
// //                                   ),
// //                                 ),
// //                                 subtitle: Text(
// //                                   clothdata_orders['arabicName'],
// //                                   style: TextStyle(
// //                                     fontFamily:
// //                                         GoogleFonts.openSans().fontFamily,
// //                                   ),
// //                                 ),
// //                                 // trailing: IconButton(
// //                                 //   icon: Icon(Icons.delete),
// //                                 //   onPressed: () {
// //                                 //     removeDataFromClothDate(index);
// //                                 //
// //                                 //   },
// //                                 // ),
// //                               ),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //
// //                       // ListView.builder(
// //                       //   shrinkWrap: true,
// //                       //   // Important to add
// //                       //   physics: NeverScrollableScrollPhysics(),
// //                       //   // Prevent inner ListView from scrolling
// //                       //   itemCount: 5,
// //                       //   // Change this according to your data
// //                       //   itemBuilder: (context, index) {
// //                       //     return Padding(
// //                       //       padding: EdgeInsets.symmetric(
// //                       //           vertical: 5.0, horizontal: 10.0),
// //                       //       child: Card(
// //                       //         child: ListTile(
// //                       //           // leading: SizedBox(
// //                       //           //   width: 80,
// //                       //           //   child: Image.network(
// //                       //           //     'https://via.placeholder.com/150',
// //                       //           //     // Replace with your image URL
// //                       //           //     fit: BoxFit.cover,
// //                       //           //   ),
// //                       //           // ),
// //                       //           title: Text(
// //                       //             'Heading $index',
// //                       //             style: TextStyle(
// //                       //               fontFamily:
// //                       //                   GoogleFonts.openSans().fontFamily,
// //                       //             ),
// //                       //           ),
// //                       //           subtitle: Text(
// //                       //             'Subheading $index',
// //                       //             style: TextStyle(
// //                       //               fontFamily:
// //                       //                   GoogleFonts.openSans().fontFamily,
// //                       //             ),
// //                       //           ),
// //                       //         ),
// //                       //       ),
// //                       //     );
// //                       //   },
// //                       // ),
// //
// //                       SizedBox(height: 15),
// //                       // Small card at the bottom
// //                       Card(
// //                         child: Padding(
// //                           padding: const EdgeInsets.all(15.0),
// //                           child: Row(
// //                             children: [
// //                               ElevatedButton(
// //                                 onPressed: () {
// //                                   print(
// //                                       '{"pickupassgn_id": ${state.response.pickupassgnId},"pickuporderTime": $formatedtime,"quantity": $totalQty,"subTotal": 0.0, "discount": 0.0,"totalAmount": 0.0,"paidAmount": 0.0,"balance": 0.0,"deliveryType": "PICKUP & DELIVERY","accountType": "MobileApp","clothData":$clothdate}');
// //
// //                                   postData();
// //
// //                                   //   {
// //                                   //     "pickupassgn_id": "67",
// //                                   //   "pickuporderTime": "12:39",
// //                                   //   "quantity": 2,
// //                                   //   "subTotal": 2000.0,
// //                                   //   "discount": 0.0,
// //                                   //   "totalAmount": 3000.0,
// //                                   //   "paidAmount": 0.0,
// //                                   //   "balance": 300.0,
// //                                   //   "deliveryType": "PICKUP & DELIVERY",
// //                                   //   "accountType": "MobileApp",
// //                                   //   "clothData": [
// //                                   //   {
// //                                   //   "priceId": 106,
// //                                   //   "clothName": "T-SHIRT",
// //                                   //   "arabicName": "بلوزة",
// //                                   //   "clothPrice": "10.000",
// //                                   //   "clothImg": "https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg",
// //                                   //   "qnty": 1,
// //                                   //   "service": "DC",
// //                                   //   "billing": "Express"
// //                                   //   },
// //                                   //   {
// //                                   //   "priceId": 106,
// //                                   //   "clothName": "T-SHIRT",
// //                                   //   "arabicName": "بلوزة",
// //                                   //   "clothPrice": "5.000",
// //                                   //   "clothImg": "https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg",
// //                                   //   "qnty": 1,
// //                                   //   "service": "DC",
// //                                   //   "billing": "Normal"
// //                                   //   }
// //                                   //   ]
// //                                   // }
// //                                 },
// //                                 style: ElevatedButton.styleFrom(
// //                                   padding: const EdgeInsets.all(16.0),
// //                                   primary: Color(0xFF301C93),
// //                                   // Background color
// //                                   onPrimary: Colors.white,
// //                                   // Text color
// //                                   shape: RoundedRectangleBorder(
// //                                     borderRadius: BorderRadius.circular(
// //                                         10), // Border radius
// //                                   ),
// //                                 ),
// //                                 child: Text(
// //                                   'Collect now',
// //                                   style: TextStyle(
// //                                     fontFamily:
// //                                         GoogleFonts.openSans().fontFamily,
// //                                   ),
// //                                 ),
// //                               ),
// //                               SizedBox(width: 10),
// //                               Expanded(
// //                                 child: Row(
// //                                   mainAxisAlignment: MainAxisAlignment.center,
// //                                   children: [
// //                                     Text(
// //                                       'ITEMS : $itemCount',
// //                                       style: TextStyle(
// //                                         fontSize: 20,
// //                                         fontFamily:
// //                                             GoogleFonts.openSans().fontFamily,
// //                                         fontWeight: FontWeight.bold,
// //                                         color: Color(0xFF301C93),
// //                                       ),
// //                                     ),
// //                                     SizedBox(width: 30),
// //                                     Text(
// //                                       'QTY : $totalQty',
// //                                       style: TextStyle(
// //                                         fontSize: 20,
// //                                         fontFamily:
// //                                             GoogleFonts.openSans().fontFamily,
// //                                         fontWeight: FontWeight.bold,
// //                                         color: Color(0xFF301C93),
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //               bottomNavigationBar: BottomNavigationBar(
// //                 currentIndex: _currentIndex,
// //                 onTap: _onItemTapped,
// //                 type: BottomNavigationBarType.fixed,
// //                 items: [
// //                   BottomNavigationBarItem(
// //                     icon: Icon(
// //                       Icons.home,
// //                     ),
// //                     label: 'Home',
// //                   ),
// //                   BottomNavigationBarItem(
// //                     icon: Icon(
// //                       Icons.car_crash,
// //                     ),
// //                     label: 'Pickup',
// //                   ),
// //                   BottomNavigationBarItem(
// //                     icon: Icon(
// //                       Icons.car_crash,
// //                     ),
// //                     label: 'Delivery',
// //                   ),
// //                   BottomNavigationBarItem(
// //                     icon: Icon(
// //                       Icons.compare_arrows,
// //                     ),
// //                     label: 'History',
// //                   ),
// //                   BottomNavigationBarItem(
// //                     icon: Icon(
// //                       Icons.person,
// //                     ),
// //                     label: 'Me',
// //                   ),
// //                 ],
// //                 selectedItemColor: Color(0xFF301C93),
// //                 selectedFontSize:
// //                     12.0, // Adjust the font size for the selected item
// //                 unselectedFontSize:
// //                     12.0, // Adjust the font size for unselected items
// //                 iconSize: 26.0, // Adjust the icon size
// //               ),
// //             );
// //           } else if (state is LoadingState) {
// //             // return Center(
// //             //   child: CircularProgressIndicator(),
// //             // );
// //             return _buildShimmerLoading();
// //           } else {
// //             return _buildShimmerLoading();
// //           }
// //         },
// //       ),
// //     );
// //   }
// //
// //   Widget _buildShimmerLoading() {
// //     return SafeArea(
// //       child: Scaffold(
// //         backgroundColor: Colors.white,
// //         body: SingleChildScrollView(
// //           child: Padding(
// //             padding: const EdgeInsets.all(10.0),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 SizedBox(height: 40),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Row(
// //                       children: [
// //                         SizedBox(width: 10),
// //                         Text(
// //                           'Taj Muhammed',
// //                           style: TextStyle(
// //                               fontSize: 24,
// //                               fontFamily: GoogleFonts.openSans().fontFamily,
// //                               fontWeight: FontWeight.normal,
// //                               color: Color(0xFF000000)),
// //                         ),
// //                       ],
// //                     ),
// //                     IconButton(
// //                       icon: Icon(Icons.notifications_outlined,
// //                           size: 50, color: Color(0xFF301C93)),
// //                       onPressed: () {
// //                         // Add your onPressed logic here
// //                       },
// //                     ),
// //                   ],
// //                 ),
// //                 // Image.asset(
// //                 //   logo,
// //                 //   height: 90,
// //                 //   width: 130,
// //                 // ),
// //
// //                 const SizedBox(height: 25),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Text(
// //                       'Collect now',
// //                       style: TextStyle(
// //                           fontSize: 24,
// //                           fontFamily: GoogleFonts.openSans().fontFamily,
// //                           fontWeight: FontWeight.bold,
// //                           color: Color(0xFF301C93)),
// //                     ),
// //                     TextButton.icon(
// //                       icon: Icon(Icons.arrow_back_outlined,
// //                           size: 25, color: Color(0xFF301C93)),
// //                       label: Text('Back',
// //                           style: TextStyle(
// //                             color: Color(0xFF301C93),
// //                             fontSize: 20,
// //                             fontFamily: GoogleFonts.openSans().fontFamily,
// //                           )),
// //                       onPressed: () {
// //                         // Add your onPressed logic here
// //                       },
// //                     ),
// //                   ],
// //                 ),
// //                 Shimmer.fromColors(
// //                   baseColor: Colors.grey[300]!,
// //                   highlightColor: Colors.grey[100]!,
// //                   direction: ShimmerDirection.ltr,
// //                   child: Column(
// //                     children: [
// //                       Card(
// //                         color: Colors.white,
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(15.0),
// //                           side: const BorderSide(
// //                             color: Colors.grey,
// //                             width: 0.5,
// //                           ),
// //                         ),
// //                         margin: const EdgeInsets.symmetric(vertical: 5),
// //                         child: Container(
// //                           height: MediaQuery.of(context).size.height / 3,
// //                           padding: const EdgeInsets.all(16),
// //                           child: Row(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               // Logo (30%)
// //                               Container(
// //                                 width: 480,
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                       ListView.builder(
// //                         shrinkWrap: true,
// //                         physics: const NeverScrollableScrollPhysics(),
// //                         itemCount: 5,
// //                         itemBuilder: (context, index) {
// //                           return Padding(
// //                             padding: const EdgeInsets.all(15.0),
// //                             child: Card(
// //                               color: Colors.white,
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(15.0),
// //                                 side: const BorderSide(
// //                                   color: Colors.grey,
// //                                   width: 0.5,
// //                                 ),
// //                               ),
// //                               margin: const EdgeInsets.symmetric(vertical: 5),
// //                               child: Container(
// //                                 height: MediaQuery.of(context).size.height / 8,
// //                                 padding: const EdgeInsets.all(16),
// //                                 child: Row(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     // Logo (30%)
// //                                     Container(
// //                                       width: 90,
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Future<Map<String, dynamic>> fetchClothDetails(String clothname) async {
// //     final String apiUrl =
// //         'https://be.syswash.net/api/syswash/clothdetails?code=A';
// //
// //     final response = await http.get(Uri.parse(apiUrl), headers: {
// //       "Accept": "application/json",
// //       "Authorization": "Bearer $userToken"
// //     });
// //
// //     if (response.statusCode == 200) {
// //       final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
// //       if (data.isNotEmpty) {
// //         for (var clothData in data) {
// //           if (clothData['data']['clothName'] == clothname) {
// //             return {
// //               'clothNameArabic': clothData['data']['clothNameArabic'],
// //               'clothImg': clothData['data']['clothImg']
// //             };
// //           }
// //         }
// //
// //         throw Exception('No data available for the provided cloth name.');
// //       } else {
// //         throw Exception('No data available from the server.');
// //       }
// //     } else {
// //       throw Exception('Failed to load cloth details');
// //     }
// //   }
// //
// //   Future<int> getPriceId(
// //     String selectedService,
// //     String selectedCloth,
// //   ) async {
// //     final String apiUrl =
// //         'https://be.syswash.net/api/syswash/pricedetails?code=A';
// //
// //     final response = await http.get(Uri.parse(apiUrl), headers: {
// //       "Accept": "application/json",
// //       "Authorization": "Bearer $userToken"
// //     });
// //
// //     if (response.statusCode == 200) {
// //       final List<dynamic> data = json.decode(response.body);
// //
// //       //   print(data);
// //       final Map<String, dynamic> serviceData = data.firstWhere(
// //         (element) =>
// //             element['serviceName'] == selectedService &&
// //             element['clothType'] == selectedCloth,
// //         orElse: () => null,
// //       );
// //
// //       if (serviceData != null) {
// //         // Assuming quantity selection influences which priceId to select
// //         return serviceData['priceId'];
// //       } else {
// //         throw Exception('Service or cloth type not found.');
// //       }
// //     } else {
// //       throw Exception('Failed to load data');
// //     }
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
// //
// //   Future<void> postData() async {
// //     var pickupassgnIdNum = int.tryParse(pickupassgnId);
// //
// //     // Convert 'qnty' strings to integers, keeping other fields unchanged
// //     List<Map<String, dynamic>> convertedClothData = clothdate.map((item) {
// //       var qntyInt = int.tryParse(item['qnty'] ?? '0') ?? 0;
// //       return {
// //         ...item,
// //         'qnty': qntyInt,
// //       };
// //     }).toList();
// //
// //     var response = await http.Client().post(
// //       Uri.parse('https://be.syswash.net/api/syswash/pickuporder?code=A'),
// //       headers: {
// //         "Content-Type": "application/json",
// //         "Accept": "application/json",
// //         "Authorization": "Bearer $userToken"
// //       },
// //       body: jsonEncode({
// //         "pickupassgn_id": pickupassgnIdNum,
// //         "pickuporderTime": formatedtime,
// //         "quantity": totalQty,
// //         "subTotal": 0.0,
// //         "discount": 0.0,
// //         "totalAmount": 0.0,
// //         "paidAmount": 0.0,
// //         "balance": 0.0,
// //         "deliveryType": "PICKUP & DELIVERY",
// //         "accountType": "MobileApp",
// //         "clothData": convertedClothData, // Use the converted cloth data
// //       }),
// //     );
// //
// //     if (response.statusCode == 200) {
// //       setState(() {});
// //     } else {
// //       // If request failed, handle the error
// //       print('Failed to post data: ${response.statusCode}');
// //     }
// //   }
// // }
// //
// // // import 'dart:convert';
// // //
// // // import 'package:flutter/cupertino.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_bloc/flutter_bloc.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:shimmer/shimmer.dart';
// // // import 'package:syswash/service/api_service.dart';
// // // import 'package:http/http.dart' as http;
// // // import '../../../../utils/app_constant.dart';
// // // import '../../../../utils/app_sp.dart';
// // // import '../../../../utils/app_url.dart';
// // // import 'bloc/customer_details_bloc.dart';
// // //
// // // class CustomerDetailsOrder extends StatefulWidget {
// // //   final String? pickupassgnId;
// // //
// // //   const CustomerDetailsOrder({Key? key, this.pickupassgnId}) : super(key: key);
// // //
// // //   @override
// // //   State<CustomerDetailsOrder> createState() => _CustomerDetailsOrderState();
// // // }
// // //
// // // class _CustomerDetailsOrderState extends State<CustomerDetailsOrder> {
// // //   int _currentIndex = 1;
// // //   late CustomerDetailsBloc _customerDetailsBloc;
// // //   String tokenID = '';
// // //   String userToken = "";
// // //   String companyCode = "";
// // //   String userID = "";
// // //
// // //   String pickupassgnId = '';
// // //   String selectedService = "";
// // //   List<String?> serviceNames = [];
// // //   List<String?> serviceCodes = [];
// // //
// // //   List<String> clothNames = [];
// // //   String? selectedCloth;
// // //   String selectedServiceCode = "";
// // //
// // //   String quantity = "1";
// // //
// // //   String selectedBilling = "Express";
// // //   List<String> billingOptions = ['Express', 'Normal', 'Faster'];
// // //
// // //   int PRICEID = 0;
// // //
// // //   String ClothNameArabic = "";
// // //
// // //   String ClothImage = "";
// // //
// // //   List<Map<String, dynamic>> clothdate = [];
// // //   List<Map<String, dynamic>> clothdata_order = [];
// // //   int totalQty = 0;
// // //   int totalQty1 = 0;
// // //   int totalQty2 = 0;
// // //   int itemCount = 0;
// // //
// // //   String formatedtime = "";
// // //
// // //   void saveDataToClothDate(Map<String, dynamic> clothData) {
// // //     setState(() {
// // //       clothdate.add(clothData);
// // //       updateCounts();
// // //     });
// // //   }
// // //
// // //   void removeDataFromClothDate(int index) {
// // //     setState(() {
// // //       clothdate.removeAt(index);
// // //       updateCounts(); // Recalculate counts after removing an item
// // //     });
// // //   }
// // //
// // //   void updateCounts() {
// // //     itemCount = clothdate.length + clothdata_order.length;
// // //     totalQty1 = 0;
// // //     for (var cloth in clothdate) {
// // //       totalQty1 += int.parse(cloth['qnty']);
// // //     }
// // //     totalQty2 = 0;
// // //     for (var cloth in clothdata_order) {
// // //       totalQty2 += int.parse(cloth['qnty'].toString());
// // //     }
// // //     totalQty = totalQty1 + totalQty2;
// // //   }
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     pickupassgnId = widget.pickupassgnId ?? '';
// // //     _customerDetailsBloc = CustomerDetailsBloc(ApiService());
// // //     getUserToken();
// // //     var currentTime = DateTime.now();
// // //     formatedtime =
// // //         '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';
// // //   }
// // //
// // //   Future<void> getUserToken() async {
// // //     AppSp appSp = AppSp();
// // //     userToken = await appSp.getToken();
// // //     companyCode = await appSp.getCompanyCode();
// // //     fetchServiceDetailsData(userToken, companyCode);
// // //     fetchClouthDetailsData(userToken, companyCode);
// // //
// // //     _customerDetailsBloc
// // //         .add(CustomerDetailsApiEvent(userToken, companyCode, pickupassgnId));
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _customerDetailsBloc.close();
// // //     super.dispose();
// // //   }
// // //
// // //   void fetchClouthDetailsData(String userToken, String companyCode) async {
// // //     final response = await http.get(
// // //         Uri.parse('${AppUrls.clothdetails}${AppUrls.code_main}$companyCode'),
// // //         headers: {
// // //           "Accept": "application/json",
// // //           "Authorization": "Bearer $userToken"
// // //         });
// // //     if (response.statusCode == 200) {
// // //       List<Map<String, dynamic>> clothDataList =
// // //           List<Map<String, dynamic>>.from(json.decode(response.body));
// // //       setState(() {
// // //         clothNames = clothDataList
// // //             .map((clothData) => clothData['data']['clothName'] as String)
// // //             .toList();
// // //       });
// // //     } else {
// // //       print("Failed to fetch data: ${response.statusCode}");
// // //     }
// // //   }
// // //
// // //   void fetchServiceDetailsData(String userToken, String companyCode) async {
// // //     final response = await http.get(
// // //         Uri.parse('${AppUrls.servicedetails}${AppUrls.code_main}$companyCode'),
// // //         headers: {
// // //           "Accept": "application/json",
// // //           "Authorization": "Bearer $userToken"
// // //         });
// // //     if (response.statusCode == 200) {
// // //       List<dynamic> responseData = json.decode(response.body);
// // //       List<Map<String, String>> services = responseData.map((data) {
// // //         return {
// // //           'serviceName': data['serviceName'] as String,
// // //           'serviceCode': data['serviceCode'] as String,
// // //         };
// // //       }).toList();
// // //       setState(() {
// // //         serviceNames =
// // //             services.map((service) => service['serviceName']).toList();
// // //         serviceCodes =
// // //             services.map((service) => service['serviceCode']).toList();
// // //
// // //         if (serviceNames.isNotEmpty) {
// // //           selectedService = serviceNames[0]!;
// // //         }
// // //       });
// // //     } else {
// // //       print("Failed to fetch data: ${response.statusCode}");
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return BlocProvider(
// // //       create: (context) => _customerDetailsBloc,
// // //       child: BlocConsumer<CustomerDetailsBloc, CustomerDetailsState>(
// // //         listener: (context, state) {
// // //           if (state is LoadedState) {
// // //             print("Category List Response: ${state.response}");
// // //           } else if (state is ErrorState) {
// // //             // Handle error state
// // //           } else if (state is UnAuthorizedState) {
// // //             // Handle unauthorized state
// // //           } else if (state is NoInternetState) {
// // //             // Handle no internet state
// // //           }
// // //         },
// // //         builder: (context, state) {
// // //           if (state is LoadingState) {
// // //             return Center(
// // //               child: CircularProgressIndicator(),
// // //             );
// // //             // return _buildShimmerLoading();
// // //           } else if (state is LoadedState) {
// // //             var pickupassgn = state.response.pickupassgn;
// // //             if (pickupassgn != null && pickupassgn is List) {
// // //               clothdata_order.clear();
// // //               for (var item in pickupassgn) {
// // //                 var clothData = item.clothData;
// // //                 if (clothData != null && clothData is List) {
// // //                   for (var clothItem in clothData) {
// // //                     Map<String, dynamic> clothDataMap = {
// // //                       "priceId": clothItem.priceId,
// // //                       "clothName": clothItem.clothName,
// // //                       "arabicName":
// // //                           utf8.decode(clothItem.arabicName!.runes.toList()),
// // //                       "clothImg": clothItem.clothImg,
// // //                       "qnty": clothItem.qnty,
// // //                       "service": clothItem.service,
// // //                       "billing": clothItem.billing
// // //                     };
// // //                     clothdata_order.add(clothDataMap);
// // //                   }
// // //                 } else {
// // //                   print('clothData is null or not an array');
// // //                 }
// // //               }
// // //             } else {
// // //               print('pickupassgn is null or not an array');
// // //             }
// // //
// // //             updateCounts();
// // //
// // //             return Scaffold(
// // //               backgroundColor: Color(0xFFEFEEF3),
// // //               body: SingleChildScrollView(
// // //                 // Wrap the entire page with SingleChildScrollView
// // //                 child: Padding(
// // //                   padding: const EdgeInsets.all(30),
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       SizedBox(height: 30),
// // //                       Row(
// // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                         children: [
// // //                           Row(
// // //                             children: [
// // //                               // CircleAvatar(
// // //                               //   backgroundImage:
// // //                               //       AssetImage('assets/profile_image.jpg'),
// // //                               //   radius: 30,
// // //                               // ),
// // //                               SizedBox(width: 10),
// // //                               // Adjust spacing between circle and text
// // //                               Text(
// // //                                 'Taj Muhammed',
// // //                                 style: TextStyle(
// // //                                   fontSize: 24,
// // //                                   fontWeight: FontWeight.normal,
// // //                                   fontFamily: GoogleFonts.openSans().fontFamily,
// // //                                   color: Color(0xFF000000),
// // //                                 ),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                           IconButton(
// // //                             icon: Icon(Icons.notifications_outlined,
// // //                                 size: 50, color: Color(0xFF301C93)),
// // //                             onPressed: () {
// // //                               // Add your onPressed logic here
// // //                             },
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       SizedBox(height: 10),
// // //                       Row(
// // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                         children: [
// // //                           Text(
// // //                             'Collect now',
// // //                             style: TextStyle(
// // //                               fontSize: 24,
// // //                               fontFamily: GoogleFonts.openSans().fontFamily,
// // //                               fontWeight: FontWeight.bold,
// // //                               color: Color(0xFF301C93),
// // //                             ),
// // //                           ),
// // //                           TextButton.icon(
// // //                             icon: Icon(Icons.arrow_back_outlined,
// // //                                 size: 25, color: Color(0xFF301C93)),
// // //                             label: Text('Back',
// // //                                 style: TextStyle(
// // //                                   color: Color(0xFF301C93),
// // //                                   fontSize: 20,
// // //                                   fontFamily: GoogleFonts.openSans().fontFamily,
// // //                                 )),
// // //                             onPressed: () {
// // //                               Navigator.pushNamed(
// // //                                   context, "/pickupOrderListing");
// // //                               // Add your onPressed logic here
// // //                             },
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       dividerLH(),
// // //                       Card(
// // //                         child: Column(
// // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // //                           children: [
// // //                             Row(
// // //                               children: [
// // //                                 Padding(
// // //                                   padding: EdgeInsets.all(20),
// // //                                   // child: CircleAvatar(
// // //                                   //   radius: 30,
// // //                                   //   backgroundImage:
// // //                                   //       AssetImage('assets/avatar.png'),
// // //                                   // ),
// // //
// // //                                   child: Column(
// // //                                     crossAxisAlignment:
// // //                                         CrossAxisAlignment.start,
// // //                                     children: [
// // //                                       Text(
// // //                                         '${state.response.pickupCustomerName}',
// // //                                         style: TextStyle(
// // //                                           fontWeight: FontWeight.bold,
// // //                                           fontFamily:
// // //                                               GoogleFonts.openSans().fontFamily,
// // //                                           fontSize: 16.0,
// // //                                         ),
// // //                                       ),
// // //                                       SizedBox(height: 5.0),
// // //                                       Text(
// // //                                         '${state.response.pickupCustomerPhno}',
// // //                                         style: TextStyle(
// // //                                           fontSize: 14.0,
// // //                                         ),
// // //                                       ),
// // //                                       SizedBox(height: 5.0),
// // //                                       Row(
// // //                                         children: [
// // //                                           Icon(Icons.location_on, size: 16.0),
// // //                                           SizedBox(width: 5.0),
// // //                                           Text(
// // //                                             '${state.response.pickupCustomerArea}',
// // //                                             style: TextStyle(
// // //                                               fontSize: 14.0,
// // //                                               fontFamily: GoogleFonts.openSans()
// // //                                                   .fontFamily,
// // //                                             ),
// // //                                           ),
// // //                                         ],
// // //                                       ),
// // //                                     ],
// // //                                   ),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                             Padding(
// // //                               padding: const EdgeInsets.all(20),
// // //                               child: Column(
// // //                                 children: [
// // //                                   Row(
// // //                                     crossAxisAlignment:
// // //                                         CrossAxisAlignment.start,
// // //                                     children: [
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'Created at',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.grey,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               '12-4-2033',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'Pickup',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.grey,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               '12-45-2039',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                     ],
// // //                                   ),
// // //                                   SizedBox(height: 15),
// // //                                   Row(
// // //                                     crossAxisAlignment:
// // //                                         CrossAxisAlignment.start,
// // //                                     children: [
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'Drop off',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 color: Colors.grey,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               '12-4-2033',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'Status',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 color: Colors.grey,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               '${state.response.pickupstatus}',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                     ],
// // //                                   ),
// // //                                   SizedBox(height: 15),
// // //                                   Row(
// // //                                     crossAxisAlignment:
// // //                                         CrossAxisAlignment.start,
// // //                                     children: [
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'Street',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.grey,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               'Akhilnrd',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'Postal Code',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.grey,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               '345673',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                     ],
// // //                                   ),
// // //                                   SizedBox(height: 15),
// // //                                   Row(
// // //                                     crossAxisAlignment:
// // //                                         CrossAxisAlignment.start,
// // //                                     children: [
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'House Number',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.grey,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               '323',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'Town',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.grey,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               'Quater',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                     ],
// // //                                   ),
// // //                                   SizedBox(height: 15),
// // //                                   Row(
// // //                                     crossAxisAlignment:
// // //                                         CrossAxisAlignment.start,
// // //                                     children: [
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'Bill Amount',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.grey,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               '34',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                     ],
// // //                                   ),
// // //                                   SizedBox(height: 15)
// // //                                 ],
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                       SizedBox(height: 15),
// // //                       Row(
// // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                         children: [
// // //                           Text(
// // //                             'Order Items',
// // //                             style: TextStyle(
// // //                               fontSize: 30,
// // //                               fontFamily: GoogleFonts.openSans().fontFamily,
// // //                               fontWeight: FontWeight.bold,
// // //                               color: Color(0xFF301C93),
// // //                             ),
// // //                           ),
// // //                           ElevatedButton(
// // //                             onPressed: () {
// // //                               showDialog(
// // //                                 context: context,
// // //                                 builder: (BuildContext context) {
// // //                                   return AlertDialog(
// // //                                     backgroundColor: Color(0xFFEFEEF3),
// // //                                     shape: RoundedRectangleBorder(
// // //                                       borderRadius: BorderRadius.circular(15.0),
// // //                                     ),
// // //                                     content: StatefulBuilder(
// // //                                       builder: (BuildContext context,
// // //                                           StateSetter setState) {
// // //                                         return Container(
// // //                                           width: 400,
// // //                                           height: 550,
// // //                                           child: SingleChildScrollView(
// // //                                             child: Padding(
// // //                                               padding:
// // //                                                   const EdgeInsets.all(30.0),
// // //                                               child: Column(
// // //                                                 mainAxisAlignment:
// // //                                                     MainAxisAlignment.center,
// // //                                                 crossAxisAlignment:
// // //                                                     CrossAxisAlignment.start,
// // //                                                 children: [
// // //                                                   Text(
// // //                                                     'Add Items',
// // //                                                     style: TextStyle(
// // //                                                       fontWeight:
// // //                                                           FontWeight.bold,
// // //                                                       color: Color(0xFF301C93),
// // //                                                       fontFamily:
// // //                                                           GoogleFonts.openSans()
// // //                                                               .fontFamily,
// // //                                                       fontSize: 23.0,
// // //                                                     ),
// // //                                                   ),
// // //                                                   SizedBox(height: 20),
// // //                                                   Column(
// // //                                                     crossAxisAlignment:
// // //                                                         CrossAxisAlignment
// // //                                                             .start,
// // //                                                     children: [
// // //                                                       Text(
// // //                                                         'Select Service:',
// // //                                                         style: TextStyle(
// // //                                                           fontWeight:
// // //                                                               FontWeight.bold,
// // //                                                           fontFamily: GoogleFonts
// // //                                                                   .openSans()
// // //                                                               .fontFamily,
// // //                                                         ),
// // //                                                       ),
// // //                                                       SizedBox(height: 5),
// // //                                                       Container(
// // //                                                         padding: EdgeInsets
// // //                                                             .symmetric(
// // //                                                                 horizontal:
// // //                                                                     12.0),
// // //                                                         decoration:
// // //                                                             BoxDecoration(
// // //                                                           color:
// // //                                                               Color(0xFFF9F9F9),
// // //                                                           borderRadius:
// // //                                                               BorderRadius
// // //                                                                   .circular(
// // //                                                                       10.0),
// // //                                                         ),
// // //                                                         child: DropdownButton<
// // //                                                             String?>(
// // //                                                           isExpanded: true,
// // //                                                           onChanged: (String?
// // //                                                               newValue) {
// // //                                                             if (newValue !=
// // //                                                                 null) {
// // //                                                               setState(() {
// // //                                                                 selectedService =
// // //                                                                     newValue;
// // //                                                                 selectedServiceCode =
// // //                                                                     serviceCodes[
// // //                                                                         serviceNames
// // //                                                                             .indexOf(newValue)]!;
// // //                                                                 // print("Selected service: $selectedService, Code: $selectedServiceCode");
// // //                                                               });
// // //                                                             }
// // //                                                           },
// // //                                                           value:
// // //                                                               selectedService,
// // //                                                           items: serviceNames.map<
// // //                                                                   DropdownMenuItem<
// // //                                                                       String?>>(
// // //                                                               (String? value) {
// // //                                                             return DropdownMenuItem<
// // //                                                                 String?>(
// // //                                                               value: value,
// // //                                                               child: Text(
// // //                                                                   value ?? ""),
// // //                                                             );
// // //                                                           }).toList(),
// // //                                                         ),
// // //                                                       ),
// // //                                                     ],
// // //                                                   ),
// // //                                                   SizedBox(height: 20),
// // //                                                   Column(
// // //                                                     crossAxisAlignment:
// // //                                                         CrossAxisAlignment
// // //                                                             .start,
// // //                                                     children: [
// // //                                                       Text(
// // //                                                         'Cloth Type:',
// // //                                                         style: TextStyle(
// // //                                                           fontWeight:
// // //                                                               FontWeight.bold,
// // //                                                           fontFamily: GoogleFonts
// // //                                                                   .openSans()
// // //                                                               .fontFamily,
// // //                                                         ),
// // //                                                       ),
// // //                                                       SizedBox(height: 5),
// // //                                                       Container(
// // //                                                         padding: EdgeInsets
// // //                                                             .symmetric(
// // //                                                                 horizontal:
// // //                                                                     12.0),
// // //                                                         decoration:
// // //                                                             BoxDecoration(
// // //                                                           color:
// // //                                                               Color(0xFFF9F9F9),
// // //                                                           borderRadius:
// // //                                                               BorderRadius
// // //                                                                   .circular(
// // //                                                                       10.0),
// // //                                                         ),
// // //                                                         child: DropdownButton<
// // //                                                             String>(
// // //                                                           isExpanded: true,
// // //                                                           value: selectedCloth,
// // //                                                           onChanged: (String?
// // //                                                               newValue) {
// // //                                                             setState(() {
// // //                                                               selectedCloth =
// // //                                                                   newValue;
// // //                                                             });
// // //                                                           },
// // //                                                           items: clothNames.map(
// // //                                                               (String value) {
// // //                                                             return DropdownMenuItem<
// // //                                                                 String>(
// // //                                                               value: value,
// // //                                                               child:
// // //                                                                   Text(value),
// // //                                                             );
// // //                                                           }).toList(),
// // //                                                           hint: Text(
// // //                                                               'Select a cloth type'),
// // //                                                         ),
// // //                                                       ),
// // //                                                     ],
// // //                                                   ),
// // //                                                   dividerH(),
// // //                                                   Column(
// // //                                                     crossAxisAlignment:
// // //                                                         CrossAxisAlignment
// // //                                                             .start,
// // //                                                     children: [
// // //                                                       Text(
// // //                                                         'QTY:',
// // //                                                         style: TextStyle(
// // //                                                           fontWeight:
// // //                                                               FontWeight.bold,
// // //                                                         ),
// // //                                                       ),
// // //                                                       SizedBox(height: 5),
// // //                                                       TextField(
// // //                                                         controller:
// // //                                                             TextEditingController(
// // //                                                                 text: quantity),
// // //                                                         onChanged: (value) {
// // //                                                           quantity = value;
// // //                                                         },
// // //                                                         decoration:
// // //                                                             InputDecoration(
// // //                                                           filled: true,
// // //                                                           fillColor:
// // //                                                               Color(0xFFF9F9F9),
// // //                                                           border:
// // //                                                               OutlineInputBorder(
// // //                                                             borderRadius:
// // //                                                                 BorderRadius
// // //                                                                     .circular(
// // //                                                                         10.0),
// // //                                                           ),
// // //                                                           hintText:
// // //                                                               'Enter a quantity',
// // //                                                           contentPadding:
// // //                                                               EdgeInsets
// // //                                                                   .symmetric(
// // //                                                                       horizontal:
// // //                                                                           12.0),
// // //                                                         ),
// // //                                                       ),
// // //                                                     ],
// // //                                                   ),
// // //                                                   dividerH(),
// // //                                                   Column(
// // //                                                     crossAxisAlignment:
// // //                                                         CrossAxisAlignment
// // //                                                             .start,
// // //                                                     children: [
// // //                                                       Text(
// // //                                                         'Billing:',
// // //                                                         style: TextStyle(
// // //                                                           fontWeight:
// // //                                                               FontWeight.bold,
// // //                                                           fontFamily: GoogleFonts
// // //                                                                   .openSans()
// // //                                                               .fontFamily,
// // //                                                         ),
// // //                                                       ),
// // //                                                       SizedBox(height: 5),
// // //                                                       Container(
// // //                                                         padding: EdgeInsets
// // //                                                             .symmetric(
// // //                                                                 horizontal:
// // //                                                                     12.0),
// // //                                                         decoration:
// // //                                                             BoxDecoration(
// // //                                                           color:
// // //                                                               Color(0xFFF9F9F9),
// // //                                                           borderRadius:
// // //                                                               BorderRadius
// // //                                                                   .circular(
// // //                                                                       10.0),
// // //                                                         ),
// // //                                                         child: DropdownButton<
// // //                                                             String>(
// // //                                                           isExpanded: true,
// // //                                                           value:
// // //                                                               selectedBilling,
// // //                                                           onChanged: (String?
// // //                                                               newValue) {
// // //                                                             setState(() {
// // //                                                               selectedBilling =
// // //                                                                   newValue!;
// // //                                                             });
// // //                                                           },
// // //                                                           items: billingOptions
// // //                                                               .map((String
// // //                                                                   value) {
// // //                                                             return DropdownMenuItem<
// // //                                                                 String>(
// // //                                                               value: value,
// // //                                                               child:
// // //                                                                   Text(value),
// // //                                                             );
// // //                                                           }).toList(),
// // //                                                           hint: Text(
// // //                                                               'Select a billing type'),
// // //                                                         ),
// // //                                                       ),
// // //                                                     ],
// // //                                                   ),
// // //                                                   dividerH(),
// // //                                                   Container(
// // //                                                     padding:
// // //                                                         const EdgeInsets.all(5),
// // //                                                     width: double.infinity,
// // //                                                     // Full width
// // //                                                     decoration: BoxDecoration(
// // //                                                       borderRadius:
// // //                                                           BorderRadius.circular(
// // //                                                               10.0),
// // //                                                       color: Color(0xFF301C93),
// // //                                                     ),
// // //                                                     child: TextButton(
// // //                                                       onPressed: () async {
// // //                                                         // if (state.response.pickupOrderId == null) {
// // //                                                         // print("Selected service: $selectedService");
// // //                                                         // print("Selected cloth: $selectedCloth");
// // //                                                         // print("Quantity: $quantity");
// // //
// // //                                                         // Define an async function to fetch the priceId
// // //                                                         Future<void>
// // //                                                             fetchPriceId() async {
// // //                                                           try {
// // //                                                             int priceId =
// // //                                                                 await getPriceId(
// // //                                                                     '$selectedService',
// // //                                                                     '$selectedCloth');
// // //                                                             setState(() {
// // //                                                               PRICEID = priceId;
// // //                                                             });
// // //                                                           } catch (e) {
// // //                                                             print('Error: $e');
// // //                                                           }
// // //                                                         }
// // //
// // //                                                         await fetchPriceId();
// // //
// // //                                                         try {
// // //                                                           Map<String, dynamic>
// // //                                                               clothDetails =
// // //                                                               await fetchClothDetails(
// // //                                                                   '$selectedCloth');
// // //                                                           String
// // //                                                               clothNameArabic =
// // //                                                               clothDetails[
// // //                                                                   'clothNameArabic'];
// // //                                                           String clothImg =
// // //                                                               clothDetails[
// // //                                                                   'clothImg'];
// // //                                                           setState(() {
// // //                                                             ClothNameArabic =
// // //                                                                 clothNameArabic;
// // //                                                             ClothImage =
// // //                                                                 clothImg;
// // //                                                           });
// // //                                                         } catch (e) {
// // //                                                           print(
// // //                                                               'Error fetching cloth details: $e');
// // //                                                         }
// // //
// // //                                                         //print('{"priceId": $PRICEID,"clothName": $selectedCloth,"arabicName": $ClothNameArabic,"clothImg": $ClothImage,"qnty": $quantity,"service": $selectedServiceCode,"billing": $selectedBilling }');
// // //
// // //                                                         // Print the data to be added to clothdate list
// // //                                                         Map<String, dynamic>
// // //                                                             clothData = {
// // //                                                           "priceId": PRICEID,
// // //                                                           "clothName":
// // //                                                               selectedCloth,
// // //                                                           "arabicName":
// // //                                                               ClothNameArabic,
// // //                                                           "clothImg":
// // //                                                               ClothImage,
// // //                                                           "qnty": quantity,
// // //                                                           "service":
// // //                                                               selectedServiceCode,
// // //                                                           "billing":
// // //                                                               selectedBilling
// // //                                                         };
// // //                                                         print(clothData);
// // //
// // //                                                         // Save data to clothdate list
// // //                                                         saveDataToClothDate(
// // //                                                             clothData);
// // //
// // //                                                         // Print a separator for readability
// // //                                                         print(
// // //                                                             '-------------------');
// // //                                                         print(
// // //                                                             clothdate); // Print the clothdate list
// // //                                                         print(
// // //                                                             '-------------------');
// // //
// // //                                                         // setState(() {
// // //                                                         //   selectedService = "";
// // //                                                         //
// // //                                                         //   quantity = "";
// // //                                                         //   selectedBilling = "Express";
// // //                                                         // });
// // //                                                         Navigator.of(context)
// // //                                                             .pop();
// // //                                                       },
// // //
// // //                                                       // },
// // //
// // //                                                       child: Text(
// // //                                                         'Submit',
// // //                                                         style: TextStyle(
// // //                                                           color: Colors.white,
// // //                                                           fontFamily: GoogleFonts
// // //                                                                   .openSans()
// // //                                                               .fontFamily,
// // //                                                         ),
// // //                                                       ),
// // //                                                     ),
// // //                                                   ),
// // //                                                 ],
// // //                                               ),
// // //                                             ),
// // //                                           ),
// // //                                         );
// // //                                       },
// // //                                     ),
// // //                                   );
// // //                                 },
// // //                               );
// // //                             },
// // //                             style: TextButton.styleFrom(
// // //                               backgroundColor:
// // //                                   Color(0xFF301C93), // Button background color
// // //                               padding: EdgeInsets.symmetric(
// // //                                   vertical: 10, horizontal: 20),
// // //                               shape: RoundedRectangleBorder(
// // //                                 borderRadius: BorderRadius.circular(
// // //                                     15), // Button border radius
// // //                               ),
// // //                             ),
// // //                             child: Text(
// // //                               'ADD ITEMS',
// // //                               style: TextStyle(
// // //                                 fontSize: 15,
// // //                                 fontFamily: GoogleFonts.openSans().fontFamily,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 color: Colors.white,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //
// // //                       ListView.builder(
// // //                         shrinkWrap: true,
// // //                         itemCount: clothdate.length,
// // //                         itemBuilder: (context, index) {
// // //                           var clothData = clothdate[index];
// // //                           return Padding(
// // //                             padding: EdgeInsets.symmetric(
// // //                                 vertical: 5.0, horizontal: 10.0),
// // //                             child: Card(
// // //                               child: ListTile(
// // //                                 leading: Image.network(
// // //                                   clothData['clothImg'],
// // //                                   fit: BoxFit.cover,
// // //                                   errorBuilder: (context, error, stackTrace) {
// // //                                     return Container(
// // //                                       width: 50,
// // //                                       height: 50,
// // //                                       color: Colors.grey,
// // //                                       child: Icon(
// // //                                         Icons.error,
// // //                                         color: Colors.red,
// // //                                       ),
// // //                                     );
// // //                                   },
// // //                                 ),
// // //                                 title: Text(
// // //                                   clothData['clothName'],
// // //                                   style: TextStyle(
// // //                                     fontFamily:
// // //                                         GoogleFonts.openSans().fontFamily,
// // //                                   ),
// // //                                 ),
// // //                                 subtitle: Text(
// // //                                   clothData['arabicName'],
// // //                                   style: TextStyle(
// // //                                     fontFamily:
// // //                                         GoogleFonts.openSans().fontFamily,
// // //                                   ),
// // //                                 ),
// // //                                 trailing: IconButton(
// // //                                   icon: Icon(Icons.delete),
// // //                                   onPressed: () {
// // //                                     removeDataFromClothDate(index);
// // //                                   },
// // //                                 ),
// // //                               ),
// // //                             ),
// // //                           );
// // //                         },
// // //                       ),
// // //                       ListView.builder(
// // //                         shrinkWrap: true,
// // //                         itemCount: clothdata_order.length,
// // //                         itemBuilder: (context, index) {
// // //                           var clothdata_orders = clothdata_order[index];
// // //                           return Padding(
// // //                             padding: EdgeInsets.symmetric(
// // //                                 vertical: 5.0, horizontal: 10.0),
// // //                             child: Card(
// // //                               child: ListTile(
// // //                                 leading: Image.network(
// // //                                   clothdata_orders['clothImg'],
// // //                                   fit: BoxFit.cover,
// // //                                   errorBuilder: (context, error, stackTrace) {
// // //                                     return Container(
// // //                                       width: 50,
// // //                                       height: 50,
// // //                                       color: Colors.grey,
// // //                                       child: Icon(
// // //                                         Icons.error,
// // //                                         color: Colors.red,
// // //                                       ),
// // //                                     );
// // //                                   },
// // //                                 ),
// // //                                 title: Text(
// // //                                   clothdata_orders['clothName'],
// // //                                   style: TextStyle(
// // //                                     fontFamily:
// // //                                         GoogleFonts.openSans().fontFamily,
// // //                                   ),
// // //                                 ),
// // //                                 subtitle: Text(
// // //                                   clothdata_orders['arabicName'],
// // //                                   style: TextStyle(
// // //                                     fontFamily:
// // //                                         GoogleFonts.openSans().fontFamily,
// // //                                   ),
// // //                                 ),
// // //                                 // trailing: IconButton(
// // //                                 //   icon: Icon(Icons.delete),
// // //                                 //   onPressed: () {
// // //                                 //     removeDataFromClothDate(index);
// // //                                 //
// // //                                 //   },
// // //                                 // ),
// // //                               ),
// // //                             ),
// // //                           );
// // //                         },
// // //                       ),
// // //
// // //                       // ListView.builder(
// // //                       //   shrinkWrap: true,
// // //                       //   // Important to add
// // //                       //   physics: NeverScrollableScrollPhysics(),
// // //                       //   // Prevent inner ListView from scrolling
// // //                       //   itemCount: 5,
// // //                       //   // Change this according to your data
// // //                       //   itemBuilder: (context, index) {
// // //                       //     return Padding(
// // //                       //       padding: EdgeInsets.symmetric(
// // //                       //           vertical: 5.0, horizontal: 10.0),
// // //                       //       child: Card(
// // //                       //         child: ListTile(
// // //                       //           // leading: SizedBox(
// // //                       //           //   width: 80,
// // //                       //           //   child: Image.network(
// // //                       //           //     'https://via.placeholder.com/150',
// // //                       //           //     // Replace with your image URL
// // //                       //           //     fit: BoxFit.cover,
// // //                       //           //   ),
// // //                       //           // ),
// // //                       //           title: Text(
// // //                       //             'Heading $index',
// // //                       //             style: TextStyle(
// // //                       //               fontFamily:
// // //                       //                   GoogleFonts.openSans().fontFamily,
// // //                       //             ),
// // //                       //           ),
// // //                       //           subtitle: Text(
// // //                       //             'Subheading $index',
// // //                       //             style: TextStyle(
// // //                       //               fontFamily:
// // //                       //                   GoogleFonts.openSans().fontFamily,
// // //                       //             ),
// // //                       //           ),
// // //                       //         ),
// // //                       //       ),
// // //                       //     );
// // //                       //   },
// // //                       // ),
// // //
// // //                       SizedBox(height: 15),
// // //                       // Small card at the bottom
// // //                       Card(
// // //                         child: Padding(
// // //                           padding: const EdgeInsets.all(15.0),
// // //                           child: Row(
// // //                             children: [
// // //                               ElevatedButton(
// // //                                 onPressed: () {},
// // //                                 style: ElevatedButton.styleFrom(
// // //                                   padding: const EdgeInsets.all(16.0),
// // //                                   primary: Color(0xFF301C93),
// // //                                   // Background color
// // //                                   onPrimary: Colors.white,
// // //                                   // Text color
// // //                                   shape: RoundedRectangleBorder(
// // //                                     borderRadius: BorderRadius.circular(
// // //                                         10), // Border radius
// // //                                   ),
// // //                                 ),
// // //                                 child: Text(
// // //                                   'Collect now',
// // //                                   style: TextStyle(
// // //                                     fontFamily:
// // //                                         GoogleFonts.openSans().fontFamily,
// // //                                   ),
// // //                                 ),
// // //                               ),
// // //                               SizedBox(width: 10),
// // //                               Expanded(
// // //                                 child: Row(
// // //                                   mainAxisAlignment: MainAxisAlignment.center,
// // //                                   children: [
// // //                                     Text(
// // //                                       'ITEMS : $itemCount',
// // //                                       style: TextStyle(
// // //                                         fontSize: 20,
// // //                                         fontFamily:
// // //                                             GoogleFonts.openSans().fontFamily,
// // //                                         fontWeight: FontWeight.bold,
// // //                                         color: Color(0xFF301C93),
// // //                                       ),
// // //                                     ),
// // //                                     SizedBox(width: 30),
// // //                                     Text(
// // //                                       'QTY : $totalQty',
// // //                                       style: TextStyle(
// // //                                         fontSize: 20,
// // //                                         fontFamily:
// // //                                             GoogleFonts.openSans().fontFamily,
// // //                                         fontWeight: FontWeight.bold,
// // //                                         color: Color(0xFF301C93),
// // //                                       ),
// // //                                     ),
// // //                                   ],
// // //                                 ),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ),
// // //               bottomNavigationBar: BottomNavigationBar(
// // //                 currentIndex: _currentIndex,
// // //                 onTap: _onItemTapped,
// // //                 type: BottomNavigationBarType.fixed,
// // //                 items: [
// // //                   BottomNavigationBarItem(
// // //                     icon: Icon(
// // //                       Icons.home,
// // //                     ),
// // //                     label: 'Home',
// // //                   ),
// // //                   BottomNavigationBarItem(
// // //                     icon: Icon(
// // //                       Icons.car_crash,
// // //                     ),
// // //                     label: 'Pickup',
// // //                   ),
// // //                   BottomNavigationBarItem(
// // //                     icon: Icon(
// // //                       Icons.car_crash,
// // //                     ),
// // //                     label: 'Delivery',
// // //                   ),
// // //                   BottomNavigationBarItem(
// // //                     icon: Icon(
// // //                       Icons.compare_arrows,
// // //                     ),
// // //                     label: 'History',
// // //                   ),
// // //                   BottomNavigationBarItem(
// // //                     icon: Icon(
// // //                       Icons.person,
// // //                     ),
// // //                     label: 'Me',
// // //                   ),
// // //                 ],
// // //                 selectedItemColor: Color(0xFF301C93),
// // //                 selectedFontSize:
// // //                     12.0, // Adjust the font size for the selected item
// // //                 unselectedFontSize:
// // //                     12.0, // Adjust the font size for unselected items
// // //                 iconSize: 26.0, // Adjust the icon size
// // //               ),
// // //             );
// // //           } else if (state is LoadingState) {
// // //             // return Center(
// // //             //   child: CircularProgressIndicator(),
// // //             // );
// // //             return _buildShimmerLoading();
// // //           } else {
// // //             return _buildShimmerLoading();
// // //           }
// // //         },
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildShimmerLoading() {
// // //     return SafeArea(
// // //       child: Scaffold(
// // //         backgroundColor: Colors.white,
// // //         body: SingleChildScrollView(
// // //           child: Padding(
// // //             padding: const EdgeInsets.all(10.0),
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 SizedBox(height: 40),
// // //                 Row(
// // //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                   children: [
// // //                     Row(
// // //                       children: [
// // //                         SizedBox(width: 10),
// // //                         Text(
// // //                           'Taj Muhammed',
// // //                           style: TextStyle(
// // //                               fontSize: 24,
// // //                               fontFamily: GoogleFonts.openSans().fontFamily,
// // //                               fontWeight: FontWeight.normal,
// // //                               color: Color(0xFF000000)),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                     IconButton(
// // //                       icon: Icon(Icons.notifications_outlined,
// // //                           size: 50, color: Color(0xFF301C93)),
// // //                       onPressed: () {
// // //                         // Add your onPressed logic here
// // //                       },
// // //                     ),
// // //                   ],
// // //                 ),
// // //                 // Image.asset(
// // //                 //   logo,
// // //                 //   height: 90,
// // //                 //   width: 130,
// // //                 // ),
// // //
// // //                 const SizedBox(height: 25),
// // //                 Row(
// // //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                   children: [
// // //                     Text(
// // //                       'Collect now',
// // //                       style: TextStyle(
// // //                           fontSize: 24,
// // //                           fontFamily: GoogleFonts.openSans().fontFamily,
// // //                           fontWeight: FontWeight.bold,
// // //                           color: Color(0xFF301C93)),
// // //                     ),
// // //                     TextButton.icon(
// // //                       icon: Icon(Icons.arrow_back_outlined,
// // //                           size: 25, color: Color(0xFF301C93)),
// // //                       label: Text('Back',
// // //                           style: TextStyle(
// // //                             color: Color(0xFF301C93),
// // //                             fontSize: 20,
// // //                             fontFamily: GoogleFonts.openSans().fontFamily,
// // //                           )),
// // //                       onPressed: () {
// // //                         // Add your onPressed logic here
// // //                       },
// // //                     ),
// // //                   ],
// // //                 ),
// // //                 Shimmer.fromColors(
// // //                   baseColor: Colors.grey[300]!,
// // //                   highlightColor: Colors.grey[100]!,
// // //                   direction: ShimmerDirection.ltr,
// // //                   child: Column(
// // //                     children: [
// // //                       Card(
// // //                         color: Colors.white,
// // //                         shape: RoundedRectangleBorder(
// // //                           borderRadius: BorderRadius.circular(15.0),
// // //                           side: const BorderSide(
// // //                             color: Colors.grey,
// // //                             width: 0.5,
// // //                           ),
// // //                         ),
// // //                         margin: const EdgeInsets.symmetric(vertical: 5),
// // //                         child: Container(
// // //                           height: MediaQuery.of(context).size.height / 3,
// // //                           padding: const EdgeInsets.all(16),
// // //                           child: Row(
// // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // //                             children: [
// // //                               // Logo (30%)
// // //                               Container(
// // //                                 width: 480,
// // //                               ),
// // //                             ],
// // //                           ),
// // //                         ),
// // //                       ),
// // //                       ListView.builder(
// // //                         shrinkWrap: true,
// // //                         physics: const NeverScrollableScrollPhysics(),
// // //                         itemCount: 5,
// // //                         itemBuilder: (context, index) {
// // //                           return Padding(
// // //                             padding: const EdgeInsets.all(15.0),
// // //                             child: Card(
// // //                               color: Colors.white,
// // //                               shape: RoundedRectangleBorder(
// // //                                 borderRadius: BorderRadius.circular(15.0),
// // //                                 side: const BorderSide(
// // //                                   color: Colors.grey,
// // //                                   width: 0.5,
// // //                                 ),
// // //                               ),
// // //                               margin: const EdgeInsets.symmetric(vertical: 5),
// // //                               child: Container(
// // //                                 height: MediaQuery.of(context).size.height / 8,
// // //                                 padding: const EdgeInsets.all(16),
// // //                                 child: Row(
// // //                                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                                   children: [
// // //                                     // Logo (30%)
// // //                                     Container(
// // //                                       width: 90,
// // //                                     ),
// // //                                   ],
// // //                                 ),
// // //                               ),
// // //                             ),
// // //                           );
// // //                         },
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Future<Map<String, dynamic>> fetchClothDetails(String clothname) async {
// // //     final String apiUrl =
// // //         'https://be.syswash.net/api/syswash/clothdetails?code=A';
// // //
// // //     final response = await http.get(Uri.parse(apiUrl), headers: {
// // //       "Accept": "application/json",
// // //       "Authorization": "Bearer $userToken"
// // //     });
// // //
// // //     if (response.statusCode == 200) {
// // //       final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
// // //       if (data.isNotEmpty) {
// // //         for (var clothData in data) {
// // //           if (clothData['data']['clothName'] == clothname) {
// // //             return {
// // //               'clothNameArabic': clothData['data']['clothNameArabic'],
// // //               'clothImg': clothData['data']['clothImg']
// // //             };
// // //           }
// // //         }
// // //
// // //         throw Exception('No data available for the provided cloth name.');
// // //       } else {
// // //         throw Exception('No data available from the server.');
// // //       }
// // //     } else {
// // //       throw Exception('Failed to load cloth details');
// // //     }
// // //   }
// // //
// // //   Future<int> getPriceId(
// // //     String selectedService,
// // //     String selectedCloth,
// // //   ) async {
// // //     final String apiUrl =
// // //         'https://be.syswash.net/api/syswash/pricedetails?code=A';
// // //
// // //     final response = await http.get(Uri.parse(apiUrl), headers: {
// // //       "Accept": "application/json",
// // //       "Authorization": "Bearer $userToken"
// // //     });
// // //
// // //     if (response.statusCode == 200) {
// // //       final List<dynamic> data = json.decode(response.body);
// // //
// // //       //   print(data);
// // //       final Map<String, dynamic> serviceData = data.firstWhere(
// // //         (element) =>
// // //             element['serviceName'] == selectedService &&
// // //             element['clothType'] == selectedCloth,
// // //         orElse: () => null,
// // //       );
// // //
// // //       if (serviceData != null) {
// // //         // Assuming quantity selection influences which priceId to select
// // //         return serviceData['priceId'];
// // //       } else {
// // //         throw Exception('Service or cloth type not found.');
// // //       }
// // //     } else {
// // //       throw Exception('Failed to load data');
// // //     }
// // //   }
// // //
// // //   void _onItemTapped(int index) {
// // //     setState(() {
// // //       _currentIndex = index;
// // //     });
// // //
// // //     if (_currentIndex == 0) {
// // //       Navigator.pushReplacementNamed(context, '/dashHome');
// // //     } else if (_currentIndex == 1) {
// // //       Navigator.pushReplacementNamed(context, "/pickupOrderListing");
// // //     } else if (_currentIndex == 2) {
// // //       Navigator.pushReplacementNamed(context, "/delivery");
// // //     } else if (_currentIndex == 3) {
// // //       Navigator.pushReplacementNamed(context, '/history');
// // //     } else if (_currentIndex == 4) {
// // //       Navigator.pushReplacementNamed(context, '/profile');
// // //     }
// // //   }
// // // }
// //
// // // import 'dart:convert';
// // //
// // // import 'package:flutter/cupertino.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_bloc/flutter_bloc.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:shimmer/shimmer.dart';
// // // import 'package:syswash/service/api_service.dart';
// // // import 'package:http/http.dart' as http;
// // // import '../../../../utils/app_constant.dart';
// // // import '../../../../utils/app_sp.dart';
// // // import '../../../../utils/app_url.dart';
// // // import 'bloc/customer_details_bloc.dart';
// // //
// // // class CustomerDetailsOrder extends StatefulWidget {
// // //   final String? pickupassgnId;
// // //
// // //   const CustomerDetailsOrder({Key? key, this.pickupassgnId}) : super(key: key);
// // //
// // //   @override
// // //   State<CustomerDetailsOrder> createState() => _CustomerDetailsOrderState();
// // // }
// // //
// // // class _CustomerDetailsOrderState extends State<CustomerDetailsOrder> {
// // //   int _currentIndex = 1;
// // //   late CustomerDetailsBloc _customerDetailsBloc;
// // //   String tokenID = '';
// // //   String userToken = "";
// // //   String companyCode = "";
// // //   String userID = "";
// // //
// // //   String pickupassgnId = '';
// // //   String selectedService = "";
// // //   List<String> serviceNames = [];
// // //
// // //   List<String> clothNames = [];
// // //   String? selectedCloth;
// // //
// // //
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     pickupassgnId = widget.pickupassgnId ?? '';
// // //     _customerDetailsBloc = CustomerDetailsBloc(ApiService());
// // //     getUserToken();
// // //   }
// // //
// // //
// // //   Future<void> getUserToken() async {
// // //     AppSp appSp = AppSp();
// // //     userToken = await appSp.getToken();
// // //     companyCode = await appSp.getCompanyCode();
// // //     fetchServiceDetailsData(userToken, companyCode);
// // //     fetchClouthDetailsData(userToken, companyCode);
// // //
// // //     _customerDetailsBloc
// // //         .add(CustomerDetailsApiEvent(userToken, companyCode, pickupassgnId));
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _customerDetailsBloc.close();
// // //     super.dispose();
// // //   }
// // //
// // //
// // //   void fetchClouthDetailsData(String userToken, String companyCode) async {
// // //     final response = await http.get(
// // //         Uri.parse('${AppUrls.clothdetails}${AppUrls.code_main}$companyCode'),
// // //         headers: {
// // //           "Accept": "application/json",
// // //           "Authorization": "Bearer $userToken"
// // //         }
// // //     );
// // //     if (response.statusCode == 200) {
// // //       List<Map<String, dynamic>> clothDataList = List<Map<String, dynamic>>.from(json.decode(response.body));
// // //       setState(() {
// // //         clothNames = clothDataList.map((clothData) => clothData['data']['clothName'] as String).toList();
// // //       });
// // //
// // //     } else {
// // //       print("Failed to fetch data: ${response.statusCode}");
// // //     }
// // //   }
// // //
// // //   void fetchServiceDetailsData(String userToken, String companyCode) async {
// // //     final response = await http.get(
// // //         Uri.parse('${AppUrls.servicedetails}${AppUrls.code_main}$companyCode'),
// // //         headers: {
// // //           "Accept": "application/json",
// // //           "Authorization": "Bearer $userToken"
// // //         }
// // //     );
// // //     if (response.statusCode == 200) {
// // //       List<dynamic> responseData = json.decode(response.body);
// // //       List<String> names = responseData
// // //           .map((data) => data['serviceName'] as String)
// // //           .toList();
// // //       setState(() {
// // //         serviceNames = names;
// // //
// // //         if (serviceNames.isNotEmpty) {
// // //           selectedService = serviceNames[0];
// // //         }
// // //       });
// // //     } else {
// // //       print("Failed to fetch data: ${response.statusCode}");
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return BlocProvider(
// // //       create: (context) => _customerDetailsBloc,
// // //       child: BlocConsumer<CustomerDetailsBloc, CustomerDetailsState>(
// // //         listener: (context, state) {
// // //           if (state is LoadedState) {
// // //             print("Category List Response: ${state.response}");
// // //           } else if (state is ErrorState) {
// // //             // Handle error state
// // //           } else if (state is UnAuthorizedState) {
// // //             // Handle unauthorized state
// // //           } else if (state is NoInternetState) {
// // //             // Handle no internet state
// // //           }
// // //         },
// // //         builder: (context, state) {
// // //           if (state is LoadingState) {
// // //             return Center(
// // //               child: CircularProgressIndicator(),
// // //             );
// // //             // return _buildShimmerLoading();
// // //           } else if (state is LoadedState) {
// // //
// // //             return Scaffold(
// // //               backgroundColor: Color(0xFFEFEEF3),
// // //               body: SingleChildScrollView(
// // //                 // Wrap the entire page with SingleChildScrollView
// // //                 child: Padding(
// // //                   padding: const EdgeInsets.all(30),
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       SizedBox(height: 30),
// // //                       Row(
// // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                         children: [
// // //                           Row(
// // //                             children: [
// // //                               // CircleAvatar(
// // //                               //   backgroundImage:
// // //                               //       AssetImage('assets/profile_image.jpg'),
// // //                               //   radius: 30,
// // //                               // ),
// // //                               SizedBox(width: 10),
// // //                               // Adjust spacing between circle and text
// // //                               Text(
// // //                                 'Taj Muhammed',
// // //                                 style: TextStyle(
// // //                                   fontSize: 24,
// // //                                   fontWeight: FontWeight.normal,
// // //                                   fontFamily: GoogleFonts.openSans().fontFamily,
// // //                                   color: Color(0xFF000000),
// // //                                 ),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                           IconButton(
// // //                             icon: Icon(Icons.notifications_outlined,
// // //                                 size: 50, color: Color(0xFF301C93)),
// // //                             onPressed: () {
// // //                               // Add your onPressed logic here
// // //                             },
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       SizedBox(height: 10),
// // //                       Row(
// // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                         children: [
// // //                           Text(
// // //                             'Collect now',
// // //                             style: TextStyle(
// // //                               fontSize: 24,
// // //                               fontFamily: GoogleFonts.openSans().fontFamily,
// // //                               fontWeight: FontWeight.bold,
// // //                               color: Color(0xFF301C93),
// // //                             ),
// // //                           ),
// // //                           TextButton.icon(
// // //                             icon: Icon(Icons.arrow_back_outlined,
// // //                                 size: 25, color: Color(0xFF301C93)),
// // //                             label: Text('Back',
// // //                                 style: TextStyle(
// // //                                   color: Color(0xFF301C93),
// // //                                   fontSize: 20,
// // //                                   fontFamily: GoogleFonts.openSans().fontFamily,
// // //                                 )),
// // //                             onPressed: () {
// // //                               Navigator.pushNamed(context, "/pickupOrderListing");
// // //                               // Add your onPressed logic here
// // //                             },
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       dividerLH(),
// // //                       Card(
// // //                         child: Column(
// // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // //                           children: [
// // //                             Row(
// // //                               children: [
// // //                                 Padding(
// // //                                   padding: EdgeInsets.all(20),
// // //                                   // child: CircleAvatar(
// // //                                   //   radius: 30,
// // //                                   //   backgroundImage:
// // //                                   //       AssetImage('assets/avatar.png'),
// // //                                   // ),
// // //
// // //                                   child: Column(
// // //                                     crossAxisAlignment:
// // //                                         CrossAxisAlignment.start,
// // //                                     children: [
// // //                                       Text(
// // //                                         '${state.response.pickupCustomerName}',
// // //                                         style: TextStyle(
// // //                                           fontWeight: FontWeight.bold,
// // //                                           fontFamily:
// // //                                               GoogleFonts.openSans().fontFamily,
// // //                                           fontSize: 16.0,
// // //                                         ),
// // //                                       ),
// // //                                       SizedBox(height: 5.0),
// // //                                       Text(
// // //                                         '${state.response.pickupCustomerPhno}',
// // //                                         style: TextStyle(
// // //                                           fontSize: 14.0,
// // //                                         ),
// // //                                       ),
// // //                                       SizedBox(height: 5.0),
// // //                                       Row(
// // //                                         children: [
// // //                                           Icon(Icons.location_on, size: 16.0),
// // //                                           SizedBox(width: 5.0),
// // //                                           Text(
// // //                                             '${state.response.pickupCustomerArea}',
// // //                                             style: TextStyle(
// // //                                               fontSize: 14.0,
// // //                                               fontFamily: GoogleFonts.openSans()
// // //                                                   .fontFamily,
// // //                                             ),
// // //                                           ),
// // //                                         ],
// // //                                       ),
// // //                                     ],
// // //                                   ),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //
// // //                             Padding(
// // //                               padding: const EdgeInsets.all(20),
// // //                               child: Column(
// // //                                 children: [
// // //                                   Row(
// // //                                     crossAxisAlignment:
// // //                                         CrossAxisAlignment.start,
// // //                                     children: [
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'Created at',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.grey,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               '12-4-2033',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'Pickup',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.grey,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               '12-45-2039',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                     ],
// // //                                   ),
// // //                                   SizedBox(height: 15),
// // //                                   Row(
// // //                                     crossAxisAlignment:
// // //                                         CrossAxisAlignment.start,
// // //                                     children: [
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'Drop off',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 color: Colors.grey,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               '12-4-2033',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'Status',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 color: Colors.grey,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               '${state.response.pickupstatus}',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                     ],
// // //                                   ),
// // //                                   SizedBox(height: 15),
// // //                                   Row(
// // //                                     crossAxisAlignment:
// // //                                         CrossAxisAlignment.start,
// // //                                     children: [
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'Street',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.grey,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               'Akhilnrd',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'Postal Code',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.grey,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               '345673',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                     ],
// // //                                   ),
// // //                                   SizedBox(height: 15),
// // //                                   Row(
// // //                                     crossAxisAlignment:
// // //                                         CrossAxisAlignment.start,
// // //                                     children: [
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'House Number',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.grey,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               '323',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'Town',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.grey,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               'Quater',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                     ],
// // //                                   ),
// // //                                   SizedBox(height: 15),
// // //                                   Row(
// // //                                     crossAxisAlignment:
// // //                                         CrossAxisAlignment.start,
// // //                                     children: [
// // //                                       Expanded(
// // //                                         flex: 1,
// // //                                         child: Column(
// // //                                           crossAxisAlignment:
// // //                                               CrossAxisAlignment.start,
// // //                                           children: [
// // //                                             Text(
// // //                                               'Bill Amount',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 14,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 color: Colors.grey,
// // //                                               ),
// // //                                             ),
// // //                                             Text(
// // //                                               '34',
// // //                                               style: TextStyle(
// // //                                                 fontSize: 16,
// // //                                                 fontFamily:
// // //                                                     GoogleFonts.openSans()
// // //                                                         .fontFamily,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                                 color: Colors.black,
// // //                                               ),
// // //                                             ),
// // //                                           ],
// // //                                         ),
// // //                                       ),
// // //                                     ],
// // //                                   ),
// // //                                   SizedBox(height: 15)
// // //                                 ],
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                       SizedBox(height: 15),
// // //                       Row(
// // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                         children: [
// // //                           Text(
// // //                             'Order Items',
// // //                             style: TextStyle(
// // //                               fontSize: 30,
// // //                               fontFamily: GoogleFonts.openSans().fontFamily,
// // //                               fontWeight: FontWeight.bold,
// // //                               color: Color(0xFF301C93),
// // //                             ),
// // //                           ),
// // //                           ElevatedButton(
// // //                             onPressed: () {
// // //                               showDialog(
// // //                                 context: context,
// // //                                 builder: (BuildContext context) {
// // //                                   return AlertDialog(
// // //                                     backgroundColor: Color(0xFFEFEEF3),
// // //                                     shape: RoundedRectangleBorder(
// // //                                       borderRadius: BorderRadius.circular(15.0),
// // //                                     ),
// // //                                     content: StatefulBuilder(
// // //                                       builder: (BuildContext context,
// // //                                           StateSetter setState) {
// // //                                         return Container(
// // //                                           width: 400,
// // //                                           height: 450,
// // //                                           child: SingleChildScrollView(
// // //                                             child: Padding(
// // //                                               padding:
// // //                                               const EdgeInsets.all(30.0),
// // //                                               child: Column(
// // //                                                 mainAxisAlignment:
// // //                                                 MainAxisAlignment.center,
// // //                                                 crossAxisAlignment:
// // //                                                 CrossAxisAlignment.start,
// // //                                                 children: [
// // //                                                   Text(
// // //                                                     'Add Items',
// // //                                                     style: TextStyle(
// // //                                                       fontWeight:
// // //                                                       FontWeight.bold,
// // //                                                       color: Color(0xFF301C93),
// // //                                                       fontFamily:
// // //                                                       GoogleFonts.openSans()
// // //                                                           .fontFamily,
// // //                                                       fontSize: 23.0,
// // //                                                     ),
// // //                                                   ),
// // //                                                   SizedBox(height: 20),
// // //                                                   Column(
// // //                                                     crossAxisAlignment:
// // //                                                     CrossAxisAlignment
// // //                                                         .start,
// // //                                                     children: [
// // //                                                       Text(
// // //                                                         'Select Service:',
// // //                                                         style: TextStyle(
// // //                                                           fontWeight:
// // //                                                           FontWeight.bold,
// // //                                                           fontFamily: GoogleFonts
// // //                                                               .openSans()
// // //                                                               .fontFamily,
// // //                                                         ),
// // //                                                       ),
// // //                                                       SizedBox(height: 5),
// // //                                                       Container(
// // //                                                         padding: EdgeInsets
// // //                                                             .symmetric(
// // //                                                             horizontal:
// // //                                                             12.0),
// // //                                                         decoration:
// // //                                                         BoxDecoration(
// // //                                                           color:
// // //                                                           Color(0xFFF9F9F9),
// // //                                                           borderRadius:
// // //                                                           BorderRadius
// // //                                                               .circular(
// // //                                                               10.0),
// // //                                                         ),
// // //                                                         child: DropdownButton<String>(
// // //                                                           isExpanded: true,
// // //                                                           onChanged: (String?newValue) {
// // //                                                             setState(() {
// // //                                                               selectedService =
// // //                                                                   newValue ??
// // //                                                                       "";
// // //                                                               print(
// // //                                                                   "Selected service: $selectedService");
// // //                                                             });
// // //                                                           },
// // //                                                           value:
// // //                                                           selectedService,
// // //                                                           items: serviceNames.map<
// // //                                                               DropdownMenuItem<
// // //                                                                   String>>((String
// // //                                                           value) {
// // //                                                             return DropdownMenuItem<
// // //                                                                 String>(
// // //                                                               value: value,
// // //                                                               child:
// // //                                                               Text(value),
// // //                                                             );
// // //                                                           }).toList(),
// // //                                                         ),
// // //                                                       ),
// // //                                                     ],
// // //                                                   ),
// // //                                                   SizedBox(height: 20),
// // //                                                   Column(
// // //                                                     crossAxisAlignment:
// // //                                                     CrossAxisAlignment
// // //                                                         .start,
// // //                                                     children: [
// // //                                                       Text(
// // //                                                         'Cloth Type:',
// // //                                                         style: TextStyle(
// // //                                                           fontWeight:
// // //                                                           FontWeight.bold,
// // //                                                           fontFamily: GoogleFonts
// // //                                                               .openSans()
// // //                                                               .fontFamily,
// // //                                                         ),
// // //                                                       ),
// // //                                                       SizedBox(height: 5),
// // //                                                       Container(
// // //                                                         padding: EdgeInsets
// // //                                                             .symmetric(
// // //                                                             horizontal:
// // //                                                             12.0),
// // //                                                         decoration:
// // //                                                         BoxDecoration(
// // //                                                           color:
// // //                                                           Color(0xFFF9F9F9),
// // //                                                           borderRadius:
// // //                                                           BorderRadius
// // //                                                               .circular(
// // //                                                               10.0),
// // //                                                         ),
// // //                                                         child: DropdownButton<
// // //                                                             String>(
// // //                                                           isExpanded: true,
// // //                                                           value: selectedCloth,
// // //                                                           onChanged: (String?
// // //                                                           newValue) {
// // //                                                             setState(() {
// // //                                                               selectedCloth =
// // //                                                                   newValue;
// // //                                                             });
// // //                                                           },
// // //                                                           items: clothNames.map(
// // //                                                                   (String value) {
// // //                                                                 return DropdownMenuItem<
// // //                                                                     String>(
// // //                                                                   value: value,
// // //                                                                   child:
// // //                                                                   Text(value),
// // //                                                                 );
// // //                                                               }).toList(),
// // //                                                           hint: Text(
// // //                                                               'Select a cloth type'),
// // //                                                         ),
// // //                                                       ),
// // //                                                     ],
// // //                                                   ),
// // //                                                   dividerH(),
// // //                                                   Column(
// // //                                                     crossAxisAlignment:
// // //                                                     CrossAxisAlignment
// // //                                                         .start,
// // //                                                     children: [
// // //                                                       Text(
// // //                                                         'QTY:',
// // //                                                         style: TextStyle(
// // //                                                           fontWeight:
// // //                                                           FontWeight.bold,
// // //                                                         ),
// // //                                                       ),
// // //                                                       SizedBox(height: 5),
// // //                                                       TextField(
// // //                                                         decoration:
// // //                                                         InputDecoration(
// // //                                                           filled: true,
// // //                                                           fillColor:
// // //                                                           Color(0xFFF9F9F9),
// // //                                                           border:
// // //                                                           OutlineInputBorder(
// // //                                                             borderRadius:
// // //                                                             BorderRadius
// // //                                                                 .circular(
// // //                                                                 10.0),
// // //                                                           ),
// // //                                                           hintText:
// // //                                                           'Enter a quantity',
// // //                                                           contentPadding:
// // //                                                           EdgeInsets
// // //                                                               .symmetric(
// // //                                                               horizontal:
// // //                                                               12.0),
// // //                                                         ),
// // //                                                       ),
// // //                                                     ],
// // //                                                   ),
// // //                                                   dividerH(),
// // //                                                   Container(
// // //                                                     padding:
// // //                                                     const EdgeInsets.all(5),
// // //                                                     width: double.infinity,
// // //                                                     // Full width
// // //                                                     decoration: BoxDecoration(
// // //                                                       borderRadius:
// // //                                                       BorderRadius.circular(
// // //                                                           10.0),
// // //                                                       color: Color(0xFF301C93),
// // //                                                     ),
// // //                                                     child: TextButton(
// // //                                                       onPressed: () {
// // //                                                         showDialog(
// // //                                                           context: context,
// // //                                                           builder: (BuildContext
// // //                                                           context) {
// // //                                                             return Dialog(
// // //                                                               backgroundColor:
// // //                                                               Color(
// // //                                                                   0xFFEFEEF3),
// // //                                                               shape:
// // //                                                               RoundedRectangleBorder(
// // //                                                                 borderRadius:
// // //                                                                 BorderRadius
// // //                                                                     .circular(
// // //                                                                     15.0),
// // //                                                               ),
// // //                                                               child: Stack(
// // //                                                                 children: [
// // //                                                                   Container(
// // //                                                                     width: 400,
// // //                                                                     height: 450,
// // //                                                                     child:
// // //                                                                     SingleChildScrollView(
// // //                                                                       child:
// // //                                                                       Padding(
// // //                                                                         padding: const EdgeInsets
// // //                                                                             .all(
// // //                                                                             30.0),
// // //                                                                         child:
// // //                                                                         Column(
// // //                                                                           mainAxisAlignment:
// // //                                                                           MainAxisAlignment.center,
// // //                                                                           crossAxisAlignment:
// // //                                                                           CrossAxisAlignment.start,
// // //                                                                           children: [
// // //                                                                             Text(
// // //                                                                               'Status',
// // //                                                                               style: TextStyle(
// // //                                                                                 fontWeight: FontWeight.bold,
// // //                                                                                 color: Color(0xFF301C93),
// // //                                                                                 fontFamily: GoogleFonts.openSans().fontFamily,
// // //                                                                                 fontSize: 27.0,
// // //                                                                               ),
// // //                                                                             ),
// // //                                                                             SizedBox(height: 50),
// // //                                                                             Text(
// // //                                                                               "in publishing ang grraphic design.lorem ipsum is placeholder text commonly ",
// // //                                                                               style: TextStyle(
// // //                                                                                 fontSize: 18,
// // //                                                                                 fontFamily: GoogleFonts.openSans().fontFamily,
// // //                                                                               ),
// // //                                                                             ),
// // //                                                                             SizedBox(height: 50),
// // //                                                                             Container(
// // //                                                                               padding: const EdgeInsets.all(10.0),
// // //                                                                               width: double.infinity,
// // //                                                                               height: 50,
// // //                                                                               // Full width
// // //                                                                               decoration: BoxDecoration(
// // //                                                                                 borderRadius: BorderRadius.circular(10.0),
// // //                                                                                 color: Color(0xFF301C93),
// // //                                                                               ),
// // //                                                                               child: TextButton(
// // //                                                                                 onPressed: () {
// // //                                                                                   // Handle submit button press
// // //                                                                                 },
// // //                                                                                 child: Text(
// // //                                                                                   'COMPLETED',
// // //                                                                                   style: TextStyle(
// // //                                                                                     color: Colors.white,
// // //                                                                                     fontFamily: GoogleFonts.openSans().fontFamily,
// // //                                                                                   ),
// // //                                                                                 ),
// // //                                                                               ),
// // //                                                                             ),
// // //                                                                           ],
// // //                                                                         ),
// // //                                                                       ),
// // //                                                                     ),
// // //                                                                   ),
// // //                                                                   Positioned(
// // //                                                                     top: 0,
// // //                                                                     right: 0,
// // //                                                                     child:
// // //                                                                     GestureDetector(
// // //                                                                       onTap:
// // //                                                                           () {
// // //                                                                         Navigator.of(context)
// // //                                                                             .pop();
// // //                                                                       },
// // //                                                                       child:
// // //                                                                       CircleAvatar(
// // //                                                                         radius:
// // //                                                                         20.0,
// // //                                                                         backgroundColor:
// // //                                                                         Color(0xFF301C93),
// // //                                                                         child:
// // //                                                                         Icon(
// // //                                                                           Icons
// // //                                                                               .close,
// // //                                                                           color:
// // //                                                                           Colors.white,
// // //                                                                           size:
// // //                                                                           30,
// // //                                                                         ),
// // //                                                                       ),
// // //                                                                     ),
// // //                                                                   ),
// // //                                                                 ],
// // //                                                               ),
// // //                                                             );
// // //                                                           },
// // //                                                         );
// // //                                                       },
// // //                                                       child: Text(
// // //                                                         'Submit',
// // //                                                         style: TextStyle(
// // //                                                           color: Colors.white,
// // //                                                           fontFamily: GoogleFonts
// // //                                                               .openSans()
// // //                                                               .fontFamily,
// // //                                                         ),
// // //                                                       ),
// // //                                                     ),
// // //                                                   ),
// // //                                                 ],
// // //                                               ),
// // //                                             ),
// // //                                           ),
// // //                                         );
// // //                                       },
// // //                                     ),
// // //                                   );
// // //                                 },
// // //                               );
// // //                             },
// // //                             style: TextButton.styleFrom(
// // //                               backgroundColor:
// // //                               Color(0xFF301C93), // Button background color
// // //                               padding: EdgeInsets.symmetric(
// // //                                   vertical: 10, horizontal: 20),
// // //                               shape: RoundedRectangleBorder(
// // //                                 borderRadius: BorderRadius.circular(
// // //                                     15), // Button border radius
// // //                               ),
// // //                             ),
// // //                             child: Text(
// // //                               'ADD ITEMS',
// // //                               style: TextStyle(
// // //                                 fontSize: 15,
// // //                                 fontFamily: GoogleFonts.openSans().fontFamily,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 color: Colors.white,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       ListView.builder(
// // //                         shrinkWrap: true,
// // //                         // Important to add
// // //                         physics: NeverScrollableScrollPhysics(),
// // //                         // Prevent inner ListView from scrolling
// // //                         itemCount: 5,
// // //                         // Change this according to your data
// // //                         itemBuilder: (context, index) {
// // //                           return Padding(
// // //                             padding: EdgeInsets.symmetric(
// // //                                 vertical: 5.0, horizontal: 10.0),
// // //                             child: Card(
// // //                               child: ListTile(
// // //                                 // leading: SizedBox(
// // //                                 //   width: 80,
// // //                                 //   child: Image.network(
// // //                                 //     'https://via.placeholder.com/150',
// // //                                 //     // Replace with your image URL
// // //                                 //     fit: BoxFit.cover,
// // //                                 //   ),
// // //                                 // ),
// // //                                 title: Text(
// // //                                   'Heading $index',
// // //                                   style: TextStyle(
// // //                                     fontFamily:
// // //                                         GoogleFonts.openSans().fontFamily,
// // //                                   ),
// // //                                 ),
// // //                                 subtitle: Text(
// // //                                   'Subheading $index',
// // //                                   style: TextStyle(
// // //                                     fontFamily:
// // //                                         GoogleFonts.openSans().fontFamily,
// // //                                   ),
// // //                                 ),
// // //                               ),
// // //                             ),
// // //                           );
// // //                         },
// // //                       ),
// // //
// // //                       SizedBox(height: 15),
// // //                       // Small card at the bottom
// // //                       Card(
// // //                         child: Padding(
// // //                           padding: const EdgeInsets.all(15.0),
// // //                           child: Row(
// // //                             children: [
// // //                               ElevatedButton(
// // //                                 onPressed: () {
// // //                                   // Add your onPressed logic here
// // //                                 },
// // //                                 style: ElevatedButton.styleFrom(
// // //                                   padding: const EdgeInsets.all(16.0),
// // //                                   primary: Color(0xFF301C93),
// // //                                   // Background color
// // //                                   onPrimary: Colors.white,
// // //                                   // Text color
// // //                                   shape: RoundedRectangleBorder(
// // //                                     borderRadius: BorderRadius.circular(
// // //                                         10), // Border radius
// // //                                   ),
// // //                                 ),
// // //                                 child: Text(
// // //                                   'Collect now',
// // //                                   style: TextStyle(
// // //                                     fontFamily:
// // //                                         GoogleFonts.openSans().fontFamily,
// // //                                   ),
// // //                                 ),
// // //                               ),
// // //                               SizedBox(width: 10),
// // //                               Expanded(
// // //                                 child: Row(
// // //                                   mainAxisAlignment: MainAxisAlignment.center,
// // //                                   children: [
// // //                                     Text(
// // //                                       'ITEMS : 5',
// // //                                       style: TextStyle(
// // //                                         fontSize: 20,
// // //                                         fontFamily:
// // //                                             GoogleFonts.openSans().fontFamily,
// // //                                         fontWeight: FontWeight.bold,
// // //                                         color: Color(0xFF301C93),
// // //                                       ),
// // //                                     ),
// // //                                     SizedBox(width: 30),
// // //                                     Text(
// // //                                       'QTY : 11',
// // //                                       style: TextStyle(
// // //                                         fontSize: 20,
// // //                                         fontFamily:
// // //                                             GoogleFonts.openSans().fontFamily,
// // //                                         fontWeight: FontWeight.bold,
// // //                                         color: Color(0xFF301C93),
// // //                                       ),
// // //                                     ),
// // //                                   ],
// // //                                 ),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //
// // //               ),
// // //               bottomNavigationBar: BottomNavigationBar(
// // //                 currentIndex: _currentIndex,
// // //                 onTap: _onItemTapped,
// // //                 type: BottomNavigationBarType.fixed,
// // //                 items: [
// // //                   BottomNavigationBarItem(
// // //                     icon: Icon(
// // //                       Icons.home,
// // //                     ),
// // //                     label: 'Home',
// // //                   ),
// // //                   BottomNavigationBarItem(
// // //                     icon: Icon(
// // //                       Icons.car_crash,
// // //                     ),
// // //                     label: 'Pickup',
// // //                   ),
// // //                   BottomNavigationBarItem(
// // //                     icon: Icon(
// // //                       Icons.car_crash,
// // //                     ),
// // //                     label: 'Delivery',
// // //                   ),
// // //                   BottomNavigationBarItem(
// // //                     icon: Icon(
// // //                       Icons.compare_arrows,
// // //                     ),
// // //                     label: 'History',
// // //                   ),
// // //                   BottomNavigationBarItem(
// // //                     icon: Icon(
// // //                       Icons.person,
// // //                     ),
// // //                     label: 'Me',
// // //                   ),
// // //                 ],
// // //                 selectedItemColor: Color(0xFF301C93),
// // //                 selectedFontSize:
// // //                 12.0, // Adjust the font size for the selected item
// // //                 unselectedFontSize:
// // //                 12.0, // Adjust the font size for unselected items
// // //                 iconSize: 26.0, // Adjust the icon size
// // //               ),
// // //             );
// // //           } else if (state is LoadingState) {
// // //             // return Center(
// // //             //   child: CircularProgressIndicator(),
// // //             // );
// // //             return _buildShimmerLoading();
// // //           } else {
// // //             return _buildShimmerLoading();
// // //           }
// // //         },
// // //       ),
// // //     );
// // //   }
// // //   Widget _buildShimmerLoading() {
// // //     return SafeArea(
// // //       child: Scaffold(
// // //         backgroundColor: Colors.white,
// // //         body: SingleChildScrollView(
// // //           child: Padding(
// // //             padding: const EdgeInsets.all(10.0),
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 SizedBox(height:40 ),
// // //                 Row(
// // //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                   children: [
// // //                     Row(
// // //                       children: [
// // //
// // //                         SizedBox(
// // //                             width:
// // //                             10),
// // //                         Text(
// // //                           'Taj Muhammed',
// // //                           style: TextStyle(
// // //                               fontSize: 24,
// // //                               fontFamily: GoogleFonts.openSans().fontFamily,
// // //                               fontWeight: FontWeight.normal,
// // //                               color: Color(0xFF000000)),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                     IconButton(
// // //                       icon: Icon(Icons.notifications_outlined,
// // //                           size: 50, color: Color(0xFF301C93)),
// // //                       onPressed: () {
// // //                         // Add your onPressed logic here
// // //                       },
// // //                     ),
// // //                   ],
// // //                 ),
// // //                 // Image.asset(
// // //                 //   logo,
// // //                 //   height: 90,
// // //                 //   width: 130,
// // //                 // ),
// // //
// // //                 const SizedBox(height: 25),
// // //                 Row(
// // //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                   children: [
// // //                     Text(
// // //                       'Collect now',
// // //                       style: TextStyle(
// // //                           fontSize: 24,
// // //                           fontFamily: GoogleFonts.openSans().fontFamily,
// // //                           fontWeight: FontWeight.bold,
// // //                           color: Color(0xFF301C93)),
// // //                     ),
// // //                     TextButton.icon(
// // //                       icon: Icon(Icons.arrow_back_outlined,
// // //                           size: 25, color: Color(0xFF301C93)),
// // //                       label: Text('Back',
// // //                           style: TextStyle(
// // //                             color: Color(0xFF301C93),
// // //                             fontSize: 20,
// // //                             fontFamily: GoogleFonts.openSans().fontFamily,
// // //                           )),
// // //                       onPressed: () {
// // //                         // Add your onPressed logic here
// // //                       },
// // //                     ),
// // //                   ],
// // //                 ),
// // //                 Shimmer.fromColors(
// // //                   baseColor: Colors.grey[300]!,
// // //                   highlightColor: Colors.grey[100]!,
// // //                   direction: ShimmerDirection.ltr,
// // //                   child: Column(
// // //                     children: [
// // //                       Card(
// // //                         color: Colors.white,
// // //                         shape: RoundedRectangleBorder(
// // //                           borderRadius: BorderRadius.circular(15.0),
// // //                           side: const BorderSide(
// // //                             color: Colors.grey,
// // //                             width: 0.5,
// // //                           ),
// // //                         ),
// // //                         margin: const EdgeInsets.symmetric(vertical: 5),
// // //                         child: Container(
// // //                           height: MediaQuery.of(context).size.height / 3,
// // //                           padding: const EdgeInsets.all(16),
// // //                           child: Row(
// // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // //                             children: [
// // //                               // Logo (30%)
// // //                               Container(
// // //                                 width: 480,
// // //                               ),
// // //                             ],
// // //                           ),
// // //                         ),
// // //                       ),
// // //                       ListView.builder(
// // //                         shrinkWrap: true,
// // //                         physics: const NeverScrollableScrollPhysics(),
// // //                         itemCount: 5,
// // //                         itemBuilder: (context, index) {
// // //                           return Padding(
// // //                             padding: const EdgeInsets.all(15.0),
// // //                             child: Card(
// // //                               color: Colors.white,
// // //                               shape: RoundedRectangleBorder(
// // //                                 borderRadius: BorderRadius.circular(15.0),
// // //                                 side: const BorderSide(
// // //                                   color: Colors.grey,
// // //                                   width: 0.5,
// // //                                 ),
// // //                               ),
// // //                               margin: const EdgeInsets.symmetric(vertical: 5),
// // //                               child: Container(
// // //                                 height: MediaQuery.of(context).size.height / 8,
// // //                                 padding: const EdgeInsets.all(16),
// // //                                 child: Row(
// // //                                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                                   children: [
// // //                                     // Logo (30%)
// // //                                     Container(
// // //                                       width: 90,
// // //                                     ),
// // //                                   ],
// // //                                 ),
// // //                               ),
// // //                             ),
// // //                           );
// // //                         },
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   void _onItemTapped(int index) {
// // //     setState(() {
// // //       _currentIndex = index;
// // //     });
// // //
// // //     if (_currentIndex == 0) {
// // //       Navigator.pushReplacementNamed(context, '/dashHome');
// // //     } else if (_currentIndex == 1) {
// // //       Navigator.pushReplacementNamed(context, "/pickupOrderListing");
// // //     } else if (_currentIndex == 2) {
// // //       Navigator.pushReplacementNamed(context, "/delivery");
// // //     } else if (_currentIndex == 3) {
// // //       Navigator.pushReplacementNamed(context, '/history');
// // //     } else if (_currentIndex == 4) {
// // //       Navigator.pushReplacementNamed(context, '/profile');
// // //     }
// // //   }
// // // }
// // //
// // //
