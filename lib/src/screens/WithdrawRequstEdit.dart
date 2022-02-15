import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eBazaarMerchant/src/screens/RequestWithdrawList.dart';
import 'package:intl/intl.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/Widget/styled_flat_button.dart';
import 'package:eBazaarMerchant/src/utils/CustomTextStyle.dart';
import 'package:eBazaarMerchant/src/utils/validate.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class WithdrawRequestEdit extends StatefulWidget {
  final WithdrawList? withdrawList;

  WithdrawRequestEdit({Key? key, this.withdrawList}) : super(key: key);

  @override
  _RequestWithdrawEditState createState() => _RequestWithdrawEditState();
}

class _RequestWithdrawEditState extends State<WithdrawRequestEdit> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final dateFormat = DateFormat("yyyy-MM-dd");
  DateTime? date;

  String? dateWithdraw;
  String? amount;

  String message = '';
  Map response = new Map();
  List category = [];
  String api = FoodApi.baseApi;
  String? token;
  String? shopID;
  String? currency;
  TextEditingController dateCtl = TextEditingController();
  Future<void> submit() async {
    final form = _formKey.currentState!;
    if (form.validate()) {
      Map<String, String?> body = {
        "amount": amount != null ? amount : '',
        "date": dateWithdraw != null ? dateWithdraw : '',
      };
      print(body);
      final url = "$api/request-withdraw/${widget.withdrawList!.id}";
      final response = await http.put(Uri.parse(url), body: body, headers: {
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.authorizationHeader: 'Bearer $token'
      });
      var resBody = json.decode(response.body);
      print(resBody);
      if (response.statusCode == 200) {
        _showAlert(context, true, 'Successfully update Request Withdraw ');
      } else {
        _showAlert(context, false, 'Not Successfully update Request Withdraw');
        throw Exception('Failed to data');
      }
    }
  }

  Future<void> _showAlert(BuildContext context, bool, mes) {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Request Withdraw update'),
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
                          builder: (context) => RequestWithdrawList()));
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
    shopID = Provider.of<AuthProvider>(context, listen: false).shopID;
    currency = Provider.of<AuthProvider>(context, listen: false).currency;
    token = Provider.of<AuthProvider>(context, listen: false).token;
  }

  @override
  Widget build(BuildContext context) {
    SystemChannels.textInput.invokeMethod('TextInput.hide');

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
          "Request Withdraw Edit",
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
              Icons.payment,
              color: Colors.black54,
            ),
            title: Text(
              'Request Withdraw',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CustomTextStyle.textFormFieldMedium.copyWith(
                  color: Colors.black54,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Edit your Request withdraw'),
          ),
        ),
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Container(
                child: amountWidget(),
                margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              ),
              Container(
                child: DateWidget(),
                margin: EdgeInsets.only(left: 12, right: 12, top: 12),
              ),
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

  Widget amountWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Amount *',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        SizedBox(
          height: 15,
        ),
        TextFormField(
            obscureText: false,
            initialValue: widget.withdrawList!.amount != null
                ? widget.withdrawList!.amount.toString()
                : '',
            decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),
            keyboardType: TextInputType.number,
            validator: (value) {
              amount = value!.trim();
              return Validate.requiredField(value, 'Amount is required.');
            })
      ],
    );
  }

  Widget DateWidget() {
    DateTime tempDate =
        new DateFormat("yyyy-MM-dd").parse(widget.withdrawList!.dateDB!);
    dateWithdraw = tempDate.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Date *',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        SizedBox(
          height: 15,
        ),
        TextFormField(
          controller: dateCtl,
          decoration: InputDecoration(
            labelText: 'Date',
          ),
          readOnly: true,
          onTap: () async {
            DateTime? date = DateTime(1990);
            FocusScope.of(context).requestFocus(new FocusNode());
            date = await (showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1990),
              lastDate: DateTime(2100),
            ) as FutureOr<DateTime>);
            dateCtl.text = date.toIso8601String();
          },
        ),
      ],
    );
  }
}
