import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/models/cartmodel.dart';
import 'package:eBazaarMerchant/src/Widget/CircularLoadingWidget.dart';
import 'package:eBazaarMerchant/src/screens/ProductEdit.dart';
import 'package:eBazaarMerchant/src/screens/ProductPage.dart';
import 'package:eBazaarMerchant/src/screens/ProductPost.dart';
import 'package:eBazaarMerchant/src/shared/Product.dart';
import 'package:provider/provider.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../main.dart';

class ProductList extends StatefulWidget {
  final String? categoryID;
  final String? category;
  final shop;
  final CartModel? model;
  ProductList({Key? key, this.category, this.categoryID, this.shop, this.model})
      : super(key: key);

  @override
  _ProductAllState createState() => _ProductAllState();
}

class _ProductAllState extends State<ProductList> {
  TextEditingController editingProductsController = TextEditingController();
  GlobalKey<RefreshIndicatorState>? refreshKey;

  String api = FoodApi.baseApi;
  List<Product> _products = [];
  List? _listProduct = [];
  String? token;
  String? shopID;

  Future<String> getProducts(String? shopID) async {
    final url = "$api/shop-product/1/shop/product";
    print (url);
    var response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });
    print(token);
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        print(resBody);
        _listProduct = resBody['data'];

        print(_listProduct);
        _listProduct!.forEach((element) {
          _products.add(Product(
              variations: element['variations'],
              options: element['options'],
              name: element['name'],
              id: element['id'],
              productItemID: element['id'],
              imgUrl: element['image'],
              quantity: element['p_society'],
              plot_no: element['plot_no'].toString(),
              size: element['size'].toString(),
              price: double.tryParse('${element['unit_price']}')!.toDouble(),
              discount:
                  double.tryParse('${element['discount_price']}')!.toDouble()));
        });
      });
    } else {
      throw Exception('Failed to');
    }
    return "Success";
  }

  Future<void> getDelete(String productID) async {
    final url = "$api/shop-product/$shopID/shop/$productID/product";
    final response = await http.delete(Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      _showAlert(context, true, 'Successfully Delete Product ');
    } else {
      _showAlert(context, false, 'Not Successfully Delete Product ');
      throw Exception('Failed to data');
    }
  }

  Future<void> _showAlert(BuildContext context, bool, mes) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Product Update'),
          content: Text(mes),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                if (bool) {
                  Navigator.of(context).pop();
                  refreshList();
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
      _products.clear();
      this.getProducts(shopID);
    });
  }

  @override
  void initState() {
    super.initState();
    shopID = Provider.of<AuthProvider>(context, listen: false).shopID;
    token = Provider.of<AuthProvider>(context, listen: false).token;
    getProducts(shopID);
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AuthProvider>(context).currency;

    return Scaffold(
        backgroundColor: Colors.indigo[50],
        body: RefreshIndicator(
            key: refreshKey,
            onRefresh: () async {
              await refreshList();
            },
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                _products.isEmpty
                    ? ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          SizedBox(
                            height: 145.0,
                          ),
                          CircularLoadingWidget(
                            height: 200,
                            subtitleText: 'No Products Found',
                            img: 'assets/shopping6.png',
                          )
                        ],
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: _products.length,
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 10);
                        },
                        itemBuilder: (context, index) {
                          return Slidable(
                            startActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.25,
                              children: [

                                //haris arshad
                                // SlidableAction(
                                //   label: 'Edit',
                                //   backgroundColor: Colors.black45,
                                //   icon: Icons.edit,
                                //   onPressed: (context) {
                                //     Navigator.of(context)
                                //         .push(MaterialPageRoute(
                                //       builder: (context) => ProductEdit(
                                //         product: _products[index],
                                //       ),
                                //     ));
                                //   },
                                // ),
                                SlidableAction(
                                  label: 'Delete',
                                  backgroundColor: Colors.red,
                                  icon: Icons.delete,
                                  onPressed: (context) {
                                    getDelete(_products[index]
                                        .productItemID
                                        .toString());
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
                                _products[index],
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return new ProductPage(
                                          currency: currency,
                                          productData: _products[index]);
                                    }),
                                  );
                                },
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
                        builder: (context) => ProductPost(),
                      ));
                    },
                    isExtended: true,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    icon: Icon(Icons.add_circle_outline),
                    label: Text('Add'),
                  ),
                ),
              ],
            )));
  }
}

Widget _buildFoodCard(context, currency, Product food, onTapped) {
  return InkWell(
    splashColor: Theme.of(context).colorScheme.secondary,
    focusColor: Theme.of(context).colorScheme.secondary,
    highlightColor: Theme.of(context).primaryColor,
    onTap: onTapped,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
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
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                image: DecorationImage(
                    image: NetworkImage(food.imgUrl!), fit: BoxFit.cover),
              ),
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
                      Text(
                        food.name!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      Text(
                        'Plot Size - ' + food.size.toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Text(
                        'Plot no - ' + food.plot_no.toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 5),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RichText(
                          text: TextSpan(children: [
                        new TextSpan(
                          text: ' Rs' +
                              (food.price! - food.discount!).toString(),
                          style: TextStyle(
                              fontFamily: 'Google Sans',
                              color: Color(0xFFF75A4C),
                              fontSize: 14.0),
                        ),
                      ])),
                      flex: -1,
                    ),
                    SizedBox(width: 15),
                    food.discount != 0
                        ? RichText(
                            text: TextSpan(children: [
                            new TextSpan(
                              text: '$currency' + food.price.toString(),
                              style: new TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                                fontFamily: 'Google Sans',
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ]))
                        : Container(),
                  ],
                ),

//                Row(
//                  children: <Widget>[
//                    Text('$currency' + food.price.toString(), style: TextStyle(fontFamily: 'Google Sans', fontSize: 18.0,fontWeight: FontWeight.bold, color: Colors.black87,),),
//                    Text('$currency' + food.price.toString(), style: TextStyle( fontFamily: 'Google Sans',fontSize: 15.0,  color: Colors.black54,),),
//                  ],
//                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}
