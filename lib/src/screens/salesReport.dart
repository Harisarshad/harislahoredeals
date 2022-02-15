import 'dart:io';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/services.dart';
import 'package:eBazaarMerchant/src/Widget/drawer.dart';
import 'package:eBazaarMerchant/src/Widget/styled_flat_button.dart';
import 'package:eBazaarMerchant/src/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/Widget/CircularLoadingWidget.dart';
import 'package:eBazaarMerchant/src/utils/CustomTextStyle.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SalesReport extends StatefulWidget {
  SalesReport({
    Key? key,
  }) : super(key: key);

  @override
  _SalesReportState createState() {
    return new _SalesReportState();
  }
}

class Item {
  final String? shopName;
  final String? dateTime;
  final String? oderId;
  final String? PaidAmount;
  final String? totalAmount;
  final String? subTotal;
  final String? status_name;
  final String? status;
  final String? oderCode;
  final String? paymentMethod;
  final String? paymentStatus;

  Item(
      {this.shopName,
      this.dateTime,
      this.oderId,
      this.PaidAmount,
      this.subTotal,
      this.totalAmount,
      this.oderCode,
      this.status_name,
      this.status,
      this.paymentMethod,
      this.paymentStatus});
}

class _SalesReportState extends State<SalesReport> {
  GlobalKey<RefreshIndicatorState>? refreshKey;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String api = FoodApi.baseApi;
  List? resOrder = [];
  List<Item> itemList = <Item>[];
  String? token;
  DateTime? fromDate;
  DateTime? toDate;
  String? currency;

  Future<String> getReport() async {
    refreshList(token);
    final url = "$api/shop-owner-sales-report";
    Map<String, String> body = {
      "from_date": fromDate != null ? fromDate.toString() : '',
      "to_date": toDate != null ? toDate.toString() : '',
    };
    final response = await http.post(Uri.parse(url), body: body, headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        resOrder = resBody['data'];
        resOrder!.forEach((element) {
          itemList.add(Item(
            shopName: element['shop_name'],
            oderCode: '${element['order_code']}',
            subTotal: '${element['sub_total']}',
            totalAmount: '${element['total']}',
            PaidAmount: '${element['paid_amount']}',
            paymentMethod: '${element['payment_method_name']}',
            paymentStatus: '${element['payment_status_name']}',
            status_name: element['status_name'],
            dateTime: element['updated_at'],
          ));
        });
      });
    } else {
      throw Exception('Failed to data');
    }
    return "Success";
  }

  Future<Null> refreshList(String? token) async {
    setState(() {
      itemList.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    token = Provider.of<AuthProvider>(context, listen: false).token;
    currency = Provider.of<AuthProvider>(context, listen: false).currency;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          iconTheme: new IconThemeData(color: Colors.white),
          backgroundColor: primaryColor,
          title: Text(
            "Sales Report",
            style: TextStyle(color: Colors.white),
          ),
        ),
        drawer: AppDrawer(),
        body: RefreshIndicator(
          key: refreshKey,
          onRefresh: () async {
            await refreshList(token);
          },
          child: ListView(
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: _date(),
                      margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 48, right: 48),
                      child: StyledFlatButton(
                        'Get Report',
                        onPressed: getReport,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  leading: Icon(
                    Icons.library_books,
                    color: Colors.black54,
                  ),
                  title: Text(
                    'Sales Report',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyle.textFormFieldMedium.copyWith(
                        color: Colors.black54,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              itemList.isEmpty
                  ? CircularLoadingWidget(
                      height: 100,
                      subtitleText: 'No Data Found',
                      img: 'assets/shopping.png',
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: itemList.length,
                      itemBuilder: (BuildContext cont, int ind) {
                        return SafeArea(
                            child: Column(children: <Widget>[
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
                                          ' ' + itemList[ind].shopName!,
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
                                          'Date - ' + itemList[ind].dateTime!,
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
                                          Expanded(
                                            child: Container(
                                                padding: EdgeInsets.all(3.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      'Order Code',
                                                      style: TextStyle(
                                                          fontSize: 13.0,
                                                          color:
                                                              Colors.black54),
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
                                          ),
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
                                                          .paymentStatus!,
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
                                                    'Payment Method',
                                                    style: TextStyle(
                                                        fontSize: 13.0,
                                                        color: Colors.black54),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 3.0),
                                                    child: Text(
                                                      itemList[ind]
                                                          .paymentMethod!,
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
                                                    'Status',
                                                    style: TextStyle(
                                                        fontSize: 13.0,
                                                        color: Colors.black54),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 3.0),
                                                    child: Text(
                                                      itemList[ind]
                                                          .status_name!,
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
                                                    'Sub Total',
                                                    style: TextStyle(
                                                        fontSize: 13.0,
                                                        color: Colors.black54),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 3.0),
                                                    child: Text(
                                                      '$currency' +
                                                          itemList[ind]
                                                              .subTotal!,
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
                                                    'Total',
                                                    style: TextStyle(
                                                        fontSize: 13.0,
                                                        color: Colors.black54),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 3.0),
                                                    child: Text(
                                                      '$currency' +
                                                          itemList[ind]
                                                              .totalAmount!,
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
                                                    'Paid Amount',
                                                    style: TextStyle(
                                                        fontSize: 13.0,
                                                        color: Colors.black54),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 3.0),
                                                    child: Text(
                                                      '$currency' +
                                                          itemList[ind]
                                                              .PaidAmount!,
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
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]));
                      })
            ],
          ),
        ));
  }

  Widget _date() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    final format = DateFormat("yyyy-MM-dd");
    return Row(
      children: <Widget>[
        Expanded(
            child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'From Date',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              DateTimeField(
                format: format,
                decoration: InputDecoration(
                  labelText: 'Date',
                ),
                readOnly: true,
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                },
              ),
            ],
          ),
        )),
        SizedBox(width: 15.0),
        Expanded(
            child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'To Date',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              DateTimeField(
                format: format,
                decoration: InputDecoration(
                  labelText: 'Date',
                ),
                readOnly: true,
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                },
              ),
            ],
          ),
        ))
      ],
    );
  }
}
