
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../../../../utils/app_sp.dart';

class AddNewPickup extends StatefulWidget {
  const AddNewPickup({super.key});

  @override
  State<AddNewPickup> createState() => _AddNewPickupState();
}

class _AddNewPickupState extends State<AddNewPickup> {
  int _currentIndex = 1;

  String orderId = '';
  String tokenID = '';
  String userToken = "";
  String companyCode = "";
  String userID = "";
  String LoggerUsername = "";
  String? selectedCustomer;
  List<dynamic> customers = [];
  List<dynamic> filteredCustomers = [];
  bool isLoading = true;
  String formateddate = "";
  late Map<String, dynamic> selectedCustomerDetails = {};

  TextEditingController customername = TextEditingController();
  TextEditingController customerphone = TextEditingController();
  TextEditingController customerarea = TextEditingController();
  TextEditingController pickupdate = TextEditingController();

  TextEditingController notes = TextEditingController();
  TextEditingController remarks = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserToken();
    var currentDate = DateTime.now();
    formateddate =
    '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
  }

  Future<void> getUserToken() async {
    AppSp appSp = AppSp();
    userToken = await appSp.getToken();
    companyCode = await appSp.getCompanyCode();
    LoggerUsername = await appSp.getUserName();
    userID = await appSp.getUserID();
    await customers_list();
  }

  Future<void> customers_list() async {
    final url =
        'https://be.syswash.net/api/syswash/customerlist?code=$companyCode';
    print(url);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        },
      );
      if (response.statusCode == 200) {
        print(response.body);
        setState(() {
          customers = jsonDecode(response.body);
          filteredCustomers = customers;
          isLoading = false;
        });
        print('Customer Data List: $customers'); // Debug print
      } else {
        print(
            'Failed to load customer details, status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching customer details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showCustomDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDropdownDialog(
          customers: filteredCustomers,
          onCustomerSelected: (customer) {
            setState(() {
              selectedCustomer =
                  customer['name'] + " - " + customer['mobile'].toString();

              // Extract mobile number from selectedCustomer
              int mobileNumber = int.parse(selectedCustomer!.split(' - ')[1]);

              // Find customer details by mobile number
              Map<String, dynamic>? customerDetails = customers.firstWhere(
                    (customer) => customer['mobile'] == mobileNumber,
                orElse: () => null,
              );

              if (customerDetails != null) {
                print('Customer Found:');
                print(customerDetails);

                selectedCustomerDetails = customerDetails;
                customername.text = selectedCustomerDetails['name'].toString();
                customerphone.text =
                    selectedCustomerDetails['mobile'].toString();
                customerarea.text = selectedCustomerDetails['area'].toString();
                pickupdate.text = formateddate.toString();

                // Access specific details like customer name
                String customerName = customerDetails['name'];
                print('Customer Name: $customerName');
              } else {
                print('Customer not found.');
              }
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return   SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFEFEEF3),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Select Customer",
                          style: TextStyle(
                            fontSize:  MediaQuery.of(context).size.width * 0.050,
                  fontFamily: GoogleFonts.dmSans().fontFamily,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF150B3D),

                          ),
                        ),
                      ],
                    ),
                    // Container(
                    //   width: 40,
                    //   height: 40,// Add padding of 10px
                    //   decoration: BoxDecoration(
                    //     color:  Color(0xFF000000), // Set background color to red
                    //     borderRadius: BorderRadius.circular(45), // Set border radius
                    //   ),
                    //   child: IconButton(
                    //
                    //     icon: Icon(Icons.close,
                    //         size:  30,  color: Color(0xFFFFFFFF)),
                    //     onPressed: () {
                    //       Navigator.pushReplacementNamed(context, '/pickupOrderListing');
                    //     },
                    //   ),
                    // ),

                    GestureDetector(
                      onTap:
                          () {
                            Navigator.pushReplacementNamed(context, '/pickupOrderListing');
                      },
                      child:
                      CircleAvatar(
                        radius: 20.0,
                        backgroundColor: Color(0xFF000000),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),



                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //       'Add new Pickup',
                //       style: TextStyle(
                //         fontSize: 23,
                //         fontFamily: GoogleFonts.openSans().fontFamily,
                //         fontWeight: FontWeight.bold,
                //         color: Color(0xFF301C93),
                //       ),
                //     ),
                //     TextButton.icon(
                //       icon: Icon(
                //         Icons.arrow_back_outlined,
                //         size: 22,
                //         color: Color(0xFF301C93),
                //       ),
                //       label: Text(
                //         'Back',
                //         style: TextStyle(
                //           color: Color(0xFF301C93),
                //           fontWeight: FontWeight.bold,
                //           fontSize: 20,
                //           fontFamily: GoogleFonts.openSans().fontFamily,
                //         ),
                //       ),
                //       onPressed: () {
                //         Navigator.pushNamed(context, "/pickupOrderListing");
                //       },
                //     ),
                SizedBox(height: 30),




                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ' Customer:',
                      style: TextStyle(
                        fontSize:  MediaQuery.of(context).size.width * 0.040,
                        fontFamily: GoogleFonts.dmSans().fontFamily,
                          color: Color(0xFF150B3D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    isLoading
                        ? Center(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 50.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    )
                        : InkWell(
                      onTap: () => _showCustomDropdown(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 10.0),
                          ),
                          child: Text(
                            selectedCustomer ?? 'Select Customer name',
                            style: TextStyle(

                              color: selectedCustomer == null
                                  ? Colors.grey
                                  : Colors.black,
                              fontSize:   MediaQuery.of(context).size.width * 0.040,
                              fontFamily: GoogleFonts.dmSans().fontFamily,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // {customerId: 2614, name: Jenifer, joinDate: 2024-06-16, email: , mobile: 9088762, streetNo: , villaNumber: , roomNo: , refNo: , cusCode: JL2613, area: Doha, hotel: , discount: 0, acType: WALK IN CASH, deliveryType: TAKE AWAY, openingBalance: 0, wallet: 38, cusPaidAmount: 0, cusBalance: 0, fragrance: , trash: false}

                selectedCustomer != null
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer Name:',
                                style: TextStyle(
                                  fontSize:  MediaQuery.of(context).size.width * 0.040,
                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                  color: Color(0xFF150B3D),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 5),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF9F9F9),
                                  borderRadius:
                                  BorderRadius.circular(8.0),
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
                                  controller: customername,
                                  style:TextStyle(color: Color(0xFF524B6B),
                                    fontSize:   MediaQuery.of(context).size.width * 0.040,
                                    fontFamily: GoogleFonts.dmSans().fontFamily,
                                    fontWeight: FontWeight.w500,
                                  ),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer Phone:',
                                style: TextStyle(
                                  fontSize:  MediaQuery.of(context).size.width * 0.040,
                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                  color: Color(0xFF150B3D),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 5),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF9F9F9),
                                  borderRadius:
                                  BorderRadius.circular(8.0),
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
                                  controller: customerphone,
                                  style:TextStyle(color: Color(0xFF524B6B),
                                    fontSize:   MediaQuery.of(context).size.width * 0.040,
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

                    SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer Area:',
                                style: TextStyle(
                                  fontSize:  MediaQuery.of(context).size.width * 0.040,
                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                  color: Color(0xFF150B3D),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 5),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF9F9F9),
                                  borderRadius:
                                  BorderRadius.circular(8.0),
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
                                  controller: customerarea,
                                  style:TextStyle(color: Color(0xFF524B6B),
                                    fontSize:   MediaQuery.of(context).size.width * 0.040,
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pickup Date:',
                                style: TextStyle(
                                  fontSize:  MediaQuery.of(context).size.width * 0.040,
                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                  color: Color(0xFF150B3D),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 5),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF9F9F9),
                                  borderRadius:
                                  BorderRadius.circular(8.0),
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
                                  controller: pickupdate,
                                  style:TextStyle(color: Color(0xFF524B6B),
                                    fontSize:   MediaQuery.of(context).size.width * 0.040,
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
                    SizedBox(height: 10),
                    Text(
                      'Notes',
                      style: TextStyle(
                        fontSize:  MediaQuery.of(context).size.width * 0.040,
                        fontFamily: GoogleFonts.dmSans().fontFamily,
                        color: Color(0xFF150B3D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
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
                        controller: notes,
                        style:TextStyle(color: Color(0xFF524B6B),
                            fontSize:   MediaQuery.of(context).size.width * 0.040,
                        fontFamily: GoogleFonts.dmSans().fontFamily,
                        fontWeight: FontWeight.w500,),
                        decoration: InputDecoration(
                          hintText:"Write Notes here",

                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Color(0xFFC5C5C5)),
                          fillColor: Color(
                              0xFFF9F9F9), // Add background color here
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 18.0,
                              horizontal:
                              10.0), // Adjust content padding as needed
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(8.0),

                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(8.0),

                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Remarks',
                      style: TextStyle(
                        fontSize:  MediaQuery.of(context).size.width * 0.040,
                        fontFamily: GoogleFonts.dmSans().fontFamily,
                        color: Color(0xFF150B3D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
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
                        controller: remarks,
                        style:TextStyle(color: Color(0xFF524B6B),
                          fontSize:   MediaQuery.of(context).size.width * 0.040,
                          fontFamily: GoogleFonts.dmSans().fontFamily,
                          fontWeight: FontWeight.w500,),
                        decoration: InputDecoration(
                          hintText:"Write Remark here",
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Color(0xFFC5C5C5)),
                          fillColor: Color(
                              0xFFF9F9F9), // Add background color here
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical:18.0,
                              horizontal:
                              20.0), // Adjust content padding as needed
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                           width: MediaQuery.of(context).size.width * 0.4,
                          child: CupertinoButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/addnewpickup");
                            },
                            color: Color(0xFFFED9CD),
                            padding: EdgeInsets.symmetric(vertical: 15.0),
                            borderRadius: BorderRadius.circular(8.0),
                            child: Text(
                              'CLEAR',
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize:  MediaQuery.of(context).size.width * 0.040,
                                letterSpacing: 2,
                                fontFamily: GoogleFonts.dmSans().fontFamily,
                              ),
                            ),
                          ),
                        ),
                        Container(
                           width: MediaQuery.of(context).size.width * 0.4,
                          child: CupertinoButton(
                            onPressed: () {
                              if (selectedCustomer == null || selectedCustomerDetails.isEmpty) {
                                EasyLoading.showToast("Please Select Customer");
                              } else {
                                UploadPickupData(context);
                              }
                            },
                            color: Color(0xFF68188B),
                            padding: EdgeInsets.symmetric(vertical: 15.0),
                            borderRadius: BorderRadius.circular(8.0),
                            child: Text(
                              'SAVE',
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                 letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                                fontSize:  MediaQuery.of(context).size.width * 0.040,
                                fontFamily: GoogleFonts.dmSans().fontFamily,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                  ],
                )
                    : Container(),

              ],
            ),

          ),

        ),

        // bottomNavigationBar: BottomNavigationBar(
        //         //   currentIndex: _currentIndex,
        //         //   onTap: _onItemTapped,
        //         //   type: BottomNavigationBarType.fixed,
        //         //   items: [
        //         //     BottomNavigationBarItem(
        //         //       icon: Icon(
        //         //         Icons.home,
        //         //       ),
        //         //       label: 'Home',
        //         //     ),
        //         //     BottomNavigationBarItem(
        //         //       icon: Icon(
        //         //         Icons.car_crash,
        //         //       ),
        //         //       label: 'Pickup',
        //         //     ),
        //         //     BottomNavigationBarItem(
        //         //       icon: Icon(
        //         //         Icons.car_crash,
        //         //       ),
        //         //       label: 'Delivery',
        //         //     ),
        //         //     BottomNavigationBarItem(
        //         //       icon: Icon(
        //         //         Icons.compare_arrows,
        //         //       ),
        //         //       label: 'History',
        //         //     ),
        //         //     BottomNavigationBarItem(
        //         //       icon: Icon(
        //         //         Icons.person,
        //         //       ),
        //         //       label: 'Me',
        //         //     ),
        //         //   ],
        //         //   selectedItemColor: Color(0xFF301C93),
        //         //   selectedFontSize: 12.0, // Adjust the font size for the selected item
        //         //   unselectedFontSize: 12.0, // Adjust the font size for unselected items
        //         //   iconSize: 26.0, // Adjust the icon size
        //         // ),

      ),
    );
  }



  Future<void> UploadPickupData(BuildContext context) async {
    var content = {
      "pickupDate": formateddate,
      "pickupCustomerId": selectedCustomerDetails['customerId'].toString(),
      "pickupCustomerName": selectedCustomerDetails['name'].toString(),
      "pickupCustomerArea": selectedCustomerDetails['area'].toString(),
      "pickupCustomerCode": selectedCustomerDetails['cusCode'].toString(),
      "pickupCustomerPhno": selectedCustomerDetails['mobile'],
      "pickupDriverid": userID,
      "pickupDrivername": LoggerUsername,
      "AssignedFrom": null,
      "pickupOrderId": null,
      // "remarks": remarks.text,
      // "notes": notes.text
      "remarks": remarks.text.isEmpty ? null : remarks.text,
      "notes": notes.text.isEmpty ? null : notes.text,
    };

    print('Request Payload: $content');

    var response = await http.Client().post(
      Uri.parse('https://be.syswash.net/api/syswash/pickup?code=$companyCode'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $userToken"
      },
      body: jsonEncode(content),
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      EasyLoading.showToast("Data Added Successfully");
      Navigator.pushNamed(context, "/pickupOrderListing");
    } else {
      // If request failed, handle the error
      EasyLoading.showToast("Error: ${response.statusCode}");
      print('Error: ${response.body}');
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
}



class CustomDropdownDialog extends StatefulWidget {
  final List<dynamic> customers;
  final ValueChanged<Map<String, dynamic>> onCustomerSelected;

  CustomDropdownDialog({
    required this.customers,
    required this.onCustomerSelected,
  });

  @override
  _CustomDropdownDialogState createState() => _CustomDropdownDialogState();
}

class _CustomDropdownDialogState extends State<CustomDropdownDialog> {
  late List<dynamic> filteredCustomers;

  @override
  void initState() {
    super.initState();
    filteredCustomers = widget.customers;
  }

  void filterCustomers(String query) {
    setState(() {
      filteredCustomers = widget.customers.where((customer) {
        final customerName = customer['name'].toLowerCase();
        final customerMobile = customer['mobile'].toString().toLowerCase();
        final searchLower = query.toLowerCase();
        return customerName.contains(searchLower) ||
            customerMobile.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) {
              filterCustomers(value);
            },
            decoration: InputDecoration(
              hintText: 'Search Customers',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 300, // Set a fixed height for the ListView
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer = filteredCustomers[index];
                return ListTile(
                  title: Text(
                      customer['name'] + " - " + customer['mobile'].toString()),
                  onTap: () {
                    widget.onCustomerSelected(customer);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}















