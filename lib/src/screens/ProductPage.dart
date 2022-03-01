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
class Hourly {
  int? time;
  String? icon;
  String? temp;

  Hourly({this.time, this.icon, this.temp});
}

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
String? unit_price;
String? plot_no;
String? p_city;
String? size;
String? p_societys;
String? socname;
String? phasename;
String? blockname;
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
   // "id": '',
    "name": '',
    "first_name": '',
    "last_name": '',
    "email": '',
    "phone": '',
  };

  Future<String> getProduct(String? shopID, String UserID) async {
    //final url = "$api/shops/1/user/6";
    final url = "$api/shops/1/user/$UserID";


    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        unit_price = widget.productData!.price.toString();
        plot_no = widget.productData!.plot_no.toString();
        p_city = widget.productData!.id.toString();
        size = widget.productData!.size.toString();
        p_societys= widget.productData!.id.toString();
        socname= widget.productData!.socname.toString();
        phasename= widget.productData!.phasename.toString();
        blockname= widget.productData!.blockname.toString();
       print(resBody['data']) ;
      // print(resBody['data']['name']) ;
       print('${resBody['data']['name'].toString()}') ;
        ProductShow['name'] = resBody['data']['name'];
        ProductShow['first_name'] = resBody['data']['first_name'];
        ProductShow['last_name'] = resBody['data']['last_name'];

        ProductShow['email'] = resBody['data']['email'];
        ProductShow['phone'] = resBody['data']['phone'];
        ProductShow['address'] = resBody['data']['address'];
        ProductShow['username'] = resBody['data']['username'];
        // ProductShow['unit_price'] =
        //     (double.tryParse('${resBody['data']['unit_price']}')! -
        //             double.tryParse('${resBody['data']['discount_price']}')!)
        //         .toString();
        // ProductShow['discount_price'] =
        //     resBody['data']['discount_price'].toString();
        // ProductShow['stock_count'] = resBody['data']['stock_count'];
        // ProductShow['in_stock'] = resBody['data']['in_stock'];
        // ProductShow['description'] = resBody['data']['description'];
        // ProductShow['avgRating'] = resBody['data']['ratings']['avgRating'];
        // reviews = resBody['data']['ratings']['reviews'];
        // _listImage = resBody['data']['image'];
        // _variations = resBody['data']['variations'];
        // _options = resBody['data']['options'];
        // imageList.clear();
        // _listImage!.forEach((f) => imageList.add(NetworkImage(f)));
        // _variations!
        //     .forEach((variation) => _groupVariations.add(GroupModelVariations(
        //           id: variation['id'].toString(),
        //           name: variation['name'],
        //           stock_count: int.tryParse('${variation['stock_count']}'),
        //           in_stock: variation['in_stock'],
        //           price: variation['unit_price'].toString(),
        //           discount: variation['discount_price'].toString(),
        //         )));
        // _options!.forEach((option) => _groupOptions.add(GroupModelOptions(
        //       id: option['id'].toString(),
        //       name: option['name'],
        //       price: option['unit_price'].toString(),
        //     )));
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

   // widget.productData!.qty = _quantity;
  }

  @override
  Widget build(BuildContext context) {
    final authenticated = Provider.of<AuthProvider>(context).status;
    final currency = Provider.of<AuthProvider>(context).currency;



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
          '${widget.productData!.socname} ',
          style: TextStyle(color: Colors.white),
        ),

      ),
      body: SafeArea(
        child: phasename == ''
            ? CircularLoadingWidget(
                height: 400,
                subtitleText: 'Products No Found',
                img: 'assets/shopping1.png')
            :

                   Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                            child: ListView(children: <Widget>[
                         // myCarousel(),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 20, left: 20, bottom: 10, top: 25),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text('Society' + ' '+
                                    socname.toString(),
                                    overflow: TextOverflow.fade,
                                    softWrap: true,
                                    maxLines: 2,
                                    style: CustomTextStyle.textFormFieldMedium
                                        .copyWith(
                                            color: Colors.black,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                              phasename == '' ? Container(): Padding(
                                padding: const EdgeInsets.only(
                                    right: 20, left: 20, bottom: 10, top: 25),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text('Phase' + ' ' +
                                        phasename.toString(),
                                        overflow: TextOverflow.fade,
                                        softWrap: true,
                                        maxLines: 2,
                                        style: CustomTextStyle.textFormFieldMedium
                                            .copyWith(
                                            color: Colors.black,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              blockname == '' ? Container(): Padding(
                                padding: const EdgeInsets.only(
                                    right: 20, left: 20, bottom: 10, top: 25),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text('Block' + ' '+
                                        blockname.toString(),
                                        overflow: TextOverflow.fade,
                                        softWrap: true,
                                        maxLines: 2,
                                        style: CustomTextStyle.textFormFieldMedium
                                            .copyWith(
                                            color: Colors.black,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              plot_no == ''? Container () :Padding(
                            padding: const EdgeInsets.only(
                                right: 20, left: 20, bottom: 10, top: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'Plot no  ' +
                                        ' '+
                                        plot_no.toString(),
                                    overflow: TextOverflow.fade,
                                    softWrap: true,
                                    maxLines: 2,
                                    style: CustomTextStyle.textFormFieldMedium
                                        .copyWith(
                                            color: Colors.red,
                                            fontSize: 18,
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
                                            currency! + ' '+
                                            unit_price.toString(),
                                        overflow: TextOverflow.fade,
                                        softWrap: true,
                                        maxLines: 2,
                                        style: CustomTextStyle.textFormFieldMedium
                                            .copyWith(
                                            color: Colors.red,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: Text(
                              ProductShow['name'] != null
                                  ? ProductShow['name']
                                  : '',
                              overflow: TextOverflow.fade,
                              style: CustomTextStyle.textFormFieldMedium
                                  .copyWith(
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                child: Text(
                                  ProductShow['first_name'] != null
                                      ? ProductShow['first_name']
                                      : '',
                                  overflow: TextOverflow.fade,
                                  style: CustomTextStyle.textFormFieldMedium
                                      .copyWith(
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
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

                    ],
                  )

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
