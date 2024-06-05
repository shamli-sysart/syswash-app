


import 'package:flutter/cupertino.dart';

import '../view/screen/dashboard/home_screen.dart';
import '../view/screen/delivery/customerdeatailsdelivery/customer_details_delivery.dart';
import '../view/screen/delivery/delivery/delivery.dart';
import '../view/screen/history/history.dart';
import '../view/screen/login/login_screen.dart';
import '../view/screen/notification/message.dart';
import '../view/screen/order/customerdetails/customer_details.dart';
import '../view/screen/order/pickuporder/pickuporder_listing.dart';

import '../view/screen/profile/profile.dart';
import '../view/screen/splash/splash_screen.dart';

Route onGenerateRoute(RouteSettings settings) {
  Route _createPageRoute(Widget Function(BuildContext) builder) {
    return CupertinoPageRoute(
      builder: builder,
    );
  }

  switch (settings.name) {
    case "/splash":
      return _createPageRoute((context) => SplashPage());
    case "/login":
      return _createPageRoute((context) => const LoginScreen());
    case "/dashHome":
      return _createPageRoute((context) => const DashBoardScreen());
    case "/pickupOrderListing":
      return _createPageRoute((context) => const PickupOrderListing());
    case "/customer_details":
      return _createPageRoute((context) {
        final Map<String, dynamic>? args = settings.arguments as Map<String, dynamic>?;
        return CustomerDetailsOrder(
          pickupassgnId: args?['pickupassgnId'] as String?,
          pickupCustomerId: args?['pickupCustomerId'] as String?,
        );
      });
    case "/delivery":
      return _createPageRoute((context) => const Delivery());
    case "/profile":
      return _createPageRoute((context) => const Profile());
    case "/message":
      return _createPageRoute((context) => const Message(
      ));


    case "/customDetailsDelivery":
    return _createPageRoute((context) {
    final Map<String, dynamic>? args = settings.arguments as Map<String, dynamic>?;
     return CustomerDetailsDelivery(
      orderId: args?['deliveryInvoiceNo'] as String?,
       deliveryCustomerId: args?['deliveryCustomerId'] as String?,
  );
    });


      // return _createPageRoute((context) => CustomerDetailsDelivery(
      //   orderId: settings.arguments as String?,
      // ));
    case "/history":
      return _createPageRoute((context) => const History());
    default:
    // Handle unknown routes here
      return _createPageRoute((context) => Container());
      // You can change this to a 404 page
  }
}















//
//
// import 'package:flutter/cupertino.dart';
// import 'package:syswash/view/screen/history/history.dart';
//
// import '../view/screen/dashboard/home_screen.dart';
// import '../view/screen/delivery/customerdeatailsdelivery/customer_details_delivery.dart';
// import '../view/screen/delivery/delivery/delivery.dart';
// import '../view/screen/login/login_screen.dart';
// import '../view/screen/order/customerdetails/customer_details.dart';
// import '../view/screen/order/pickuporder/pickuporder_listing.dart';
//
// import '../view/screen/splash/splash_screen.dart';
//
// Route onGenerateRoute(RouteSettings settings) {
//   Route page = CupertinoPageRoute(
//     builder: (context) => SplashPage(),
//   );
//   switch (settings.name) {
//     case "/splash":
//       page = CupertinoPageRoute(
//         builder: (context) => SplashPage(),
//       );
//       break;
//     case "/login":
//       page = CupertinoPageRoute(
//         builder: (context) => const LoginScreen(),
//       );
//       break;
//     case "/dashHome":
//       page = CupertinoPageRoute(
//         builder: (context) => const DashBoardScreen(),
//       );
//       break;
//     //  pickup
//     case "/pickupOrderListing":
//       page = CupertinoPageRoute(
//         builder: (context) => const PickupOrderListing(),
//       );
//       break;
//     case "/customer_details":
//       page = CupertinoPageRoute(
//         builder: (context) => CustomerDetailsOrder(
//           pickupassgnId: settings.arguments as String?,
//         ),
//       );
//       break;
//
//     //delivery
//     case "/delivery":
//       page = CupertinoPageRoute(
//         builder: (context) => const Delivery(),
//       );
//       break;
//     case "/customDetailsDelivery":
//       page = CupertinoPageRoute(
//         builder: (context) => const CustomerDetailsDelivery(),
//       );
//       break;
//   //history
//     case "/history":
//       page = CupertinoPageRoute(
//         builder: (context) => const History(),
//       );
//       break;
//
//
//   }
//   return page;
// }
