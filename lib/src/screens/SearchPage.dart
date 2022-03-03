import 'package:eBazaarMerchant/src/screens/ProductPage.dart';
import 'package:eBazaarMerchant/src/screens/shopPages.dart';
import 'package:eBazaarMerchant/src/shared/Product.dart';
import 'package:eBazaarMerchant/src/shared/colors.dart';
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
//import 'package:geolocator/geolocator.dart';
import 'package:search_choices/search_choices.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:eBazaarMerchant/src/Widget/styled_flat_button.dart';



class Animal {
  final int? id;
  final String? name;

  Animal({
    this.id,
    this.name,
  });
}
class SearchPage extends StatefulWidget {
  @override
  _ShopPageState createState() {
    return new _ShopPageState();
  }
}

class _ShopPageState extends State<SearchPage> {

  TextEditingController editingController = TextEditingController();
  GlobalKey<RefreshIndicatorState>? refreshKey;
  //late Position _currentPosition;
  TextEditingController nameController = TextEditingController();
  String UserName = '';

  // Future<void> _checkPermission() async {
  //   // verify permissions
  //   LocationPermission permission = await Geolocator.requestPermission();
  //   if (permission == LocationPermission.denied ||
  //       permission == LocationPermission.deniedForever) {
  //     await Geolocator.openAppSettings();
  //     await Geolocator.openLocationSettings();
  //   }
  // }

  String location = '1';
  String api = FoodApi.baseApi;
  String? _selectedLocation = '1';
  String? _selectedArea = '1';
  List _selectedAnimals4 = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Animal> _selectedAnimals = [];
  List _locations = [];
  List _areas = [];
  List _shops = [];
  String? _selectedProductType = 'Single';
  String? _selectedPriceType = 'Single';

  String? selectedValueSingleDialog;
  bool haris = true;
  List<Product> _products = [];
  List<DropdownMenuItem> itemss = [];
  List<int> selectedItemsMultiDialog = [];
  bool asTabs = false;


  String? locationone;
  String? locationonetype;
  String? areamin;
  String? areamax;
  String area_type = '225';
  String? pricemin;
  String? pricemax;
  String? properttype;
  String? properttypeID ='5';

  final textController_areamin = TextEditingController();
  final textController_areamax = TextEditingController();
  final textController_pricemin = TextEditingController();
  final textController_pricemax = TextEditingController();


  List<DropdownMenuItem> itemsss = [];
  List<DropdownMenuItem> editableItems = [];
  List<DropdownMenuItem> futureItems = [];
  final _multiSelectKey = GlobalKey<FormFieldState>();

  final items = List<String>.generate(10000, (i) => "Item $i");
  static List<Animal> _animals = [
    Animal(id: 1, name: "Residential"),
    Animal(id: 2, name: "Commercial"),

  ];
  final _items = _animals
      .map((animal) => MultiSelectItem<Animal>(animal, animal.name!))
      .toList();

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
        print(original);
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

  Future<String> getShops(String areaID, String slug, String order) async {
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
              user_id: element['user_id'].toString(),

              socname: element['socname'],
              phasename: element['phasename'],
              blockname: element['blockname'],
              id: element['id'],
              productItemID: element['id'],
              imgUrl: element['image'],
              quantity: element['p_society'],
              plot_no: element['plot_no'].toString(),
              size: element['size'].toString(),
              size_word: element['size_word'],
              pricewords: element['unit_words'].toString(),
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
      // this.getLocations(
      //     _currentPosition != null ? _currentPosition.latitude : '',
      //     _currentPosition != null ? _currentPosition.longitude : '');
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
    _selectedProductType =
    'Marla';
    _selectedPriceType =
    'PKR';

    super.initState();
   // _checkPermission();
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
    haris = true;
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

  // _getCurrentLocation() {
  //   Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
  //       .then((Position position) {
  //     setState(() {
  //       _selectedArea = null;
  //       _selectedLocation = null;
  //       _currentPosition = position;
  //       this.getLocations(
  //           _currentPosition != null ? _currentPosition.latitude : '',
  //           _currentPosition != null ? _currentPosition.longitude : '');
  //
  //       this.getShops(
  //           _selectedArea!,
  //           '',
  //           ''
  //       );
  //     });
  //   }).catchError((e) {
  //     print(e);
  //     this.getLocations(
  //         _currentPosition != null ? _currentPosition.latitude : '',
  //         _currentPosition != null ? _currentPosition.longitude : '');
  //
  //     this.getShops(
  //         _selectedArea!,
  //         '',
  //         ''
  //     );
  //     _checkPermission();
  //   });
  // }

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
                  SizedBox(height: 20.0),
                  Column(

                    children: <Widget>[
                      //SizedBox(width: 900),
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,

                        child:


                        //SizedBox(height: 40),
                        //################################################################################################
                        // Rounded blue MultiSelectDialogField
                        //################################################################################################
                        SearchChoices.multiple(

                          ///decoration of list
                          // displayItem: (item, selected) {
                          //   return (Row(children: [
                          //     selected
                          //         ? Icon(
                          //       Icons.radio_button_checked,
                          //       color: Colors.grey,
                          //     )
                          //         : Icon(
                          //       Icons.radio_button_unchecked,
                          //       color: Colors.grey,
                          //     ),
                          //     SizedBox(width: 7),
                          //     Container(
                          //
                          //       child: item,
                          //     ),
                          //   ]));},
                          items: _areas.map((area) {
                            return DropdownMenuItem(
                              child: new Text(
                                area['name'],
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                // softWrap: false,
                              ),
                              value: area['name'].toString(),
                            );
                          }).toList(),
                          selectedItems: selectedItemsMultiDialog,
                          hint: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text("Select location"),
                          ),
                          searchHint: "Select location",
                          onChanged: (area) {
                            setState(() {
                              selectedItemsMultiDialog = area;
                              //selectedItemsMultiDialog = _areas[area]['id'];
                              print(selectedItemsMultiDialog);


                              // print(area);
                              //  print(_areas[area]['id']);
                            });
                          },

                          validator: (selectedItemsForValidator) {
                            if (selectedItemsForValidator.length > 1) {
                              return ("Max 1 Area Allowed");
                            }
                            return (null);
                          },

                          clearIcon: Icon(Icons.cancel),
                          icon: Icon(Icons.arrow_drop_down_circle),
                          iconDisabledColor: Colors.brown,
                          iconEnabledColor: Colors.indigo,
                          closeButton: (selectedItems) {
                            selectedItemsMultiDialog = selectedItems;
                            print(selectedItemsMultiDialog);

                            print(selectedItems
                            );
                            print(selectedItems.isNotEmpty
                                ? selectedItems
                                : "kuch b nai list");
                            selectedItems.isNotEmpty
                                ? locationone =
                                _areas[selectedItems[0]]['order'].toString()
                                : "1";
                            selectedItems.isNotEmpty
                                ? locationonetype =
                                _areas[selectedItems[0]]['slug'].toString()
                                : "society";

                            print(selectedItems.length > 1
                                ? _areas[selectedItems[1]]['id'].toString()
                                : "kuch b nai index == 1");
                            print(selectedItems.length > 2
                                ? _areas[selectedItems[2]]['id'].toString()
                                : "kuch b nai index == 2");
                            print(selectedItems.length > 3
                                ? _areas[selectedItems[3]]['id'].toString()
                                : "kuch b nai index == 3");
                            final index1 = _areas.indexWhere((
                                element) => element["id"] == "1");
                            if (index1 != -1) {
                              // print("Index $index1: ${_areas[index1]}");
                            }
                            return (selectedItems.isNotEmpty
                                ? "Select ${selectedItems.length == 1 ? '"' +
                                _areas[selectedItems.first]['name'].toString() +
                                '"' : '(' + selectedItems.length.toString() +
                                ')'}"
                                : "Cancel"

                            );
                            // return (selectedItems.isNotEmpty
                            //     ? "Save ${selectedItems.length == 1 ? '"' +
                            //     _areas[selectedItems.first]['id'].toString() +
                            //     '"' : '(' + selectedItems.length.toString() +
                            //     ')'}"
                            //     : "Save without selection"
                            //
                            // );
                          },
                          isExpanded: true,
                        ),)

                      //     MultiSelectDialogField(
                      //       items:_areas.map((animal) {
                      //   return MultiSelectItem<Animal>(
                      //       animal, animal.name!
                      //     // child: new Text(
                      //     //   area['name'],
                      //     //   overflow: TextOverflow.fade,
                      //     //   maxLines: 1,
                      //     //   softWrap: false,
                      //     // ),
                      //   //  value: area['id'].toString(),
                      //   );
                      // }).toList(),
                      //       // items: _areas
                      //       //     .map((animal) => MultiSelectItem<Animal>(animal, animal.name!))
                      //       //     .toList(),
                      //       listType: MultiSelectListType.CHIP,
                      //
                      //       onConfirm: (e) {
                      //         //_selectedAnimals = values;
                      //         //_selectedAnimals = values;
                      //         print(e);
                      //       },
                      //     ),
                      // Padding(
                      //   padding:
                      //       EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                      //   child: Container(
                      //     height: haris ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height * .12 ,
                      //     width: MediaQuery.of(context).size.width * .80,
                      //     padding: EdgeInsets.all(3.0),
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.only(
                      //         bottomRight: Radius.circular(10.0),
                      //         bottomLeft: Radius.circular(10.0),
                      //         topLeft: Radius.circular(10.0),
                      //         topRight: Radius.circular(10.0),
                      //       ),
                      //     ),
                      //     child: Column(
                      //       children: <Widget>[
                      //
                      //         Container(
                      //           margin: EdgeInsets.all(10),
                      //           child: Column(
                      //             mainAxisAlignment: MainAxisAlignment.start,
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //
                      //               TextFormField(
                      //                 controller: txtQuery,
                      //                 onChanged: search,
                      //                 decoration: InputDecoration(
                      //                   hintText: "Search",
                      //                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                      //                   focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                      //                   prefixIcon: Icon(Icons.search),
                      //                   suffixIcon: IconButton(
                      //                     icon: Icon(Icons.clear),
                      //                     onPressed: () {
                      //                       txtQuery.text = '';
                      //                       search(txtQuery.text);
                      //                       //haris =true;
                      //                     },
                      //                   ),
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //          haris ? _listView(persons) : Container()
                      //         // SvgPicture.asset(
                      //         //   "assets/icons/maps-and-flags.svg",
                      //         // // ),
                      //         // Padding(
                      //         //   padding: const EdgeInsets.all(12.0),
                      //         //   child: TextField(
                      //         //     //controller: _textController,
                      //         //     decoration: InputDecoration(
                      //         //       hintText: 'Search Here...',
                      //         //     ),
                      //         //     onChanged: onItemChanged,
                      //         //   ),
                      //         // ),
                      //         // Expanded(
                      //         //   child:  ListView.builder(
                      //         //     itemCount: _areas.length,
                      //         //     itemBuilder: (context, index) => Card(
                      //         //       key: ValueKey(_areas[index]["id"]),
                      //         //       color: Colors.amberAccent,
                      //         //       elevation: 4,
                      //         //       margin: const EdgeInsets.symmetric(vertical: 10),
                      //         //       child:
                      //         //
                      //         //       ListTile(
                      //         //         leading: Text(
                      //         //           _areas[index]["id"].toString(),
                      //         //           style: const TextStyle(fontSize: 24),
                      //         //         ),
                      //         //           onTap: ()=> print(_areas[index]['name']),
                      //         //         title: Text(_areas[index]['name']),
                      //         //         subtitle: Text(
                      //         //             '${_areas[index]["slug"].toString()} '),
                      //         //       ),
                      //         //     ),
                      //         //   )
                      //         // ),
                      //         // SizedBox(width:10),
                      //         // Expanded(child:
                      //         //
                      //         //
                      //         // TextFormField(
                      //         //     readOnly: true,
                      //         //     onTap: () {
                      //         //       showDialog(
                      //         //           context: context,
                      //         //           builder: (BuildContext context) {
                      //         //             return AlertDialog(
                      //         //               title: Text('Country List'),
                      //         //               content: setupAlertDialoadContainer(),
                      //         //             );
                      //         //           });
                      //         //     },
                      //         //   controller: editingController,
                      //         //   decoration: InputDecoration(
                      //         //       labelText: "Search",
                      //         //       hintText: "Search",
                      //         //       prefixIcon: Icon(Icons.search),
                      //         //       border: OutlineInputBorder(
                      //         //           borderRadius: BorderRadius.all(Radius.circular(25.0)))),
                      //         // ),
                      //         //
                      //         //
                      //         // ),
                      //
                      //         // Expanded(
                      //         //   child: DropdownButton(
                      //         //     isExpanded: true,
                      //         //     // underline: SizedBox(
                      //         //     //   width: 80,
                      //         //     // ),
                      //         //     icon: SvgPicture.asset(
                      //         //         "assets/icons/dropdown.svg"),
                      //         //     hint: Text(
                      //         //       'choose a Area',
                      //         //       overflow: TextOverflow.fade,
                      //         //       maxLines: 1,
                      //         //       softWrap: false,
                      //         //     ),
                      //         //     // Not necessary for Option 1
                      //         //     value: _selectedArea != null
                      //         //         ? _selectedArea
                      //         //         : null,
                      //         //     onChanged: (area) {
                      //         //       setState(() {
                      //         //         //selectedValueSingleDialog = area as String?;
                      //         //         _selectedArea = area as String?;
                      //         //         _shops.clear();
                      //         //         getShops(
                      //         //             area!,
                      //         //             _currentPosition != null
                      //         //                 ? _currentPosition.latitude
                      //         //                 : '',
                      //         //             _currentPosition != null
                      //         //                 ? _currentPosition.longitude
                      //         //                 : '');
                      //         //       });
                      //         //     },
                      //         //     items: _areas.map((area) {
                      //         //       return DropdownMenuItem(
                      //         //         child: new Text(
                      //         //           area['name'],
                      //         //           overflow: TextOverflow.fade,
                      //         //           maxLines: 1,
                      //         //           softWrap: false,
                      //         //         ),
                      //         //         value: area['id'].toString(),
                      //         //       );
                      //         //     }).toList(),
                      //         //   ),
                      //         // ),
                      //       ],
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    children: <Widget>[
                      SizedBox(height: 10.0),
                      SizedBox(width: 10.0),
                      Expanded(


                          child: Icon(Icons.square_foot)
                      )
                      , Expanded(
                          flex: 5,

                          child:
                          Text('Area Range')
                      ),
                      SizedBox(width: 10.0),


                      Expanded(
                        flex: 2,
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
                          ),
                          // Not necessary for Option 1
                          value: _selectedProductType != null
                              ? _selectedProductType
                              : 'Marla',
                          onChanged: (dynamic value) {
                            setState(() {
                              if ('Marla' == value) {
                                area_type = '225';
                              } else {
                                area_type = '4500';
                              }
                              _selectedProductType = value;
                            });
                          },
                          items:
                          <String>['Marla', 'Kanal'].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: 10.0),

                      //  OtherWidget(),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 10.0),

                      Expanded(
                        flex: 5,
                        child:
                        TextField(
                          keyboardType: TextInputType.number,
                          // onChanged: (text) {
                          //   areamin = text;
                          // },
                          controller: textController_areamin,
                          decoration: InputDecoration(

                            labelText: "Minimum Area",
                            labelStyle: TextStyle(
                              //color: Colors.white,
                                fontSize: 13
                            ),

                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2.0)),
                            enabledBorder: myinputborder(),
                            //enabled border
                            focusedBorder: myfocusborder(),
                          ),
                        ),),
                      SizedBox(width: 10.0),
                      Expanded(


                          child: Container(
                              width: 23,

                              child: new
                              Text("To", style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 20.0)))),

                      SizedBox(width: 10.0),

                      Expanded(flex: 5,
                        child: TextField(

                          // onChanged: (text) {
                          //   areamax = text;
                          // },
                          controller: textController_areamax,
                          keyboardType: TextInputType.number,

                          decoration: InputDecoration(
                            labelText: "Maximum Area",
                            labelStyle: TextStyle(
                              // color: Colors.white,
                                fontSize: 13
                            ),

                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2.0)),
                            enabledBorder: myinputborder(),
                            //enabled border
                            focusedBorder: myfocusborder(),
                          ),
                        ),),
                      SizedBox(width: 10.0),

                      //  OtherWidget(),
                    ],
                  ),
                  SizedBox(height: 10.0),

                  Row(
                    children: <Widget>[
                      SizedBox(width: 10.0),
                      Expanded(


                          child: Icon(Icons.local_offer)
                      )
                      , Expanded(
                          flex: 5,

                          child:
                          Text('Price Range')
                      ),
                      SizedBox(width: 10.0),


                      Expanded(
                        flex: 2,
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
                          ),
                          // Not necessary for Option 1
                          value: _selectedPriceType != null
                              ? _selectedPriceType
                              : 'PKR',
                          onChanged: (dynamic value) {
                            setState(() {
                              if ('PKR' == value) {
                                //product_type = '1';

                              } else {
                                //  product_type = '1';
                              }
                              _selectedPriceType = value;
                            });
                          },
                          items:
                          <String>['PKR',].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: 5.0),

                      //  OtherWidget(),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 10.0),

                      Expanded(
                        flex: 5,
                        child:
                        TextField(
                          // controller: textController_pricemin,
                          // onChanged: (text) {
                          //   pricemin = text;
                          // },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Minimum Price",
                            labelStyle: TextStyle(
                              //color: Colors.white,
                                fontSize: 13
                            ),

                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2.0)),
                            enabledBorder: myinputborder(),
                            //enabled border
                            focusedBorder: myfocusborder(),
                          ),
                        ),),
                      SizedBox(width: 10.0),
                      Expanded(


                          child: Container(
                              width: 23,

                              child: new
                              Text("To", style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 20.0)))),

                      SizedBox(width: 10.0),

                      Expanded(flex: 5,
                        child: TextField(
                          controller: textController_pricemax,
                          // onChanged: (text) {
                          //   pricemax = text;
                          // },
                          keyboardType: TextInputType.number,

                          decoration: InputDecoration(
                            labelText: "Maximum Price",
                            labelStyle: TextStyle(
                              // color: Colors.white,
                                fontSize: 13
                            ),

                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2.0)),
                            enabledBorder: myinputborder(),
                            //enabled border
                            focusedBorder: myfocusborder(),
                          ),
                        ),),
                      SizedBox(width: 10.0),

                      //  OtherWidget(),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Container(


                    margin: EdgeInsets.only(left: 40, right: 40),
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
                      ),
                      // Not necessary for Option 1
                      value: properttype != null
                          ? properttype
                          : 'Residential',
                      onChanged: (dynamic value) {
                        setState(() {
                          if ('Residential' == value) {
                            properttypeID = '1';
                          } else {
                            //  product_type = '1';
                            properttypeID = '2';
                          }
                          properttype = value;
                        });
                      },
                      items:
                      <String>['Commercial', 'Residential'].map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                    ),),

                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    width: double.infinity / 2,
                    margin: EdgeInsets.only(left: 40, right: 40),
                    child:

                    StyledFlatButton(
                      'Search',
                      onPressed: submit,
                    ),
                  ),


                  // _shops.isEmpty
                  //     ? CircularLoadingWidget(
                  //         height: 200,
                  //         subtitleText: 'No Shops Found ',
                  //         img: 'assets/shopping3.png',
                  //       )
                  //     : ListView.separated(
                  //   padding: EdgeInsets.symmetric(vertical: 10),
                  //   scrollDirection: Axis.vertical,
                  //   shrinkWrap: true,
                  //   primary: false,
                  //   itemCount: _products.length,
                  //   separatorBuilder: (context, index) {
                  //     return SizedBox(height: 10);
                  //   },
                  //   itemBuilder: (context, index) {
                  //
                  //      return Container(
                  //         height: 40,
                  //         color: Colors.white,
                  //         child: _buildFoodCard(
                  //           context,
                  //
                  //           _products[index],
                  //               () {
                  //             Navigator.push(
                  //               context,
                  //               MaterialPageRoute(builder: (context) {
                  //                 return new ProductPage(
                  //                     currency: "Rs",
                  //                     productData: _products[index]);
                  //               }),
                  //             );
                  //           },
                  //         ),
                  //
                  //     );
                  //   },
                  // ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> submit() async {
    if (locationonetype == null) {
      showAlertDialog(context,);

    }
    else {
      areamin =
      textController_areamin.text.isNotEmpty ? textController_areamin.text : '1';
      areamax = textController_areamax.text.isNotEmpty
          ? textController_areamax.text
          : '9999999999';
      pricemin = textController_pricemin.text.isNotEmpty
          ? textController_pricemin.text
          : '1';
      pricemax = textController_pricemax.text.isNotEmpty
          ? textController_pricemax.text
          : '9999999999';


      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              ShopPages(locationone: locationone,
                locationonetype: locationonetype,
                areamin: areamin,
                areamax: areamax,
                area_type: area_type,
                pricemin: pricemin,
                pricemax: pricemax,
                properttype: properttypeID,

              )));

    }

  }

  Widget _buildFoodCard(context, Product food, onTapped) {
    return InkWell(
      splashColor: Theme
          .of(context)
          .colorScheme
          .secondary,
      focusColor: Theme
          .of(context)
          .colorScheme
          .secondary,
      highlightColor: Theme
          .of(context)
          .primaryColor,
      onTap: onTapped,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
                color: Theme
                    .of(context)
                    .focusColor
                    .withOpacity(0.1),
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
                          food.phasename.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyText1,
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
                          food.blockname.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyText1,
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
                          food.plot_no!.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyText1,
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
                          food.size!.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyText1,
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
                                text: food.price!.toString(),

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

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: MediaQuery
                .of(context)
                .size
                .width / 1.3,
            height: MediaQuery
                .of(context)
                .size
                .height / 7.5,
            decoration:  BoxDecoration(
              shape: BoxShape.rectangle,
              color: const Color(0xFFFFFF),
              borderRadius:  BorderRadius.all(new Radius.circular(99.0)),
            ),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Please Select Location",
                  maxLines: 11,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontFamily: 'helvetica_neue_light',
                  ),
                  textAlign: TextAlign.center,
                ),
                MaterialButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height / 12,
                    padding: EdgeInsets.all(15.0),
                    child: Material(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(25.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontFamily: 'helvetica_neue_light',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
OutlineInputBorder myinputborder(){ //return type is OutlineInputBorder
  return OutlineInputBorder( //Outline border type for TextFeild
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(
        color:Colors.redAccent,
        width: 1,
      )
  );
}

OutlineInputBorder myfocusborder(){
  return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(
        color:Colors.greenAccent,
        width: 1,
      )
  );
}