import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/screens/Shopdetails.dart';
import 'package:intl/intl.dart';
import 'package:eBazaarMerchant/src/Widget/styled_flat_button.dart';
import 'package:eBazaarMerchant/src/utils/validate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ShopEditPage extends StatefulWidget {
  final shop;

  ShopEditPage({Key? key, this.shop}) : super(key: key);

  @override
  _EditShopPageState createState() => _EditShopPageState();
}

class _EditShopPageState extends State<ShopEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final timeFormat = DateFormat("h:mm a");
  DateTime? date;
  TimeOfDay? time;
  String? token;
  String? name;
  String? delivery_charge;
  String? location_id;
  String? area_id;
  String? description;
  String? lat;
  String? long;
  String? opening_time;
  String? closing_time;
  String? address;
  String? status;
  String? current_status;
  String? phone;
  File? _image;
  String? base64Image;
  String? fileName;
  String message = '';
  Map response = new Map();
  String? _selectedLocation;
  String? _selectedArea;
  String? _selectedStatus;
  String? _selectedCurrentStatus;
  List? _locations = [];
  List? _areas = [];
  List _status = [];
  List _currentStatus = [];
  String api = FoodApi.baseApi;
  TextEditingController dateCtl = TextEditingController();
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

  Future<String> getArea(String? locationID, latitude, longitude) async {
    final url = "$api/locations/$locationID/areas";
    var response = await http.get(Uri.parse(url), headers: {
      "X-FOOD-LAT": "$latitude",
      "X-FOOD-LONG": "$longitude",
      "Accept": "application/json"
    });
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      setState(() {
        _areas = resBody['data']['areas'];
      });
    } else {
      throw Exception('Failed to');
    }

    return "Sucess";
  }

  Future<void> submit() async {
    final form = _formKey.currentState!;
    if (form.validate()) {
      Map<String, String?> params = {
        "name": name,
        "location_id": location_id != null
            ? location_id
            : widget.shop['location_id'].toString(),
        "area_id":
            area_id != null ? area_id : widget.shop['area_id'].toString(),
        "delivery_charge": delivery_charge != null ? delivery_charge : '',
        "lat": lat != null ? lat : '',
        "long": long != null ? long : '',
        "opening_time": opening_time != null ? opening_time : '',
        "closing_time": closing_time != null ? closing_time : '',
        "status": status != null ? status : '5',
        "current_status": current_status != null ? current_status : '5',
        "shopaddress": address != null ? address : '',
        "description": description != null ? description : '',
        "image": base64Image != null ? base64Image : '',
        "fileName": fileName != null ? fileName : '',
      };
      print(params);
      final url = "$api/shop/${widget.shop['id'].toString()}";
      final response = await http.put(Uri.parse(url), body: params, headers: {
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.authorizationHeader: 'Bearer $token'
      });
      var resBody = json.decode(response.body);
      print(resBody);
      if (response.statusCode == 200) {
        _showAlert(context, true, 'Successfully Updated Shop ');
      } else {
        _showAlert(context, false, 'Not Successfully Updated Shop');
        throw Exception('Failed to data');
      }
    }
  }

  Future<void> _showAlert(BuildContext context, bool, mes) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Shop Update'),
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
                          builder: (context) => ShopDetailsWidget()));
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

  @override
  void initState() {
    super.initState();
    token = Provider.of<AuthProvider>(context, listen: false).token;
    getLocations('latitude', 'longitude');
    getArea(widget.shop['location_id'].toString(), 'latitude', 'longitude');
    _status.add({"id": '5', "name": 'Active'});
    _status.add({"id": '10', "name": 'Inactive'});
    _currentStatus.add({"id": '5', "name": 'Active'});
    _currentStatus.add({"id": '10', "name": 'Inactive'});
  }

  @override
  Widget build(BuildContext context) {
    Future getImage() async {
      var image = await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {
        _image = image as File?;
        base64Image = base64Encode(_image!.readAsBytesSync());
        fileName = _image!.path.split("/").last;
      });
    }

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
          "Shop Update",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(children: <Widget>[
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 24,
              ),
              Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.yellow,
                          child: ClipOval(
                            child: new SizedBox(
                              width: 150.0,
                              height: 150.0,
                              child: (_image != null)
                                  ? Image.file(
                                      _image!,
                                      fit: BoxFit.fill,
                                    )
                                  : Image.network(
                                      widget.shop['image'],
                                      fit: BoxFit.fill,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 60.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.camera,
                            size: 30.0,
                          ),
                          onPressed: () {
                            getImage();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _locations!.isEmpty
                  ? Container()
                  : Container(
                      child: _locationWidget(),
                      margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                    ),
              _areas!.isEmpty
                  ? Container()
                  : Container(
                      child: _areaWidget(),
                      margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                    ),
              Container(
                child: _nameWidget(),
                margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              ),
              Container(
                child: _priceWidget(),
                margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              ),
              Container(
                child: _LatitudeLongWidget(),
                margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              ),
              Container(
                child: _statusWidget(),
                margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              ),
              Container(
                child: _time(),
                margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              ),
              Container(
                child: _addressWidget(),
                margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              ),
              Container(
                child: _descriptionWidget(),
                margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              ),
              SizedBox(
                height: 24,
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
                height: 30,
              ),
            ],
          ),
        )
      ]),
    );
  }

  var border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(width: 1, color: Colors.grey));

  Widget _locationWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Location *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.all(5.0),
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
                          'choose a location',
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                        ), // Not necessary for Option 1
                        value: _selectedLocation != null
                            ? _selectedLocation
                            : widget.shop['location_id'].toString(),
                        onChanged: (dynamic location) {
                          setState(() {
                            _selectedLocation = location;
                            _areas!.clear();
                            location_id = location;
                            _selectedArea = '';
                            this.getArea(location, '', '');
                          });
                        },
                        items: _locations!.length > 0
                            ? _locations!.map((location) {
                                return DropdownMenuItem(
                                  child: new Text(
                                    location['name'] != null
                                        ? location['name']
                                        : '',
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                  value: location['id'].toString(),
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

  Widget _areaWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Area *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.all(5.0),
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
                          'choose a Area',
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                        ), // Not necessary for Option 1
                        value: _selectedArea != null
                            ? _selectedArea
                            : widget.shop['area_id'].toString(),
                        onChanged: (dynamic area) {
                          setState(() {
                            _selectedArea = area;
                            area_id = area;
                          });
                        },
                        items: _areas!.map((area) {
                          return DropdownMenuItem(
                            child: new Text(
                              area['name'],
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                            ),
                            value: area['id'].toString(),
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

  Widget _nameWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Name *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: false,
                  initialValue:
                      widget.shop['name'] != null ? widget.shop['name'] : '',
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true),
                  validator: (value) {
                    name = value!.trim();
                    return Validate.requiredField(value, 'Name is required.');
                  })
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
                'Delivery Charge *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: false,
                  initialValue:
                      widget.shop['delivery_charge'].toString() != null
                          ? widget.shop['delivery_charge'].toString()
                          : '',
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    delivery_charge = value!.trim();
                    return Validate.NorequiredField();
                  })
            ],
          ),
        )
      ],
    );
  }

  Widget _LatitudeLongWidget() {
    return Row(
      children: <Widget>[
        Expanded(
            child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Longitude',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: false,
                  initialValue:
                      widget.shop['long'] != null ? widget.shop['long'] : '',
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true),
                  validator: (value) {
                    long = value!.trim();
                    return Validate.NorequiredField();
                  })
            ],
          ),
        )),
        SizedBox(width: 15.0),
        Expanded(
            child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Latitude',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: false,
                  initialValue:
                      widget.shop['lat'] != null ? widget.shop['lat'] : '',
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true),
                  validator: (value) {
                    lat = value!.trim();
                    return Validate.NorequiredField();
                  })
            ],
          ),
        ))
      ],
    );
  }

  Widget _time() {
    return Row(
      children: <Widget>[
        Expanded(
            child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Opening Time *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),

              // TimePickerFormField(
              //   initialTime: TimeOfDay.now(),
              //   format: timeFormat,
              //   decoration: InputDecoration(labelText: ''),
              //   onChanged: (t) => setState(() {
              //     if (t != null) {
              //       var tt = t.toString().substring(10, 15);
              //       opening_time = tt.toString();
              //     }
              //   }),
              // ),
            ],
          ),
        )),
        SizedBox(width: 15.0),
        Expanded(
            child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Closing Time *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: dateCtl,
                decoration: InputDecoration(
                  labelText: 'Time',
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? time = DateTime(1990, 1, 1, 12, 0);
                  FocusScope.of(context).requestFocus(new FocusNode());
                  time = await (showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1990, 1, 1, 12, 0),
                    lastDate: DateTime(2100, 1, 1, 12, 0),
                  ) as FutureOr<DateTime>);
                  dateCtl.text = time.toIso8601String();
                },
              ),
            ],
          ),
        ))
      ],
    );
  }

  Widget _statusWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Current Status *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.all(5.0),
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
                          '',
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                        ), // Not necessary for Option 1
                        value: _selectedCurrentStatus != null
                            ? _selectedCurrentStatus
                            : widget.shop['current_status'] == 'Yes'
                                ? '5'
                                : '10',
                        onChanged: (dynamic current) {
                          setState(() {
                            _selectedCurrentStatus = current;
                            current_status = current;
                          });
                        },
                        items: _currentStatus.map((current) {
                          return DropdownMenuItem(
                            child: new Text(
                              current['name'] != null ? current['name'] : '',
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                            ),
                            value: current['id'].toString(),
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

  Widget _addressWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Address',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: false,
                  initialValue: widget.shop['address'] != null
                      ? widget.shop['address']
                      : '',
                  keyboardType: TextInputType.multiline,
                  maxLines: 2,
                  maxLength: 1000,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true),
                  onSaved: (value) {
                    print(value);
                  },
                  validator: (value) {
                    address = value!.trim();
                    return Validate.requiredField(
                        value, 'Address is required.');
                  })
            ],
          ),
        )
      ],
    );
  }

  Widget _descriptionWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: false,
                  initialValue: widget.shop['description'] != null
                      ? widget.shop['description']
                      : '',
                  keyboardType: TextInputType.multiline,
                  maxLines: 2,
                  maxLength: 1000,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true),
                  onSaved: (value) {
                    print(value);
                  },
                  validator: (value) {
                    description = value!.trim();
                    return Validate.NorequiredField();
                  })
            ],
          ),
        )
      ],
    );
  }
}
