import 'dart:convert';
import 'dart:io';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/Widget/styled_flat_button.dart';
import 'package:eBazaarMerchant/src/utils/validate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'Shopdetails.dart';

class ShopAddPage extends StatefulWidget {
  final userdata;

  ShopAddPage({Key? key, this.userdata}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<ShopAddPage> {
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
    return "Sucess";
  }

  Future<String> getArea(String? locationID, latitude, longitude) async {
    final url = "$api/locations/$locationID/areas";
    var response = await http.get(Uri.parse(url), headers: {
      "X-FOOD-LAT": "$latitude",
      "X-FOOD-LONG": "$longitude",
      "Accept": "application/json"
    });
    var resBody = json.decode(response.body);
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
      Map<String, String?> body = {
        "name": name,

        "fileName": fileName != null ? fileName : '',
      };
      final url = "$api/shop";
      final response = await http.post(Uri.parse(url), body: body, headers: {
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.authorizationHeader: 'Bearer $token'
      });
      var resBody = json.decode(response.body);
      if (response.statusCode == 200) {
        Provider.of<AuthProvider>(context, listen: false)
            .updateShop(resBody['data']);
        _showAlert(context, true, 'Shop  Successfully Created ');
      } else {
        _showAlert(context, false, 'Shop Not Successfully Created');
        throw Exception('Failed to data');
      }
    }
  }

  Future<void> _showAlert(BuildContext context, bool, mes) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Shop Add'),
          content: Text(mes),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                if (bool) {
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
    _status.add({"id": '5', "name": 'Active'});
    _status.add({"id": '10', "name": 'Inactive'});
    _currentStatus.add({"id": '5', "name": 'Yes'});
    _currentStatus.add({"id": '10', "name": 'No'});
  }

  @override
  Widget build(BuildContext context) {
    Future getImage() async {
      var image = await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {
        _image = File(image!.path);
        base64Image = base64Encode(_image!.readAsBytesSync());
        fileName = _image!.path.split("/").last;
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfffada36),
        centerTitle: true,
        title: Text("Shop Add"),
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
                          backgroundColor: Color(0xff476cfb),
                          child: ClipOval(
                            child: new SizedBox(
                              width: 150.0,
                              height: 150.0,
                              child: (_image != null)
                                  ? Image.file(
                                      _image!,
                                      fit: BoxFit.fill,
                                    )
                                  : Image.asset(
                                      'assets/steak.png',
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
              Container(
                child: _locationWidget(),
                margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              ),
              Container(
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
                  'Shop Add',
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
                          'choose a location',
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                        ), // Not necessary for Option 1
                        value: _selectedLocation != null
                            ? _selectedLocation
                            : null,
                        onChanged: (dynamic location) {
                          setState(() {
                            _selectedLocation = location;
                            _areas!.clear();
                            location_id = location;
                            _selectedArea = null;
                            this.getArea(location, '', '');
                          });
                        },
                        items: _locations!.map((location) {
                          return DropdownMenuItem(
                            child: new Text(
                              location['name'] != null ? location['name'] : '',
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                            ),
                            value: location['id'].toString(),
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
                          'choose a Area',
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                        ), // Not necessary for Option 1
                        value: _selectedArea != null ? _selectedArea : null,
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
    final format = DateFormat("HH:mm");
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
              DateTimeField(
                format: format,
                decoration: InputDecoration(
                  labelText: 'Date',
                ),
                readOnly: true,
                onShowPicker: (context, currentValue) async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime:
                        TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                  );
                  return DateTimeField.convert(time);
                },
              ),
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
              //
              DateTimeField(
                format: format,
                decoration: InputDecoration(
                  labelText: 'Date',
                ),
                readOnly: true,
                onShowPicker: (context, currentValue) async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime:
                        TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                  );
                  return DateTimeField.convert(time);
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
                          '',
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                        ), // Not necessary for Option 1
                        value: _selectedCurrentStatus != null
                            ? _selectedCurrentStatus
                            : '5',
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
                'Address *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: false,
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
