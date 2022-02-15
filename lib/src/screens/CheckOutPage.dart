import 'dart:io';

import 'package:flutter/material.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/main.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/shared/Product.dart';
import 'package:eBazaarMerchant/src/utils/CustomTextStyle.dart';
import 'package:eBazaarMerchant/src/utils/validate.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:eBazaarMerchant/models/cartmodel.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class CheckOutPage extends StatefulWidget {
  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  TextEditingController editingControlCustomerler = TextEditingController();
  TextEditingController _controllerName = new TextEditingController();
  TextEditingController _controllerEmail = new TextEditingController();
  TextEditingController _controllerPhone = new TextEditingController();

  GlobalKey<RefreshIndicatorState>? refreshKey;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String api = FoodApi.baseApi;
  String? _OrderSucess;
  String? _OrderAmount;
  String? _OrderId;

  String? name;
  String? email;
  String? customer_mobile;
  String? delivery_address;
  String? customer_lat;
  String? customer_long;
  String? remarks;
  double? delivery_charge;
  double? total;
  String? token;
  String? showInput;
  Future<String> submitOrder(
      cart,
      customer_id,
      customer_mobile,
      delivery_address,
      total,
      ShopID,
      delivery_charge,
      remarks,
      customer_lat,
      customer_long,
      token) async {
    List<Map> items = [];
    cart.forEach((element) => items.add(ItemProduct(
            shop_id: ShopID,
            product_id: element.id,
            unit_price: element.price,
            discounted_price: 0.0,
            quantity: element.qty)
        .TojsonData()));
    var body = json.encode({
      "items": json.encode(items),
      "mobile": customer_mobile,
      "address": delivery_address,
      "delivery_charge": delivery_charge,
      "lat": customer_lat,
      "long": customer_long,
      "remarks": 'remarks',
      "total": total,
      "user_id": customer_id.toString(),
      "name": name,
      "email": email,
      "phone": customer_mobile,
      "address": delivery_address,
      "shop_id": ShopID,
    });
    final url = "$api/shop-order";
    var response = await http.post(Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: "application/json; charset=utf-8"
        },
        body: body);
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      setState(() {
        _OrderSucess = resBody['message'];
        _OrderId = resBody['data']['id'].toString();
        _OrderAmount = resBody['data']['total'].toString();
        showThankYouBottomSheet(
            context,
            resBody['message'],
            resBody['data']['id'].toString(),
            resBody['data']['total'].toString());
        ScopedModel.of<CartModel>(context, rebuildOnChange: true).clearCart();
      });
    } else {
      _showAlert(context);
      throw Exception('Failed to data');
    }
    return "Sucess";
  }

  Future<void> _showAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Order'),
          content: Text('Failed to data'),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Map<String, dynamic> user = {
    "id": '',
    "name": '',
    "email": '',
    "image": '',
    "username": '',
    "phone": '',
    "address": ''
  };

  void SerchCustomer(value) async {
    final url = "$api/customer-search?phone=$value";
    var response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.acceptHeader: "application/json"
    });
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _controllerName.text =
            resBody['data'] != null ? resBody['data']['name'] : '';
        _controllerEmail.text =
            resBody['data'] != null ? resBody['data']['email'] : '';
        _controllerPhone.text =
            resBody['data'] != null ? resBody['data']['phone'] : '';
      });
    } else {
      _controllerName.text = '';
      _controllerEmail.text = '';
      _controllerPhone.text = '';
      throw Exception('Failed to data');
    }
    return;
  }

  bool _firstPress = true;
  @override
  void initState() {
    super.initState();
    _firstPress = true;
    token = Provider.of<AuthProvider>(context, listen: false).token;
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: true).token;
    final currency = Provider.of<AuthProvider>(context).currency;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xfffada36),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(
          "Checkout",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
      body: Builder(builder: (context) {
        return Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: ListView(
                  children: <Widget>[
                    Form(
                        key: _formKey,
                        child: Column(children: <Widget>[
                          selectedAddressSection(user),
                          priceSection(currency),
                        ])),
                  ],
                ),
              ),
              flex: 90,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: RaisedButton(
                  onPressed: () {
                    final form = _formKey.currentState!;
                    if (form.validate()) {
                      if (_firstPress) {
                        _firstPress = false;
                        submitOrder(
                            ScopedModel.of<CartModel>(context,
                                    rebuildOnChange: true)
                                .cart,
                            user['id'].toString(),
                            customer_mobile,
                            delivery_address,
                            ScopedModel.of<CartModel>(context,
                                    rebuildOnChange: true)
                                .totalCartValue,
                            ScopedModel.of<CartModel>(context,
                                    rebuildOnChange: true)
                                .ShopID,
                            ScopedModel.of<CartModel>(context,
                                    rebuildOnChange: true)
                                .deliveryCharge,
                            '',
                            '_555',
                            '_6666',
                            token);
                      }
                      if (_OrderSucess != null) {
                        ScopedModel.of<CartModel>(context,
                                rebuildOnChange: true)
                            .clearCart();
                        showThankYouBottomSheet(
                            context, _OrderSucess, _OrderId, _OrderAmount);
                      }
                    }
                  },
                  child: Text(
                    "Place Order",
                    style: CustomTextStyle.textFormFieldMedium.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  color: Color(0xfffada36),
                  textColor: Colors.white,
                ),
              ),
              flex: 10,
            )
          ],
        );
      }),
    );
  }

  showThankYouBottomSheet(BuildContext context, resBody, orderId, amount) {
    return _scaffoldKey.currentState!.showBottomSheet((context) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200, width: 2),
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(16), topLeft: Radius.circular(16))),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image(
                    image: AssetImage("assets/icons/ic_thank_you.png"),
                    width: 300,
                  ),
                ),
              ),
              flex: 5,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  children: <Widget>[
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          TextSpan(
                            text:
                                "\n\nThank you for your purchase. Our company values each and every customer. We strive to provide state-of-the-art devices that respond to our clients’ individual needs. If you have any questions or feedback, please don’t hesitate to reach out.",
                            style: CustomTextStyle.textFormFieldMedium.copyWith(
                                fontSize: 14, color: Colors.grey.shade800),
                          )
                        ])),
                    SizedBox(
                      height: 24,
                    ),
                    new Container(
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyHomePage(
                                            title: 'My Order',
                                            tabsIndex: 1,
                                          )));
                            },
                            padding: EdgeInsets.only(left: 35, right: 35),
                            child: Text(
                              "My Orders",
                              style: CustomTextStyle.textFormFieldMedium
                                  .copyWith(color: Colors.white),
                            ),
                            color: Color(0xfffada36),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(24))),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              flex: 10,
            )
          ],
        ),
      );
    },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        backgroundColor: Colors.white,
        elevation: 2);
  }

  selectedAddressSection(user) {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              border: Border.all(color: Colors.grey.shade200)),
          padding: EdgeInsets.only(left: 12, top: 8, right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 6,
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xfff3f3f4),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0),
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      )),
                  child: TextField(
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      setState(() {
                        SerchCustomer(value != null ? value : null);
                      });
                    },
                    controller: editingControlCustomerler,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      contentPadding: EdgeInsets.only(top: 14.0),
                      hintText: 'Search for customer phone',
                      hintStyle:
                          TextStyle(fontFamily: 'Montserrat', fontSize: 14.0),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              _nameWidget(),
              _emailWidget(),
              _phoneWidget(),
              _addressWidget(),
              SizedBox(
                height: 16,
              ),
              Container(
                color: Colors.grey.shade300,
                height: 1,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nameWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Name *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                  obscureText: false,
                  controller: _controllerName,
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontSize: 18,
                    height: 0.6,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54)),
                    hintText: "Enter name",
                  ),
                  validator: (value) {
                    name = value!.trim();
                    return Validate.requiredField(value, 'Name is required.');
                  })
            ],
          ),
        )
      ],
    );
  }

  Widget _emailWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Email *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                  obscureText: false,
                  controller: _controllerEmail,
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontSize: 18,
                    height: 0.6,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54)),
                    hintText: "Enter email",
                  ),
                  validator: (value) {
                    email = value!.trim();
                    return Validate.requiredField(value, 'Email is required.');
                  })
            ],
          ),
        )
      ],
    );
  }

  Widget _phoneWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Phone *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: false,
                  controller: _controllerPhone,
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 18,
                    height: 0.6,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54)),
                    hintText: "Enter phone",
                  ),
                  validator: (value) {
                    customer_mobile = value!.trim();
                    return Validate.requiredField(value, 'Phone is required.');
                  })
            ],
          ),
        )
      ],
    );
  }

  Widget _addressWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Delivery Address *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                  obscureText: false,
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontSize: 18,
                    height: 0.6,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54)),
                    hintText: "Enter address",
                  ),
                  validator: (value) {
                    delivery_address = value!.trim();
                    return Validate.requiredField(
                        value, 'address is required.');
                  })
            ],
          ),
        )
      ],
    );
  }

  createAddressText(user, double topMargin) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: Text(
        user != null ? user : '',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey.shade800),
      ),
    );
  }

  priceSection(currency) {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              border: Border.all(color: Colors.grey.shade200)),
          padding: EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 4,
              ),
              Text(
                "PRICE DETAILS",
                style: CustomTextStyle.textFormFieldMedium.copyWith(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 4,
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                margin: EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade400,
              ),
              SizedBox(
                height: 8,
              ),
              createPriceItem(
                  "Order Total",
                  currency,
                  '${ScopedModel.of<CartModel>(context, rebuildOnChange: true).totalCartValue}',
                  Colors.grey.shade700),
              createPriceItem(
                  "Delievery Charges",
                  currency,
                  '${ScopedModel.of<CartModel>(context, rebuildOnChange: true).deliveryCharge}',
                  Colors.teal.shade300),
              SizedBox(
                height: 8,
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                margin: EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade400,
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Total",
                    style: CustomTextStyle.textFormFieldSemiBold
                        .copyWith(color: Colors.black, fontSize: 12),
                  ),
                  Text(
                    "$currency" +
                        '${ScopedModel.of<CartModel>(context, rebuildOnChange: true).totalCartValue + ScopedModel.of<CartModel>(context, rebuildOnChange: true).deliveryCharge}',
                    style: CustomTextStyle.textFormFieldMedium
                        .copyWith(color: Colors.black, fontSize: 12),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  createPriceItem(String key, String? currency, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            key,
            style: CustomTextStyle.textFormFieldMedium
                .copyWith(color: Colors.grey.shade700, fontSize: 12),
          ),
          Text(
            '$currency' + value,
            style: CustomTextStyle.textFormFieldMedium
                .copyWith(color: color, fontSize: 12),
          )
        ],
      ),
    );
  }
}
