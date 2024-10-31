import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../service/api_service.dart';
import '../../../../utils/app_constant.dart';
import '../../../../utils/app_sp.dart';
import 'bloc/delivery_listing_bloc.dart';

class Delivery extends StatefulWidget {
  const Delivery({super.key});

  @override
  State<Delivery> createState() => _DeliveryState();
}

class _DeliveryState extends State<Delivery> {
  late DeliveryListingBloc _deliveryListingBloc;

  String tokenID = '';
  String userToken = "";
  String companyCode = "";
  String userID = "";
  String LoggerUsername = "";
  String lastAddedCustomerID = "";

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _deliveryListingBloc = DeliveryListingBloc(ApiService());
    getUserToken();
  }

  Future<void> getUserToken() async {
    AppSp appSp = AppSp();
    userToken = await appSp.getToken();
    companyCode = await appSp.getCompanyCode();
    LoggerUsername = await appSp.getUserName();
    userID = await appSp.getUserID();
    _deliveryListingBloc.add(DeliveryListingApiEvent(userToken, companyCode, userID));
    lastAddedCustomerID = await appSp.getLastDelivery();
    print("Last Added Customer ID: $lastAddedCustomerID");
  }

  List<dynamic>? _getFilteredOrders(List<dynamic>? orders) {
    if (_searchQuery.isEmpty) {
      return orders;
    } else {
      return orders?.where((order) =>
      order?.deliveryCustomerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false
      ).toList();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  void dispose() {
    _deliveryListingBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _deliveryListingBloc,
      child: BlocBuilder<DeliveryListingBloc, DeliveryListingState>(
          builder: (context, state) {
            if (state is LoadedState) {
              var orders = state.response.data;
              int lastAddedCustomerIDNum = int.tryParse(lastAddedCustomerID) ?? 0;

              var filteredOrders = orders?.where((order) => order.status != 'Delivered').toList();
              var specificOrder = filteredOrders?.where((order) => order.deliveryassgnId == lastAddedCustomerIDNum).toList();
              var otherOrders = filteredOrders?.where((order) => order.deliveryassgnId != lastAddedCustomerIDNum).toList();

              otherOrders?.sort((a, b) {
                var aNum = num.tryParse((a.deliveryassgnId ?? '').toString()) ?? 0;
                var bNum = num.tryParse((b.deliveryassgnId ?? '').toString()) ?? 0;
                return bNum.compareTo(aNum);
              });

              var deliveryOrders = [...?specificOrder, ...?otherOrders];
              var filteredDeliveryOrders = _getFilteredOrders(deliveryOrders);

              return SafeArea(
                child: Scaffold(
                  backgroundColor: Color(0xFFEFEEF3),
                  body: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              LoggerUsername,
                              style: TextStyle(
                                color: Color(0xFF000000),
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontSize: MediaQuery.of(context).size.width * 0.057,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Image.asset(bell,height: 35,width: 35,),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Delivery Customers',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.040,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF63629C),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/dashHome");
                              },
                              icon: Icon(Icons.west_sharp, size:  MediaQuery.of(context).size.width * 0.050, color: Color(0xFF524B6B)),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
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
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Search...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredDeliveryOrders?.length ?? 0,
                            itemBuilder: (context, index) {
                              var order = filteredDeliveryOrders?[index];
                              var isLastAddedOrder = order?.deliveryassgnId == lastAddedCustomerIDNum;
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 5.0),
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
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/customDetailsDelivery",
                                      arguments: {
                                        'deliveryInvoiceNo': order?.deliveryInvoiceNo.toString(),
                                        'deliveryCustomerId': order?.deliveryCustomerId.toString() ?? 'Unknown',
                                      },
                                    );
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          SizedBox(width: 15.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      order?.deliveryCustomerName ?? 'Unknown',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14.0,
                                                        fontFamily: GoogleFonts.dmSans().fontFamily,
                                                        color: Color(0xFF150B3D),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5.0),
                                                Text(
                                                  order?.deliveryCustomerPhno?.toString() ?? 'Unknown',
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontFamily: GoogleFonts.openSans().fontFamily,
                                                    color: Color(0xFF524B6B),
                                                  ),
                                                ),
                                                SizedBox(height: 5.0),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 16.0,
                                                      color: Color(0xFFC7C7CC),
                                                    ),
                                                    SizedBox(width: 5.0),
                                                    Text(
                                                      order?.deliveryCustomerArea ?? 'Unknown',
                                                      style: TextStyle(
                                                        fontSize: 9.0,
                                                        fontFamily: GoogleFonts.poppins().fontFamily,
                                                        color: Color(0xFF000000),
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10.0),
                                                    Icon(
                                                      Icons.access_time,
                                                      size: 16.0,
                                                      color: Color(0xFFC7C7CC),
                                                    ),
                                                    SizedBox(width: 5.0),
                                                    Text(
                                                      '${order?.deliveryDate ?? ''} (${order?.deliveryTime ?? ''})',
                                                      style: TextStyle(
                                                        fontSize: 9.0,
                                                        fontFamily: GoogleFonts.poppins().fontFamily,
                                                        color: Color(0xFF000000),
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
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
                            },
                          ),
                        ),
                      ],
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
          }),
    );
  }

  ////old code////////
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => _deliveryListingBloc,
//       child: BlocBuilder<DeliveryListingBloc, DeliveryListingState>(
//           builder: (context, state) {
//             if (state is LoadedState) {
//               // var pickuporders = state.response.data;
//               print("---------------------------------");
//               // print(pickuporders);
//               // pickuporders?.sort((a, b) {
//               //   var aNum =
//               //       num.tryParse((a.deliveryInvoiceNo ?? '').toString()) ?? 0;
//               //   var bNum =
//               //       num.tryParse((b.deliveryInvoiceNo ?? '').toString()) ?? 0;
//               //   return bNum.compareTo(aNum);
//               // });
//
//               //
//               //
//               // var pickupordersx = state.response.data;
//               // int lastAddedCustomerIDNum = int.tryParse(lastAddedCustomerID) ?? 0;
//               //
//               // var specificOrder = pickupordersx?.where((order) => order.deliveryassgnId == lastAddedCustomerIDNum).toList();
//               // var otherOrders = pickupordersx?.where((order) => order.deliveryassgnId != lastAddedCustomerIDNum).toList();
//               //
//               //
//               //   otherOrders?.sort((a, b) {
//               //     var aNum =
//               //         num.tryParse((a.deliveryassgnId ?? '').toString()) ?? 0;
//               //     var bNum =
//               //         num.tryParse((b.deliveryassgnId ?? '').toString()) ?? 0;
//               //     return bNum.compareTo(aNum);
//               //   });
//               //
//               //
//               // var pickuporders = [...?specificOrder, ...?otherOrders];
//
//
//
//               var pickupordersx = state.response.data;
//               print(pickupordersx);
//               int lastAddedCustomerIDNum = int.tryParse(lastAddedCustomerID) ?? 0;
//
// // Filter out orders that have the status "Delivered"
//               var filteredOrders = pickupordersx?.where((order) => order.status != 'Delivered').toList();
//
// // Separate the specific order and other orders based on the delivery assignment ID
//               var specificOrder = filteredOrders?.where((order) => order.deliveryassgnId == lastAddedCustomerIDNum).toList();
//               var otherOrders = filteredOrders?.where((order) => order.deliveryassgnId != lastAddedCustomerIDNum).toList();
//
// // Sort the other orders by delivery assignment ID in descending order
//               otherOrders?.sort((a, b) {
//                 var aNum = num.tryParse((a.deliveryassgnId ?? '').toString()) ?? 0;
//                 var bNum = num.tryParse((b.deliveryassgnId ?? '').toString()) ?? 0;
//                 return bNum.compareTo(aNum);
//               });
//
// // Combine specificOrder and otherOrders into pickuporders
//               var pickuporders = [...?specificOrder, ...?otherOrders];
//
//               print(pickuporders);
//
//
//
//               return SafeArea(
//                 child: Scaffold(
//                   backgroundColor: Color(0xFFEFEEF3),
//                   body: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: 10),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   '$LoggerUsername',
//                                   style: TextStyle(
//                                       fontSize: 24,
//                                       fontFamily: GoogleFonts.openSans().fontFamily,
//                                       fontWeight: FontWeight.normal,
//                                       color: Color(0xFF000000)),
//                                 ),
//                               ],
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.notifications_outlined,
//                                   size: 45, color: Color(0xFF301C93)),
//                               onPressed: () {
//                                 // Add your onPressed logic here
//                               },
//                             ),
//                           ],
//                         ),
//
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Delivery Customers',
//                               style: TextStyle(
//                                   fontSize: 23,
//                                   fontFamily: GoogleFonts.openSans().fontFamily,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF301C93)),
//                             ),
//                             TextButton.icon(
//                               icon: Icon(Icons.arrow_back_outlined,
//                                   size: 22, color: Color(0xFF301C93)),
//                               label: Text('Back',
//                                   style: TextStyle(
//                                     color: Color(0xFF301C93),
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 20,
//                                     fontFamily: GoogleFonts.openSans().fontFamily,
//                                   )),
//                               onPressed: () {
//                                 Navigator.pushNamed(context, "/dashHome");
//                               },
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 5),
//                         Expanded(
//                           child: ListView.builder(
//                             itemCount: pickuporders?.length,
//                             itemBuilder: (context, index) {
//
//                               var order = pickuporders?[index];
//
//                               var isLastAddedOrder = order?.deliveryassgnId == lastAddedCustomerIDNum;
//
//                               return Container(
//                                 margin: EdgeInsets.symmetric(
//                                     vertical:
//                                     5.0), // Add margin for spacing between cards
//                                 decoration: BoxDecoration(
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.grey
//                                           .withOpacity(0.5), // Shadow color
//                                       spreadRadius: 2, // Spread radius
//                                       blurRadius: 5, // Blur radius
//                                       offset:
//                                       Offset(0, 3), // Offset in x and y axes
//                                     ),
//                                   ],
//                                 ),
//                                 child: GestureDetector(
//
//                                   // onTap: () {
//                                   //   Navigator.pushNamed(
//                                   //     context,
//                                   //     "/customer_details",
//                                   //     arguments: {
//                                   //       'pickupassgnId': pickuporders?[index].pickupassgnId.toString(),
//                                   //       'pickupCustomerId': pickuporders?[index].pickupCustomerId.toString() ?? 'Unknown',
//                                   //     },
//                                   //   );
//                                   // },
//                                   //
//                                   onTap: () {
//                                     Navigator.pushNamed(
//                                         context,
//                                         "/customDetailsDelivery",
//                                         arguments:{
//                                           'deliveryInvoiceNo' : pickuporders?[index].deliveryInvoiceNo.toString() ,
//                                           'deliveryCustomerId' : pickuporders?[index].deliveryCustomerId.toString() ?? 'Unknown',
//
//
//                                         }
//
//
//                                     );
//                                   },
//
//
//
//                                   // onTap: () {
//                                   //   Navigator.pushNamed(
//                                   //     context,
//                                   //     "/customDetailsDelivery",
//                                   //     arguments: pickuporders?[index].deliveryInvoiceNo.toString() ?? 'Unknown',
//                                   //
//                                   //   );
//                                   // },
//                                   child: Card(
//                                     child: Padding(
//                                       padding: EdgeInsets.all(8.0),
//                                       child: Row(
//                                         children: [
//                                           // CircleAvatar(m
//                                           //   radius: 30, // Increase radius for larger avatar
//                                           //   backgroundImage: AssetImage('assets/avatar.png'), // Provide your image path
//                                           // ),
//                                           SizedBox(
//                                               width:
//                                               15.0), // Add spacing between avatar and text
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                               children: [
//
//
//                                                 Row(
//                                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                   children: [
//                                                     Text(
//                                                       order?.deliveryCustomerName ?? 'Unknown',
//                                                       style: TextStyle(
//                                                         fontWeight: FontWeight.bold,
//                                                         fontSize: 18.0,
//                                                         fontFamily: GoogleFonts.openSans().fontFamily,
//                                                         color: Color(0xFF301C93),
//                                                       ),
//                                                     ),
//                                                     // if (isLastAddedOrder)
//                                                     //   Container(
//                                                     //     padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//                                                     //     decoration: BoxDecoration(
//                                                     //         color: Color(0xFF301C93),
//                                                     //       borderRadius: BorderRadius.circular(12.0),
//                                                     //     ),
//                                                     //     child: Text(
//                                                     //       'Delivered',
//                                                     //       style: TextStyle(
//                                                     //         color: Colors.white,
//                                                     //         fontWeight: FontWeight.bold,
//                                                     //         fontSize: 12.0,
//                                                     //       ),
//                                                     //     ),
//                                                     //   ),
//                                                   ],
//                                                 ),
//
//                                                 // Text(
//                                                 //   pickuporders?[index]
//                                                 //           .deliveryCustomerName ??
//                                                 //       '  ',
//                                                 //   style: TextStyle(
//                                                 //     fontWeight: FontWeight.bold,
//                                                 //     fontSize: 15.0,
//                                                 //     fontFamily:
//                                                 //         GoogleFonts.openSans()
//                                                 //             .fontFamily,
//                                                 //     color: Color(0xFF301C93),
//                                                 //   ),
//                                                 // ),
//                                                 SizedBox(height: 5.0),
//                                                 Text(
//                                                   pickuporders![index]
//                                                       .deliveryCustomerPhno
//                                                       .toString(),
//                                                   style: TextStyle(
//                                                     fontSize: 13.0,
//                                                     fontFamily:
//                                                     GoogleFonts.openSans()
//                                                         .fontFamily,
//                                                   ),
//                                                 ),
//                                                 SizedBox(height: 5.0),
//                                                 Row(
//                                                   children: [
//                                                     Icon(
//                                                       Icons.location_on,
//                                                       size: 16.0,
//                                                       color: Colors.red,
//                                                     ),
//                                                     SizedBox(width: 5.0),
//                                                     Text(
//                                                       pickuporders?[index]
//                                                           .deliveryCustomerArea ??
//                                                           ' ',
//                                                       style: TextStyle(
//                                                         fontSize: 13.0,
//                                                         fontFamily:
//                                                         GoogleFonts.openSans()
//                                                             .fontFamily,
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                         width:
//                                                         10.0), // Adjust spacing between location and time
//                                                     Icon(
//                                                       Icons.access_time,
//                                                       size: 16.0,
//                                                       color: Colors.red,
//                                                     ),
//                                                     SizedBox(width: 5.0),
//                                                     Text(
//                                                       pickuporders?[index]
//                                                           .deliveryTime ??
//                                                           ' ',
//                                                       style: TextStyle(
//                                                         fontSize: 13.0,
//                                                         fontFamily:
//                                                         GoogleFonts.openSans()
//                                                             .fontFamily,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   bottomNavigationBar: BottomNavigationBar(
//                     currentIndex: _currentIndex,
//                     onTap: _onItemTapped,
//                     type: BottomNavigationBarType.fixed,
//                     items: [
//                       BottomNavigationBarItem(
//                         icon: Icon(
//                           Icons.home,
//                         ),
//                         label: 'Home',
//                       ),
//                       BottomNavigationBarItem(
//                         icon: Icon(
//                           Icons.car_crash,
//                         ),
//                         label: 'Pickup',
//                       ),
//                       BottomNavigationBarItem(
//                         icon: Icon(
//                           Icons.car_crash,
//                         ),
//                         label: 'Delivery',
//                       ),
//                       BottomNavigationBarItem(
//                         icon: Icon(
//                           Icons.compare_arrows,
//                         ),
//                         label: 'History',
//                       ),
//                       BottomNavigationBarItem(
//                         icon: Icon(
//                           Icons.person,
//                         ),
//                         label: 'Me',
//                       ),
//                     ],
//                     selectedItemColor: Color(0xFF301C93),
//                     selectedFontSize:
//                     12.0, // Adjust the font size for the selected item
//                     unselectedFontSize:
//                     12.0, // Adjust the font size for unselected items
//                     iconSize: 26.0, // Adjust the icon size
//                   ),
//                 ),
//               );
//             } else if (state is LoadingState) {
//               // return Center(
//               //   child: CircularProgressIndicator(),
//               // );
//               return _buildShimmerLoading();
//             } else {
//               return _buildShimmerLoading();
//             }
//           }),
//     );
//   }
  //// old code stop//////

  Widget _buildShimmerLoading() {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LoggerUsername,
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: MediaQuery.of(context).size.width * 0.057,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Image.asset(bell,height: 35,width: 35,),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivery Customers',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.040,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF63629C),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/dashHome");
                      },
                      icon: Icon(Icons.west_sharp, size:  MediaQuery.of(context).size.width * 0.050, color: Color(0xFF524B6B)),
                    ),
                  ],
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  direction: ShimmerDirection.ltr,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 0.3,
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