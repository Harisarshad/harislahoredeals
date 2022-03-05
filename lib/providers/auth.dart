import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:eBazaarMerchant/src/widget/notification_text.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class AuthProvider with ChangeNotifier {
  Status _status = Status.Uninitialized;
  String? _token;
  String? _shopID;
  String? _shopName;
  String? _openingTime;
  String? _closingTime;
  String? _deliveryCharge;
  String? _shopAddress;
  String? _shopImg;
  String? _user;
  String? _sitename;
  String? _currency;
  String? _currencyname;
  String? _stripekey;
  String? _stripesecret;
  String? _orderAttachment;
  String? _otpLimit;
  NotificationText? _notification;

  Status get status => _status;
  String? get token => _token;
  String? get sitename => _sitename;
  String? get currency => _currency;
  String? get currencyname => _currencyname;
  String? get stripekey => _stripekey;
  String? get stripesecret => _stripesecret;
  String? get shopID => _shopID;
  String? get shopName => _shopName;
  String? get openingTime => _openingTime;
  String? get closingTime => _closingTime;
  String? get deliveryCharge => _deliveryCharge;
  String? get shopAddress => _shopAddress;
  String? get shopImg => _shopImg;
  String? get userName => _user;
  String? get otpLimit => _otpLimit;
  String? get orderAttachment => _orderAttachment;
  NotificationText? get notification => _notification;

  final String api = FoodApi.baseApi;

  initAuthProvider() async {
    String? token = await getToken();
    String? user = await getUser();
    String? shop = await getShop();
    String? shopname = await getShopName();
    String? openingTime = await getOpeningTime();
    String? closingtime = await getClosingTime();
    String? charge = await getdeliveryCharge();
    String? address = await getShopAddress();
    String? shopimg = await getShopImg();
    if (token != null) {
      // if (shop != null) {
      //   _shopID = shop;
      //   _shopName = shopname;
      //   _openingTime = openingTime;
      //   _closingTime = closingtime;
      //   _deliveryCharge = charge;
      //   _shopAddress = address;
      //   _shopImg = shopimg;
      // } else {
      //   _shopID = null;
      // }
      _status = Status.Authenticated;
      _token = token;
      refreshToken();
      _user = user;
    } else {
      _token = null;
      _shopID = null;
      _status = Status.Unauthenticated;
    }

    _currency = await getCurrency();
    _sitename = await getSiteName();
    _currencyname = await getCurrencyName();
    _stripekey = await getStripeKey();
    _stripesecret = await getStripeSecret();
    _orderAttachment = await getOrderAttachment();
    _otpLimit = await getOtp();
    notifyListeners();
  }

  Future<bool> login(String? email, String? password) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.clear();
    _status = Status.Authenticating;
    _notification = null;
    notifyListeners();

    final url = "$api/login";

    Map<String, String?> body = {
      'email': email,
      'password': password,
      'role': '3',
    };

    final response = await http.post(
      Uri.parse(url),
      body: body,
    );
    Map<String, dynamic>? apiResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      _status = Status.Authenticated;
      print(apiResponse);
      _token = apiResponse!['token'];
      _user = apiResponse['data']['name'];
      // if (apiResponse['shop'] != null) {
      //
      //   _shopID = '${apiResponse['shop']['id'].toString()}';
      //   _shopName = apiResponse['shop']['name'].toString();
      //   _openingTime = apiResponse['shop']['opening_time'].toString();
      //   _closingTime = apiResponse['shop']['closing_time'].toString();
      //   _deliveryCharge = apiResponse['shop']['delivery_charge'].toString();
      //   _shopAddress = apiResponse['shop']['address'].toString();
      //   _shopImg = apiResponse['shop']['image'].toString();
      // }
      await storeUserData(apiResponse);
      notifyListeners();
      return true;
    }

    if (response.statusCode == 401) {
      _status = Status.Unauthenticated;
      _notification = NotificationText(apiResponse!['message']);
      notifyListeners();
      return false;
    }

    _status = Status.Unauthenticated;
    _notification = NotificationText('Server error.');
    notifyListeners();
    return false;
  }

  Future<bool> Otplogin(String value) async {
    _status = Status.Authenticating;
    _notification = null;
    notifyListeners();

    final url = "$api/verify-otp";

    Map<String, String> body = {
      'code': value,
    };

    final response = await http.post(
      Uri.parse(url),
      body: body,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> apiResponse = json.decode(response.body);
      print(apiResponse['shop']);
      _status = Status.Authenticated;
      _token = apiResponse['token'];
      _user = apiResponse['data']['name'];
      if (apiResponse['shop'] != null) {
        _shopID = apiResponse['shop']['id'].toString();
        _shopName = apiResponse['shop']['name'].toString();
        _openingTime = apiResponse['shop']['opening_time'].toString();
        _closingTime = apiResponse['shop']['closing_time'].toString();
        _deliveryCharge = apiResponse['shop']['delivery_charge'].toString();
        _shopAddress = apiResponse['shop']['address'].toString();
        _shopImg = apiResponse['shop']['image'].toString();
      }
      await storeUserData(apiResponse);
      notifyListeners();
      return true;
    }

    if (response.statusCode == 401) {
      _status = Status.Unauthenticated;
      _notification = NotificationText('The code is not valid');
      notifyListeners();
      return false;
    }

    _status = Status.Unauthenticated;
    _notification = NotificationText('Server error.');
    notifyListeners();
    return false;
  }

  Future<bool> Otpregister(String value) async {
    _notification = null;
    final url = "$api/get-otp";
    Map<String, String> body = {
      'otp': value,
    };
    final response = await http.post(
      Uri.parse(url),
      body: body,
    );
    if (response.statusCode == 200) {
      Map<String, dynamic>? apiResponse = json.decode(response.body);
      return true;
    }

    if (response.statusCode == 401) {
      _status = Status.Unauthenticated;
      return false;
    }
    return false;
  }

  Future<Map> register(String? name, String? email, String? phone,
      String? password, String? passwordConfirm) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.clear();
    final url = "$api/reg";
    _notification = null;
    notifyListeners();
    Map<String, String?> body = {
      'name': name,
      'email': email,
      'phone': phone,
      'role': '3',
      'password': password,
      'password_confirmation': passwordConfirm,
    };

    Map<String, dynamic> result = {
      "success": false,
      "message": 'Unknown error.'
    };

    final response = await http.post(Uri.parse(url), body: body);
    Map? apiResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      _status = Status.Authenticated;
      _token = apiResponse!['token'];
      _shopID = null;
      await storeUserData(apiResponse);
      _notification = NotificationText(
          'Registration successful, please log in.',
          type: 'info');
      notifyListeners();
      result['success'] = true;
      return result;
    }
    if (response.statusCode == 422) {
      _status = Status.Unauthenticated;
      if (apiResponse!['message'].containsKey('email')) {
        result['message'] = apiResponse['message']['email'][0];
        _notification = NotificationText(result['message']);
        notifyListeners();
        return result;
      }

      if (apiResponse['message'].containsKey('password')) {
        result['message'] = apiResponse['message']['password'][0];
        _notification = NotificationText(result['message']);
        notifyListeners();
        return result;
      }
      notifyListeners();
      return result;
    }

    return result;
  }

  Future<Map> ProfileUpdate(
      String? name,
      String? email,
      String? phone,
      String? username,
      String? address,
      String? fileName,
      String? base64Image) async {
    Map<String, String?> params = {
      "name": name,
      "email": email,
      "phone": phone,
      "username": username,
      "address": address,
      "image": base64Image != null ? base64Image : '',
      "fileName": fileName != null ? fileName : '',
    };
    print(params);
    Map<String, dynamic> result = {
      "success": false,
      "message": 'Unknown error.'
    };
    final url = "$api/profile";
    final response = await http.put(Uri.parse(url), body: params, headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      _notification =
          NotificationText('Successfully Updated Profile', type: 'info');
      result['success'] = true;
      return result;
    } else {
      throw Exception('Failed to data');
    }
  }

  Future<Map> ChangePassword(String? password_current, String? password,
      String? passwordConfirm) async {
    Map<String, String?> params = {
      "password_current": password_current,
      "password": password,
      "password_confirmation": passwordConfirm,
    };

    Map<String, dynamic> result = {
      "success": false,
      "message": 'Unknown error.'
    };
    final url = "$api/change-password";
    final response = await http.put(Uri.parse(url), body: params, headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      _notification =
          NotificationText('Successfully Change Password ', type: 'info');
      result['success'] = true;
      return result;
    } else if (response.statusCode == 422) {
      result['success'] = false;
      if (resBody['message'].containsKey('password_current')) {
        _notification = NotificationText(
          resBody['message']['password_current'][0],
        );
        result['message'] = resBody['message']['password_current'][0];
        return result;
      }
      if (resBody['message'].containsKey('password')) {
        _notification = NotificationText(
          resBody['message']['password'][0],
        );
        result['message'] = resBody['message']['password'][0];
        return result;
      }
      return result;
    } else {
      throw Exception('Failed to data');
    }
  }

  Future<bool> refreshToken() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.remove('token');
    _notification = null;
    final url = "$api/refresh";
    final response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> apiResponse = json.decode(response.body);
      _status = Status.Authenticated;
      _token = apiResponse['token'];
      await storeUserData(apiResponse);
      notifyListeners();
      return true;
    }
    _status = Status.Unauthenticated;
    _token = null;
    _notification = NotificationText('Server error.');
    notifyListeners();
    return false;
  }

  Future<bool> setting() async {
    final url = "$api/settings";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> apiResponse = json.decode(response.body);
      _sitename = apiResponse['data']['site_name'].toString();
      _currency = apiResponse['data']['currency_code'].toString();
      _currencyname = apiResponse['data']['currency_name'].toString();
      _stripekey = apiResponse['data']['stripe_key'].toString();
      _stripesecret = apiResponse['data']['stripe_secret'].toString();
      _orderAttachment =
          apiResponse['data']['order_attachment_checking'].toString();
      _otpLimit = apiResponse['data']['otp_digit_limit'].toString();
      await storeSettingData(apiResponse);
      notifyListeners();
      return true;
    }

    if (response.statusCode == 401) {
      _status = Status.Unauthenticated;
      _notification = NotificationText('Invalid email or password.');
      notifyListeners();
      return false;
    }

    _status = Status.Unauthenticated;
    _notification = NotificationText('Server error.');
    notifyListeners();
    return false;
  }

  storeUserData(apiResponse) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setString('token', apiResponse['token']);
    // if (apiResponse['shop'] != null) {
    //   await storage.setString('shop', apiResponse['shop']['id'].toString());
    //   await storage.setString(
    //       'shopName', apiResponse['shop']['name'].toString());
    //   await storage.setString(
    //       'shopImg', apiResponse['shop']['image'].toString());
    //   await storage.setString(
    //       'openingTime', apiResponse['shop']['opening_time'].toString());
    //   await storage.setString(
    //       'closingTime', apiResponse['shop']['closing_time'].toString());
    //   await storage.setString(
    //       'deliveryCharge', apiResponse['shop']['delivery_charge'].toString());
    //   await storage.setString(
    //       'shopAddress', apiResponse['shop']['address'].toString());
    // }
  }

  storeSettingData(apiResponse) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setString(
        'sitename', apiResponse['data']['site_name'].toString());
    await storage.setString(
        'currency', apiResponse['data']['currency_code'].toString());
    await storage.setString(
        'currencyname', apiResponse['data']['currency_name'].toString());
    await storage.setString(
        'stripekey', apiResponse['data']['stripe_key'].toString());
    await storage.setString(
        'stripesecret', apiResponse['data']['stripe_secret'].toString());
    await storage.setString('orderAttachment',
        apiResponse['data']['order_attachment_checking'].toString());
    await storage.setString(
        'otp', apiResponse['data']['otp_digit_limit'].toString());
  }

  updateShop(apiResponse) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    _shopID = apiResponse['id'].toString();
    _shopName = apiResponse['name'].toString();
    _shopImg = apiResponse['image'].toString();
    _openingTime = apiResponse['opening_time'].toString();
    _closingTime = apiResponse['closing_time'].toString();
    _deliveryCharge = apiResponse['delivery_charge'].toString();
    _shopAddress = apiResponse['address'].toString();

    await storage.setString('shop', apiResponse['id'].toString());
    await storage.setString('shopName', apiResponse['name'].toString());
    await storage.setString('shopImg', apiResponse['image'].toString());
    await storage.setString(
        'openingTime', apiResponse['opening_time'].toString());
    await storage.setString(
        'closingTime', apiResponse['closing_time'].toString());
    await storage.setString(
        'deliveryCharge', apiResponse['delivery_charge'].toString());
    await storage.setString('shopAddress', apiResponse['address'].toString());
  }

  Future<String?> getToken() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? token = storage.getString('token');
    return token;
  }

  Future<String?> getShop() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? shop = storage.getString('shop');
    return shop;
  }

  Future<String?> getOpeningTime() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? openingTime = storage.getString('openingTime');
    return openingTime;
  }

  Future<String?> getClosingTime() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? closingTime = storage.getString('closingTime');
    return closingTime;
  }

  Future<String?> getdeliveryCharge() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? deliveryCharge = storage.getString('deliveryCharge');
    return deliveryCharge;
  }

  Future<String?> getShopAddress() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? shopAddress = storage.getString('shopAddress');
    return shopAddress;
  }

  Future<String?> getShopName() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? shop = storage.getString('shopName');
    return shop;
  }

  Future<String?> getShopImg() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? shop = storage.getString('shopImg');
    return shop;
  }

  Future<String?> getSiteName() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? sitename = storage.getString('sitename');
    return sitename;
  }

  Future<String?> getCurrency() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? currency = storage.getString('currency');
    return currency;
  }

  Future<String?> getCurrencyName() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? currencyname = storage.getString('currencyname');
    return currencyname;
  }

  Future<String?> getStripeKey() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? stripekey = storage.getString('stripekey');
    return stripekey;
  }

  Future<String?> getStripeSecret() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? stripesecret = storage.getString('stripesecret');
    return stripesecret;
  }

  Future<String?> getUser() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? name = storage.getString('name');
    return name;
  }

  Future<String?> getOrderAttachment() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? orderAttachment = storage.getString('orderAttachment');
    return orderAttachment;
  }

  Future<String?> getOtp() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? otp = storage.getString('otp');
    return otp;
  }

  logOut() async {
    print('object');
    _status = Status.Unauthenticated;
    _token = null;
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.clear();
    notifyListeners();
    return true;
  }
}
