import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:eBazaarMerchant/src/screens/ProductRequestList.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/Widget/styled_flat_button.dart';
import 'package:eBazaarMerchant/src/utils/CustomTextStyle.dart';
import 'package:eBazaarMerchant/src/utils/validate.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProductRequstPost extends StatefulWidget {
  ProductRequstPost({
    Key? key,
  }) : super(key: key);

  @override
  _ProductRequstPostState createState() => _ProductRequstPostState();
}

class _ProductRequstPostState extends State<ProductRequstPost> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List? _myCategory;

  String? name;
  String? productID;
  String? price;
  String? description;
  File? _image;
  String? base64Image;
  String? fileName;

  String message = '';
  String? _selectedProduct;
  Map response = new Map();
  List? category = [];
  String api = FoodApi.baseApi;
  String? token;
  String? shopID;
  String? currency;

  Future<String> getProducts() async {
    final url = "$api/product-category";
    var response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });
    var resBody = json.decode(response.body);
    print(resBody);
    if (response.statusCode == 200) {
      setState(() {
        category = resBody['data'];
      });
    } else {
      throw Exception('Failed to data');
    }
    return "Success";
  }

  Future<void> submit() async {
    final form = _formKey.currentState!;
    if (form.validate()) {
      Map<String, String?> body = {
        "name": name != null ? name : '',
        "categories":
            (_myCategory != null ? _myCategory.toString() : []) as String?,
        "mrp": price != null ? price : '',
        "description": description != null ? description : '',
        "image": base64Image != null ? base64Image : '',
        "fileName": fileName != null ? fileName : '',
      };
      print(body);
      final url = "$api/request-product";
      final response = await http.post(Uri.parse(url), body: body, headers: {
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.authorizationHeader: 'Bearer $token'
      });
      var resBody = json.decode(response.body);
      if (response.statusCode == 200) {
        _showAlert(context, true, 'Successfully Create Product Request ');
      } else {
        _showAlert(context, false, 'Not Successfully Create Product Request');
        throw Exception('Failed to data');
      }
    }
  }

  Future<void> _showAlert(BuildContext context, bool, mes) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Product Request Add'),
          content: Text(mes),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                if (bool) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductRequestList()));
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
    _myCategory = [];
    shopID = Provider.of<AuthProvider>(context, listen: false).shopID;
    currency = Provider.of<AuthProvider>(context, listen: false).currency;
    token = Provider.of<AuthProvider>(context, listen: false).token;
    getProducts();
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
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(
          "Product Request",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(children: <Widget>[
        SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 0),
            leading: Icon(
              Icons.fastfood,
              color: Colors.black54,
            ),
            title: Text(
              'Product Request',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CustomTextStyle.textFormFieldMedium.copyWith(
                  color: Colors.black54,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Post your Request product'),
          ),
        ),
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Container(
                child: NameWidget(),
                margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              ),
              Container(
                child: _CategoryWidget(),
                margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              ),
              Column(children: <Widget>[
                Container(
                  child: _priceWidget(),
                  margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                ),
                Container(
                  child: _descriptionWidget(),
                  margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                ),
                Stack(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: CircleAvatar(
                            radius: 75,
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
                                    : Image.network(
                                        '',
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
                SizedBox(
                  height: 20,
                ),
              ])
            ],
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(left: 48, right: 48),
          child: StyledFlatButton(
            'Product Add',
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

  Widget NameWidget() {
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
              name = value!.trim();
              return Validate.requiredField(value, 'Name is required.');
            })
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
                'MRP *',
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
                    return Validate.requiredField(value, 'MRP is required.');
                  })
            ],
          ),
        )
      ],
    );
  }

  Widget _CategoryWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Categories',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 15,
              ),
              MultiSelectFormField(
                autovalidate: false,
                title: Text('Categories'),
                dataSource: category != null ? category : [],
                textField: 'name',
                valueField: 'id',
                okButtonLabel: 'OK',
                cancelButtonLabel: 'CANCEL',
                required: false,
                hintWidget: Text('Please choose one or more'),
                initialValue: _myCategory,
                onSaved: (value) {
                  if (value == null) return;
                  setState(() {
                    _myCategory = value;
                  });
                },
              ),
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
