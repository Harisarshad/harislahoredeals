import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/Widget/CircularLoadingWidget.dart';
import 'package:eBazaarMerchant/src/screens/orderhistoryView.dart';
import 'package:eBazaarMerchant/src/utils/CustomTextStyle.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class OrderPage extends StatefulWidget {
  OrderPage({
    Key? key,
  }) : super(key: key);

  @override
  _OrderHistoryPageState createState() {
    return new _OrderHistoryPageState();
  }
}

class Item {
  final String? name;
  final String? deliveryTime;
  final String? oderId;
  final String? oderAmount;
  final String? status_name;
  final String? status;
  final String? oderCode;
  final String? paymentType;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? address;
  final String? user;
  final List? Items;

  Item(
      {this.name,
      this.deliveryTime,
      this.oderId,
      this.oderAmount,
      this.paymentType,
      this.address,
      this.oderCode,
      this.status_name,
      this.status,
      this.user,
      this.Items,
      this.paymentMethod,
      this.paymentStatus});
}

class _OrderHistoryPageState extends State<OrderPage> {
  GlobalKey<RefreshIndicatorState>? refreshKey;

  String api = FoodApi.baseApi;
  List? resOrder = [];
  List<Item> itemList = <Item>[];
  String? token;
  String? currency;
  Map<String, dynamic> user = {
    "name": '',
    "email": '',
    "image": '',
    "username": '',
    "phone": '',
    "address": ''
  };

  Future<String> getmyOrder() async {
    final url = "$api/shop-order";
    var response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: "application/json; charset=utf-8"
    });
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        resOrder = resBody['data'];
        resOrder!.forEach((element) {
          var order = json.decode(element['misc']);
          itemList.add(Item(
            name: 'shop',
            deliveryTime: element['created_at'],
            oderId: '${element['id']}',
            oderCode: '${order['order_code']}',
            oderAmount: '${element['total']}',
            paymentType: element['payment_status'].toString() == '10'
                ? 'Cash on delivery'
                : 'Paid',
            paymentMethod: '${element['payment_method']}',
            paymentStatus: '${element['payment_status']}',
            address: element['address'],
            status: element['status'].toString(),
            status_name: element['status_name'],
            user: element['user']['name'],
          ));
        });
      });
    } else {
      throw Exception('Failed to data');
    }
    return "Success";
  }

  Future<Void?> orderUpdate(String? id, String status) async {
    final url = "$api/shop-order/$id?status=$status";
    final response = await http.put(Uri.parse(url), headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        itemList.clear();
        this.getmyOrder();
        if (status == "14") {
          _showAlert(context, 'Order Accepted');
        } else {
          _showAlert(context, 'Order Reject');
        }
      });
    } else {
      throw Exception('Failed to data');
    }
  }

  Future<void> _showAlert(BuildContext context, title) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text('Successfully Updated Order'),
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

  Future<Null> refreshList(String? token) async {
    setState(() {
      itemList.clear();
      this.getmyOrder();
    });
  }

  @override
  void initState() {
    super.initState();
    token = Provider.of<AuthProvider>(context, listen: false).token;
    currency = Provider.of<AuthProvider>(context, listen: false).currency;
    getmyOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(000),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: () async {
          await refreshList(token);
        },
        child: itemList.isEmpty
            ? ListView(
                children: <Widget>[
                  CircularLoadingWidget(
                      height: 400,
                      subtitleText: 'No Orders Found',
                      img: 'assets/shopping6.png')
                ],
              )
            : ListView.builder(
                itemCount: itemList.length,
                itemBuilder: (BuildContext cont, int ind) {
                  return SafeArea(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return new OrderViewPage(
                                orderID: itemList[ind].oderId.toString(),
                                currency: currency);
                          }),
                        );
                      },
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                                left: 5.0, right: 5.0, bottom: 5.0),
                            child: Card(
                              elevation: 4.0,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                    10.0, 10.0, 10.0, 10.0),
                                child: GestureDetector(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      // three line description
                                      Container(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          ' ' + itemList[ind].user!,
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontStyle: FontStyle.normal,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),

                                      Container(
                                        margin: EdgeInsets.only(top: 3.0),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          'To Deliver On :' +
                                              itemList[ind].deliveryTime!,
                                          style: TextStyle(
                                              fontSize: 13.0,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      Divider(
                                        height: 10.0,
                                        color: Colors.amber.shade500,
                                      ),

                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                              padding: EdgeInsets.all(3.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    'Order Code',
                                                    style: TextStyle(
                                                        fontSize: 13.0,
                                                        color: Colors.black54),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 3.0),
                                                    child: Text(
                                                      itemList[ind].oderCode!,
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                  )
                                                ],
                                              )),
                                          Container(
                                              padding: EdgeInsets.all(3.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    'Order Amount',
                                                    style: TextStyle(
                                                        fontSize: 13.0,
                                                        color: Colors.black54),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 3.0),
                                                    child: Text(
                                                      '$currency ' +
                                                          itemList[ind]
                                                              .oderAmount!,
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                          Container(
                                              padding: EdgeInsets.all(3.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    'Payment Status',
                                                    style: TextStyle(
                                                        fontSize: 13.0,
                                                        color: Colors.black54),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 3.0),
                                                    child: Text(
                                                      itemList[ind]
                                                          .paymentType!,
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                  )
                                                ],
                                              )),
                                        ],
                                      ),
                                      Divider(
                                        height: 10.0,
                                        color: Colors.amber.shade500,
                                      ),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(
                                            Icons.location_on,
                                            size: 20.0,
                                            color: Colors.amber.shade500,
                                          ),
                                          Text(itemList[ind].address!,
                                              style: TextStyle(
                                                  fontSize: 13.0,
                                                  color: Colors.black54)),
                                        ],
                                      ),
                                      Divider(
                                        height: 10.0,
                                        color: Colors.amber.shade500,
                                      ),
                                      itemList[ind].status == '5'
                                          ? Container(
                                              child: new Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  RaisedButton(
                                                    onPressed: () {
                                                      orderUpdate(
                                                        itemList[ind].oderId,
                                                        '12',
                                                      );
                                                    },
                                                    padding: EdgeInsets.only(
                                                        left: 30, right: 30),
                                                    child: Text(
                                                      "Reject",
                                                      style: CustomTextStyle
                                                          .textFormFieldMedium
                                                          .copyWith(
                                                              color:
                                                                  Colors.white),
                                                    ),
                                                    color: Colors.red,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    24))),
                                                  ),
                                                  SizedBox(
                                                    width: 15,
                                                  ),
                                                  RaisedButton(
                                                    onPressed: () {
                                                      orderUpdate(
                                                        itemList[ind].oderId,
                                                        '14',
                                                      );
                                                    },
                                                    padding: EdgeInsets.only(
                                                        left: 30, right: 30),
                                                    child: Text(
                                                      "Accept",
                                                      style: CustomTextStyle
                                                          .textFormFieldMedium
                                                          .copyWith(
                                                              color:
                                                                  Colors.white),
                                                    ),
                                                    color: Colors.green,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(
                                                          24,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
