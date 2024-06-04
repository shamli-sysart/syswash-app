import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import '../model/PickupOrderListingResponse.dart';
import '../model/delivery_listing_response.dart';
import '../model/history_response.dart';
import '../model/login_response.dart';

import '../model/pickup_customer_response.dart';
import '../utils/app_url.dart';

class ApiService {
//  login

  Future<LoginResponse> getLogin(
      String username, String password, String companycode) async {
    try {
      var response = await http.Client().post(
        Uri.parse("${AppUrls.login}$companycode"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": username,
          "password": password,
        }),
      );
      log("API>>>URL>>${AppUrls.login}<<<REQ>>>${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        return LoginResponse(code: 401);
      } else {
        return LoginResponse(code: response.statusCode);
      }
    } catch (e) {
      log("Error in API $e");
      return LoginResponse(code: 500);
    }
  }
//pick up order list
  Future<PickupOrderListingResponse> getPickupOrderList(
      String userToken, String companyCode, String userID) async {
    try {
      var response = await http.get(
        Uri.parse(
            '${AppUrls.pickuplist}$userID${AppUrls.code_main}$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        },
      );
      log("API>>>URL>>${AppUrls.pickuplist}$companyCode<<<REQ>>>${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = json.decode(response.body);
        var modifiedResponse = {"pickup": jsonResponse};
        return PickupOrderListingResponse.fromJson(modifiedResponse);
      } else if (response.statusCode == 401) {
        return PickupOrderListingResponse(code: 401);
      } else {
        return PickupOrderListingResponse(code: 500);
      }
    } catch (e) {
      log("Error in API $e");
      if (e.toString().startsWith("ClientException with SocketException") ||
          e.toString().startsWith("SocketException") ||
          e.toString().startsWith("Failed host lookup")) {
        return PickupOrderListingResponse(code: 503);
      } else {
        return PickupOrderListingResponse(code: 500);
      }
    }
  }


  //pick up  customer response
  Future<PickupCustomerResponse> getPickupCustomerDetails(
      String userToken, String companyCode, String pickupassgnId) async {
    try {
      var response = await http.get(
        Uri.parse('${AppUrls.pickup}$pickupassgnId${AppUrls.code_main}$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        },
      );
      log("API>>>URL>>${AppUrls.pickup}$companyCode<<<REQ>>>${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.body);
        return PickupCustomerResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        return PickupCustomerResponse(code: 401);
      } else {
        return PickupCustomerResponse(code: 500);
      }
    } catch (e) {
      log("Error in API $e");
      if (e.toString().startsWith("ClientException with SocketException") ||
          e.toString().startsWith("SocketException") ||
          e.toString().startsWith("Failed host lookup")) {
        return PickupCustomerResponse(code: 503);
      } else {
        return PickupCustomerResponse(code: 500);
      }
    }
  }



  //delivery



  Future<DeliveryListingResponse> getDeliveryList(
      String userToken, String companyCode, String userID) async {
    try {
      var response = await http.get(
        Uri.parse(
            '${AppUrls.deliverylist}$userID${AppUrls.code_main}$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        },
      );
      log("API>>>URL>>${AppUrls.deliverylist}$companyCode<<<REQ>>>${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = json.decode(response.body);
        var modifiedResponse = {"data": jsonResponse};
        return DeliveryListingResponse.fromJson(modifiedResponse);
      } else if (response.statusCode == 401) {
        return DeliveryListingResponse(code: 401);
      } else {
        return DeliveryListingResponse(code: 500);
      }
    } catch (e) {
      log("Error in API $e");
      if (e.toString().startsWith("ClientException with SocketException") ||
          e.toString().startsWith("SocketException") ||
          e.toString().startsWith("Failed host lookup")) {
        return DeliveryListingResponse(code: 503);
      } else {
        return DeliveryListingResponse(code: 500);
      }
    }
  }

  //history

  Future<HistoryResponse> getHistory(
      String userToken, String companyCode, String userID) async {
    try {
      var response = await http.get(
        Uri.parse(
            '${AppUrls.history}$userID${AppUrls.code_main}$companyCode'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $userToken"
        },
      );
      log("API>>>URL>>${AppUrls.pickuplist}$companyCode<<<REQ>>>${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {

        print(response.body);
        return HistoryResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        return HistoryResponse(code: 401);
      } else {
        return HistoryResponse(code: 500);
      }
    } catch (e) {
      log("Error in API $e");
      if (e.toString().startsWith("ClientException with SocketException") ||
          e.toString().startsWith("SocketException") ||
          e.toString().startsWith("Failed host lookup")) {
        return HistoryResponse(code: 503);
      } else {
        return HistoryResponse(code: 500);
      }
    }
  }


//add new order item
//
//   Future<AddNewOrderItemsResponse> AddNewOrder(
//       String itemId,
//       String name,
//       String descriptions,
//       String mrp,
//       String cost,
//       String stockStatus,
//       String categoryId,
//       File productImage,
//       String tokenId,
//       ) async {
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(AppUrls.createProduct));
//       request.headers.addAll({
//         "Accept": "application/json",
//         "Authorization": "Bearer $tokenId"
//       });
//       request.fields.addAll({
//         "item_id": itemId,
//         "name": name,
//         "descriptions": descriptions,
//         "mrp": mrp,
//         "cost": cost,
//         "stock_status": "1",
//         "category_id": categoryId,
//       });
//       var stream = http.ByteStream(productImage.openRead());
//       var length = await productImage.length();
//       var multipartFile = http.MultipartFile('product_image', stream, length, filename: basename(productImage.path));
//       request.files.add(multipartFile);
//
//       var response = await http.Response.fromStream(await request.send());
//       log("API>>>URL>>${AppUrls.createProduct}<<<REQ>>>${response.body}");
//
//       if (response.statusCode == 200) {
//         return AddNewOrderItemsResponse.fromJson(json.decode(response.body));
//       } else if (response.statusCode == 201) {
//         return AddNewOrderItemsResponse.fromJson(json.decode(response.body));
//       } else if (response.statusCode == 401) {
//         return AddNewOrderItemsResponse(code: 401);
//       } else {
//         return AddNewOrderItemsResponse(code: 500);
//       }
//     } catch (e) {
//       log("Error in API$e");
//       if (e.toString().startsWith("ClientException with SocketException") ||
//           e.toString().startsWith("SocketException") ||
//           e.toString().startsWith("Failed host lookup")) {
//         //no internet case
//         return AddNewOrderItemsResponse(code: 503);
//       } else {
//         return AddNewOrderItemsResponse(code: 500);
//       }
//     }
//   }


}

