import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/src/Widget/CircularLoadingWidget.dart';
import 'package:eBazaarMerchant/src/Widget/drawer.dart';
import 'package:eBazaarMerchant/src/screens/ProductRequestEdit.dart';
import 'package:eBazaarMerchant/src/screens/ProductRequstPost.dart';
import 'package:eBazaarMerchant/src/shared/Product.dart';
import 'package:eBazaarMerchant/src/shared/colors.dart';
import 'package:provider/provider.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductRequestList extends StatefulWidget {
  ProductRequestList({Key? key}) : super(key: key);

  @override
  _ProductRequestList createState() => _ProductRequestList();
}

class _ProductRequestList extends State<ProductRequestList> {
  TextEditingController editingProductsController = TextEditingController();
  GlobalKey<RefreshIndicatorState>? refreshKey;

  String api = FoodApi.baseApi;
  List<Product> _products = [];
  List? _listProduct = [];
  String? token;
  String? shopID;

  Future<String> getProducts(String? shopID) async {
    final url = "$api/request-product";
    var response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _listProduct = resBody['data'];
        _listProduct!.forEach((element) => _products.add(Product(
            name: element['name'],
            id: element['id'],
            imgUrl: element['image'],
            categories: element['categories'],
            categoriesID: element['categoriesID'],
            description: element['description'],
            price: double.parse(element['unit_price']))));
      });
    } else {
      throw Exception('Failed to');
    }
    return "Success";
  }

  Future<void> getDelete(String productID) async {
    final url = "$api/request-product/$productID";
    final response = await http.delete(Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      _showAlert(context, true, 'Successfully Delete Request Product ');
    } else {
      _showAlert(context, false, 'Not Successfully Delete Request Product ');
      throw Exception('Failed to data');
    }
  }

  Future<void> _showAlert(BuildContext context, bool, mes) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Product Request List'),
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
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        iconTheme: new IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
        title: Text(
          "Product Request List",
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
            _products.isEmpty
                ? ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      SizedBox(
                        height: 100,
                      ),
                      CircularLoadingWidget(
                          height: 500,
                          subtitleText: 'No products found',
                          img: 'assets/shopping1.png')
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
                            SlidableAction(
                              label: 'Edit',
                              backgroundColor: Colors.black45,
                              icon: Icons.edit,
                              onPressed: (context) {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ProductRequestEdit(
                                    product: _products[index],
                                  ),
                                ));
                              },
                            ),
                            SlidableAction(
                              label: 'Delete',
                              backgroundColor: Colors.red,
                              icon: Icons.delete,
                              onPressed: (context) {
                                getDelete(_products[index].id.toString());
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
                    builder: (context) => ProductRequstPost(),
                  ));
                },
                isExtended: true,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                icon: Icon(Icons.add_circle_outline),
                label: Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildFoodCard(context, currency, Product food) {
  return InkWell(
    splashColor: Theme.of(context).colorScheme.secondary,
    focusColor: Theme.of(context).colorScheme.secondary,
    highlightColor: Theme.of(context).primaryColor,
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
                      Flexible(
                        child: Text(
                          food.name!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
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
                          text: ' $currency' + (food.price).toString(),
                          style: TextStyle(
                              fontFamily: 'Google Sans',
                              color: Color(0xFFF75A4C),
                              fontSize: 16.0),
                        ),
                      ])),
                      flex: -1,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}
