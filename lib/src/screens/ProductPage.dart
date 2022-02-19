import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/models/cartmodel.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/Widget/CircularLoadingWidget.dart';
import 'package:eBazaarMerchant/src/utils/CustomTextStyle.dart';
import 'package:provider/provider.dart';
import '../shared/Product.dart';
import '../shared/styles.dart';
import '../shared/colors.dart';
import '../shared/buttons.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'cartpage.dart';

class GroupModelOptions {
  String? id;
  String? name;
  String? price;
  GroupModelOptions({this.name, this.price, this.id});
}

class GroupModelVariations {
  String? id;
  String? name;
  String? price;
  String? discount;
  int? stock_count;
  bool? in_stock;
  GroupModelVariations(
      {this.name,
      this.price,
      this.discount,
      this.stock_count,
      this.in_stock,
      this.id});
}

class ProductPage extends StatefulWidget {
  final String? pageTitle;
  final Product? productData;
  final String? currency;
  final shop;
  ProductPage({Key? key, this.pageTitle, this.currency, this.productData, this.shop})
      : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String api = FoodApi.baseApi;
  List? _listImage = [];
  List? _variations = [];
  List? _options = [];
  List? reviews = [];

  List imageList = [AssetImage('assets/images/icon.png')];

  int _quantity = 1;
  int count = 0;

  String _currOption = '1';
  String? _currVariation = '1';
  String? deliveryCharge;
  String? shopID;

  List<GroupModelVariations> _groupVariations = [];
  List<GroupModelOptions> _groupOptions = [];
  Map<String, dynamic> ProductShow = {
    "id": '',
    "name": '',
    "unit_price": '',
    "stock_count": '',
    "in_stock": '',
    "description": '',
  };

  Future<String> getProduct(String? shopID, String ProductID) async {
    final url = "$api/shops/1/products/$ProductID";
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        ProductShow['id'] = resBody['data']['id'];
        ProductShow['name'] = resBody['data']['name'];
        ProductShow['unit_price'] =
            (double.tryParse('${resBody['data']['unit_price']}')! -
                    double.tryParse('${resBody['data']['discount_price']}')!)
                .toString();
        ProductShow['discount_price'] =
            resBody['data']['discount_price'].toString();
        ProductShow['stock_count'] = resBody['data']['stock_count'];
        ProductShow['in_stock'] = resBody['data']['in_stock'];
        ProductShow['description'] = resBody['data']['description'];
        ProductShow['avgRating'] = resBody['data']['ratings']['avgRating'];
        reviews = resBody['data']['ratings']['reviews'];
        _listImage = resBody['data']['image'];
        _variations = resBody['data']['variations'];
        _options = resBody['data']['options'];
        imageList.clear();
        _listImage!.forEach((f) => imageList.add(NetworkImage(f)));
        _variations!
            .forEach((variation) => _groupVariations.add(GroupModelVariations(
                  id: variation['id'].toString(),
                  name: variation['name'],
                  stock_count: int.tryParse('${variation['stock_count']}'),
                  in_stock: variation['in_stock'],
                  price: variation['unit_price'].toString(),
                  discount: variation['discount_price'].toString(),
                )));
        _options!.forEach((option) => _groupOptions.add(GroupModelOptions(
              id: option['id'].toString(),
              name: option['name'],
              price: option['unit_price'].toString(),
            )));
      });
    } else {
      throw Exception('Failed to');
    }
    return "Success";
  }

  List _selecteCategorys = [];
  List selecteOptions = [];

  void _onCategorySelected(bool? selected, category_id, options) {
    if (selected == true) {
      setState(() {
        _selecteCategorys.add(category_id);
        selecteOptions.add(options);
        print(selecteOptions.length);
      });
    } else {
      setState(() {
        selecteOptions.removeWhere((item) => item.id == category_id);
        _selecteCategorys.remove(category_id);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    shopID = Provider.of<AuthProvider>(context, listen: false).shopID;
    deliveryCharge =
        Provider.of<AuthProvider>(context, listen: false).deliveryCharge;

    getProduct(shopID, (widget.productData!.id).toString());
    widget.productData!.qty = _quantity;
  }

  @override
  Widget build(BuildContext context) {
    final authenticated = Provider.of<AuthProvider>(context).status;
    final currency = Provider.of<AuthProvider>(context).currency;

    Future<void> _showAlert(BuildContext context) {
      return showDialog<void>(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Product Stock Out'),
            actions: <Widget>[
              TextButton(
                child: Text('Dismiss'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    myCarousel();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        centerTitle: true,
        leading: BackButton(
          color: Colors.white,
        ),
        title: Text(
          widget.productData!.name!,
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          new Padding(
            padding: const EdgeInsets.all(10.0),
            child: new Container(
              height: 150.0,
              width: 30.0,
              child: new GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CartPage()));
                },
                child: Stack(
                  children: <Widget>[
                    new IconButton(
                        icon: new Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartPage(),
                            ),
                          );
                        }),
                    new Positioned(
                        child: new Stack(
                      children: <Widget>[
                        new Icon(Icons.brightness_1,
                            size: 20.0, color: Colors.orange.shade500),
                        new Positioned(
                            top: 4.0,
                            right: 5.5,
                            child: new Center(
                              child: new Text(
                                ScopedModel.of<CartModel>(context,
                                        rebuildOnChange: true)
                                    .totalQunty
                                    .toString(),
                                style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            )),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: ProductShow['name'] == ''
            ? CircularLoadingWidget(
                height: 400,
                subtitleText: 'Products No Found',
                img: 'assets/shopping1.png')
            : ScopedModelDescendant<CartModel>(
                builder: (context, child, model) {
                  return Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                            child: ListView(children: <Widget>[
                          myCarousel(),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 20, left: 20, bottom: 10, top: 25),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    ProductShow['name'],
                                    overflow: TextOverflow.fade,
                                    softWrap: true,
                                    maxLines: 2,
                                    style: CustomTextStyle.textFormFieldMedium
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
                            padding: const EdgeInsets.only(
                                right: 20, left: 20, bottom: 10, top: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'Price ' +
                                        currency! +
                                        ProductShow['unit_price'].toString(),
                                    overflow: TextOverflow.fade,
                                    softWrap: true,
                                    maxLines: 2,
                                    style: CustomTextStyle.textFormFieldMedium
                                        .copyWith(
                                            color: Colors.amberAccent,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          reviews!.isEmpty
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 0),
                                  child: RatingBar.builder(
                                    initialRating: ProductShow['avgRating'] !=
                                            ''
                                        ? double.tryParse(
                                                '${ProductShow['avgRating']}')!
                                            .toDouble()
                                        : 0,
                                    itemSize: 25.0,
                                    glowColor: Colors.amberAccent,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      print(rating);
                                    },
                                  ),
                                ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: Text(
                              ProductShow['description'] != null
                                  ? ProductShow['description']
                                  : '',
                              overflow: TextOverflow.fade,
                              style: CustomTextStyle.textFormFieldMedium
                                  .copyWith(
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                          _groupVariations.isEmpty
                              ? Container()
                              : Column(children: <Widget>[
                                  Container(
                                    child: ListTile(
                                      title: Text(
                                        'Variation',
                                        overflow: TextOverflow.fade,
                                        softWrap: true,
                                        maxLines: 2,
                                        style: CustomTextStyle
                                            .textFormFieldMedium
                                            .copyWith(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Container(
                                      child: Container(
                                    child: Column(
                                      children: _groupVariations
                                          .map((t) => t.in_stock == true
                                              ? RadioListTile(
                                                  value: t.id,
                                                  groupValue: _currVariation,
                                                  title: Text(
                                                    "${t.name}",
                                                    overflow: TextOverflow.fade,
                                                    softWrap: true,
                                                    maxLines: 1,
                                                    style: CustomTextStyle
                                                        .textFormFieldMedium
                                                        .copyWith(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                  ),
                                                  onChanged: (dynamic val) {
                                                    setState(() {
                                                      _currVariation = val;
                                                      ProductShow[
                                                          'unit_price'] = (double
                                                                  .tryParse(
                                                                      '${t.price}')! -
                                                              double.tryParse(
                                                                  '${t.discount}')!)
                                                          .toString();
                                                      ProductShow[
                                                              'stock_count'] =
                                                          t.stock_count;
                                                      ProductShow['in_stock'] =
                                                          t.in_stock;
                                                      int index = model.cart
                                                          .indexWhere((i) =>
                                                              i.id ==
                                                              ProductShow[
                                                                  'id']);
                                                      if (index != -1) {
                                                        model.removeProduct(
                                                            model.cart[index]
                                                                .id);
                                                      }
                                                    });
                                                  },
                                                  activeColor: Colors.red,
                                                  secondary: OutlineButton(
                                                    child: Text(currency +
                                                        (double.tryParse(
                                                                    '${t.price}')! -
                                                                double.tryParse(
                                                                    '${t.discount}')!)
                                                            .toString()),
                                                    onPressed: () {},
                                                  ),
                                                )
                                              : Container())
                                          .toList(),
                                    ),
                                  )),
                                ]),
                          _groupVariations.isEmpty
                              ? Container()
                              : SizedBox(
                                  height: 5,
                                ),
                          _groupOptions.isEmpty
                              ? Container()
                              : Column(
                                  children: <Widget>[
                                    Container(
                                      child: ListTile(
                                        title: Text(
                                          'Options',
                                          overflow: TextOverflow.fade,
                                          softWrap: true,
                                          maxLines: 2,
                                          style: CustomTextStyle
                                              .textFormFieldMedium
                                              .copyWith(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                        ),
                                        child: Container(
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              primary: false,
                                              itemCount: _groupOptions.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return CheckboxListTile(
                                                  title: Text(
                                                    _groupOptions[index].name!,
                                                    overflow: TextOverflow.fade,
                                                    softWrap: true,
                                                    maxLines: 2,
                                                    style: CustomTextStyle
                                                        .textFormFieldMedium
                                                        .copyWith(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                  ),
                                                  subtitle: Text(
                                                    '\$' +
                                                        _groupOptions[index]
                                                            .price!,
                                                    overflow: TextOverflow.fade,
                                                    softWrap: true,
                                                    maxLines: 2,
                                                    style: CustomTextStyle
                                                        .textFormFieldMedium
                                                        .copyWith(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                  ),
                                                  value: _selecteCategorys
                                                      .contains(
                                                          _groupOptions[index]
                                                              .id),
                                                  onChanged: (bool? selected) {
                                                    _onCategorySelected(
                                                        selected,
                                                        _groupOptions[index].id,
                                                        _groupOptions[index]);
                                                  },
                                                );
                                              }),
                                        )),
                                  ],
                                ),
                          Divider(),
                          reviews!.isEmpty
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, bottom: 16.0),
                                  child: Align(
                                      alignment: Alignment(-1, 0),
                                      child: Text(
                                        'Recent Reviews',
                                        style: CustomTextStyle
                                            .textFormFieldMedium
                                            .copyWith(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                      )),
                                ),
                          reviews!.isEmpty
                              ? Container()
                              : Column(
                                  children:
                                      List.generate(reviews!.length, (index) {
                                    return reviews![index]['status'] == 5
                                        ? Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0))),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 16.0),
                                                  child: CircleAvatar(
                                                    maxRadius: 14,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            reviews![index]
                                                                ['image']),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Text(
                                                            reviews![index]
                                                                    ['name']
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            reviews![index]
                                                                    ['date']
                                                                .toString(),
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 10.0),
                                                          )
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 8.0),
                                                        child:
                                                            RatingBar.builder(
                                                          initialRating:
                                                              double.tryParse(
                                                                      '${reviews![index]['rating']}')!
                                                                  .toDouble(),
                                                          itemSize: 20.0,
                                                          glowColor: Colors
                                                              .amberAccent,
                                                          minRating: 1,
                                                          direction:
                                                              Axis.horizontal,
                                                          allowHalfRating: true,
                                                          itemCount: 5,
                                                          itemPadding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      4.0),
                                                          itemBuilder:
                                                              (context, _) =>
                                                                  Icon(
                                                            Icons.star,
                                                            color: Colors.amber,
                                                          ),
                                                          onRatingUpdate:
                                                              (rating) {
                                                            print(rating);
                                                          },
                                                        ),
                                                      ),
                                                      Text(
                                                        reviews![index]
                                                                ['review']
                                                            .toString(),
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ))
                                        : Container();
                                  }),
                                )
                        ])),
                        flex: 90,
                      ),
                      Expanded(
                        child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            child: ProductShow['in_stock'] == false
                                ? Container()
                                : Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: 55,
                                          height: 40,
                                          child: OutlineButton(
                                            onPressed: () {
                                              setState(() {
                                                if (ProductShow['in_stock']) {
                                                  if (_quantity == 1) return;
                                                  _quantity -= 1;
                                                }
                                              });
                                            },
                                            child: Icon(Icons.remove),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 20, right: 20),
                                          child: Text(_quantity.toString(),
                                              style: h3),
                                        ),
                                        Container(
                                          width: 55,
                                          height: 40,
                                          child: OutlineButton(
                                            onPressed: () {
                                              int index = model.cart.indexWhere(
                                                  (i) =>
                                                      i.id ==
                                                      ProductShow['id']);
                                              var value = 0;
                                              if (index != -1) {
                                                value =
                                                    (model.cart[index].qty! +
                                                        _quantity);
                                              } else {
                                                value = _quantity;
                                              }
                                              setState(() {
                                                if (ProductShow['in_stock']) {
                                                  if (ProductShow[
                                                              'stock_count'] >=
                                                          value &&
                                                      (ProductShow[
                                                                  'stock_count'] -
                                                              value) !=
                                                          0) {
                                                    _quantity += 1;
                                                  } else {
                                                    _showAlert(context);
                                                  }
                                                }
                                              });
                                            },
                                            child: Icon(Icons.add),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            width: 180,
                                            height: 45,
                                            margin: EdgeInsets.only(
                                              left: 20,
                                            ),
                                            child:
                                                froyoFlatBtn('Add to Cart', () {
                                              int index = model.cart.indexWhere(
                                                  (i) =>
                                                      i.id ==
                                                      ProductShow['id']);
                                              var value = 0;
                                              if (index != -1) {
                                                value =
                                                    (model.cart[index].qty! +
                                                        _quantity);
                                              } else {
                                                value = _quantity;
                                              }

                                              if (ProductShow['stock_count'] >=
                                                  value) {
                                                double total = 0;
                                                selecteOptions.forEach(
                                                    (element) => total =
                                                        (total +
                                                            double.parse(element
                                                                .price)));
                                                model.addProduct(
                                                    ProductShow['stock_count'],
                                                    ProductShow['id'],
                                                    ProductShow['name'],
                                                    (total +
                                                            double.parse(
                                                                ProductShow[
                                                                    'unit_price']))
                                                        .toDouble(),
                                                    _quantity,
                                                    widget.productData!.imgUrl,
                                                    _currVariation,
                                                    selecteOptions,
                                                    shopID,
                                                    deliveryCharge);
                                                _quantity = 1;
                                              } else {
                                                _showAlert(context);
                                              }
                                            }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                        flex: 10,
                      )
                    ],
                  );
                },
              ),
      ),
    );
  }

  myCarousel() {
    return CarouselSlider.builder(
      itemCount: imageList.length,
      itemBuilder: (BuildContext context, int itemIndex, _) {
        return Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageList[itemIndex],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
      options: CarouselOptions(
        autoPlay: false,
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        aspectRatio: 1.3,
        initialPage: 0,
      ),
    );
  }
}
