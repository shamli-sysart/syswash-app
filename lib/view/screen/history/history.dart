import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shimmer/shimmer.dart';

import '../../../service/api_service.dart';
import '../../../utils/app_constant.dart';
import '../../../utils/app_sp.dart';
import 'bloc/history_bloc.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 3;

  late HistoryBloc _historyBloc;
  String tokenID = '';
  String userToken = "";
  String companyCode = "";
  String userID = "";
  String LoggerUsername = "";

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _historyBloc = HistoryBloc(ApiService());
    getUserToken();
  }

  Future<void> getUserToken() async {
    AppSp appSp = AppSp();
    userToken = await appSp.getToken();
    companyCode = await appSp.getCompanyCode();
    LoggerUsername = await appSp.getUserName();
    userID = await appSp.getUserID();
    _historyBloc.add(HistoryApiEvent(userToken, companyCode, userID));
  }

  List<dynamic>? _getFilteredOrders(List<dynamic>? orders, bool isPickup) {
    if (_searchQuery.isEmpty) {
      return orders;
    } else {
      return orders
          ?.where((order) => (isPickup
          ? order?.pickupCustomerName
          : order?.deliveryassgn?[0]?.deliveryCustomerName)
          ?.toLowerCase()
          .contains(_searchQuery.toLowerCase()) ??
          false)
          .toList();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  void dispose() {
    _historyBloc.close();
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _historyBloc,
      child: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            if (state is LoadedState) {
              var pickuporders = state.response.pickup;
              var deliveries = state.response.delivery;

              deliveries?.sort((a, b) {
                var aNum = num.tryParse((a.orderId ?? '').toString()) ?? 0;
                var bNum = num.tryParse((b.orderId ?? '').toString()) ?? 0;
                return bNum.compareTo(aNum);
              });

              pickuporders?.sort((a, b) {
                var aNum = num.tryParse((a.pickupassgnId ?? '').toString()) ?? 0;
                var bNum = num.tryParse((b.pickupassgnId ?? '').toString()) ?? 0;
                return bNum.compareTo(aNum);
              });

              var filteredPickupOrders = _getFilteredOrders(pickuporders, true);
              var filteredDeliveryOrders = _getFilteredOrders(deliveries, false);


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
                              'History',
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
                              icon: Icon(Icons.west_sharp,  size:  MediaQuery.of(context).size.width * 0.050, color: Color(0xFF524B6B)),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              children: [
                                TabBar(
                                  controller: _tabController,
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.black,
                                  indicatorColor: Colors.white,
                                  labelStyle: TextStyle(
                                      fontSize:   MediaQuery.of(context).size.width * 0.040,
                                      fontWeight: FontWeight.bold),
                                  unselectedLabelStyle: TextStyle( fontSize:   MediaQuery.of(context).size.width * 0.040,),
                                  indicator: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8), // Adjust as needed
                                      color:  Color(0xFF68188B),
                                  ),

                                  tabs: [
                                    Container(
                                      height: 40,
                                      child:   Tab(text: 'Pickup',),),
                                    Container(
                                      height: 40,
                                      child:   Tab(text: 'Delivery',),),


                                  ],
                                ),
                                SizedBox(height: 10,),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: Offset(0, 3), // changes position of shadow
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
                                  child: TabBarView(

                                    controller: _tabController,
                                    children: [
                                      ListView.builder(
                                        itemCount: filteredPickupOrders?.length ?? 0,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin: const EdgeInsets.symmetric(vertical: 2.0),
                                            // decoration: BoxDecoration(
                                            //   boxShadow: [
                                            //     BoxShadow(
                                            //       color: Colors.grey.withOpacity(0.1),
                                            //       spreadRadius: 1,
                                            //       blurRadius: 1,
                                            //       offset: Offset(0, 1), // changes position of shadow
                                            //     ),
                                            //   ],
                                            //
                                            // ),

                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 15.0),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            filteredPickupOrders?[index]
                                                                .pickupCustomerName ??
                                                                'Unknown',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 14.0,
                                                              fontFamily: GoogleFonts.dmSans().fontFamily,
                                                              color: Color(0xFF150B3D),
                                                            ),
                                                          ),
                                                          SizedBox(height: 5.0),
                                                          Text(
                                                            filteredPickupOrders?[index]
                                                                .pickupstatus ??
                                                                'Unknown',
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
                                                                filteredPickupOrders?[index]
                                                                    .pickupCustomerArea ??
                                                                    'Unknown',
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
                                                                filteredPickupOrders?[index]
                                                                    .pickupDate ??
                                                                    'Unknown',
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
                                          );
                                        },
                                      ),
                                      ListView.builder(
                                        itemCount:filteredDeliveryOrders?.length ?? 0,
                                        itemBuilder: (context, index) {

                                          return Container(
                                            margin: const EdgeInsets.symmetric(vertical: 2.0),
                                            // decoration: BoxDecoration(
                                            //   boxShadow: [
                                            //     BoxShadow(
                                            //       color: Colors.grey.withOpacity(0.2),
                                            //       spreadRadius: 1,
                                            //       blurRadius: 5,
                                            //       offset: Offset(0, 3), // changes position of shadow
                                            //     ),
                                            //   ],
                                            // ),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 15.0),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            filteredDeliveryOrders![index].deliveryassgn?[0]?.deliveryCustomerName ?? 'Unknown',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 14.0,
                                                              fontFamily: GoogleFonts.dmSans().fontFamily,
                                                              color: Color(0xFF150B3D),
                                                            ),
                                                          ),
                                                          SizedBox(height: 5.0),


                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                filteredDeliveryOrders![index].deliveryassgn?[0]?.status ?? 'Unknown',
                                                                style: TextStyle(
                                                                  fontSize: 12.0,
                                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                                ),
                                                              ),
                                                              Text(
                                                                filteredDeliveryOrders![index].deliveryassgn?[0]?.paymentstatus?.toUpperCase() ?? 'Unknown',
                                                                style: TextStyle(
                                                                  fontSize: 12.0,
                                                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                                                  color: filteredDeliveryOrders![index].deliveryassgn?[0]?.paymentstatus == 'collected' ? Colors.green : Colors.red,
                                                                ),
                                                              ),




                                                            ],
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
                                                                filteredDeliveryOrders![index].deliveryassgn?[0]?.deliveryCustomerArea ?? 'Unknown',
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
                                                                '${filteredDeliveryOrders![index].deliveryassgn?[0]?.deliveryDate ?? 'Unknown'} ${deliveries![index].deliveryassgn?[0]?.deliveryTime ?? 'Unknown'}',
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
                // SizedBox(height:40 ),
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
                      'History',
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
                      icon: Icon(Icons.west_sharp,  size:  MediaQuery.of(context).size.width * 0.050, color: Color(0xFF524B6B)),
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

}