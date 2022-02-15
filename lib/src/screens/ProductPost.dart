import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/Widget/styled_flat_button.dart';
import 'package:eBazaarMerchant/src/utils/CustomTextStyle.dart';
import 'package:eBazaarMerchant/src/utils/validate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../main.dart';

class Variation {
  String? name;
  String? price;
  String? discount_price;
  String? quantity;
  Variation({
    this.name,
    this.price,
    this.discount_price,
    this.quantity,
  });

  Map<String, dynamic> TojsonData() {
    var map = new Map<String, dynamic>();
    map["name"] = name;
    map["price"] = price;
    map["discount_price"] = discount_price;
    map["quantity"] = quantity;
    return map;
  }
}

class Options {
  String? name;
  String? price;
  Options({this.name, this.price});
  Map<String, dynamic> TojsonData() {
    var map = new Map<String, dynamic>();
    map["name"] = name;
    map["price"] = price;
    return map;
  }
}

class ProductPost extends StatefulWidget {
  ProductPost({
    Key? key,
  }) : super(key: key);

  @override
  _ProductPostState createState() => _ProductPostState();
}

class _ProductPostState extends State<ProductPost> {
  final _ProductStateScrean = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _variationFormKey = GlobalKey<FormState>();
  List<Variation> _variations = [];
  List<Options> _options = [];

  String? product_type;
  String? productID;
  String? price;
  String discount_price = '0';
  String? quantity;

  String? variationName;
  String? variationPrice;
  String variationDiscount = '0';
  String? variationQuantity;

  String message = '';
  String? _selectedProduct;
  String? _selectedProductType = 'Single';
  Map response = new Map();
  List? _products = [];
  String api = FoodApi.baseApi;
  String? token;
  String? shopID;
  String? currency;

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
              name: element.name,
              price: element.price,
              discount_price:
                  element.discount_price != '' ? element.discount_price : '0',
              quantity: element.quantity)
          .TojsonData()));
      _options.forEach((element) => itemsOption
          .add(Options(name: element.name, price: element.price).TojsonData()));
      Map<String, String?> body = {
        "product_type": product_type != null ? product_type : '5',
        "product_id": productID != null ? productID : '1',
        "unit_price": price != null ? price : '',
        "discount_price": discount_price != null
            ? discount_price != ''
                ? discount_price
                : '0'
            : '0',
        "quantity": quantity != null ? quantity : '',
        "variations": json.encode(itemsVariation),
        "options": json.encode(itemsOption),
      };
      print(body);
      final url = "$api/shop-product/$shopID/shop/product";
      final response = await http.post(Uri.parse(url), body: body, headers: {
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.authorizationHeader: 'Bearer $token'
      });
      var resBody = json.decode(response.body);
      print(resBody);
      if (response.statusCode == 200) {
        _showAlert(context, true, 'Successfully Create Product ');
      } else if (response.statusCode == 401) {
        _showAlert(context, false, 'This product already assign ');
      } else {
        _showAlert(context, false, 'Not Successfully Create Product ');
        throw Exception('Failed to data');
      }
    }
  }

  Future<void> _showAlert(BuildContext context, bool, mes) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Product Add'),
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
                                title: 'My Product',
                              ))).then((_) => _formKey.currentState!.reset());
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

  _displayDialog(BuildContext context, type) async {
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
                              child: _variationNameWidget(),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Container(
                              child: _variationPriceWidget(),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Container(
                              child: _variationQuantityWidget(),
                            ),
                            SizedBox(
                              height: 24,
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Container(
                              child: _variationDiscountWidget(),
                            ),
                            SizedBox(
                              height: 24,
                            ),
                            Container(
                              width: double.infinity,
                              child: StyledFlatButton(
                                'Variation Add',
                                onPressed: () {
                                  final form = _variationFormKey.currentState!;
                                  if (form.validate()) {
                                    setState(() {
                                      _variations.add(Variation(
                                          name: variationName,
                                          price: variationPrice,
                                          discount_price: variationDiscount,
                                          quantity: variationQuantity));
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
                              child: _variationNameWidget(),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Container(
                              child: _variationPriceWidget(),
                            ),
                            SizedBox(
                              height: 24,
                            ),
                            Container(
                              width: double.infinity,
                              child: StyledFlatButton(
                                'Add',
                                onPressed: () {
                                  final form = _variationFormKey.currentState!;
                                  if (form.validate()) {
                                    setState(() {
                                      _options.add(Options(
                                        name: variationName,
                                        price: variationPrice,
                                      ));
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
    currency = Provider.of<AuthProvider>(context, listen: false).currency;
    token = Provider.of<AuthProvider>(context, listen: false).token;
    getProducts();
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
        title: Text(
          "Product",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 48, right: 48, top: 30),
                      child: FlatButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        padding: EdgeInsets.all(8.0),
                        splashColor: Colors.blueAccent,
                        onPressed: () => _displayDialog(context, '1'),
                        child: Text(
                          "Click Variation",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      )),
            ],
          ),
        ),
        _selectedProductType == 'Single'
            ? Container()
            : SizedBox(
                height: 20.0,
              ),
        _selectedProductType == 'Single'
            ? Container()
            : Padding(
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
              ),
        SizedBox(
          height: 20.0,
        ),
        _selectedProductType == 'Single'
            ? Container()
            : ListView.separated(
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
              ),
        Container(
            width: double.infinity,
            margin: EdgeInsets.only(left: 48, right: 48, top: 30),
            child: FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              padding: EdgeInsets.all(8.0),
              splashColor: Colors.blueAccent,
              onPressed: () => _displayDialog(context, '2'),
              child: Text(
                "Click Options",
                style: TextStyle(fontSize: 20.0),
              ),
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 0),
            leading: Icon(
              Icons.fastfood,
              color: Colors.black54,
            ),
            title: Text(
              'Product Options List',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CustomTextStyle.textFormFieldMedium.copyWith(
                  color: Colors.black54,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
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
                      text: TextSpan(
                        children: [
                          new TextSpan(
                            text: ' $currency' + _options[index].price!,
                            style: TextStyle(
                                fontFamily: 'Google Sans',
                                color: Color(0xFFF75A4C),
                                fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
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
            'Product Add',
            onPressed: () {
              submit();
            },
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

  Widget _variationNameWidget() {
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

  Widget _variationPriceWidget() {
    return Column(
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
            decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),
            keyboardType: TextInputType.number,
            validator: (value) {
              variationPrice = value!.trim();
              return Validate.requiredField(value, 'Price is required.');
            })
      ],
    );
  }

  Widget _variationDiscountWidget() {
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

  Widget _variationQuantityWidget() {
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
                        value:
                            _selectedProduct != null ? _selectedProduct : '1',
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
}
