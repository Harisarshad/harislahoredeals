import 'package:eBazaarMerchant/src/screens/dimensions.dart';
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
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';




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
String? size_word;
String? priceWord;
String? blockname;
String? propType;
  List imageList = [AssetImage('assets/images/icon.png')];

  int _quantity = 1;
  int count = 0;

  String _currOption = '1';
  String? _currVariation = '1';
  String? deliveryCharge;
  String? shopID;


  Map<String, dynamic> ProductShow = {
   // "id": '',
    "name": '',
    "first_name": '',
    "last_name": '',
    "email": '',
    "phone": '',
  };

  Future<String> getProduct(String? shopID, String UserID) async {
   // final url = "$api/shops/1/user/2";
    final url = "$api/shops/1/user/$UserID";


    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        unit_price = widget.productData!.price.toString();
        priceWord = widget.productData!.pricewords.toString();
        plot_no = widget.productData!.plot_no.toString();
        p_city = widget.productData!.user_id.toString();
        size = widget.productData!.size.toString();
        p_societys= widget.productData!.id.toString();
        socname= widget.productData!.socname.toString();
        propType= widget.productData!.propType.toString();
        phasename= widget.productData!.phasename.toString();
        blockname= widget.productData!.blockname.toString();
        size_word= widget.productData!.size_word.toString();
       print(resBody['data']) ;
      print(resBody['data']['name']) ;
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

    getProduct(shopID, (widget.productData!.user_id).toString());
    print((widget.productData!.user_id).toString());
    print('(widget.productData!.user_id).toString()');

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
      body:Column(
        children: <Widget>[
        SizedBox(
        height: 30,
        child: Stack(
          children: <Widget>[


            Positioned(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)), color: Colors.green),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
              ),
              top: 32,
              left: 32,
            )
          ],
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            //column for whole container
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 32, right: 32, top: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: <Widget>[
                        Container(
                          width: 200,
                          child: Text(socname.toString() +' ' + phasename.toString() +' '+ blockname.toString(),
                            style: TextStyle(fontSize: 22, color: Colors.grey[800], fontWeight: FontWeight.bold),
                          ),
                        ),

                        SizedBox(height: 8,),
                        // Text("Karachi, Bahria Town, A123-4",
                        //     style: TextStyle(color: Colors.grey[500],), overflow: TextOverflow.ellipsis),
                        SizedBox(height: 16,),


                      ],
                    ),

                    // IconButton(
                    //   icon: Icon(Icons.navigation),
                    // )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 32, right: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //Text("Features", style: TextStyle(color: Colors.grey[800], fontSize: 18, fontWeight: FontWeight.w600), ),
                    SizedBox(height: 16,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(Icons.local_offer, color:  primaryColor,),
                            SizedBox(width: 4,),
                            Text("Price", style: TextStyle(color: Colors.grey[900],fontSize: 22, fontWeight: FontWeight.w500),)
                          ],
                        ),


                        Row(
                          children: <Widget>[

                            SizedBox(width: 4,),
                            Text( ' Rs ' , style: TextStyle(color: Colors.grey[900],fontSize: 15, fontWeight: FontWeight.w600),),
                            Text( priceWord.toString()  , style: TextStyle(color: Colors.grey[900],fontSize: 22, fontWeight: FontWeight.w500),)
                          ],
                        ),
                        Row(
                          children: <Widget>[
                           // Icon(Icons.videogame_asset, color:  Colors.green,),
                            SizedBox(width: 50,),
                          //  Text("T. Tennis", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),)
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(Icons.local_offer, color:  primaryColor,),
                            SizedBox(width: 4,),
                            Text("SIZE", style: TextStyle(color: Colors.grey[900],fontSize: 20, fontWeight: FontWeight.w500),)
                          ],
                        ),
                        Row(
                          children: <Widget>[

                            SizedBox(width: 4,),
                            Text(size_word.toString(), style: TextStyle(color: Colors.grey[900],fontSize: 20, fontWeight: FontWeight.w500),)
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            // Icon(Icons.videogame_asset, color:  Colors.green,),
                            SizedBox(width:80,),
                            //  Text("T. Tennis", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),)
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(Icons.local_offer, color:  primaryColor,),
                            SizedBox(width: 4,),
                            Text("Property Type", style: TextStyle(color: Colors.grey[900],fontSize: 15, fontWeight: FontWeight.w500),)
                          ],
                        ),
                        Row(
                          children: <Widget>[

                            SizedBox(width: 4,),
                            Text(propType.toString() != '0' ? 'Residential' :'Commercial', style: TextStyle(color: Colors.grey[900],fontSize: 15, fontWeight: FontWeight.w500),)
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            // Icon(Icons.videogame_asset, color:  Colors.green,),
                            SizedBox(width:80,),
                            //  Text("T. Tennis", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),)
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8,),
                    SizedBox(height: 15,),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 32, right: 32, top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.location_city, size: 20, color: Colors.grey[600],),
                        SizedBox(width: 4,),
                        Text("SOCIETY", style: TextStyle(color: Colors.grey[900],fontSize: 20, fontWeight: FontWeight.w500),)
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Icon(Icons.location_on_rounded, size: 12, color: Colors.grey[600],),
                        SizedBox(width: 4,),
                        Text("PHASE", style: TextStyle(color: Colors.grey[900], fontSize: 20,fontWeight: FontWeight.w500),)
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Icon(Icons.my_location_rounded, size: 20, color: Colors.grey[600],),
                        SizedBox(width: 4,),
                        Text("BLOCK", style: TextStyle(color: Colors.grey[900],fontSize: 20, fontWeight: FontWeight.w500),)
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 32, right: 32, top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(


                      children: <Widget>[
                     //  Icon(Icons.location_city, size: 20, color: Colors.grey[600],),
                        SizedBox(width: 4,),
                        Text(socname.toString(), style: TextStyle(color: Colors.black,fontSize: 20, fontWeight: FontWeight.w500),)
                      ],
                    ),
                    Row(
                      children: <Widget>[
                       // Icon(Icons.location_on_rounded, size: 12, color: Colors.grey[600],),
                        SizedBox(width: 4,),
                        Text(phasename.toString(), style: TextStyle(color: Colors.black, fontSize: 20,fontWeight: FontWeight.w500),)
                      ],
                    ),
                    Row(
                      children: <Widget>[
                      //  Icon(Icons.my_location_rounded, size: 20, color: Colors.grey[600],),
                        SizedBox(width: 4,),
                        Text(blockname.toString(), style: TextStyle(color: Colors.black,fontSize: 20, fontWeight: FontWeight.w500),)
                      ],
                    ),
                  ],
                ),
              ),


              SizedBox(
                height: 8,
              ),

              Divider(),

              Container(
                margin: EdgeInsets.only(left: 32, right: 32),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      child: ClipRRect(
                       child: const Text('LD'),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),

                    SizedBox(width: 16,),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(ProductShow['first_name'] != null
                                                            ? ProductShow['first_name']
                                                            : '' + ' '+ ProductShow['last_name'] != null
                              ? ProductShow['last_name']
                              : '' , style: TextStyle(color: Colors.grey[800], fontSize : 18, fontWeight: FontWeight.w600),),
                          Text(ProductShow['phone'] != null
                              ? ProductShow['phone']
                              : '' , style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w400),)
                        ],
                      ),
                    ),

                    ProductShow['phone'] != null ?

                    Container(
                        width: 60,
                        height: 60,
                    decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor),

                        child: IconButton(icon: new Icon(Icons.phone),
                      onPressed: ()
                      {
                        setState(() {
                          _makePhoneCall('tel:${ProductShow['phone']}');
                        });
                      },
                    )) :Container(),
                  ],
                ),
              ),

              SizedBox(
                height: 8,
              ),

              Divider(

              ),



            ],
          ),
        ),
      )





      // SafeArea(
      //   child: phasename == ''
      //       ? CircularLoadingWidget(
      //           height: 400,
      //           subtitleText: 'Products No Found',
      //           img: 'assets/shopping1.png')
      //       :
      //
      //              Column(
      //               children: <Widget>[
      //                 Expanded(
      //                   child: Container(
      //                       child: ListView(children: <Widget>[
      //                    // myCarousel(),
      //                    //  Padding(
      //                    //    padding: const EdgeInsets.only(
      //                    //        right: 20, left: 20, bottom: 10, top: 25),
      //                    //    child: Row(
      //                    //      crossAxisAlignment: CrossAxisAlignment.start,
      //                    //      children: <Widget>[
      //                    //        Expanded(
      //                    //          child: Text('Society' + ' '+
      //                    //            socname.toString(),
      //                    //            overflow: TextOverflow.fade,
      //                    //            softWrap: true,
      //                    //            maxLines: 2,
      //                    //            style: CustomTextStyle.textFormFieldMedium
      //                    //                .copyWith(
      //                    //                    color: Colors.black,
      //                    //                    fontSize: 22,
      //                    //                    fontWeight: FontWeight.bold),
      //                    //          ),
      //                    //        ),
      //                    //      ],
      //                    //    ),
      //                    //  ),
      //
      //                         phasename == '' ? Container(): Padding(
      //                           padding: const EdgeInsets.only(
      //                               right: 20, left: 20, bottom: 10, top: 25),
      //                           child: Row(
      //                             crossAxisAlignment: CrossAxisAlignment.start,
      //                             children: <Widget>[
      //                               Expanded(
      //                                 child: Text('Phase' + ' ' +
      //                                   phasename.toString(),
      //                                   overflow: TextOverflow.fade,
      //                                   softWrap: true,
      //                                   maxLines: 2,
      //                                   style: CustomTextStyle.textFormFieldMedium
      //                                       .copyWith(
      //                                       color: Colors.black,
      //                                       fontSize: 22,
      //                                       fontWeight: FontWeight.bold),
      //                                 ),
      //                               ),
      //                             ],
      //                           ),
      //                         ),
      //                         blockname == '' ? Container(): Padding(
      //                           padding: const EdgeInsets.only(
      //                               right: 20, left: 20, bottom: 10, top: 25),
      //                           child: Row(
      //                             crossAxisAlignment: CrossAxisAlignment.start,
      //                             children: <Widget>[
      //                               Expanded(
      //                                 child: Text('Block' + ' '+
      //                                   blockname.toString(),
      //                                   overflow: TextOverflow.fade,
      //                                   softWrap: true,
      //                                   maxLines: 2,
      //                                   style: CustomTextStyle.textFormFieldMedium
      //                                       .copyWith(
      //                                       color: Colors.black,
      //                                       fontSize: 22,
      //                                       fontWeight: FontWeight.bold),
      //                                 ),
      //                               ),
      //                             ],
      //                           ),
      //                         ),
      //                         plot_no == ''? Container () :Padding(
      //                       padding: const EdgeInsets.only(
      //                           right: 20, left: 20, bottom: 10, top: 5),
      //                       child: Row(
      //                         crossAxisAlignment: CrossAxisAlignment.start,
      //                         children: <Widget>[
      //                           Expanded(
      //                             child: Text(
      //                               'Plot no  ' +
      //                                   ' '+
      //                                   plot_no.toString(),
      //                               overflow: TextOverflow.fade,
      //                               softWrap: true,
      //                               maxLines: 2,
      //                               style: CustomTextStyle.textFormFieldMedium
      //                                   .copyWith(
      //                                       color: Colors.red,
      //                                       fontSize: 18,
      //                                       fontWeight: FontWeight.bold),
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                         Padding(
      //                           padding: const EdgeInsets.only(
      //                               right: 20, left: 20, bottom: 10, top: 5),
      //                           child: Row(
      //                             crossAxisAlignment: CrossAxisAlignment.start,
      //                             children: <Widget>[
      //                               Expanded(
      //                                 child: Text(
      //                                   'Price ' +
      //                                       currency! + ' '+
      //                                       unit_price.toString(),
      //                                   overflow: TextOverflow.fade,
      //                                   softWrap: true,
      //                                   maxLines: 2,
      //                                   style: CustomTextStyle.textFormFieldMedium
      //                                       .copyWith(
      //                                       color: Colors.red,
      //                                       fontSize: 18,
      //                                       fontWeight: FontWeight.bold),
      //                                 ),
      //                               ),
      //                             ],
      //                           ),
      //                         ),
      //
      //                     Padding(
      //                       padding: const EdgeInsets.symmetric(
      //                           horizontal: 20, vertical: 5),
      //                       child: Text(
      //                         ProductShow['name'] != null
      //                             ? ProductShow['name']
      //                             : '',
      //                         overflow: TextOverflow.fade,
      //                         style: CustomTextStyle.textFormFieldMedium
      //                             .copyWith(
      //                                 color: Colors.black54,
      //                                 fontSize: 14,
      //                                 fontWeight: FontWeight.bold),
      //                       ),
      //                     ),
      //                         Container(
      //
      //                           child: InkWell(
      //                             onTap: () {
      //                               // Navigator.push(
      //                               //     context,
      //                               //     MaterialPageRoute(
      //                               //         builder: (BuildContext context) =>
      //                               //             ShopScreen(
      //                               //               shopId: product!.shopId,
      //                               //             )));
      //                             },
      //                             child: Row(
      //                               mainAxisSize: MainAxisSize.min,
      //                               children: [
      //                                 Container(
      //                                   color: Colors.orange,
      //                                   child: FlutterLogo(
      //                                     size: 60.0,
      //                                   ),
      //                                 ),
      //                                 Container(
      //                                   color: Colors.blue,
      //                                   child: FlutterLogo(
      //                                     size: 60.0,
      //                                   ),
      //                                 ),
      //                                 Container(
      //                                   color: Colors.purple,
      //                                   child: FlutterLogo(
      //                                     size: 60.0,
      //                                   ),
      //                                 ),
      //
      //
      //                               ],
      //                             ),
      //                           ),
      //                         ),
      //                         Padding(
      //                           padding: const EdgeInsets.symmetric(
      //                               horizontal: 20, vertical: 5),
      //                           child: Text(
      //                             ProductShow['first_name'] != null
      //                                 ? ProductShow['first_name']
      //                                 : '',
      //                             overflow: TextOverflow.fade,
      //                             style: CustomTextStyle.textFormFieldMedium
      //                                 .copyWith(
      //                                 color: Colors.black54,
      //                                 fontSize: 14,
      //                                 fontWeight: FontWeight.bold),
      //                           ),
      //                         ),
      //                         Padding(
      //                           padding: const EdgeInsets.symmetric(
      //                               horizontal: 20, vertical: 5),
      //                           child: Text(
      //                             ProductShow['phone'] != null
      //                                 ? ProductShow['phone']
      //                                 : '',
      //                             overflow: TextOverflow.fade,
      //                             style: CustomTextStyle.textFormFieldMedium
      //                                 .copyWith(
      //                                 color: Colors.black54,
      //                                 fontSize: 14,
      //                                 fontWeight: FontWeight.bold),
      //                           ),
      //                         ),
      //
      //
      //
      //
      //                     reviews!.isEmpty
      //                         ? Container()
      //                         : Column(
      //                             children:
      //                                 List.generate(reviews!.length, (index) {
      //                               return reviews![index]['status'] == 5
      //                                   ? Container(
      //                                       margin: const EdgeInsets.symmetric(
      //                                           vertical: 4.0),
      //                                       padding: const EdgeInsets.all(8.0),
      //                                       decoration: BoxDecoration(
      //                                           color: Colors.white,
      //                                           borderRadius: BorderRadius.all(
      //                                               Radius.circular(5.0))),
      //                                       child: Row(
      //                                         crossAxisAlignment:
      //                                             CrossAxisAlignment.start,
      //                                         children: <Widget>[
      //                                           Padding(
      //                                             padding:
      //                                                 const EdgeInsets.only(
      //                                                     right: 16.0),
      //                                             child: CircleAvatar(
      //                                               maxRadius: 14,
      //                                               backgroundImage:
      //                                                   NetworkImage(
      //                                                       reviews![index]
      //                                                           ['image']),
      //                                             ),
      //                                           ),
      //                                           Expanded(
      //                                             child: Column(
      //                                               mainAxisSize:
      //                                                   MainAxisSize.min,
      //                                               crossAxisAlignment:
      //                                                   CrossAxisAlignment
      //                                                       .start,
      //                                               children: <Widget>[
      //                                                 Row(
      //                                                   mainAxisAlignment:
      //                                                       MainAxisAlignment
      //                                                           .spaceBetween,
      //                                                   children: <Widget>[
      //                                                     Text(
      //                                                       reviews![index]
      //                                                               ['name']
      //                                                           .toString(),
      //                                                       style: TextStyle(
      //                                                           fontWeight:
      //                                                               FontWeight
      //                                                                   .bold),
      //                                                     ),
      //                                                     Text(
      //                                                       reviews![index]
      //                                                               ['date']
      //                                                           .toString(),
      //                                                       style: TextStyle(
      //                                                           color:
      //                                                               Colors.grey,
      //                                                           fontSize: 10.0),
      //                                                     )
      //                                                   ],
      //                                                 ),
      //                                                 Padding(
      //                                                   padding:
      //                                                       const EdgeInsets
      //                                                               .symmetric(
      //                                                           vertical: 8.0),
      //                                                   child:
      //                                                       RatingBar.builder(
      //                                                     initialRating:
      //                                                         double.tryParse(
      //                                                                 '${reviews![index]['rating']}')!
      //                                                             .toDouble(),
      //                                                     itemSize: 20.0,
      //                                                     glowColor: Colors
      //                                                         .amberAccent,
      //                                                     minRating: 1,
      //                                                     direction:
      //                                                         Axis.horizontal,
      //                                                     allowHalfRating: true,
      //                                                     itemCount: 5,
      //                                                     itemPadding: EdgeInsets
      //                                                         .symmetric(
      //                                                             horizontal:
      //                                                                 4.0),
      //                                                     itemBuilder:
      //                                                         (context, _) =>
      //                                                             Icon(
      //                                                       Icons.star,
      //                                                       color: Colors.amber,
      //                                                     ),
      //                                                     onRatingUpdate:
      //                                                         (rating) {
      //                                                       print(rating);
      //                                                     },
      //                                                   ),
      //                                                 ),
      //                                                 Text(
      //                                                   reviews![index]
      //                                                           ['review']
      //                                                       .toString(),
      //                                                   style: TextStyle(
      //                                                     color: Colors.grey,
      //                                                   ),
      //                                                 ),
      //                                               ],
      //                                             ),
      //                                           )
      //                                         ],
      //                                       ))
      //                                   : Container();
      //                             }),
      //                           )
      //                   ])),
      //                   flex: 90,
      //                 ),
      //
      //               ],
      //             )
      //
      //         ),

    ],
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
  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }

}

  }

