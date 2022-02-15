import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/src/Widget/CircularLoadingWidget.dart';
import 'package:eBazaarMerchant/src/Widget/drawer.dart';
import 'package:eBazaarMerchant/src/screens/RequstWithdrawPost.dart';
import 'package:eBazaarMerchant/src/shared/colors.dart';
import 'package:eBazaarMerchant/src/utils/CustomTextStyle.dart';
import 'package:provider/provider.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'WithdrawRequstEdit.dart';

class WithdrawList {
  String? id;
  String? name;
  int? amount;
  String? date;
  String? dateDB;
  String? status_label;
  String? status;
  WithdrawList(
      {this.name,
      this.id,
      this.amount,
      this.date,
      this.dateDB,
      this.status_label,
      this.status});

  Map<String, dynamic> TojsonData() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["date"] = date;
    map["dateDB"] = dateDB;
    map["amount"] = amount;
    map["status"] = status;
    map["status_label"] = status_label;
    return map;
  }
}

class RequestWithdrawList extends StatefulWidget {
  RequestWithdrawList({Key? key}) : super(key: key);

  @override
  _RequesWithdrawtList createState() => _RequesWithdrawtList();
}

class _RequesWithdrawtList extends State<RequestWithdrawList> {
  TextEditingController editingProductsController = TextEditingController();
  GlobalKey<RefreshIndicatorState>? refreshKey;

  String api = FoodApi.baseApi;
  List<WithdrawList> _withdrawList = [];
  List? _listProduct = [];
  String? token;
  String? shopID;
  String? currency;

  Future<String> getRequestWithdraw(String? shopID) async {
    final url = "$api/request-withdraw";
    var response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      setState(() {
        _listProduct = resBody['data'];
        _listProduct!.forEach((element) => _withdrawList.add(WithdrawList(
            name: element['name'],
            date: element['date'],
            dateDB: element['date_db_style'],
            id: element['id'].toString(),
            amount: int.tryParse('${element['amount']}')!.toInt(),
            status_label: element['status_label'])));
      });
    } else {
      throw Exception('Failed to');
    }
    return "Success";
  }

  Future<void> getDelete(String withdrawID) async {
    final url = "$api/request-withdraw/$withdrawID";
    final response = await http.delete(Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      _DeleteAlert(context, true, 'Successfully Delete Request Withdraw ');
    } else {
      _DeleteAlert(context, false, 'Not Successfully Delete Request Withdraw ');
      throw Exception('Failed to data');
    }
  }

  Future<void> _showAlert(BuildContext context, bool, mes) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Product Request Update'),
          content: Text(mes),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                if (bool) {
                  refreshList();
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _DeleteAlert(BuildContext context, bool, mes) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Request Withdraw Delete'),
          content: Text(mes),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                if (bool) {
                  refreshList();
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<Null> refreshList() async {
    setState(() {
      shopID = Provider.of<AuthProvider>(context, listen: false).shopID;
      _withdrawList.clear();
      this.getRequestWithdraw(shopID);
    });
  }

  @override
  void initState() {
    super.initState();
    shopID = Provider.of<AuthProvider>(context, listen: false).shopID;
    token = Provider.of<AuthProvider>(context, listen: false).token;
    getRequestWithdraw(shopID);
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AuthProvider>(context).currency;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        iconTheme: new IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
        title: Text(
          "Request Withdraw List",
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: () async {
          await refreshList();
        },
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _withdrawList.isEmpty
                ? ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      SizedBox(
                        height: 100,
                      ),
                      CircularLoadingWidget(
                          height: 500,
                          subtitleText: 'Request withdraw no found',
                          img: 'assets/shopping1.png')
                    ],
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    primary: false,
                    itemCount: _withdrawList.length,
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 10);
                    },
                    itemBuilder: (context, index) {
                      return Slidable(
                        startActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                              label: 'Edit',
                              backgroundColor: Colors.black45,
                              icon: Icons.edit,
                              onPressed: (context) {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => WithdrawRequestEdit(
                                    withdrawList: _withdrawList[index],
                                  ),
                                ));
                              },
                            ),
                            SlidableAction(
                              label: 'Delete',
                              backgroundColor: Colors.red,
                              icon: Icons.delete,
                              onPressed: (context) {
                                getDelete(_withdrawList[index].id.toString());
                              },
                            ),
                          ],
                        ),
                        child: Container(
                          height: 80,
                          color: Colors.white,
                          child: _buildFoodCard(
                            context,
                            currency,
                            _withdrawList[index],
                          ),
                        ),
                      );
                    },
                  ),
            Positioned(
              bottom: 10,
              right: 10,
              child: FloatingActionButton.extended(
                backgroundColor: Color(0xfffada36),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => RequestWithdrawPost(),
                  ));
                },
                isExtended: true,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                icon: Icon(Icons.add_circle_outline),
                label: Text('Request Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildFoodCard(context, currency, WithdrawList withdraw) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
            color: Theme.of(context).focusColor.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2)),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Container(
            height: 70,
            width: 70,
            decoration: new BoxDecoration(
              border: new Border(
                right: new BorderSide(width: 1.0, color: Colors.white24),
              ),
            ),
            child: Icon(Icons.payment, size: 70, color: Colors.black54),
          ),
        ),
        SizedBox(width: 15),
        Flexible(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        withdraw.name!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: CustomTextStyle.textFormFieldMedium.copyWith(
                            color: Colors.black54,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      withdraw.date!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: CustomTextStyle.textFormFieldMedium.copyWith(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      withdraw.status_label!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: CustomTextStyle.textFormFieldMedium.copyWith(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Text(
                "$currency" + withdraw.amount.toString(),
                style: CustomTextStyle.textFormFieldMedium.copyWith(
                    color: Colors.black54,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        )
      ],
    ),
  );
}
