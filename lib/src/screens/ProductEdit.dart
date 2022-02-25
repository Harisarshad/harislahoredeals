import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/Widget/styled_flat_button.dart';
import 'package:eBazaarMerchant/src/shared/Product.dart';
import 'package:eBazaarMerchant/src/utils/CustomTextStyle.dart';
import 'package:eBazaarMerchant/src/utils/validate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';

import '../../main.dart';
import 'Shopdetails.dart';

class Variation {
  String? id;
  String? name;
  String? price;
  String? size;
  String? plot_no;
  String? discount_price;
  String? quantity;
  Variation({
    this.id,
    this.name,
    this.discount_price,
    this.price,
    this.size,
    this.plot_no,
    this.quantity,
  });

  Map<String, dynamic> TojsonData() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["price"] = price;
    map["size"] = size;
    map["plot_no"] = plot_no;
    map["discount_price"] = discount_price;
    map["quantity"] = quantity;
    return map;
  }
}

class Options {
  String? id;
  String? name;
  String? price;
  String? size;
  String? plot_no;
  Options({this.id, this.name, this.price,this.size,this.plot_no});
  Map<String, dynamic> TojsonData() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["price"] = price;
    map["size"] = size;
    map["plot_no"] = plot_no;
    return map;
  }
}

class ProductEdit extends StatefulWidget {
  final Product? product;
  ProductEdit({
    Key? key,
    this.product,
  }) : super(key: key);

  @override
  _ProductEditState createState() => _ProductEditState();
}

class _ProductEditState extends State<ProductEdit> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _variationFormKey = GlobalKey<FormState>();
  List<Variation> _variations = [];
  List<Options> _options = [];
  String? variationName;
  String? variationPrice;
  String? variationDiscount;
  String? variationQuantity;
  String? _selectedProductType = 'Single';
  String? product_type;
  String? productID;
  String? price;
  String? plot_no;
  String? size;
  String? discount_price;
  String? quantity;
  String? currency;
  String message = '';
  String? _selectedProduct;
  Map response = new Map();
  List? _products = [];
  String api = FoodApi.baseApi;
  String? token;
  String? shopID;

  Future<String> getProducts() async {
    final url = "$api/products";
    var response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _products = resBody['data'];
      });
    } else {
      throw Exception('Failed to data');
    }
    return "Success";
  }

  Future<void> submit() async {
    final form = _formKey.currentState!;
    if (form.validate()) {
      List<Map> itemsVariation = [];
      List<Map> itemsOption = [];
      _variations.forEach((element) => itemsVariation.add(Variation(
              id: element.id,
              name: element.name,
              discount_price: element.discount_price != null
                  ? element.discount_price != ''
                      ? element.discount_price
                      : '0'
                  : '0',
              price: element.price,
              size: element.size,
              plot_no: element.plot_no,
              quantity: element.quantity)
          .TojsonData()));
      _options.forEach((element) => itemsOption.add(
          Options(id: element.id, name: element.name, price: element.price)
              .TojsonData()));
      Map<String, String?> body = {
        "product_type": product_type != null ? product_type : '5',
        "product_id":
            productID != null ? productID : widget.product!.id.toString(),
        "unit_price": price != null ? price : '',
        "size": size != null ? size : '',
        "plot_no": plot_no != null ? plot_no : '',
        "discount_price": discount_price != null
            ? discount_price != ''
                ? discount_price
                : '0'
            : '0',
        "quantity": quantity != null ? quantity : '',
        "variations": json.encode(itemsVariation),
        "options": json.encode(itemsOption),
      };
      final url =
          "$api/shop-product/$shopID/shop/${widget.product!.productItemID}/product";
      print(body);
      final response = await http.put(Uri.parse(url), body: body, headers: {
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.authorizationHeader: 'Bearer $token'
      });
      var resBody = json.decode(response.body);
      print(resBody);
      if (response.statusCode == 200) {
        _showAlert(context, true, 'Successfully Update Product ');
      } else if (response.statusCode == 401) {
        _showAlert(context, false, 'This product already assign ');
      } else {
        _showAlert(context, false, 'Not Successfully Update Product ');
        throw Exception('Failed to data');
      }
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyHomePage(
                                tabsIndex: 2,
                                title: ' My Product',
                              )));
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

  // _displayDialog(BuildContext context, type) async {
  //   return showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //             title: type == '1'
  //                 ? Text('Product Variations')
  //                 : Text('Product Options'),
  //             content: SingleChildScrollView(
  //               child: type == '1'
  //                   ? Form(
  //                       key: _variationFormKey,
  //                       child: Column(
  //                         children: <Widget>[
  //                           Container(
  //                             child: _variationNameWidget(null),
  //                           ),
  //                           SizedBox(
  //                             height: 20.0,
  //                           ),
  //                           // Container(
  //                           //   child: _variationPriceWidget(null),
  //                           // ),
  //                           SizedBox(
  //                             height: 20.0,
  //                           ),
  //                           Container(
  //                             child: _variationQuantityWidget(null),
  //                           ),
  //                           Container(
  //                             child: _variationDiscountWidget(null),
  //                           ),
  //                           SizedBox(
  //                             height: 24,
  //                           ),
  //                           Container(
  //                             width: double.infinity,
  //                             child: StyledFlatButton(
  //                               'Add',
  //                               onPressed: () {
  //                                 final form = _variationFormKey.currentState!;
  //                                 if (form.validate()) {
  //                                   setState(() {
  //                                     _variations.add(Variation(
  //                                         id: '0',
  //                                         name: variationName,
  //                                         price: variationPrice,
  //                                         discount_price: variationDiscount,
  //                                         quantity: variationQuantity));
  //                                     Navigator.of(context).pop();
  //                                   });
  //                                 }
  //                               },
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     )
  //                   : Form(
  //                       key: _variationFormKey,
  //                       child: Column(
  //                         children: <Widget>[
  //                           Container(
  //                             child: _variationNameWidget(null),
  //                           ),
  //                           SizedBox(
  //                             height: 20.0,
  //                           ),
  //                           // Container(
  //                           //   child: _variationPriceWidget(null),
  //                           // ),
  //                           SizedBox(
  //                             height: 24,
  //                           ),
  //                           Container(
  //                             width: double.infinity,
  //                             child: StyledFlatButton(
  //                               'Add',
  //                               onPressed: () {
  //                                 final form = _variationFormKey.currentState!;
  //                                 if (form.validate()) {
  //                                   setState(() {
  //                                     _options.add(Options(
  //                                       id: '0',
  //                                       name: variationName,
  //                                       price: variationPrice,
  //                                     ));
  //                                     Navigator.of(context).pop();
  //                                   });
  //                                 }
  //                               },
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //             ));
  //       });
  // }

  _EditDialog(BuildContext context, type, index) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: type == '1'
                  ? Text('Product Variations')
                  : Text('Product Options'),
              content: SingleChildScrollView(
                child: type == '1'
                    ? Form(
                        key: _variationFormKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              child:
                                  _variationNameWidget(_variations[index].name),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),

                            SizedBox(
                              height: 20.0,
                            ),
                            Container(
                              child: _variationQuantityWidget(
                                  _variations[index].quantity),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Container(
                              child: _variationDiscountWidget(
                                  _variations[index].discount_price),
                            ),
                            SizedBox(
                              height: 24,
                            ),
                            Container(
                              width: double.infinity,
                              child: StyledFlatButton(
                                'Update',
                                onPressed: () {
                                  final form = _variationFormKey.currentState!;
                                  if (form.validate()) {
                                    setState(() {
                                      _variations[index].name = variationName;
                                      _variations[index].price = variationPrice;
                                      _variations[index].size = size;
                                      _variations[index].plot_no = plot_no;
                                      _variations[index].quantity =
                                          variationQuantity;
                                      _variations[index].discount_price =
                                          variationDiscount;
                                      Navigator.of(context).pop();
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : Form(
                        key: _variationFormKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: _variationNameWidget(_options[index].name),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            // Container(
                            //   child:
                            //       _variationPriceWidget(_options[index].price),
                            // ),
                            SizedBox(
                              height: 24,
                            ),
                            Container(
                              width: double.infinity,
                              child: StyledFlatButton(
                                'Update',
                                onPressed: () {
                                  final form = _variationFormKey.currentState!;
                                  if (form.validate()) {
                                    setState(() {
                                      _options[index].name = variationName;
                                      _options[index].price = variationPrice;
                                      Navigator.of(context).pop();
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ));
        });
  }

  @override
  void initState() {
    super.initState();
    shopID = Provider.of<AuthProvider>(context, listen: false).shopID;
    token = Provider.of<AuthProvider>(context, listen: false).token;
    currency = Provider.of<AuthProvider>(context, listen: false).currency;
    getProducts();
    print(widget.product!.variations);
    _selectedProductType =
          'Single';
    product_type =  '5';


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfffada36),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text("Product Edit", style: TextStyle(color: Colors.white)),
      ),
      body: ListView(children: <Widget>[
        SizedBox(
          height: 20.0,
        ),
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Container(
                child: _productTypeWidget(),
                margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              ),
              Container(
                child: _productWidget(),
                margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              ),
              _selectedProductType == 'Single'
                  ? Column(children: <Widget>[
                      Container(
                        child: _priceWidget(),
                        margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                      ),
                Container(
                  child: _sizeWidget(),
                  margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                ),
                Container(
                  child: _sizePlot(),
                  margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                ),
                      Container(
                        child: _QuantityWidget(),
                        margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                      ),
                      Container(
                        child: _discountPriceWidget(),
                        margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                    ])
                  : Container(
                      // width: double.infinity,
                      // margin: EdgeInsets.only(left: 48, right: 48, top: 30),
                      // child: FlatButton(
                      //   color: Colors.blue,
                      //   textColor: Colors.white,
                      //   padding: EdgeInsets.all(8.0),
                      //   splashColor: Colors.blueAccent,
                      //   onPressed: () => _displayDialog(context, '1'),
                      //   child: Text(
                      //     "Click Variation",
                      //     style: TextStyle(fontSize: 20.0),
                      //   ),
                      // )
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        _selectedProductType != 'Single'
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  leading: Icon(
                    Icons.fastfood,
                    color: Colors.black54,
                  ),
                  title: Text(
                    'Product Variations List',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyle.textFormFieldMedium.copyWith(
                        color: Colors.black54,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            : Container(),
        SizedBox(
          height: 20.0,
        ),
        _selectedProductType != 'Single'
            ? ListView.separated(
                itemCount: _variations.length,
                shrinkWrap: true,
                primary: false,
                separatorBuilder: (context, index) {
                  return SizedBox(height: 10);
                },
                itemBuilder: (context, index) {
                  final item = _variations[index];
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
                            _EditDialog(context, '1', index);
                          },
                        ),
                        SlidableAction(
                          label: 'Delete',
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                          onPressed: (context) {
                            _variations.removeAt(index);
                          },
                        ),
                      ],
                    ),
                    child: new Container(
                      color: Colors.white,
                      child: Card(
                        child: ListTile(
                          title: Text(
                            _variations[index].name!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CustomTextStyle.textFormFieldMedium.copyWith(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Quantity - ' + _variations[index].quantity!,
                            style: CustomTextStyle.textFormFieldMedium.copyWith(
                                color: Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: RichText(
                            text: TextSpan(
                              children: [
                                new TextSpan(
                                  text: ' $currency' +
                                      _variations[index].price.toString() +
                                      ' ',
                                  style: TextStyle(
                                      fontFamily: 'Google Sans',
                                      color: Color(0xFFF75A4C),
                                      fontSize: 16.0),
                                ),
                                _variations[index].discount_price != null
                                    ? new TextSpan(
                                        text: ' ' +
                                            '$currency' +
                                            _variations[index]
                                                .discount_price
                                                .toString(),
                                        style: new TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16.0,
                                          fontFamily: 'Google Sans',
                                        ),
                                      )
                                    : TextSpan(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container(),
        // Container(
        //     width: double.infinity,
        //     margin: EdgeInsets.only(left: 48, right: 48, top: 30),
        //     child: FlatButton(
        //       color: Colors.blue,
        //       textColor: Colors.white,
        //       padding: EdgeInsets.all(8.0),
        //       splashColor: Colors.blueAccent,
        //       onPressed: () => _displayDialog(context, '2'),
        //       child: Text(
        //         "Click Options",
        //         style: TextStyle(fontSize: 20.0),
        //       ),
        //     )),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 10),
        //   child: ListTile(
        //     contentPadding: EdgeInsets.symmetric(vertical: 0),
        //     leading: Icon(
        //       Icons.fastfood,
        //       color: Colors.black54,
        //     ),
        //     title: Text(
        //       'Product Options List',
        //       maxLines: 1,
        //       overflow: TextOverflow.ellipsis,
        //       style: CustomTextStyle.textFormFieldMedium.copyWith(
        //           color: Colors.black54,
        //           fontSize: 20,
        //           fontWeight: FontWeight.bold),
        //     ),
        //   ),
        // ),
        SizedBox(
          height: 20.0,
        ),
        ListView.separated(
          itemCount: _options.length,
          shrinkWrap: true,
          primary: false,
          separatorBuilder: (context, index) {
            return SizedBox(height: 10);
          },
          itemBuilder: (context, index) {
            final item = _options[index];
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
                      _EditDialog(context, '2', index);
                    },
                  ),
                  SlidableAction(
                    label: 'Delete',
                    backgroundColor: Colors.red,
                    icon: Icons.delete,
                    onPressed: (context) {
                      setState(() {
                        _options.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
              child: new Container(
                color: Colors.white,
                child: Card(
                  child: ListTile(
                    title: Text(
                      _options[index].name!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyle.textFormFieldMedium.copyWith(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: RichText(
                        text: TextSpan(children: [
                      new TextSpan(
                        text: ' $currency' + _options[index].price!,
                        style: TextStyle(
                            fontFamily: 'Google Sans',
                            color: Color(0xFFF75A4C),
                            fontSize: 16.0),
                      ),
                    ])),
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(
          height: 20.0,
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(left: 48, right: 48),
          child: StyledFlatButton(
            'Update',
            onPressed: submit,
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
      ]),
    );
  }

  var border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(width: 1, color: Colors.grey));

  Widget _priceWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Price *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                  obscureText: false,
                  initialValue: widget.product!.price != null
                      ? (widget.product!.price!.toInt()).toString()
                      : '',
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    price = value!.trim();
                    return Validate.requiredField(value, 'Price is required.');
                  })
            ],
          ),
        )
      ],
    );
  }
  Widget _sizeWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Size *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                  obscureText: false,
                  initialValue: widget.product!.size != null
                      ? (widget.product!.size!).toString()
                      : '',
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    size = value!.trim();
                    return Validate.requiredField(value, 'Size is required.');
                  })
            ],
          ),
        )
      ],
    );
  }
  Widget _sizePlot() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Plot no *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                  obscureText: false,
                  initialValue: widget.product!.plot_no != null
                      ? (widget.product!.plot_no!).toString()
                      : '',
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    plot_no = value!.trim();
                    return Validate.requiredField(value, 'Plot No is required.');
                  })
            ],
          ),
        )
      ],
    );
  }


  Widget _QuantityWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Quantity *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                  obscureText: false,
                  initialValue: widget.product!.quantity != null
                      ? widget.product!.quantity.toString()
                      : '',
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    quantity = value!.trim();
                    return Validate.requiredField(
                        value, 'Quantity is required.');
                  })
            ],
          ),
        )
      ],
    );
  }

  Widget _productWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Product *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                    color: Color(0xfff3f3f4),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                      topLeft: Radius.circular(5.0),
                      topRight: Radius.circular(5.0),
                    )),
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButton(
                        isExpanded: true,
                        underline: SizedBox(
                          width: 20,
                        ),
                        icon: SvgPicture.asset("assets/icons/dropdown.svg"),
                        hint: Text(
                          'choose a product',
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                        ), // Not necessary for Option 1
                        value: _selectedProduct != null
                            ? _selectedProduct
                            : widget.product!.id.toString(),
                        onChanged: (dynamic product) {
                          setState(() {
                            _selectedProduct = product;
                            productID = product;
                          });
                        },
                        items: _products!.length > 0
                            ? _products!.map((product) {
                                return DropdownMenuItem(
                                  child: new Text(
                                    product['name'] != null
                                        ? product['name']
                                        : '',
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                  value: product['id'].toString(),
                                );
                              }).toList()
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _discountPriceWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Discount Price',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                  obscureText: false,
                  initialValue: widget.product!.discount != null
                      ? (widget.product!.discount!.toInt()).toString()
                      : '',
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    discount_price = value!.trim();
                    return Validate.NorequiredField();
                  })
            ],
          ),
        )
      ],
    );
  }

  Widget _variationNameWidget(name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Name *',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        SizedBox(
          height: 15,
        ),
        TextFormField(
            obscureText: false,
            initialValue: name != null ? name : null,
            decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),
            keyboardType: TextInputType.text,
            validator: (value) {
              variationName = value!.trim();
              return Validate.requiredField(value, 'Name is required.');
            })
      ],
    );
  }



  Widget _variationDiscountWidget(discount) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Discount Price',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                  obscureText: false,
                  initialValue: discount != null ? discount : null,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    variationDiscount = value!.trim();
                    return Validate.NorequiredField();
                  })
            ],
          ),
        )
      ],
    );
  }

  Widget _variationQuantityWidget(qty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Quantity *',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        SizedBox(
          height: 15,
        ),
        TextFormField(
            obscureText: false,
            initialValue: qty != null ? qty : null,
            decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),
            keyboardType: TextInputType.number,
            validator: (value) {
              variationQuantity = value!.trim();
              return Validate.requiredField(value, 'Quantity is required.');
            })
      ],
    );
  }

  Widget _productTypeWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Product Type *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                    color: Color(0xfff3f3f4),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                      topLeft: Radius.circular(5.0),
                      topRight: Radius.circular(5.0),
                    )),
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButton(

                        isExpanded: true,
                        underline: SizedBox(
                          width: 20,
                        ),
                        icon: SvgPicture.asset("assets/icons/dropdown.svg"),
                        hint: Text(
                          'choose a Type',
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                        ), // Not necessary for Option 1
                        value: _selectedProductType != null
                            ? _selectedProductType
                            : 'Single',
                        onChanged: (dynamic value) {
                          setState(() {
                            if ('Single' == value) {
                              product_type = '5';
                              _variations.clear();
                            } else {
                              product_type = '10';
                            }
                            _selectedProductType = value;
                          });
                        },
                        items:
                            <String>['Single', 'Variation'].map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
