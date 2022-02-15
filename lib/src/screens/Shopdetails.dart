import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/Widget/CircularLoadingWidget.dart';
import 'package:eBazaarMerchant/src/Widget/drawer.dart';
import 'package:eBazaarMerchant/src/screens/ShopEditPage.dart';
import 'package:eBazaarMerchant/src/shared/Product.dart';
import 'package:eBazaarMerchant/src/utils/CustomTextStyle.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ProductPage.dart';

class ShopDetailsWidget extends StatefulWidget {
  ShopDetailsWidget({
    Key? key,
  }) : super(key: key);

  @override
  _DetailsWidgetState createState() {
    return _DetailsWidgetState();
  }
}

class _DetailsWidgetState extends State<ShopDetailsWidget> {
  GlobalKey<RefreshIndicatorState>? refreshKey;
  List<Product> _products = [];
  List? _listProduct = [];
  String api = FoodApi.baseApi;
  String? token;

  Map<String, dynamic> shop = {
    "shop": '',
    "id": '',
    "name": '',
    "delivery_charge": 0.0,
    "opening_time": '',
    "phone": '',
    "closing_time": '',
    "image": null,
    "description": '',
    "address": ''
  };

  Future<String> getShop(String? shopID, token) async {
    final url = "$api/shop/$shopID/show";
    var response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      setState(() {
        shop['shop'] = resBody['data'];
        shop['id'] = resBody['data']['id'];
        shop['name'] = resBody['data']['name'];
        shop['description'] = resBody['data']['description'];
        shop['delivery_charge'] = resBody['data']['delivery_charge'] != null
            ? resBody['data']['delivery_charge'].toDouble()
            : 0.0;
        shop['opening_time'] = resBody['data']['opening_time'];
        shop['closing_time'] = resBody['data']['closing_time'];
        shop['address'] = resBody['data']['address'];
        shop['phone'] = resBody['data']['phone'];
        shop['image'] = resBody['data']['image'];
      });
    } else {
      throw Exception('Failed to data');
    }
    return "Success";
  }

  Future<String> getProducts(String? shopID) async {
    final url = "$api/shop-product/$shopID/shop/product";
    var response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      setState(() {
        _listProduct = resBody['data'];
        _listProduct!.forEach((element) => _products.add(Product(
            name: element['product']['name'],
            id: element['product']['id'],
            imgUrl: element['product']['image'],
            quantity: element['quantity'],
            avgRating: double.tryParse('${element['product']['avgRating']}'),
            price: double.tryParse('${element['unit_price']}')!.toDouble(),
            discount:
                double.tryParse('${element['discount_price']}')!.toDouble())));
      });
    } else {
      throw Exception('Failed to');
    }
    return "Success";
  }

  Future<Null> refreshList() async {
    setState(() {
      _products.clear();
      final shop = Provider.of<AuthProvider>(context, listen: false).shopID;
      getProducts(shop);
      getShop(shop, token);
    });
  }

  @override
  void initState() {
    super.initState();
    _products.clear();
    final shop = Provider.of<AuthProvider>(context, listen: false).shopID;
    token = Provider.of<AuthProvider>(context, listen: false).token;
    getProducts(shop);
    getShop(shop, token);
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AuthProvider>(context, listen: false).currency;
    return Scaffold(
        backgroundColor: Color(0xffF4F7FA),
        drawer: AppDrawer(),
        body: RefreshIndicator(
          key: refreshKey,
          onRefresh: () async {
            await refreshList();
          },
          child: shop['id'] == ''
              ? CircularLoadingWidget(
                  height: 600,
                  subtitleText: 'No shop',
                )
              : Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CustomScrollView(
                      primary: true,
                      shrinkWrap: false,
                      slivers: <Widget>[
                        SliverAppBar(
                          backgroundColor: Color(0xffffffff),
                          expandedHeight: 300,
                          elevation: 0,
                          iconTheme: IconThemeData(color: Color(0xfffada36)),
                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            background: shop['image'] != null
                                ? Container(
                                    child: Image.network(
                                      shop['image'],
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Wrap(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 20, left: 20, bottom: 10, top: 25),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        shop['name'] != null
                                            ? shop['name']
                                            : '',
                                        overflow: TextOverflow.fade,
                                        softWrap: true,
                                        maxLines: 2,
                                        style: CustomTextStyle
                                            .textFormFieldMedium
                                            .copyWith(
                                                color: Colors.black54,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.access_alarm,
                                      size: 16.0,
                                      color: Colors.amber.shade500,
                                    ),
                                    Text(
                                      ' Opening time ${shop['opening_time'] != null ? shop['opening_time'] : ''}',
                                      style: TextStyle(
                                          color: Color(0xFF575E67),
                                          fontFamily: 'Varela',
                                          fontSize: 15.0),
                                      softWrap: false,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.access_alarm,
                                      size: 16.0,
                                      color: Colors.amber.shade500,
                                    ),
                                    Text(
                                      ' Closing time ${shop['closing_time'] != null ? shop['closing_time'] : ''}',
                                      style: TextStyle(
                                          color: Color(0xFF575E67),
                                          fontFamily: 'Varela',
                                          fontSize: 15.0),
                                      softWrap: false,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.location_on,
                                      size: 16.0,
                                      color: Colors.amber.shade500,
                                    ),
                                    Text(
                                      shop['address'] != null
                                          ? shop['address']
                                          : '',
                                      style: TextStyle(
                                          color: Color(0xFF575E67),
                                          fontFamily: 'Varela',
                                          fontSize: 15.0),
                                      softWrap: false,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                color: Color(0xffF4F7FA),
                                child: Text(
                                  '${' Delivery Charge - $currency ${shop['delivery_charge'].toString() != null ? shop['delivery_charge'].toString() : ''}'}',
                                  overflow: TextOverflow.fade,
                                  style: CustomTextStyle.textFormFieldMedium
                                      .copyWith(
                                          color: Colors.red,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                child: Text(
                                  shop['description'] != null
                                      ? shop['description']
                                      : '',
                                  overflow: TextOverflow.fade,
                                  style: CustomTextStyle.textFormFieldMedium
                                      .copyWith(
                                          color: Colors.black54,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                ),
                              ),
                              _products.isEmpty
                                  ? SizedBox(height: 0)
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: ListTile(
                                        dense: true,
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 0),
                                        leading: Icon(
                                          Icons.fastfood,
                                          color: Theme.of(context).hintColor,
                                        ),
                                        title: Text(
                                          'Product List',
                                          style: CustomTextStyle
                                              .textFormFieldMedium
                                              .copyWith(
                                                  color: Colors.black54,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                              _products.isEmpty
                                  ? SizedBox(height: 0)
                                  : ListView.separated(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      primary: false,
                                      itemCount: _products.length,
                                      separatorBuilder: (context, index) {
                                        return SizedBox(height: 10);
                                      },
                                      itemBuilder: (context, index) {
                                        return _buildFoodCard(
                                            context, currency, _products[index],
                                            () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                              return new ProductPage(
                                                  currency: currency,
                                                  productData:
                                                      _products[index]);
                                            }),
                                          );
                                        });
                                      },
                                    ),
                              SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 32,
                      right: 20,
                      child: FloatingActionButton.extended(
                        backgroundColor: Color(0xfffada36),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ShopEditPage(
                              shop: shop['shop'],
                            ),
                          ));
                        },
                        isExtended: true,
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        icon: Icon(Icons.edit),
                        label: Text('Edit'),
                      ),
                    ),
                  ],
                ),
        ));
  }
}

Widget _buildFoodCard(context, currency, Product food, onTapped) {
  return InkWell(
    splashColor: Theme.of(context).colorScheme.secondary,
    focusColor: Theme.of(context).colorScheme.secondary,
    highlightColor: Theme.of(context).primaryColor,
    onTap: onTapped,
    child: Container(
      height: 80,
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
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Quantity - ' + food.quantity.toString(),
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
                          text: ' $currency' +
                              (food.price! - food.discount!).toString(),
                          style: TextStyle(
                              fontFamily: 'Google Sans',
                              color: Color(0xFFF75A4C),
                              fontSize: 16.0),
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
                                fontSize: 16.0,
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
