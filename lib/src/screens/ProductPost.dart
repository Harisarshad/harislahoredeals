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
  List _locations = [];
  String? product_type;
  String? productID;
  String? price;
  String? size;
  String? plot;
  String? combilename;
  String? phase;
  String? phasename = '';
  String? society = '0';
  String? societyname = '';
  String? block = '0';
  String? blockname = '';

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

  List _Society = [];
  List _areas = [];
  List _Phase = [];
  List _Block = [];
  List _shops = [];
  String? _selectedArea = '13';
  String? _selectedAreaBlock = '1';
  String? _selectedAreaPhase = '1';
  String? _selectedLocation = '1';
  bool harissoc = false;
  bool harisphase = false;
  bool harisblock = false;
  List originalsoc = [];
  List personssoc = [];
  TextEditingController txtQuerysoc = new TextEditingController();
  List originalphase = [];
  List personsphase = [];
  TextEditingController txtQueryphase = new TextEditingController();
  List originalblock = [];
  List personsblock = [];
  TextEditingController txtQueryblock = new TextEditingController();
  void searchsoc(String query) {
    if (query.isEmpty) {
      personssoc = originalsoc;

      setState(() {});
      return;
    }
    setState(() {

    });
    originalphase.clear();
    personsphase.clear();
    originalblock.clear();
    personsblock.clear();
    setState(() {

    });
    harissoc =true;
    query = query.toLowerCase();
    print(query);
    List result = [];
    personssoc.forEach((p) {
      var name = p["soc_title"].toString().toLowerCase();
      if (name.contains(query)) {
        result.add(p);
      }
    });

    personssoc = result;
    setState(() {});
  }
  void searchphase(String query) {
    if (query.isEmpty) {
      personsphase = originalphase;

      setState(() {});
      return;
    }

    originalblock.clear();
    personsblock.clear();
    harisphase =true;
    query = query.toLowerCase();
    print(query);
    List result = [];
    personsphase.forEach((p) {
      var name = p["phase_title"].toString().toLowerCase();
      if (name.contains(query)) {
        result.add(p);
      }
    });

    personsphase = result;
    setState(() {});
  }
  void searchblock(String query) {
    if (query.isEmpty) {
      personsblock = originalblock;

      setState(() {});
      return;
    }
    harisblock =true;
    query = query.toLowerCase();
    print(query);
    List result = [];
    personssoc.forEach((p) {
      var name = p["block_title"].toString().toLowerCase();
      if (name.contains(query)) {
        result.add(p);
      }
    });

    personsblock = result;
    setState(() {});
  }


  String? _selectedLocationPhase = '1';
  String? _selectedLocationBlock = '1';
  Future<String> getSociety() async {
    final url = "$api/locations/1/society";
    print(url);
    print("harisurlgetSociety");
    var response = await http.get(Uri.parse(url), headers: {
      "X-FOOD-LAT": "1",
      "X-FOOD-LONG": "1",
      "Accept": "application/json"
    });
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _Society = resBody['data']['society'];
        _areas = resBody['data']['society'];
        originalsoc = resBody['data']['society'];
        personssoc = resBody['data']['society'];


        print(url);
        print(_areas);
        setState(() {});
        print("harisurlgetSocietydone");
      });
    } else {
      throw Exception('Failed to');
    }

    return "Success";
  }
  Future<String> getPhase(String Soc) async {
    final url = "$api/locations/$Soc/phase";
    print(url);
    print("harisurlgetPhase");
    var response = await http.get(Uri.parse(url), headers: {
      "X-FOOD-LAT": "1",
      "X-FOOD-LONG": "1",
      "Accept": "application/json"
    });
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _Phase = resBody['data']['phase'];
        originalphase = resBody['data']['phase'];
        personsphase = resBody['data']['phase'];

        print(url);
        print(_Phase);
        setState(() {});
        print("harisurlgetArea");
      });
    } else {
      throw Exception('Failed to');
    }


    return "Success";
  }
  Future<String> getBlock(String Phase) async {
    final url = "$api/locations/$Phase/block";
    print(url);
    print("harisurlgetArea");
    var response = await http.get(Uri.parse(url), headers: {
      "X-FOOD-LAT": "1",
      "X-FOOD-LONG": "1",
      "Accept": "application/json"
    });
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _Block = resBody['data']['block'];

        originalblock = resBody['data']['block'];
        personsblock = resBody['data']['block'];

        print(url);
        setState(() {});
        print("harisurlgetArea");
      });
    } else {
      throw Exception('Failed to');
    }


    return "Success";
  }
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
        "product_type":  '5',
        "product_id": productID != null ? productID : '1',
        "name":  '$societyname' ' + $phasename +' ' $blockname',
        "unit_price": price != null ? price : '',
        "p_city":  '1',
        "plot_no": plot != null ? plot : '',
        "plot_size": size != null ? size : '',
        "p_society": society != null ? society : '',
        "p_phase": phase != null ? phase : '',
        "p_block": block != null ? block : '',
        "discount_price": discount_price != null
            ? discount_price != ''
                ? discount_price
                : '0'
            : '0',
        "quantity": quantity != null ? quantity : '5',
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
      print(body);
      print("postupload");

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
  //                             child: _variationNameWidget(),
  //                           ),
  //                           SizedBox(
  //                             height: 20.0,
  //                           ),
  //                           Container(
  //                             child: _variationPriceWidget(),
  //                           ),
  //
  //                           SizedBox(
  //                             height: 20.0,
  //                           ),
  //                           Container(
  //                             child: _variationQuantityWidget(),
  //                           ),
  //                           SizedBox(
  //                             height: 24,
  //                           ),
  //                           SizedBox(
  //                             height: 20.0,
  //                           ),
  //                           Container(
  //                             child: _variationDiscountWidget(),
  //                           ),
  //                           SizedBox(
  //                             height: 24,
  //                           ),
  //                           Container(
  //                             width: double.infinity,
  //                             child: StyledFlatButton(
  //                               'Variation Add',
  //                               onPressed: () {
  //                                 final form = _variationFormKey.currentState!;
  //                                 if (form.validate()) {
  //                                   setState(() {
  //                                     _variations.add(Variation(
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
  //                             child: _variationNameWidget(),
  //                           ),
  //                           SizedBox(
  //                             height: 20.0,
  //                           ),
  //                           Container(
  //                             child: _variationPriceWidget(),
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
  //                                     _options.add(Options(
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

  @override
  void initState() {
    super.initState();
    getSociety();
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
                child: _productSocietyWidget(),
                margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              ),
              originalphase.isNotEmpty ? Container(
                child: _productPhaseWidget(),
                margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              ):Container(),
              originalblock.isNotEmpty ? Container(
                child: _productBlockWidget(),
                margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              ):Container(),
              // Container(
              //   child: _productWidget(),
              //   margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              // ),
               Column(children: <Widget>[
                      Container(
                        child: _priceWidget(),
                        margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                      ),
                       Container(
                         child: _sizeWidget(),
                         margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                       ),
                       Container(
                         child: _plotWidget(),
                         margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                       ),
                      // Container(
                      //   child: _QuantityWidget(),
                      //   margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                      // ),
                      // Container(
                      //   child: _discountPriceWidget(),
                      //   margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                      // ),
                      SizedBox(
                        height: 24,
                      ),
                    ])

            ],
          ),
        ),


        SizedBox(
          height: 20.0,
        ),

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
        // ListView.separated(
        //   itemCount: _options.length,
        //   shrinkWrap: true,
        //   primary: false,
        //   separatorBuilder: (context, index) {
        //     return SizedBox(height: 10);
        //   },
        //   itemBuilder: (context, index) {
        //     final item = _options[index];
        //     return Slidable(
        //       startActionPane: ActionPane(
        //         motion: const DrawerMotion(),
        //         extentRatio: 0.25,
        //         children: [
        //           SlidableAction(
        //             label: 'Delete',
        //             backgroundColor: Colors.red,
        //             icon: Icons.delete,
        //             onPressed: (context) {
        //               setState(() {
        //                 _options.removeAt(index);
        //               });
        //             },
        //           ),
        //         ],
        //       ),
        //       child: new Container(
        //         color: Colors.white,
        //         child: Card(
        //           child: ListTile(
        //             title: Text(
        //               _options[index].name!,
        //               maxLines: 1,
        //               overflow: TextOverflow.ellipsis,
        //               style: CustomTextStyle.textFormFieldMedium.copyWith(
        //                   color: Colors.black87,
        //                   fontSize: 18,
        //                   fontWeight: FontWeight.bold),
        //             ),
        //             trailing: RichText(
        //               text: TextSpan(
        //                 children: [
        //                   new TextSpan(
        //                     text: ' $currency' + _options[index].price!,
        //                     style: TextStyle(
        //                         fontFamily: 'Google Sans',
        //                         color: Color(0xFFF75A4C),
        //                         fontSize: 16.0),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //     );
        //   },
        // ),
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

  Widget _productSocietyWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Select Society *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                height: harissoc ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height * .09 ,

                padding: EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                    color: Color(0xfff3f3f4),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                      topLeft: Radius.circular(5.0),
                      topRight: Radius.circular(5.0),
                    )),
                child: Column(
                  children: <Widget>[
                    SizedBox(width: 10),
                 TextFormField(


                   controller: txtQuerysoc,
                    onChanged: searchsoc,
                    decoration: InputDecoration(

                      hintText: "Search",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          txtQuerysoc.text = '';
                          searchsoc(txtQuerysoc.text);
                          //haris =true;
                        },
                      ),
                    ),
                  ),
                    harissoc ? _listViewsoc(personssoc) : Container()
                //    child: DropdownButton(
                //   isExpanded: true,
                //   underline: SizedBox(
                //     width: 20,
                //   ),
                //   icon: SvgPicture.asset(
                //       "assets/icons/dropdown.svg"),
                //   hint: Text(
                //     'choose a Area',
                //     overflow: TextOverflow.fade,
                //     maxLines: 1,
                //     softWrap: false,
                //   ),
                //   // Not necessary for Option 1
                //   // value: _selectedArea != null
                //   //     ? _selectedArea
                //   //     : null,
                //   onChanged: (area) {
                //     setState(() {
                //       _selectedArea = area as String?;
                //       _shops.clear();
                //       print(_selectedArea);
                //       // // getShops(
                //       //     area!,
                //       //     _currentPosition != null
                //       //         ? _currentPosition.latitude
                //       //         : '',
                //       //     _currentPosition != null
                //       //         ? _currentPosition.longitude
                //       //         : '');
                //     });
                //   },
                //   items: _areas.map((area) {
                //     return DropdownMenuItem(
                //       child: new Text(
                //        area['soc_title'].toString(),
                //         overflow: TextOverflow.fade,
                //         maxLines: 1,
                //         softWrap: false,
                //       ),
                //       value: area['soc_id'].toString(),
                //     );
                //   }).toList(),
                // ),


                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }


  Widget _listViewsoc(personssoc) {
    return Expanded(
      child: ListView.builder(
          itemCount: personssoc.length,
          itemBuilder: (context, index) {
            var person = personssoc[index];
            return ListTile(
              onTap: () {
                print(person['slug']);
                setState(() {
                  harissoc=false;
                  society = person['soc_id'].toString();
                  societyname = person['soc_title'].toString();

                  txtQuerysoc.text = person['soc_title'];
                  harissoc=false;
                  getPhase(person['soc_id'].toString() );

                });


                // harissoc=false;
                // txtQuerysoc.text = person['soc_title'];
                // getPhase(person['soc_id'].toString() );
              },
              leading: CircleAvatar(
                child: Text(person['soc_title'][0]),
              ),
              title: Text(person['soc_title']),
              // subtitle: Text("City: " + person['id']),
            );
          }),
    );
  }
  Widget _listViewphase(personssoc) {
    return Expanded(
      child: ListView.builder(
          itemCount: personssoc.length,
          itemBuilder: (context, index) {
            var person = personssoc[index];
            return ListTile(
              onTap: () {
                print(person['slug']);
                setState(() {});
                harisphase=false;
                phase = person['phase_id'].toString();
                phasename = person['phase_title'].toString();

                txtQueryphase.text = person['phase_title'];
                harisphase=false;
                getBlock(person['phase_id'].toString() );
              },
              leading: CircleAvatar(
                child: Text(person['phase_title'][0]),
              ),
              title: Text(person['phase_title']),
              // subtitle: Text("City: " + person['id']),
            );
          }),
    );
  }
  Widget _listViewblock(personsblock) {
    return Expanded(
      child: ListView.builder(
          itemCount: personsblock.length,
          itemBuilder: (context, index) {
            var person = personsblock[index];
            return ListTile(
              onTap: () {
                print(person['block_title']);
                setState(() {});
                harisblock=false;
                block = person['block_id'].toString();
                blockname = person['block_title'].toString();
                txtQueryblock.text = person['block_title'];
                harisblock=false;

              },
              leading: CircleAvatar(
                child: Text(person['block_title'][0]),
              ),
              title: Text(person['block_title']),
              // subtitle: Text("City: " + person['id']),
            );
          }),
    );
  }

   Widget _productPhaseWidget() {
     return Column(
       children: <Widget>[
         Container(
           margin: EdgeInsets.symmetric(vertical: 5),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: <Widget>[
               Text(
                 'Select Phase *',
                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
               ),
               SizedBox(
                 height: 15,
               ),
               Container(
                 height: harisphase ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height * .09 ,

                 padding: EdgeInsets.all(2.0),
                 decoration: BoxDecoration(
                     color: Color(0xfff3f3f4),
                     borderRadius: BorderRadius.only(
                       bottomRight: Radius.circular(5.0),
                       bottomLeft: Radius.circular(5.0),
                       topLeft: Radius.circular(5.0),
                       topRight: Radius.circular(5.0),
                     )),
                 child: Column(
                   children: <Widget>[
                     SizedBox(width: 10),
                     TextFormField(
                       controller: txtQueryphase,
                       onChanged: searchphase,
                       decoration: InputDecoration(
                         hintText: "Search",
                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                         focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                         prefixIcon: Icon(Icons.search),
                         suffixIcon: IconButton(
                           icon: Icon(Icons.clear),
                           onPressed: () {
                             txtQueryphase.text = '';
                             searchphase(txtQueryphase.text);
                             //haris =true;
                           },
                         ),
                       ),
                     ),
                     harisphase ? _listViewphase(personsphase) : Container()
                     //    child: DropdownButton(
                     //   isExpanded: true,
                     //   underline: SizedBox(
                     //     width: 20,
                     //   ),
                     //   icon: SvgPicture.asset(
                     //       "assets/icons/dropdown.svg"),
                     //   hint: Text(
                     //     'choose a Area',
                     //     overflow: TextOverflow.fade,
                     //     maxLines: 1,
                     //     softWrap: false,
                     //   ),
                     //   // Not necessary for Option 1
                     //   // value: _selectedArea != null
                     //   //     ? _selectedArea
                     //   //     : null,
                     //   onChanged: (area) {
                     //     setState(() {
                     //       _selectedArea = area as String?;
                     //       _shops.clear();
                     //       print(_selectedArea);
                     //       // // getShops(
                     //       //     area!,
                     //       //     _currentPosition != null
                     //       //         ? _currentPosition.latitude
                     //       //         : '',
                     //       //     _currentPosition != null
                     //       //         ? _currentPosition.longitude
                     //       //         : '');
                     //     });
                     //   },
                     //   items: _areas.map((area) {
                     //     return DropdownMenuItem(
                     //       child: new Text(
                     //        area['soc_title'].toString(),
                     //         overflow: TextOverflow.fade,
                     //         maxLines: 1,
                     //         softWrap: false,
                     //       ),
                     //       value: area['soc_id'].toString(),
                     //     );
                     //   }).toList(),
                     // ),


                   ],
                 ),
               ),
             ],
           ),
         )
       ],
     );
  }
   Widget _productBlockWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Product Block *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                height: harisblock ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height * .09 ,

                padding: EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                    color: Color(0xfff3f3f4),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                      topLeft: Radius.circular(5.0),
                      topRight: Radius.circular(5.0),
                    )),
                child: Column(
                  children: <Widget>[
                    SizedBox(width: 10),
                    TextFormField(
                      controller: txtQueryblock,
                      onChanged: searchblock,
                      decoration: InputDecoration(
                        hintText: "Search",

                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            txtQueryblock.text = '';
                            searchblock(txtQueryblock.text);
                            //haris =true;
                          },
                        ),
                      ),
                    ),
                    harisblock ? _listViewblock(personsblock) : Container()
                    //    child: DropdownButton(
                    //   isExpanded: true,
                    //   underline: SizedBox(
                    //     width: 20,
                    //   ),
                    //   icon: SvgPicture.asset(
                    //       "assets/icons/dropdown.svg"),
                    //   hint: Text(
                    //     'choose a Area',
                    //     overflow: TextOverflow.fade,
                    //     maxLines: 1,
                    //     softWrap: false,
                    //   ),
                    //   // Not necessary for Option 1
                    //   // value: _selectedArea != null
                    //   //     ? _selectedArea
                    //   //     : null,
                    //   onChanged: (area) {
                    //     setState(() {
                    //       _selectedArea = area as String?;
                    //       _shops.clear();
                    //       print(_selectedArea);
                    //       // // getShops(
                    //       //     area!,
                    //       //     _currentPosition != null
                    //       //         ? _currentPosition.latitude
                    //       //         : '',
                    //       //     _currentPosition != null
                    //       //         ? _currentPosition.longitude
                    //       //         : '');
                    //     });
                    //   },
                    //   items: _areas.map((area) {
                    //     return DropdownMenuItem(
                    //       child: new Text(
                    //        area['soc_title'].toString(),
                    //         overflow: TextOverflow.fade,
                    //         maxLines: 1,
                    //         softWrap: false,
                    //       ),
                    //       value: area['soc_id'].toString(),
                    //     );
                    //   }).toList(),
                    // ),


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
  Widget _plotWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Plot No *',
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
                    plot = value!.trim();
                    return Validate.requiredField(value, 'Plot No is required.');
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
                'Plot size *',
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
                    size = value!.trim();
                    return Validate.requiredField(value, 'Plot size required.');
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
                'Society *',
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
