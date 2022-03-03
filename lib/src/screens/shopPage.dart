import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/Widget/CircularLoadingWidget.dart';
import 'package:eBazaarMerchant/src/screens/productAll.dart';
import 'package:eBazaarMerchant/src/shared/Product.dart';
import 'package:eBazaarMerchant/src/shared/colors.dart';
import 'package:eBazaarMerchant/src/shared/styles.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
//import 'package:geolocator/geolocator.dart';

import 'ProductPage.dart';

class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() {
    return new _ShopPageState();
  }
}

class _ShopPageState extends State<ShopPage> {
  TextEditingController editingProductController = TextEditingController();
  GlobalKey<RefreshIndicatorState>? refreshKey;
 // Position? _currentPosition;

  // Future<void> _checkPermission() async {
  //   // verify permissions
  //   LocationPermission permission = await Geolocator.requestPermission();
  //   if (permission == LocationPermission.denied ||
  //       permission == LocationPermission.deniedForever) {
  //     await Geolocator.openAppSettings();
  //     await Geolocator.openLocationSettings();
  //   }
  // }

  String api = FoodApi.baseApi;
  List? _categories = [];
  List? _listProduct = [];
  List<Product> _products = [];
  String? token;
  String? shop;
  bool _loading = false;
  int offset = 0;
  int time = 800;

  Future<String> getCategories(String? shopID) async {
    final url = "$api/shops/$shopID/categories";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _categories = resBody['data']['categories'];
      });
    } else {
      throw Exception('Failed to data');
    }
    return "Success";
  }

  Future<String?> getProducts(String? shopID) async {
    Timer(
        Duration(seconds: 4),
        () => {
              setState(() async {
                token = Provider.of<AuthProvider>(context, listen: false).token;
                final url = "$api/shop-product/$shopID/shop/product";
                print(url);
                print("urlharis");

                var response = await http.get(Uri.parse(url), headers: {
                  HttpHeaders.acceptHeader: "application/json",
                  HttpHeaders.authorizationHeader: 'Bearer $token'
                });


                var resBody = json.decode(response.body);

                print(resBody);
                print("resbody");
                if (response.statusCode == 200) {
                  setState(() {
                    _listProduct = resBody['data'];
                    _listProduct!.forEach((element) => _products.add(Product(
                        name: element['product']['name'],
                        id: element['product']['id'],
                        imgUrl: element['product']['image'],
                        quantity: element['quantity'],
                        avgRating: double.tryParse(
                            '${element['product']['avgRating']}'),
                        price: double.tryParse('${element['unit_price']}')!
                            .toDouble(),
                        discount:
                            double.tryParse('${element['discount_price']}')!
                                .toDouble())));
                  });
                } else {
                  throw Exception('Failed to');
                }
                print("Success");
              })
            });
    return null;
  }

  void SerchProduct(shop, value) async {
    final url = "$api/search/$shop/shops/$value/products";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      setState(() {
        _products.clear();
        _listProduct = resBody['data'];
        _listProduct!.forEach((element) => _products.add(Product(
            name: element['name'],
            id: element['id'],
            imgUrl: element['image'],
            avgRating: double.tryParse('${element['avgRating']}'),
            price: double.tryParse('${element['unit_price']}'),
            discount: double.tryParse('${element['discount_price']}'))));
      });
    } else {
      throw Exception('Failed to data');
    }
    return;
  }

  Future<Null> refreshList() async {
    final shop = Provider.of<AuthProvider>(context, listen: false).shopID;
    setState(() {
      _products.clear();
      _categories!.clear();
      this.getCategories(shop);
      this.getProducts(shop);
    });
  }

  @override
  void initState() {
    super.initState();
    token = Provider.of<AuthProvider>(context, listen: false).token;
    shop = Provider.of<AuthProvider>(context, listen: false).shopID;
    this.getCategories(shop);
    this.getProducts(shop);
   // _getCurrentLocation();
 //   _checkPermission();
  }

  // _getCurrentLocation() {
  //   Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
  //       .then((Position position) {
  //     _checkPermission();
  //     setState(() {
  //       _currentPosition = position;
  //     });
  //   }).catchError((e) {
  //     print(e);
  //     _checkPermission();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AuthProvider>(context, listen: false).currency;

    return Scaffold(
        backgroundColor: Color(000),
        body: SafeArea(
          child: RefreshIndicator(
            key: refreshKey,
            onRefresh: () async {
              await refreshList();
            },
            child: storeTab(context, currency, _categories, _products),
          ),
        ));
  }

  int _selectedCategory = 0;
  storeTab(
    BuildContext context,
    currency,
    List? _categories,
    List<Product> _products,
  ) {
    return _products.isEmpty
        ? CircularLoadingWidget(
            height: 400,
            subtitleText: 'Products & Categories No Found',
            img: 'assets/shopping1.png')
        : ListView(shrinkWrap: true, children: <Widget>[
            SizedBox(
              height: 10,
            ),
            _categories!.isEmpty
                ? Container()
                : Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                            _categories.length,
                            (index) => Padding(
                                  padding: EdgeInsets.only(
                                      bottom: 30, left: index == 0 ? 10 : 0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = index;
                                      });
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => ProductAllPage(
                                            category: _categories[index]
                                                ['name'],
                                            categoryID: _categories[index]['id']
                                                .toString()),
                                      ));
                                    },
                                    child: Container(
                                      height: 110,
                                      width: 90,
                                      margin: EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: index == _selectedCategory
                                              ? primaryColor
                                              : Colors.transparent,
                                          boxShadow: [
                                            BoxShadow(
                                                color:
                                                    index == _selectedCategory
                                                        ? Color.fromRGBO(
                                                            220, 46, 69, 0.31)
                                                        : Colors.transparent,
                                                blurRadius: 10,
                                                spreadRadius: 4,
                                                offset: Offset(0.0, 7.0))
                                          ]),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundColor: index ==
                                                    _selectedCategory
                                                ? Colors.white
                                                : Colors.red.withOpacity(0.1),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              child: Image.network(
                                                _categories[index]['image'],
                                                fit: BoxFit.contain,
                                                height: 35,
                                                width: 35,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            _categories[index]['name'],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color:
                                                    index == _selectedCategory
                                                        ? Colors.white
                                                        : Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                      ),
                    ),
                  ),
            _products.isEmpty
                ? Container()
                : Padding(
                    padding: EdgeInsets.only(top: 0.0, left: 15.0, right: 15.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10.0),
                            bottomLeft: Radius.circular(10.0),
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          )),
                      child: TextField(
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          SerchProduct(shop, value != null ? value : null);
                        },
                        controller: editingProductController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(top: 14.0),
                          hintText: 'Search for  products',
                          hintStyle: TextStyle(
                              fontFamily: 'Montserrat', fontSize: 14.0),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
            SizedBox(height: 10.0),
            Container(
                height: MediaQuery.of(context).size.height / 1.87,
                width: MediaQuery.of(context).size.width / 2,
                child: new GridView.builder(
                    shrinkWrap: true,
                    primary: false,
                    padding: EdgeInsets.all(8.0),
                    itemCount: _products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.8),
                    itemBuilder: (context, index) {
                      return _buildFoodCard(context, currency, _products[index],
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return new ProductPage(
                                currency: currency,
                                productData: _products[index]);
                          }),
                        );
                      });
                    })),
            SizedBox(height: 20.0),
          ]);
  }
}

_buildFoodCard(context, currency, Product food, onTapped) {
  return InkWell(
    highlightColor: Colors.transparent,
    splashColor: Colors.white,
    onTap: onTapped,
    child: Container(
      height: 5000,
      width: MediaQuery.of(context).size.width / 10,
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).focusColor.withOpacity(0.05),
                offset: Offset(0, 5),
                blurRadius: 5)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Image.network(
                  food.imgUrl!,
                  fit: BoxFit.contain,
                  height: 100,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            food.name != null ? ' ' + food.name! : '',
            style: TextStyle(color: Colors.black, fontSize: 18.0),
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.fade,
          ),
          SizedBox(height: 4),
          Row(
            children: <Widget>[
              Expanded(
                child: RichText(
                    text: TextSpan(children: [
                  new TextSpan(
                    text: ' $currency' +
                        (food.price! - food.discount!).toString(),
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Color(0xFFF75A4C),
                        fontWeight: FontWeight.bold,
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
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ]))
                  : Container(),
            ],
          ),
          SizedBox(height: 4),
          food.avgRating != 0
              ? RatingBar.builder(
                  initialRating: food.avgRating!.toDouble(),
                  itemSize: 20.0,
                  glowColor: Colors.amberAccent,
                  minRating: 1,
                  tapOnlyMode: true,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    print(rating);
                  },
                )
              : SizedBox(height: 10),
          SizedBox(height: 10),
        ],
      ),
    ),
  );
}

Widget sectionHeader(String headerTitle, {onViewMore}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Container(
        margin: EdgeInsets.only(left: 15, top: 10),
        child: Text(headerTitle, style: h4),
      ),
    ],
  );
}

// wrap the horizontal listview inside a sizedBox..
Widget headerTopCategories(context, List _categories) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      sectionHeader('All Categories', onViewMore: () {}),
      SizedBox(
        height: 130,
        child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: _categories.map((f) {
            return headerCategoryItem(context, f['name'], f['image'], f['id']);
          }).toList(),
        ),
      )
    ],
  );
}

Widget headerCategoryItem(context, String name, String? icon, int? id) {
  return Container(
    width: 70,
    margin: EdgeInsets.only(left: 15),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(bottom: 10),
            width: 70,
            height: 70,
            child: FlatButton(
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ProductAllPage(category: name, categoryID: '$id'),
                ));
              },
              child: Image(
                image: (icon != null
                    ? NetworkImage(icon)
                    : AssetImage('assets/steak.png')) as ImageProvider<Object>,
                fit: BoxFit.contain,
                width: 150,
                height: 150,
              ),
            )),
        Text(
          name,
          overflow: TextOverflow.fade,
          maxLines: 1,
          softWrap: false,
          style: categoryText,
        )
      ],
    ),
  );
}
