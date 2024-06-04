
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../service/api_service.dart';
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


  @override
  void dispose() {
    _historyBloc.close();
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


              return SafeArea(
                child: Scaffold(
                  backgroundColor: Color(0xFFEFEEF3),
                  body: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        // SizedBox(height: 30),
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
                            // SizedBox(width: 0,)
                          ],
                        ),
                        // SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'History',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: GoogleFonts.openSans().fontFamily,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF301C93),
                                ),
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
                                  // Add your onPressed logic here
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                TabBar(
                                  controller: _tabController,
                                  tabs: [
                                    Tab(
                                      child: Text("Pickup", style: TextStyle(fontSize:20,color: Colors.black),),
                                    ),
                                    Tab(
                                      child: Text("Delivery", style: TextStyle(fontSize: 20,color: Colors.black,),),
                                    )
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(

                                    controller: _tabController,
                                    children: [
                                      ListView.builder(
                                        itemCount: pickuporders?.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 5,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Card(
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
                                                            pickuporders?[index]
                                                                .pickupCustomerName ??
                                                                'Unknown',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 18.0,
                                                              fontFamily: GoogleFonts.openSans().fontFamily,
                                                              color: const Color(0xFF301C93),
                                                            ),
                                                          ),
                                                          SizedBox(height: 5.0),
                                                          Text(
                                                            pickuporders?[index]
                                                                .pickupstatus ??
                                                                'Unknown',
                                                            style: TextStyle(
                                                              fontSize: 14.0,
                                                              fontFamily: GoogleFonts.openSans().fontFamily,
                                                            ),
                                                          ),
                                                          SizedBox(height: 5.0),
                                                          Row(
                                                            children: [
                                                              Icon(Icons.location_on, size: 16.0, color: Colors.red),
                                                              SizedBox(width: 5.0),
                                                              Text(
                                                                pickuporders?[index]
                                                                    .pickupCustomerArea ??
                                                                    'Unknown',
                                                                style: TextStyle(
                                                                  fontSize: 14.0,
                                                                  fontFamily: GoogleFonts.openSans().fontFamily,
                                                                ),
                                                              ),
                                                              SizedBox(width: 10.0),
                                                              Icon(Icons.access_time, size: 16.0, color: Colors.red),
                                                              SizedBox(width: 5.0),
                                                              Text(
                                                                pickuporders?[index]
                                                                    .pickupDate ??
                                                                    'Unknown',
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
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      ListView.builder(
                                        itemCount: deliveries?.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 5,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Card(
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
                                                            deliveries?[index]
                                                                .customerName ??
                                                                'Unknown',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 15.0,
                                                              fontFamily: GoogleFonts.openSans().fontFamily,
                                                              color: const Color(0xFF301C93),
                                                            ),
                                                          ),
                                                          SizedBox(height: 5.0),
                                                          Text(
                                                            deliveries?[index]
                                                                .status ??
                                                                'Unknown',
                                                            style: TextStyle(
                                                              fontSize: 13.0,
                                                              fontFamily: GoogleFonts.openSans().fontFamily,
                                                            ),
                                                          ),
                                                          SizedBox(height: 5.0),
                                                          Row(
                                                            children: [
                                                              Icon(Icons.location_on, size: 16.0, color: Colors.red),
                                                              SizedBox(width: 5.0),
                                                              Text(
                                                                deliveries?[index]
                                                                    .customerAddress ??
                                                                    'Unknown',
                                                                style: TextStyle(
                                                                  fontSize: 13.0,
                                                                  fontFamily: GoogleFonts.openSans().fontFamily,
                                                                ),
                                                              ),
                                                              SizedBox(width: 10.0),
                                                              Icon(Icons.access_time, size: 16.0, color: Colors.red),
                                                              SizedBox(width: 5.0),
                                                              Text(
                                                                deliveries?[index]
                                                                    .deliveredDateTime ??
                                                                    'Unknown',
                                                                style: TextStyle(
                                                                  fontSize: 13.0,
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
                  bottomNavigationBar:  BottomNavigationBar(
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
                        icon:Icon(Icons.car_crash),
                        label: 'Delivery',
                      ),
                      BottomNavigationBarItem(
                        icon:Icon(Icons.compare_arrows),
                        label: 'History',
                      ),
                      BottomNavigationBarItem(
                        icon:Icon(Icons.person),
                        label: 'Me',
                      ),
                    ],
                    selectedItemColor:Color(0xFF301C93),
                    selectedFontSize: 12.0,
                    unselectedFontSize: 12.0,
                    iconSize: 26.0,
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
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(height:40 ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [

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
                      'History',
                      style: TextStyle(
                          fontSize: 24,
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









// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class History extends StatefulWidget {
//   const History({Key? key}) : super(key: key);
//
//   @override
//   State<History> createState() => _HistoryState();
// }
//
// class _HistoryState extends State<History> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   int _currentIndex = 3;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Color(0xFFEFEEF3),
//         body: Column(
//           children: [
//             SizedBox(height: 30),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     SizedBox(width: 10),
//                     Text(
//                       'Taj Muhammed',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.normal,
//                         fontFamily: GoogleFonts.openSans().fontFamily,
//                         color: Color(0xFF000000),
//                       ),
//                     ),
//                   ],
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.notifications_outlined,
//                       size: 50, color: Color(0xFF301C93)),
//                   onPressed: () {
//                     // Add your onPressed logic here
//                   },
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'History',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontFamily: GoogleFonts.openSans().fontFamily,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF301C93),
//                   ),
//                 ),
//                 TextButton.icon(
//                   icon: Icon(Icons.arrow_back_outlined,
//                       size: 25, color: Color(0xFF301C93)),
//                   label: Text('Back',
//                       style: TextStyle(
//                         color: Color(0xFF301C93),
//                         fontSize: 20,
//                         fontFamily: GoogleFonts.openSans().fontFamily,
//                       )),
//                   onPressed: () {
//                     Navigator.pushNamed(context, "/pickupOrderListing");
//                     // Add your onPressed logic here
//                   },
//                 ),
//               ],
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(15.0),
//                 child: Column(
//                   children: [
//                     TabBar(
//                       controller: _tabController,
//                       tabs: [
//                         Tab(
//                           child: Text("Pickup", style: TextStyle(fontSize:20,color: Colors.black),),
//                         ),
//                         Tab(
//                           child: Text("Order", style: TextStyle(fontSize: 20,color: Colors.black,),),
//                         )
//                       ],
//                     ),
//                     Expanded(
//                       child: TabBarView(
//                         controller: _tabController,
//                         children: [
//                           ListView.builder(
//                             itemCount: 5,
//                             itemBuilder: (context, index) {
//                               return _buildCard();
//                             },
//                           ),
//                           ListView.builder(
//                             itemCount: 2,
//                             itemBuilder: (context, index) {
//                               return _buildCard();
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//         bottomNavigationBar:  BottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: _onItemTapped,
//           type: BottomNavigationBarType.fixed,
//           items: [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.car_crash),
//               label: 'Pickup',
//             ),
//             BottomNavigationBarItem(
//               icon:Icon(Icons.car_crash),
//               label: 'Delivery',
//             ),
//             BottomNavigationBarItem(
//               icon:Icon(Icons.compare_arrows),
//               label: 'History',
//             ),
//             BottomNavigationBarItem(
//               icon:Icon(Icons.person),
//               label: 'Me',
//             ),
//           ],
//           selectedItemColor:Color(0xFF301C93),
//           selectedFontSize: 12.0,
//           unselectedFontSize: 12.0,
//           iconSize: 26.0,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCard() {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.5),
//             spreadRadius: 2,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(15.0),
//           child: Row(
//             children: [
//               SizedBox(width: 15.0),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Text",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18.0,
//                         fontFamily: GoogleFonts.openSans().fontFamily,
//                         color: const Color(0xFF301C93),
//                       ),
//                     ),
//                     SizedBox(height: 5.0),
//                     Text(
//                       'text',
//                       style: TextStyle(
//                         fontSize: 14.0,
//                         fontFamily: GoogleFonts.openSans().fontFamily,
//                       ),
//                     ),
//                     SizedBox(height: 5.0),
//                     Row(
//                       children: [
//                         Icon(Icons.location_on, size: 16.0, color: Colors.red),
//                         SizedBox(width: 5.0),
//                         Text(
//                           'text',
//                           style: TextStyle(
//                             fontSize: 14.0,
//                             fontFamily: GoogleFonts.openSans().fontFamily,
//                           ),
//                         ),
//                         SizedBox(width: 10.0),
//                         Icon(Icons.access_time, size: 16.0, color: Colors.red),
//                         SizedBox(width: 5.0),
//                         Text(
//                           'text',
//                           style: TextStyle(
//                             fontSize: 14.0,
//                             fontFamily: GoogleFonts.openSans().fontFamily,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
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
// }