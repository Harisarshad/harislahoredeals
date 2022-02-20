import 'package:eBazaarMerchant/src/screens/ProductPage.dart';
import 'package:eBazaarMerchant/src/shared/Product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/widget/CircularLoadingWidget.dart';
import 'package:eBazaarMerchant/src/screens/Category.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:search_choices/search_choices.dart';

class ExampleNumber {
  int number;

  static final Map<int, String> map = {
    0: "zero",
    1: "one",
    2: "two",
    3: "three",
    4: "four",
    5: "five",
    6: "six",
    7: "seven",
    8: "eight",
    9: "nine",
    10: "ten",
    11: "eleven",
    12: "twelve",
    13: "thirteen",
    14: "fourteen",
    15: "fifteen",
  };

  String get numberString {
    return ((map.containsKey(number) ? map[number] : "unknown") ?? "unknown");
  }

  ExampleNumber(this.number);

  String toString() {
    return ("$number $numberString");
  }

  static List<ExampleNumber> get list {
    return (map.keys.map((num) {
      return (ExampleNumber(num));
    })).toList();
  }
}
class ShopPages extends StatefulWidget {
  @override
  _ShopPageState createState() {
    return new _ShopPageState();
  }
}

class _ShopPageState extends State<ShopPages> {
  TextEditingController editingController = TextEditingController();
  GlobalKey<RefreshIndicatorState>? refreshKey;
  late Position _currentPosition;
  TextEditingController nameController = TextEditingController();
  String UserName = '';
  Future<void> _checkPermission() async {
    // verify permissions
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      await Geolocator.openLocationSettings();
    }
  }
  ExampleNumber? selectedNumber;
  List<DropdownMenuItem<ExampleNumber>> numberItems =
  ExampleNumber.list.map((exNum) {
    return (DropdownMenuItem(child: Text(exNum.numberString), value: exNum));
  }).toList();
  String location = '1';
  String api = FoodApi.baseApi;
  String? _selectedLocation = '1';
  String? _selectedArea = '1';
  List _locations = [];
  List _areas = [];
  List _shops = [];
  String? selectedValueSingleDialog;
  bool haris = true;
  List<Product> _products = [];

  final items = List<String>.generate(10000, (i) => "Item $i");

  Future<void> setting() async {
    await Provider.of<AuthProvider>(context, listen: false).setting();
  }

  Future<String> getLocations(latitude, longitude) async {
    final url = "$api/locations";
    var response = await http.get(Uri.parse(url), headers: {
      "X-FOOD-LAT": "$latitude",
      "X-FOOD-LONG": "$longitude",
      "Accept": "application/json"
    });
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _locations = resBody['data'];
      });
    } else {
      throw Exception('Failed to data');
    }
    return "Success";
  }

  Future<String> getArea() async {
    final url = "$api/locations/1/areas";
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
        _areas = resBody['data']['areas'];
         original = resBody['data']['areas'];
         print(original) ;
         persons = resBody['data']['areas'];
        _shops.clear();
       // _shops = resBody['data']['shops'];
        print(url);
        setState(() {});
        print("harisurlgetArea");
      });
    } else {
      throw Exception('Failed to');
    }

    return "Success";
  }

  Future<String> getShops(String areaID,String slug, String order  ) async {

    final url = areaID != null ? "$api/areasproduct?id=$areaID" : '$api/areas';



    var response = await http.get(Uri.parse(url), headers: {
      "X-FOOD-LAT": "$slug",
      "X-FOOD-LONG": "$order",
      "Accept": "application/json"
    });
    print("getShopsharis");
    print(url);
    print(slug);
    print(order);
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      setState(() {
        _shops.clear();


        _shops = resBody['data'];
        print(_shops);

        _shops.forEach((element) {
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
        print("shopsdata");
      });
    } else {
      throw Exception('Failed to data');
    }
    return "Success";
  }

  // void searchShop(value, latitude, longitude) async {
  //   final url = "$api/search/shops/$value";
  //   var response = await http.get(Uri.parse(url), headers: {
  //     "X-FOOD-LAT": "$latitude",
  //     "X-FOOD-LONG": "$longitude",
  //     "Accept": "application/json"
  //   });
  //   var resBody = json.decode(response.body);
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       _shops.clear();
  //       _shops = resBody['data'];
  //     });
  //   } else {
  //     throw Exception('Failed to data');
  //   }
  //   return;
  // }

  Future<Null> refreshList(area) async {
    setState(() {
      _shops.clear();
      this.setting();
      this.getShops(
          area,
          '',
          ''
         );
      this.getLocations(
          _currentPosition != null ? _currentPosition.latitude : '',
          _currentPosition != null ? _currentPosition.longitude : '');
     // _getCurrentLocation();
    });
  }

  initAuthProvider(context) async {
    Provider.of<AuthProvider>(context, listen: false).initAuthProvider();
  }
  onItemChanged(String value) {
    setState(() {
      // newDataList = mainDataList
      //     .where((string) => string.toLowerCase().contains(value.toLowerCase()))
      //     .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _checkPermission();
    getArea();
   // _getCurrentLocation();
    this.setting();
    initAuthProvider(context);
  }

  List original = [];
  List persons = [];



  void search(String query) {
    if (query.isEmpty) {
      persons = original;

      setState(() {});
      return;
    }
    haris =true;
    query = query.toLowerCase();
    print(query);
    List result = [];
    persons.forEach((p) {
      var name = p["name"].toString().toLowerCase();
      if (name.contains(query)) {
        result.add(p);
      }
    });

    persons = result;
    setState(() {});
  }
  TextEditingController txtQuery = new TextEditingController();
  _getCurrentLocation() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _selectedArea = null;
        _selectedLocation = null;
        _currentPosition = position;
        this.getLocations(
            _currentPosition != null ? _currentPosition.latitude : '',
            _currentPosition != null ? _currentPosition.longitude : '');

        this.getShops(
            _selectedArea!,
            '',
            ''
            );
      });
    }).catchError((e) {
      print(e);
      this.getLocations(
          _currentPosition != null ? _currentPosition.latitude : '',
          _currentPosition != null ? _currentPosition.longitude : '');

      this.getShops(
          _selectedArea!,
          '',
          ''
          );
      _checkPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(000),
      body: SafeArea(
        child: RefreshIndicator(
          key: refreshKey,
          onRefresh: () async {
            await refreshList(_selectedArea);
          },
          child: new LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return ListView(
                children: <Widget>[
                  SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Expanded(
                      //   child: Padding(
                      //     padding: EdgeInsets.only(
                      //         top: 10.0, left: 10.0, right: 10.0),
                      //     child: Container(
                      //       height: MediaQuery.of(context).size.height / 13.5,
                      //       width: MediaQuery.of(context).size.width / 2.2,
                      //       padding: EdgeInsets.all(2.0),
                      //       decoration: BoxDecoration(
                      //         color: Colors.white,
                      //         borderRadius: BorderRadius.only(
                      //           bottomRight: Radius.circular(10.0),
                      //           bottomLeft: Radius.circular(10.0),
                      //           topLeft: Radius.circular(10.0),
                      //           topRight: Radius.circular(10.0),
                      //         ),
                      //       ),
                      //       child: Row(
                      //         children: <Widget>[
                      //           // SvgPicture.asset(
                      //           //     "assets/icons/maps-and-flags.svg"),
                      //           SizedBox(width: 10),
                      //           // Expanded(
                      //           //   child: DropdownButton(
                      //           //     isExpanded: true,
                      //           //     underline: SizedBox(
                      //           //       width: 20,
                      //           //     ),
                      //           //     icon: SvgPicture.asset(
                      //           //         "assets/icons/dropdown.svg"),
                      //           //     hint: Text(
                      //           //       'choose a location',
                      //           //       overflow: TextOverflow.fade,
                      //           //       maxLines: 1,
                      //           //       softWrap: false,
                      //           //     ),
                      //           //     // Not necessary for Option 1
                      //           //     value: _selectedLocation != null
                      //           //         ? _selectedLocation
                      //           //         : null,
                      //           //     onChanged: (location) {
                      //           //       setState(() {
                      //           //         _selectedLocation = location as String?;
                      //           //         _shops.clear();
                      //           //         _areas.clear();
                      //           //         _selectedArea = null;
                      //           //         this.getArea(
                      //           //             location!,
                      //           //             _currentPosition != null
                      //           //                 ? _currentPosition.latitude
                      //           //                 : '',
                      //           //             _currentPosition != null
                      //           //                 ? _currentPosition.longitude
                      //           //                 : '');
                      //           //       });
                      //           //     },
                      //           //     items: _locations.length > 0
                      //           //         ? _locations.map((location) {
                      //           //             return DropdownMenuItem(
                      //           //               child: new Text(
                      //           //                 location['name'] != null
                      //           //                     ? location['name']
                      //           //                     : '',
                      //           //                 overflow: TextOverflow.fade,
                      //           //                 maxLines: 1,
                      //           //                 softWrap: false,
                      //           //               ),
                      //           //               value: location['id'].toString(),
                      //           //             );
                      //           //           }).toList()
                      //           //         : null,
                      //           //   ),
                      //           // ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                        child: Container(
                          height: haris ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height * .12 ,
                          width: MediaQuery.of(context).size.width * .80,
                          padding: EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                            ),
                          ),
                          child: Column(
                            children: <Widget>[

                              Container(
                                margin: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    TextFormField(
                                      controller: txtQuery,
                                      onChanged: search,
                                      decoration: InputDecoration(
                                        hintText: "Search",
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                        prefixIcon: Icon(Icons.search),
                                        suffixIcon: IconButton(
                                          icon: Icon(Icons.clear),
                                          onPressed: () {
                                            txtQuery.text = '';
                                            search(txtQuery.text);
                                            //haris =true;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                               haris ? _listView(persons) : Container()
                              // SvgPicture.asset(
                              //   "assets/icons/maps-and-flags.svg",
                              // // ),
                              // Padding(
                              //   padding: const EdgeInsets.all(12.0),
                              //   child: TextField(
                              //     //controller: _textController,
                              //     decoration: InputDecoration(
                              //       hintText: 'Search Here...',
                              //     ),
                              //     onChanged: onItemChanged,
                              //   ),
                              // ),
                              // Expanded(
                              //   child:  ListView.builder(
                              //     itemCount: _areas.length,
                              //     itemBuilder: (context, index) => Card(
                              //       key: ValueKey(_areas[index]["id"]),
                              //       color: Colors.amberAccent,
                              //       elevation: 4,
                              //       margin: const EdgeInsets.symmetric(vertical: 10),
                              //       child:
                              //
                              //       ListTile(
                              //         leading: Text(
                              //           _areas[index]["id"].toString(),
                              //           style: const TextStyle(fontSize: 24),
                              //         ),
                              //           onTap: ()=> print(_areas[index]['name']),
                              //         title: Text(_areas[index]['name']),
                              //         subtitle: Text(
                              //             '${_areas[index]["slug"].toString()} '),
                              //       ),
                              //     ),
                              //   )
                              // ),
                              // SizedBox(width:10),
                              // Expanded(child:
                              //
                              //
                              // TextFormField(
                              //     readOnly: true,
                              //     onTap: () {
                              //       showDialog(
                              //           context: context,
                              //           builder: (BuildContext context) {
                              //             return AlertDialog(
                              //               title: Text('Country List'),
                              //               content: setupAlertDialoadContainer(),
                              //             );
                              //           });
                              //     },
                              //   controller: editingController,
                              //   decoration: InputDecoration(
                              //       labelText: "Search",
                              //       hintText: "Search",
                              //       prefixIcon: Icon(Icons.search),
                              //       border: OutlineInputBorder(
                              //           borderRadius: BorderRadius.all(Radius.circular(25.0)))),
                              // ),
                              //
                              //
                              // ),

                              // Expanded(
                              //   child: DropdownButton(
                              //     isExpanded: true,
                              //     // underline: SizedBox(
                              //     //   width: 80,
                              //     // ),
                              //     icon: SvgPicture.asset(
                              //         "assets/icons/dropdown.svg"),
                              //     hint: Text(
                              //       'choose a Area',
                              //       overflow: TextOverflow.fade,
                              //       maxLines: 1,
                              //       softWrap: false,
                              //     ),
                              //     // Not necessary for Option 1
                              //     value: _selectedArea != null
                              //         ? _selectedArea
                              //         : null,
                              //     onChanged: (area) {
                              //       setState(() {
                              //         //selectedValueSingleDialog = area as String?;
                              //         _selectedArea = area as String?;
                              //         _shops.clear();
                              //         getShops(
                              //             area!,
                              //             _currentPosition != null
                              //                 ? _currentPosition.latitude
                              //                 : '',
                              //             _currentPosition != null
                              //                 ? _currentPosition.longitude
                              //                 : '');
                              //       });
                              //     },
                              //     items: _areas.map((area) {
                              //       return DropdownMenuItem(
                              //         child: new Text(
                              //           area['name'],
                              //           overflow: TextOverflow.fade,
                              //           maxLines: 1,
                              //           softWrap: false,
                              //         ),
                              //         value: area['id'].toString(),
                              //       );
                              //     }).toList(),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  // Padding(
                  //   padding:
                  //       EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //         color: Colors.white,
                  //         borderRadius: BorderRadius.only(
                  //           bottomRight: Radius.circular(10.0),
                  //           bottomLeft: Radius.circular(10.0),
                  //           topLeft: Radius.circular(10.0),
                  //           topRight: Radius.circular(10.0),
                  //         )),
                  //     child: TextField(
                  //       textInputAction: TextInputAction.search,
                  //       onSubmitted: (value) {
                  //         searchShop(
                  //             value != null ? value : null,
                  //             _currentPosition != null
                  //                 ? _currentPosition.latitude
                  //                 : '',
                  //             _currentPosition != null
                  //                 ? _currentPosition.longitude
                  //                 : '');
                  //       },
                  //       controller: editingController,
                  //       decoration: InputDecoration(
                  //         border: InputBorder.none,
                  //         contentPadding: EdgeInsets.only(top: 14.0),
                  //         hintText: 'Search for shops',
                  //         hintStyle: TextStyle(
                  //             fontFamily: 'Montserrat', fontSize: 14.0),
                  //         prefixIcon: Icon(Icons.search, color: Colors.grey),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  //SizedBox(height: 15.0),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.9),
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
                                      "Phase",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: Theme.of(context).textTheme.bodyText1,
                                    ),


                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "Block",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: Theme.of(context).textTheme.bodyText1,
                                    ),


                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "Plot",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: Theme.of(context).textTheme.bodyText1,
                                    ),


                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "Size",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: Theme.of(context).textTheme.bodyText1,
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
                                            text: ' Price' ,

                                            style: TextStyle(
                                                fontFamily: 'Google Sans',
                                                color: Color(0xFFF75A4C),
                                                fontSize: 14.0),
                                          ),
                                        ])),
                                    flex: -1,
                                  ),
                                  SizedBox(width: 15),

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
                  _shops.isEmpty
                      ? CircularLoadingWidget(
                          height: 200,
                          subtitleText: 'No Shops Found ',
                          img: 'assets/shopping3.png',
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

                       return Container(
                          height: 40,
                          color: Colors.white,
                          child: _buildFoodCard(
                            context,

                            _products[index],
                                () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return new ProductPage(
                                      currency: "Rs",
                                      productData: _products[index]);
                                }),
                              );
                            },
                          ),

                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFoodCard(context,  Product food, onTapped) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary,
      focusColor: Theme.of(context).colorScheme.secondary,
      highlightColor: Theme.of(context).primaryColor,
      onTap: onTapped,
      child:    Container(
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
                          "Phase",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),


                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Block",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),


                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Plot",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),


                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Size",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodyText1,
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
                                text: ' Price' ,

                                style: TextStyle(
                                    fontFamily: 'Google Sans',
                                    color: Color(0xFFF75A4C),
                                    fontSize: 14.0),
                              ),
                            ])),
                        flex: -1,
                      ),
                      SizedBox(width: 15),

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


//       Container(
//         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.9),
//           boxShadow: [
//             BoxShadow(
//                 color: Theme.of(context).focusColor.withOpacity(0.1),
//                 blurRadius: 5,
//                 offset: Offset(0, 2)),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: <Widget>[
//
//             SizedBox(width: 15),
//             Flexible(
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         Text(
//                           food.size.toString(),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 3,
//                           style: Theme.of(context).textTheme.bodyText1,
//                         ),
//
//                         Text( food.plot_no.toString(),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 2,
//                           style: Theme.of(context).textTheme.caption,
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         Text(
//                           food.name!,
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 2,
//                           style: Theme.of(context).textTheme.bodyText1,
//                         ),
//
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: 5),
//                   Row(
//                     children: <Widget>[
//                       Expanded(
//                         child: RichText(
//                             text: TextSpan(children: [
//                               new TextSpan(
//                                 text: ' Rs' +
//                                     (food.price! - food.discount!).toString(),
//                                 style: TextStyle(
//                                     fontFamily: 'Google Sans',
//                                     color: Color(0xFFF75A4C),
//                                     fontSize: 14.0),
//                               ),
//                             ])),
//                         flex: -1,
//                       ),
//                       SizedBox(width: 15),
//                       food.discount != 0
//                           ? RichText(
//                           text: TextSpan(children: [
//                             new TextSpan(
//                               text: 'Rs' + food.price.toString(),
//                               style: new TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 14.0,
//                                 fontFamily: 'Google Sans',
//                                 decoration: TextDecoration.lineThrough,
//                               ),
//                             ),
//                           ]))
//                           : Container(),
//                     ],
//                   ),
//
// //                Row(
// //                  children: <Widget>[
// //                    Text('$currency' + food.price.toString(), style: TextStyle(fontFamily: 'Google Sans', fontSize: 18.0,fontWeight: FontWeight.bold, color: Colors.black87,),),
// //                    Text('$currency' + food.price.toString(), style: TextStyle( fontFamily: 'Google Sans',fontSize: 15.0,  color: Colors.black54,),),
// //                  ],
// //                ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
    );
  }
  Widget _listView(persons) {
    return Expanded(
      child: ListView.builder(
          itemCount: persons.length,
          itemBuilder: (context, index) {
            var person = persons[index];
            return ListTile(
              onTap: () {
                print(person['id']);
                print(person['slug']);
                print(person['name']);
                print(person['order']);
                print("ontaplocation");
                setState(() {});
                this.getShops(
                    person['id'].toString(),
                    person['slug'],
                    person['order'].toString()

                );
                haris=false;
              },
              leading: CircleAvatar(
                child: Text(person['name'][0]),
              ),
              title: Text(person['name']),
             // subtitle: Text("City: " + person['id']),
            );
          }),
    );
  }
  Widget setupAlertDialoadContainer() {
    return Container(
      height: 300.0, // Change as per your requirement
      width: 300.0, // Change as per your requirement
      child:


      ListView.builder(
        itemCount: _areas.length,
        itemBuilder: (context, index) => Card(
          key: ValueKey(_areas[index]["id"]),
          color: Colors.amberAccent,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical:5),
          child: ListTile(
            // leading: Text(
            //   _areas[index]["id"].toString(),
            //   style: const TextStyle(fontSize: 24),
            // ),
            title: Text(_areas[index]['name']),
            // subtitle: Text(
            //     '${_areas[index]} '),
          ),
        ),
      )
    );
  }
  Widget _buildCard(String name, String imgPath, String address, int shopID) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.white,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Category(shopID: '$shopID', shopName: name),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.all(6),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            SizedBox(height: 2),
            Flexible(
              child: Text(
                name != null ? name : '',
                style: TextStyle(
                    color: Color(0xFF575E67),
                    fontFamily: 'Varela',
                    fontSize: 15.0),
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.fade,
              ),
            ),
            SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.location_on,
                  size: 16.0,
                  color: Colors.amber.shade500,
                ),
                Flexible(
                  child: Text(
                    address != null ? address : '',
                    style: TextStyle(
                        color: Color(0xFF575E67),
                        fontFamily: 'Varela',
                        fontSize: 11.0),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.location_on,
                  size: 16.0,
                  color: Colors.amber.shade500,
                ),
                Flexible(
                  child: Text(
                    address != null ? address : '',
                    style: TextStyle(
                        color: Color(0xFF575E67),
                        fontFamily: 'Varela',
                        fontSize: 11.0),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                  ),
                )
              ],
            ),
            SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
