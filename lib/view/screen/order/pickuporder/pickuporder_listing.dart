import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../service/api_service.dart';
import '../../../../utils/app_sp.dart';
import 'bloc/pickup_order_listing_bloc.dart';

class PickupOrderListing extends StatefulWidget {
  const PickupOrderListing({super.key});

  @override
  State<PickupOrderListing> createState() => _PickupOrderListingState();
}

class _PickupOrderListingState extends State<PickupOrderListing> {
  late PickupOrderListingBloc _pickupOrderListingBloc;

  String tokenID = '';
  String userToken = "";
  String companyCode = "";
  String userID = "";
  String LoggerUsername = "";

  String lastAddedCustomerID = "";

  @override
  void initState() {
    super.initState();
    _pickupOrderListingBloc = PickupOrderListingBloc(ApiService());
    getUserToken();
  }

  Future<void> getUserToken() async {
    AppSp appSp = AppSp();
    userToken = await appSp.getToken();
    companyCode = await appSp.getCompanyCode();
    LoggerUsername = await appSp.getUserName();

    userID = await appSp.getUserID();
    _pickupOrderListingBloc.add(PickupOrderListingApiEvent(userToken, companyCode, userID));

    lastAddedCustomerID = await appSp.getLastAddedItemOrder();
    print("fdsfdsfsd===="+ lastAddedCustomerID);

  }

  @override
  void dispose() {
    _pickupOrderListingBloc.close();
    super.dispose();
  }

  int _currentIndex = 1;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _pickupOrderListingBloc,

      child: BlocBuilder<PickupOrderListingBloc, PickupOrderListingState>(
          builder: (context, state) {
        if (state is LoadedState) {
          // var pickuporders = state.response.pickup;
          // pickuporders?.sort((a, b) {
          //   var aNum = num.tryParse((a.pickupassgnId ?? '').toString()) ?? 0;
          //   var bNum = num.tryParse((b.pickupassgnId ?? '').toString()) ?? 0;
          //   return bNum.compareTo(aNum);
          // });


          var pickupordersx = state.response.pickup;
          int lastAddedCustomerIDNum = int.tryParse(lastAddedCustomerID) ?? 0;

          var specificOrder = pickupordersx?.where((order) => order.pickupassgnId == lastAddedCustomerIDNum).toList();
          var otherOrders = pickupordersx?.where((order) => order.pickupassgnId != lastAddedCustomerIDNum).toList();

          // Sort the other orders
          otherOrders?.sort((a, b) {
            var aNum = num.tryParse((a.pickupassgnId ?? '').toString()) ?? 0;
            var bNum = num.tryParse((b.pickupassgnId ?? '').toString()) ?? 0;
            return bNum.compareTo(aNum);
          });


          var pickuporders = [...?specificOrder, ...?otherOrders];

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
                        Row(
                          children: [

                            // SizedBox(width: 10),
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
                              size: 45, color: Color(0xFF301C93)),
                          onPressed: () {
                            // Add your onPressed logic here
                          },
                        ),
                      ],
                    ),
                    // SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Collect now',
                          style: TextStyle(
                              fontSize: 23,
                              fontFamily: GoogleFonts.openSans().fontFamily,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF301C93)),
                        ),
                        TextButton.icon(
                          icon: Icon(Icons.arrow_back_outlined,
                              size: 22, color: Color(0xFF301C93)),
                          label: Text('Back',
                              style: TextStyle(
                                color: Color(0xFF301C93),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                fontFamily: GoogleFonts.openSans().fontFamily,
                              )),
                          onPressed: () {
                            Navigator.pushNamed(context, "/dashHome");
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Expanded(
                      child: ListView.builder(
                        itemCount: pickuporders?.length,
                        itemBuilder: (context, index) {

                          var order = pickuporders?[index];
                          var isLastAddedOrder = order?.pickupassgnId == lastAddedCustomerIDNum;
                          return Container(
                            margin: EdgeInsets.symmetric(
                                vertical:
                                    5.0), // Add margin for spacing between cards
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.5), // Shadow color
                                  spreadRadius: 2, // Spread radius
                                  blurRadius: 5, // Blur radius
                                  offset:
                                      Offset(0, 3), // Offset in x and y axes
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  "/customer_details",
                                  arguments: {
                                    'pickupassgnId': pickuporders?[index].pickupassgnId.toString(),
                                    'pickupCustomerId': pickuporders?[index].pickupCustomerId.toString() ?? 'Unknown',
                                  },
                                );
                              },
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      // CircleAvatar(
                                      //   radius:
                                      //       30, // Increase radius for larger avatar
                                      //   backgroundImage: AssetImage(
                                      //       'assets/avatar.png'), // Provide your image path
                                      // ),
                                      SizedBox(
                                          width:
                                              15.0), // Add spacing between avatar and text
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [



                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  order?.pickupCustomerName ?? 'Unknown',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.0,
                                                    fontFamily: GoogleFonts.openSans().fontFamily,
                                                    color: Color(0xFF301C93),
                                                  ),
                                                ),
                                                if (isLastAddedOrder)
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF301C93),
                                                      borderRadius: BorderRadius.circular(12.0),
                                                    ),
                                                    child: Text(
                                                      'Item added',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12.0,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),




                                            // Text(
                                            //   pickuporders?[index].pickupCustomerName ?? 'Unknown',
                                            //   style: TextStyle(
                                            //     fontWeight: FontWeight.bold,
                                            //     fontSize: 15.0,
                                            //     fontFamily:
                                            //         GoogleFonts.openSans()
                                            //             .fontFamily,
                                            //     color: Color(0xFF301C93),
                                            //   ),
                                            // ),
                                            SizedBox(height: 5.0),
                                            Text(
                                              pickuporders?[index].pickupCustomerPhno.toString() ?? 'Unknown',
                                              style: TextStyle(
                                                fontSize: 13.0,
                                                fontFamily:
                                                    GoogleFonts.openSans()
                                                        .fontFamily,
                                              ),
                                            ),
                                            SizedBox(height: 5.0),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: 16.0,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 5.0),
                                                Text(
                                                  pickuporders?[index].pickupCustomerArea ?? 'Unknown',
                                                  style: TextStyle(
                                                    fontSize: 13.0,
                                                    fontFamily:
                                                        GoogleFonts.openSans()
                                                            .fontFamily,
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        10.0), // Adjust spacing between location and time
                                                Icon(
                                                  Icons.access_time,
                                                  size: 16.0,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 5.0),
                                                Text(
                                                  pickuporders?[index].pickupDate ?? 'Unknown',
                                                  style: TextStyle(
                                                    fontSize: 13.0,
                                                    fontFamily:
                                                        GoogleFonts.openSans()
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
            ),
          );
        } else if (state is LoadingState) {

          return _buildShimmerLoading();
        } else {
          return _buildShimmerLoading();
        }
      }),
    );
  }
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
                SizedBox(height:10 ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        //
                        // SizedBox(
                        //     width:
                        //     10),
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
                          size: 45, color: Color(0xFF301C93)),
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

                // const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Collect now',
                      style: TextStyle(
                          fontSize: 23,
                          fontFamily: GoogleFonts.openSans().fontFamily,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF301C93)),
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.arrow_back_outlined,
                          size: 22, color: Color(0xFF301C93)),
                      label: Text('Back',
                          style: TextStyle(
                            color: Color(0xFF301C93),
                            fontWeight: FontWeight.bold,
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
