import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syswash/service/api_service.dart';
import 'package:http/http.dart' as http;
import '../../../../utils/app_constant.dart';
import '../../../../utils/app_sp.dart';
import '../../../../utils/app_url.dart';
import 'package:location/location.dart';
import 'bloc/customer_details_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding; // Import geocoding package with an alias


class CustomerDetailsOrder extends StatefulWidget {
  final String? pickupassgnId;

  const CustomerDetailsOrder({Key? key, this.pickupassgnId}) : super(key: key);

  @override
  State<CustomerDetailsOrder> createState() => _CustomerDetailsOrderState();
}

class _CustomerDetailsOrderState extends State<CustomerDetailsOrder> {
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

  List<String> clothNames = [];
  String? selectedCloth;
  String selectedServiceCode = "DC";

  String quantity = "1";
  String LoggerUsername = "";
  String selectedBilling = "Express";
  List<String> billingOptions = ['Express', 'Normal',];

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


  int customerDiscount = 0;

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
    setState(() {
      clothdate.add(clothData);
      updateCounts();
    });
  }

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
  }

  @override
  void dispose() {
    _customerDetailsBloc.close();
    super.dispose();
  }

  void fetchPriceListDatas(String userToken, String companyCode) async {
    final response = await http.get(
      Uri.parse('https://be.syswash.net/api/syswash/pricedetails?code=A'),
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
      List<Map<String, dynamic>> clothDataList =
          List<Map<String, dynamic>>.from(json.decode(response.body));
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
      List<Map<String, String>> services = responseData.map((data) {
        return {
          'serviceName': data['serviceName'] as String,
          'serviceCode': data['serviceCode'] as String,
        };
      }).toList();
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

  // Fetch existing cloth data
  Future<void> OrderAlreadyExistClothdata(
      String userToken, String pickupOrderId) async {
    final response = await http.get(
        Uri.parse(
            'https://be.syswash.net/api/syswash/order/$pickupOrderId?code=A'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      processResponseData(responseData);
      final clothData = responseData['clothData'] as List<dynamic>;
      //print(clothData);
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


            Map<String, Map<String, dynamic>> clothMap = {};
            Map<String, int> clothNameCount = {};

            clothdata_order_existing.forEach((cloth) {
              var clothName = cloth['clothName'];
              clothMap.putIfAbsent(clothName, () => cloth);
              clothNameCount[clothName] = (clothNameCount[clothName] ?? 0) + 1;
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
              backgroundColor: Color(0xFFEFEEF3),
              body: SingleChildScrollView(
                // Wrap the entire page with SingleChildScrollView
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // CircleAvatar(
                              //   backgroundImage:
                              //       AssetImage('assets/profile_image.jpg'),
                              //   radius: 30,
                              // ),
                              SizedBox(width: 10),
                              // Adjust spacing between circle and text
                              Text(
                                '$LoggerUsername ',
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
                                size: 50, color: Color(0xFF301C93)),
                            onPressed: () {
                              // Add your onPressed logic here
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Collect now',
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: GoogleFonts.openSans().fontFamily,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF301C93),
                            ),
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
                              Navigator.pushNamed(
                                  context, "/pickupOrderListing");
                              // Add your onPressed logic here
                            },
                          ),
                        ],
                      ),
                      dividerLH(),
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
                                  //   backgroundImage:
                                  //       AssetImage('assets/avatar.png'),
                                  // ),

                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${state.response.pickupCustomerName}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily:
                                              GoogleFonts.openSans().fontFamily,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        '${state.response.pickupCustomerPhno}',
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
                                            '${state.response.pickupCustomerArea}',
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontFamily: GoogleFonts.openSans()
                                                  .fontFamily,
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
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Customer code',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily:
                                                    GoogleFonts.openSans()
                                                        .fontFamily,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              "${responseData['orderDate']}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily:
                                                    GoogleFonts.openSans()
                                                        .fontFamily,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Area',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily:
                                                    GoogleFonts.openSans()
                                                        .fontFamily,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              "${responseData['orderDate']}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    GoogleFonts.openSans()
                                                        .fontFamily,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Hotel',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                                fontFamily:
                                                    GoogleFonts.openSans()
                                                        .fontFamily,
                                              ),
                                            ),
                                            Text(
                                              "${responseData['deliveryDate']}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    GoogleFonts.openSans()
                                                        .fontFamily,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Reference No',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              '${state.response.pickupstatus}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    GoogleFonts.openSans()
                                                        .fontFamily,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Street Name',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily:
                                                    GoogleFonts.openSans()
                                                        .fontFamily,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              "${responseData['customerStreet']}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily:
                                                    GoogleFonts.openSans()
                                                        .fontFamily,
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
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'House Number',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily:
                                                GoogleFonts.openSans()
                                                    .fontFamily,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              "${responseData['customerRoomNo']}",
                                              style: TextStyle(
                                                fontSize: 16,
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
                                      //     crossAxisAlignment:
                                      //         CrossAxisAlignment.start,
                                      //     children: [
                                      //       Text(
                                      //         'Postal Code',
                                      //         style: TextStyle(
                                      //           fontSize: 14,
                                      //           fontFamily:
                                      //               GoogleFonts.openSans()
                                      //                   .fontFamily,
                                      //           color: Colors.grey,
                                      //         ),
                                      //       ),
                                      //       Text(
                                      //         "${responseData['customerReffrNo']}",
                                      //         style: TextStyle(
                                      //           fontSize: 16,
                                      //           fontFamily:
                                      //               GoogleFonts.openSans()
                                      //                   .fontFamily,
                                      //           fontWeight: FontWeight.bold,
                                      //           color: Colors.black,
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Fragrance',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily:
                                                GoogleFonts.openSans()
                                                    .fontFamily,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              "${responseData['customerAddress']}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily:
                                                GoogleFonts.openSans()
                                                    .fontFamily,
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
                                      //     crossAxisAlignment:
                                      //         CrossAxisAlignment.start,
                                      //     children: [
                                      //       Text(
                                      //         'House Number',
                                      //         style: TextStyle(
                                      //           fontSize: 14,
                                      //           fontFamily:
                                      //               GoogleFonts.openSans()
                                      //                   .fontFamily,
                                      //           color: Colors.grey,
                                      //         ),
                                      //       ),
                                      //       Text(
                                      //         "${responseData['customerRoomNo']}",
                                      //         style: TextStyle(
                                      //           fontSize: 16,
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
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Discount',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily:
                                                GoogleFonts.openSans()
                                                    .fontFamily,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              "${responseData['totalAmount']}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily:
                                                GoogleFonts.openSans()
                                                    .fontFamily,
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
                                      //     crossAxisAlignment:
                                      //         CrossAxisAlignment.start,
                                      //     children: [
                                      //       Text(
                                      //         'Town',
                                      //         style: TextStyle(
                                      //           fontSize: 14,
                                      //           fontFamily:
                                      //               GoogleFonts.openSans()
                                      //                   .fontFamily,
                                      //           color: Colors.grey,
                                      //         ),
                                      //       ),
                                      //       Text(
                                      //         "${responseData['customerAddress']}",
                                      //         style: TextStyle(
                                      //           fontSize: 16,
                                      //           fontFamily:
                                      //               GoogleFonts.openSans()
                                      //                   .fontFamily,
                                      //           fontWeight: FontWeight.bold,
                                      //           color: Colors.black,
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Expanded(
                                      //   flex: 1,
                                      //   child: Column(
                                      //     crossAxisAlignment:
                                      //     CrossAxisAlignment.start,
                                      //     children: [
                                      //       Text(
                                      //         'Bill Amount',
                                      //         style: TextStyle(
                                      //           fontSize: 14,
                                      //           fontFamily:
                                      //           GoogleFonts.openSans()
                                      //               .fontFamily,
                                      //           color: Colors.grey,
                                      //         ),
                                      //       ),
                                      //       Text(
                                      //         "${responseData['totalAmount']}",
                                      //         style: TextStyle(
                                      //           fontSize: 16,
                                      //           fontFamily:
                                      //           GoogleFonts.openSans()
                                      //               .fontFamily,
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
                                          //   try {
                                          //     EasyLoading.show(status: 'Loading...');
                                          //     Location location = Location();
                                          //     bool _serviceEnabled;
                                          //     PermissionStatus _permissionGranted;
                                          //     LocationData _locationData;
                                          //
                                          //     _serviceEnabled = await location.serviceEnabled();
                                          //     if (!_serviceEnabled) {
                                          //       _serviceEnabled = await location.requestService();
                                          //       if (!_serviceEnabled) {
                                          //         EasyLoading.showError('Location services are disabled.');
                                          //         return;
                                          //       }
                                          //     }
                                          //
                                          //     _permissionGranted = await location.hasPermission();
                                          //     if (_permissionGranted == PermissionStatus.denied) {
                                          //       _permissionGranted = await location.requestPermission();
                                          //       if (_permissionGranted != PermissionStatus.granted) {
                                          //         EasyLoading.showError('Location permissions are denied.');
                                          //         return;
                                          //       }
                                          //     }
                                          //
                                          //     _locationData = await location.getLocation();
                                          //     // final destination = Uri.encodeComponent('${state.response.pickupCustomerArea}');
                                          //     // final Uri uri = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=${_locationData.latitude},${_locationData.longitude}&destination=$destination');
                                          //     final Uri uri = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=koppam&destination=pakara');
                                          //
                                          //     if (await canLaunch(uri.toString())) {
                                          //       await launch(uri.toString());
                                          //     } else {
                                          //       EasyLoading.showError('Could not launch $uri');
                                          //     }
                                          //     EasyLoading.dismiss();
                                          //   } catch (e) {
                                          //     EasyLoading.showError('Error: $e');
                                          //   }
                                          //   try {
                                          //     // Construct Google Maps URL with default location
                                          //     final Uri uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=pakara');
                                          //
                                          //     // Launch Google Maps
                                          //     if (await canLaunch(uri.toString())) {
                                          //       await launch(uri.toString());
                                          //     } else {
                                          //       print('Could not launch $uri');
                                          //     }
                                          //   } catch (e) {
                                          //     print('Error: $e');
                                          //   }


                                            final availableMaps = await MapLauncher.installedMaps;
                                            print(availableMaps);

                                            //_findLocation('koppam,pattambi');
                                            final coordinates = await _findLocation('${state.response.pickupCustomerArea}',);
                                            print('Latitude: ${coordinates?.latitude}, Longitude: ${coordinates?.longitude}');


                                            await showMapOptions('${state.response.pickupCustomerArea}', '${coordinates?.latitude}', '${coordinates?.longitude}');





                                            // try {
                                            //   final String destination = "Koppam"; // Specify the destination here
                                            //   final double latitude = 15.3505;
                                            //   final double longitude = 76.1567;
                                            //
                                            //   final url = "https://www.google.com/maps/dir/?api=1&destination=$destination&destination_place_id=$latitude,$longitude";
                                            //
                                            //   if (await canLaunch(url)) {
                                            //     await launch(url);
                                            //   } else {
                                            //     print('Could not launch $url');
                                            //   }
                                            // } catch (e) {
                                            //   print('Error: $e');
                                            // }

                                            },
                                          // onPressed: (){
                                          //   try{
                                          //     var url = 'https://www.google.com/maps/dir/?api=1&destination=${state.response.pickupCustomerArea}';
                                          //     print(url);
                                          //     final Uri _url = Uri.parse(url);
                                          //     launchUrl(_url);
                                          //   }catch (_){
                                          //     print('object');
                                          //   }
                                          // },

                                          style: ElevatedButton.styleFrom(
                                            primary: Color(0xFF301C93),
                                            onPrimary: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Location',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontFamily: GoogleFonts.openSans().fontFamily,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                Icons.location_on,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Expanded(
                                      //   flex: 1,
                                      //   child: Column(
                                      //     crossAxisAlignment:
                                      //         CrossAxisAlignment.start,
                                      //     children: [
                                      //       Text(
                                      //         'Bill Amount',
                                      //         style: TextStyle(
                                      //           fontSize: 14,
                                      //           fontFamily:
                                      //               GoogleFonts.openSans()
                                      //                   .fontFamily,
                                      //           color: Colors.grey,
                                      //         ),
                                      //       ),
                                      //       Text(
                                      //         '34',
                                      //         style: TextStyle(
                                      //           fontSize: 16,
                                      //           fontFamily:
                                      //               GoogleFonts.openSans()
                                      //                   .fontFamily,
                                      //           fontWeight: FontWeight.bold,
                                      //           color: Colors.black,
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  SizedBox(height: 15)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
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
                                          height: 475,
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
                                                  Text(
                                                    'Add Items',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF301C93),
                                                      fontFamily:
                                                          GoogleFonts.openSans()
                                                              .fontFamily,
                                                      fontSize: 18.0,
                                                    ),
                                                  ),

                                                  SizedBox(height: 20),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Select Service:',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily: GoogleFonts
                                                                  .openSans()
                                                              .fontFamily,
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
                                                        child: DropdownButton<
                                                            String?>(
                                                          isExpanded: true,
                                                          onChanged: (String?
                                                              newValue) {
                                                            if (newValue !=
                                                                null) {
                                                              setState(() {
                                                                selectedService =
                                                                    newValue;
                                                                selectedServiceCode =
                                                                    serviceCodes[
                                                                        serviceNames
                                                                            .indexOf(newValue)]!;
                                                                // print("Selected service: $selectedService, Code: $selectedServiceCode");
                                                                print(
                                                                    '+++++++');
                                                                print(
                                                                    selectedService);
                                                                print(
                                                                    '+++++++');
                                                                filterClothNames(
                                                                    selectedService);
                                                              });
                                                            }
                                                          },
                                                          value:
                                                              selectedService,
                                                          menuMaxHeight: 300.0,
                                                          items: serviceNames.map<
                                                                  DropdownMenuItem<
                                                                      String?>>(
                                                              (String? value) {
                                                            return DropdownMenuItem<
                                                                String?>(
                                                              value: value,
                                                              child: Text(
                                                                  value ?? ""),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 20),

                                                  // DropdownButton<String>(
                                                  //   value: clothNames.isNotEmpty ? clothNames[0] : null,
                                                  //   onChanged: ( newValue) {
                                                  //    print('newValue');
                                                  //   },
                                                  //   items: clothNames.map<DropdownMenuItem<String>>((String value) {
                                                  //     return DropdownMenuItem<String>(
                                                  //       value: value,
                                                  //       child: Text(value), // Display cloth name as the dropdown item
                                                  //     );
                                                  //   }).toList(),
                                                  // ),

                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Cloth Type:',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily: GoogleFonts
                                                                  .openSans()
                                                              .fontFamily,
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
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Row(
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              // Decrease quantity
                                                              int currentQuantity = int.tryParse(quantity) ?? 0;
                                                              if (currentQuantity > 0) {
                                                                setState(() {
                                                                  quantity = (currentQuantity - 1).toString();
                                                                });
                                                              }
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              primary: Color(0xFF301C93),
                                                              onPrimary: Colors.white,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(8.0),
                                                              ),
                                                            ),
                                                            child: Icon(Icons.remove),
                                                          ),
                                                          SizedBox(width: 10,),
                                                          Expanded(
                                                            child: TextField(
                                                              controller: TextEditingController(text: quantity),
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  quantity = value;
                                                                });
                                                              },
                                                              readOnly: true,
                                                              textAlign: TextAlign.center,
                                                              keyboardType: TextInputType.number,
                                                              decoration: InputDecoration(
                                                                filled: true,
                                                                fillColor: Color(0xFFF9F9F9),
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                ),
                                                                hintText: 'Enter a quantity',
                                                                contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10,),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              // Increase quantity
                                                              int currentQuantity = int.tryParse(quantity) ?? 0;
                                                              setState(() {
                                                                quantity = (currentQuantity + 1).toString();
                                                              });
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              primary: Color(0xFF301C93),
                                                              onPrimary: Colors.white,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(8.0),
                                                              ),
                                                            ),
                                                            child: Icon(Icons.add,),
                                                          ),
                                                        ],
                                                      ),
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
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Billing:',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily: GoogleFonts
                                                                  .openSans()
                                                              .fontFamily,
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
                                                        child: DropdownButton<
                                                            String>(
                                                          isExpanded: true,
                                                          value:
                                                              selectedBilling,
                                                          onChanged: (String?
                                                              newValue) {
                                                            setState(() {
                                                              selectedBilling =
                                                                  newValue!;
                                                            });
                                                          },
                                                          items: billingOptions
                                                              .map((String
                                                                  value) {
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value: value,
                                                              child:
                                                                  Text(value),
                                                            );
                                                          }).toList(),
                                                          hint: Text(
                                                              'Select a billing type'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  dividerH(),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    width: double.infinity,
                                                    // Full width
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      color: Color(0xFF301C93),
                                                    ),
                                                    child: TextButton(
                                                      onPressed: () async {
                                                        // if (state.response.pickupOrderId == null) {
                                                        // print("Selected service: $selectedService");
                                                        // print("Selected cloth: $selectedCloth");
                                                        // print("Quantity: $quantity");

                                                        // Define an async function to fetch the priceId
                                                        Future<void>
                                                            fetchPriceId() async {
                                                          try {
                                                            int priceId =
                                                                await getPriceId(
                                                                    '$selectedService',
                                                                    '$selectedCloth');
                                                            setState(() {
                                                              PRICEID = priceId;
                                                            });
                                                          } catch (e) {
                                                            print('Error: $e');
                                                          }
                                                        }

                                                        await fetchPriceId();

                                                        try {
                                                          Map<String, dynamic>
                                                              clothDetails =
                                                              await fetchClothDetails(
                                                                  '$selectedCloth');
                                                          String
                                                              clothNameArabic =
                                                              clothDetails[
                                                                  'clothNameArabic'];
                                                          String clothImg =
                                                              clothDetails[
                                                                  'clothImg'];
                                                          setState(() {
                                                            ClothNameArabic =
                                                                clothNameArabic;
                                                            ClothImage =
                                                                clothImg;
                                                          });
                                                        } catch (e) {
                                                          print(
                                                              'Error fetching cloth details: $e');
                                                        }

                                                        //print('{"priceId": $PRICEID,"clothName": $selectedCloth,"arabicName": $ClothNameArabic,"clothImg": $ClothImage,"qnty": $quantity,"service": $selectedServiceCode,"billing": $selectedBilling }');

                                                        // Print the data to be added to clothdate list
                                                        Map<String, dynamic>
                                                            clothData = {
                                                          "priceId": PRICEID,
                                                          "clothName":
                                                              selectedCloth,
                                                          "arabicName":
                                                              ClothNameArabic,
                                                          "clothImg":
                                                              ClothImage,
                                                          "qnty": quantity,
                                                          "service":
                                                              selectedServiceCode,
                                                          "billing":
                                                              selectedBilling
                                                        };
                                                        print(clothData);


                                                        if (selectedCloth == null) {
                                                          // Assuming Essyloadinf.navigate is a method to show an error or navigate to a different page
                                                          EasyLoading.showToast( "Please Select Cloth");

                                                        } else {
                                                          saveDataToClothDate(clothData);
                                                          EasyLoading.showToast("Items Added Successfully");
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                        // Save data to clothdate list
                                                        // saveDataToClothDate(
                                                        //     clothData);

                                                        // Print a separator for readability
                                                        print(
                                                            '-------------------');
                                                        print(
                                                            clothdate); // Print the clothdate list
                                                        print(
                                                            '-------------------');

                                                        // setState(() {
                                                        //   selectedService = "";
                                                        //
                                                        //   quantity = "";
                                                        //   selectedBilling = "Express";
                                                        // });

                                                      },

                                                      // },

                                                      child: Text(
                                                        'Submit',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily: GoogleFonts
                                                                  .openSans()
                                                              .fontFamily,
                                                        ),
                                                      ),
                                                    ),
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
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Color(0xFF301C93), // Button background color
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    15), // Button border radius
                              ),
                            ),
                            child: Text(
                              'ADD ITEMS',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: GoogleFonts.openSans().fontFamily,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),


                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: clothdate.length,
                        itemBuilder: (context, index) {
                          var clothData = clothdate[index];

                          if (clothdate.isEmpty) {
                            print('emplty');
                          }
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 0),
                            child: Card(
                              child: ListTile(
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
                                title: Text(
                                  clothData['clothName'],
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.openSans().fontFamily,
                                  ),
                                ),
                                subtitle: Text(
                                  clothData['arabicName'],
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.openSans().fontFamily,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    removeDataFromClothDate(index);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: clothdata_order.length,
                        itemBuilder: (context, index) {
                          var clothdata_orders = clothdata_order[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 0),
                            child: Card(
                              child: ListTile(
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
                                title: Text(
                                  clothdata_order[index]["clothName"],
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.openSans().fontFamily,
                                  ),
                                ),
                                subtitle: Text(
                                  clothdata_orders['arabicName'],
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.openSans().fontFamily,
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



                     //count kanikkunnath
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: clothMap.length,
                        itemBuilder: (context, index) {
                          var cloth = clothMap.values.elementAt(index);
                          var clothName = cloth['clothName'];
                          var count = clothNameCount[clothName] ?? 0;

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
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
                                  '$clothName',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.openSans().fontFamily,
                                  ),
                                ),
                                subtitle: Text(
                                  cloth['arabicName'],
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
                                //   },
                                // ),
                              ),
                            ),
                          );
                        },
                      ),



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
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  fetchCustomerDiscount(state.response.pickupCustomerId as String);
                                  if (state.response.pickupOrderId != null) {
                                    //
                                    // print(clothdate);
                                    // print('==-==');
                                    // print(clothdata_order_existing);

                                    postUpdateData(
                                        '${state.response.pickupOrderId}');

                                    //
                                    // print('${state.response.pickupOrderId}');
                                    //
                                    // print(clothdata_order_existing);

                                    // print(
                                    //
                                    //
                                    //
                                    //
                                    //     {
                                    //       "userName": username_x,
                                    //       "vatValue": 0,
                                    //       "quantity": totalQty,
                                    //       "subTotal": 0,
                                    //       "customerDiscount": 0,
                                    //       "discount": 0,
                                    //       "lastModifiedTime": formatedtime,
                                    //       "lastModifieddate": formateddate,
                                    //       "totalAmount": 0,
                                    //       "paidAmount": 0,
                                    //       "balance": 0,
                                    //       "clothData":clothdate,
                                    //       // "clothData": [
                                    //       //
                                    //       //   {
                                    //       //     "priceId": 106,
                                    //       //     "clothName": "T-SHIRT",
                                    //       //     "arabicName": "بلوزة",
                                    //       //     "clothPrice": "5.000",
                                    //       //     "clothImg": "https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg",
                                    //       //     "qnty": 2,
                                    //       //     "service": "DC",
                                    //       //     "billing": "Normal",
                                    //       //     "unit": "PCS"
                                    //       //   },
                                    //       //   {
                                    //       //     "priceId": 37,
                                    //       //     "clothName": "PILLOW COVER",
                                    //       //     "arabicName": "تقية",
                                    //       //     "clothPrice": "4.000",
                                    //       //     "clothImg": "https://apisys.s3.me-south-1.amazonaws.com/api/images/PILLOW_PROTECTOR.jpg",
                                    //       //     "qnty": 2,
                                    //       //     "service": "DC",
                                    //       //     "billing": "Normal",
                                    //       //     "unit": "PCS"
                                    //       //   },
                                    //       //
                                    //       //   {
                                    //       //     "arabicName": "ثوب ابيض",
                                    //       //     "billing": "Normal",
                                    //       //     "clothImg": "https://apisyss.s3.ap-south-1.amazonaws.com/api/images/THOPE_WHITE.jpg",
                                    //       //     "clothName": "THOBE WHITE",
                                    //       //     "clothPrice": "7.000",
                                    //       //     "priceId": 13,
                                    //       //     "qnty": 1,
                                    //       //     "service":"DC",
                                    //       //     "unit": "PCS"
                                    //       //   }
                                    //       // ]
                                    //     }
                                    // );

                                  } else {
                                    // ee post data on aaakanam ennaale new picup aavukayullu
                                    postData();
                                    //
                                  }

                                  //   {
                                  //     "pickupassgn_id": "67",
                                  //   "pickuporderTime": "12:39",
                                  //   "quantity": 2,
                                  //   "subTotal": 2000.0,
                                  //   "discount": 0.0,
                                  //   "totalAmount": 3000.0,
                                  //   "paidAmount": 0.0,
                                  //   "balance": 300.0,
                                  //   "deliveryType": "PICKUP & DELIVERY",
                                  //   "accountType": "MobileApp",
                                  //   "clothData": [
                                  //   {
                                  //   "priceId": 106,
                                  //   "clothName": "T-SHIRT",
                                  //   "arabicName": "بلوزة",
                                  //   "clothPrice": "10.000",
                                  //   "clothImg": "https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg",
                                  //   "qnty": 1,
                                  //   "service": "DC",
                                  //   "billing": "Express"
                                  //   },
                                  //   {
                                  //   "priceId": 106,
                                  //   "clothName": "T-SHIRT",
                                  //   "arabicName": "بلوزة",
                                  //   "clothPrice": "5.000",
                                  //   "clothImg": "https://apisys.s3.me-south-1.amazonaws.com/api/images/T-SHIRT.jpg",
                                  //   "qnty": 1,
                                  //   "service": "DC",
                                  //   "billing": "Normal"
                                  //   }
                                  //   ]
                                  // }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(10.0),
                                  primary: Color(0xFF301C93),
                                  // Background color
                                  onPrimary: Colors.white,
                                  // Text color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Border radius
                                  ),
                                ),
                                child: Text(
                                  'Collect now',
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.openSans().fontFamily,
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
                                        fontSize: 13,
                                        fontFamily:
                                            GoogleFonts.openSans().fontFamily,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF301C93),
                                      ),
                                    ),
                                    SizedBox(width: 30),
                                    Text(
                                      'QTY : $totalQty',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontFamily:
                                            GoogleFonts.openSans().fontFamily,
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
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.home,
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.car_crash,
                    ),
                    label: 'Pickup',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.car_crash,
                    ),
                    label: 'Delivery',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.compare_arrows,
                    ),
                    label: 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.person,
                    ),
                    label: 'Me',
                  ),
                ],
                selectedItemColor: Color(0xFF301C93),
                selectedFontSize:
                    12.0, // Adjust the font size for the selected item
                unselectedFontSize:
                    12.0, // Adjust the font size for unselected items
                iconSize: 26.0, // Adjust the icon size
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
                          'Taj Muhammed',
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
                      'Collect now',
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
    final url = 'https://be.syswash.net/api/syswash/customerdetails/$cus_id?code=A';
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
        'https://be.syswash.net/api/syswash/clothdetails?code=A';

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

    double subTotal = 0.0;
    for (var cloth in convertedClothData) {
      final priceId = cloth['priceId'];
      final priceDetails = await fetchPriceDetails(priceId);
      print(priceDetails);
      if (priceDetails != null) {
        double price = double.parse(priceDetails['price']);
        cloth['price'] = price;
        subTotal += price;
        print(cloth['price']);
      }
    }


    var dataprint ={
      "pickupassgn_id": pickupassgnIdNum,
      "pickuporderTime": formatedtime,
      "quantity": totalQty,
      "subTotal": subTotal,
      "discount": customerDiscount,
      "totalAmount": (subTotal-customerDiscount),
      "paidAmount": 0.0,
      "balance": 0.0,
      "deliveryType": "PICKUP & DELIVERY",
      "accountType": "MobileApp",
      "clothData": convertedClothData,
    };

    var response = await http.Client().post(
      Uri.parse('https://be.syswash.net/api/syswash/pickuporder?code=A'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $userToken"
      },
      body: jsonEncode(dataprint),
    );

    if (response.statusCode == 200) {
      AppSp().setLastAddedItemOrder(pickupassgnId.toString());
      EasyLoading.showToast("Data Added Successfull");
      clothdate.clear();
      Navigator.pushNamed(context, "/pickupOrderListing");
    } else {
      // If request failed, handle the error
      print('Failed to post data: ${response.statusCode}');
    }
  }





  Future<Map<String, dynamic>?> fetchPriceDetails(int priceId) async {
    final url = 'https://be.syswash.net/api/syswash/pricedetails/$priceId?code=A';
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

  Future<void> postUpdateData(String order_id) async {
    print('https://be.syswash.net/api/syswash/order/$order_id?code=A');
    var pickupassgnIdNum = int.tryParse(pickupassgnId);

    // Convert 'qnty' strings to integers, keeping other fields unchanged
    List<Map<String, dynamic>> convertedClothData = clothdate.map((item) {
      var qntyInt = int.tryParse(item['qnty'] ?? '0') ?? 0;
      return {
        ...item,
        'qnty': qntyInt,
      };
    }).toList();
    List<Map<String, dynamic>> combinedClothData = [];
    combinedClothData.addAll(convertedClothData);
    combinedClothData.addAll(clothdata_order_existing);


    double subTotal = 0.0;
    for (var cloth in convertedClothData) {
      final priceId = cloth['priceId'];
      final priceDetails = await fetchPriceDetails(priceId);
      print(priceDetails);
      if (priceDetails != null) {
        double price = double.parse(priceDetails['price']);
        cloth['price'] = price;
        subTotal += price;
        print(cloth['price']);
      }
    }
    var dataprint =
    {
      "userName": username_x,
      "vatValue": 0,
      "quantity": totalQty,
      "subTotal": subTotal,
      "customerDiscount": customerDiscount,
      "discount": customerDiscount,
      "lastModifiedTime": formatedtime,
      "lastModifieddate": formateddate,
      "totalAmount": (subTotal-customerDiscount),
      "paidAmount": 0,
      "balance": 0,
      "clothData": combinedClothData
    };

    var response = await http.Client().put(
      Uri.parse('https://be.syswash.net/api/syswash/order/$order_id?code=A'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $userToken"
      },
      body: jsonEncode(dataprint),
    );

    if (response.statusCode == 200) {
      print(response.body);
      AppSp().setLastAddedItemOrder(pickupassgnId.toString());
      EasyLoading.showToast("Data Added Succesfully");
      clothdate.clear();
      Navigator.pushNamed(context, "/pickupOrderListing");
    } else {
      // If request failed, handle the error
      print('Failed to post data: ${response.statusCode}');
    }
  }

  // Future<void> postUpdateData(String order_id) async {
  //   print('https://be.syswash.net/api/syswash/order/$order_id?code=A');
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
  //   List<Map<String, dynamic>> combinedClothData = [];
  //   combinedClothData.addAll(convertedClothData);
  //   combinedClothData.addAll(clothdata_order_existing);
  //
  //   var response = await http.Client().put(
  //     Uri.parse('https://be.syswash.net/api/syswash/order/$order_id?code=A'),
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Accept": "application/json",
  //       "Authorization": "Bearer $userToken"
  //     },
  //     body: jsonEncode({
  //       "userName": username_x,
  //       "vatValue": 0,
  //       "quantity": totalQty,
  //       "subTotal": 0,
  //       "customerDiscount": 0,
  //       "discount": 0,
  //       "lastModifiedTime": formatedtime,
  //       "lastModifieddate": formateddate,
  //       "totalAmount": 0,
  //       "paidAmount": 0,
  //       "balance": 0,
  //       "clothData": combinedClothData
  //     }),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     print(response.body);
  //     AppSp().setLastAddedItemOrder(pickupassgnId.toString());
  //     EasyLoading.showToast( "Data Added Succesfully");
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
