

import 'package:shared_preferences/shared_preferences.dart';

class AppSp{

  Future<bool> setIsLogged(bool login) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool("isLogged", login);
  }

  Future<bool> getIsLogged() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLogged") ?? false;
  }

  Future<bool> setIsAppLaunched(bool onceOpen) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool("isAppLaunched", onceOpen);
  }

  Future<bool> getIsAppLaunched() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isAppLaunched") ?? false;
  }


  Future<bool> setCompanyCode(String companyCode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("company_code", companyCode);
  }

  Future<String> getCompanyCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("company_code") ?? '';
  }

  Future<bool> setToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("token", token);
  }

  Future<String> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") ?? '';
  }

  Future<bool> setUserName(String userName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("user_name", userName);
  }

  Future<String> getUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_name") ?? '';
  }

  Future<bool> setUserEmail(String userMail) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("user_mail", userMail);
  }

  Future<String> getUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_mail") ?? '';
  }


  Future<bool> setUserID(String userMail) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("user_id", userMail);
  }

  Future<String> getUserID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_id") ?? '';
  }
  Future<bool> setRefreshtoken(String refresh) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("refresh", refresh);
  }

  Future<String> getRefreshtoken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("refresh") ?? '';
  }



  Future<bool> setFirebasetoken(String refresh) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("firebasetoken", refresh);
  }

  Future<String> getFirebasetoken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("firebasetoken") ?? '';
  }

  Future<bool> setLastAddedItemOrder(String pickupassgnId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("pickupassgnId", pickupassgnId);
  }

  Future<String> getLastAddedItemOrder() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("pickupassgnId") ?? '';
  }
  Future<bool> setLastDelivery(String deliveryInvoiceNo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("deliveryInvoiceNo", deliveryInvoiceNo);
  }

  Future<String> getLastDelivery() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("deliveryInvoiceNo") ?? '';
  }



}
