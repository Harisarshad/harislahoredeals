import 'dart:io';

import 'package:flutter/material.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/Widget/CircularLoadingWidget.dart';
import 'package:eBazaarMerchant/src/Widget/drawer.dart';
import 'package:eBazaarMerchant/src/shared/colors.dart';
import 'package:eBazaarMerchant/src/utils/CustomTextStyle.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class TranstionList {
  String? id;
  String? type;
  String? amount;
  String? date;
  TranstionList({this.type, this.id, this.amount, this.date});

  Map<String, dynamic> TojsonData() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["type"] = type;
    map["amount"] = amount;
    map["date"] = date;
    return map;
  }
}

class Transaction extends StatefulWidget {
  @override
  _Transaction createState() => _Transaction();
}

class _Transaction extends State<Transaction> {
  GlobalKey<RefreshIndicatorState>? refreshKey;

  List? _listTransaction = [];
  List<TranstionList> _transtionList = [];
  String api = FoodApi.baseApi;
  String? token;
  String? currency;

  Future<String> getTransaction(token) async {
    final url = "$api/transactions";
    var response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: "application/json; charset=utf-8"
    });
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      _transtionList.clear();
      setState(() {
        _listTransaction = resBody['data'];
        _listTransaction!.forEach((element) => _transtionList.add(TranstionList(
            type: element['type'],
            date: element['date'],
            id: element['id'].toString(),
            amount: element['amount'])));
      });
    } else {
      throw Exception('Failed to data');
    }
    return "Sucess";
  }

  @override
  void initState() {
    super.initState();
    token = Provider.of<AuthProvider>(context, listen: false).token;
    currency = Provider.of<AuthProvider>(context, listen: false).currency;
    getTransaction(token);
  }

  Future<Null> refreshList() async {
    setState(() {
      _transtionList.clear();
      this.getTransaction(token);
    });
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
            "Transaction",
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
                _transtionList.isEmpty
                    ? ListView(
                        children: <Widget>[
                          SizedBox(
                            height: 40,
                          ),
                          CircularLoadingWidget(
                            height: 500,
                            subtitleText: 'No Transaction found',
                            img: 'assets/shopping1.png',
                          )
                        ],
                      )
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: _transtionList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(
                                _transtionList[index].type!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: CustomTextStyle.textFormFieldMedium
                                    .copyWith(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                _transtionList[index].date!,
                                style: CustomTextStyle.textFormFieldMedium
                                    .copyWith(
                                        color: Colors.black87,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                              ),
                              trailing: RichText(
                                  text: TextSpan(children: [
                                new TextSpan(
                                  text: _transtionList[index].amount! + ' ',
                                  style: TextStyle(
                                      fontFamily: 'Google Sans',
                                      color: Color(0xFFF75A4C),
                                      fontSize: 16.0),
                                ),
                              ])),
                            ),
                          );
                        },
                      ),
              ],
            )));
  }
}
