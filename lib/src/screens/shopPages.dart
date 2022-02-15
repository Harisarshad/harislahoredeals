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
        _shops.clear();
        _shops = resBody['data']['shops'];
        print(url);
        print("harisurlgetArea");
      });
    } else {
      throw Exception('Failed to');
    }

    return "Success";
  }

  Future<String> getShops(String areaID, latitude, longitude) async {

    final url = areaID != null ? "$api/areas?id=$areaID" : '$api/areas';
    print("getShops");
    print(url);


    var response = await http.get(Uri.parse(url), headers: {
      "X-FOOD-LAT": "$latitude",
      "X-FOOD-LONG": "$longitude",
      "Accept": "application/json"
    });
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      setState(() {
        _shops.clear();
        _shops = resBody['data'];
      });
    } else {
      throw Exception('Failed to data');
    }
    return "Success";
  }

  void searchShop(value, latitude, longitude) async {
    final url = "$api/search/shops/$value";
    var response = await http.get(Uri.parse(url), headers: {
      "X-FOOD-LAT": "$latitude",
      "X-FOOD-LONG": "$longitude",
      "Accept": "application/json"
    });
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _shops.clear();
        _shops = resBody['data'];
      });
    } else {
      throw Exception('Failed to data');
    }
    return;
  }

  Future<Null> refreshList(area) async {
    setState(() {
      _shops.clear();
      this.setting();
      this.getShops(
          area,
          _currentPosition != null ? _currentPosition.latitude : '',
          _currentPosition != null ? _currentPosition.longitude : '');
      this.getLocations(
          _currentPosition != null ? _currentPosition.latitude : '',
          _currentPosition != null ? _currentPosition.longitude : '');
      _getCurrentLocation();
    });
  }

  initAuthProvider(context) async {
    Provider.of<AuthProvider>(context, listen: false).initAuthProvider();
  }

  @override
  void initState() {
    super.initState();
    _checkPermission();
    this.getArea(
        );
    _getCurrentLocation();
    this.setting();
    initAuthProvider(context);
  }

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
            _currentPosition != null ? _currentPosition.latitude : '',
            _currentPosition != null ? _currentPosition.longitude : '');
      });
    }).catchError((e) {
      print(e);
      this.getLocations(
          _currentPosition != null ? _currentPosition.latitude : '',
          _currentPosition != null ? _currentPosition.longitude : '');

      this.getShops(
          _selectedArea!,
          _currentPosition != null ? _currentPosition.latitude : '',
          _currentPosition != null ? _currentPosition.longitude : '');
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
                          height: MediaQuery.of(context).size.height / 13.5,
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
                          child: Row(
                            children: <Widget>[
                              SvgPicture.asset(
                                "assets/icons/maps-and-flags.svg",
                              ),
                              SizedBox(width:10),
                              Expanded(child: SearchChoices.single(
                                items: _areas.map((area) {
                                  return DropdownMenuItem(
                                    child: new Text(
                                      area['name'] ,
                                      overflow: TextOverflow.fade,
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                    value: area['name'],

                                  );
                                }).toList(),
                                hint: _selectedArea != null
                                    ? _selectedArea
                                    : null,
                                searchHint: "Select one",
                                value: _selectedArea != null
                                    ? _selectedArea
                                    : null,


                                onChanged: (area) {
                                  setState(() {
                                    //selectedValueSingleDialog = area as String?;
                                    _selectedArea = area;
                                    print("_selectedArea");
                                    print(_selectedArea);

                                    _shops.clear();
                                    getShops(
                                        area!,
                                        _currentPosition != null
                                            ? _currentPosition.latitude
                                            : '',
                                        _currentPosition != null
                                            ? _currentPosition.longitude
                                            : '');
                                  });
                                },
                                isExpanded: true,
                              )
                              ),
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
                  SizedBox(height: 15.0),
                  _shops.isEmpty
                      ? CircularLoadingWidget(
                          height: 200,
                          subtitleText: 'No Shops Found ',
                          img: 'assets/shopping3.png',
                        )
                      : Container(
                          height: MediaQuery.of(context).size.height / 1.5,
                          width: MediaQuery.of(context).size.width / 2,
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          child: new GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            childAspectRatio:
                                MediaQuery.of(context).size.width /
                                    (MediaQuery.of(context).size.height / 1.6),
                            primary: false,
                            children: _shops.map((shop) {
                              return _buildCard(shop['name'], shop['image'],
                                  shop['address'], shop['id']);
                            }).toList(),
                          )),
                ],
              );
            },
          ),
        ),
      ),
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
        padding: EdgeInsets.all(14),
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
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Image.network(
                  imgPath != null ? imgPath : '',
                  fit: BoxFit.cover,
                  height: 100,
                  width: double.infinity,
                ),
              ),
            ),
            SizedBox(height: 7),
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
            SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
