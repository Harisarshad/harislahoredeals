import 'package:flutter/material.dart';
import 'package:eBazaarMerchant/main.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:provider/provider.dart';
import 'loginPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eBazaarMerchant/src/utils/validate.dart';
import 'package:eBazaarMerchant/src/Widget/notification_text.dart';
import 'package:eBazaarMerchant/src/Widget/styled_flat_button.dart';

class Register extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Register'),
        ),
        body: SafeArea(
          child: Center(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                child: SignUpPage(),
              ),
            ),
          ),
        ));
  }
}

class SignUpPage extends StatefulWidget {
  SignUpPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? name;
  String? email;
  String? phone;
  String? password;
  String? passwordConfirm;
  String? message = '';
  Map response = new Map();

  Future<void> submit() async {
    final form = _formKey.currentState!;
    if (form.validate()) {
      response = await Provider.of<AuthProvider>(context, listen: false)
          .register(name, email, phone, password, passwordConfirm);
      if (response['success']) {
        Navigator.pop(context);
      } else {
        message = response['message'];
        _showAlert(context, false);
      }
    }
  }

  Future<void> _showAlert(BuildContext context, bool) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Signup'),
          content: Consumer<AuthProvider>(
            builder: (context, provider, child) =>
                provider.notification ??
                NotificationText('Registration Not successful.'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                if (bool) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyHomePage()));
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
  Widget build(BuildContext context) {
    final _sitename = Provider.of<AuthProvider>(context).sitename;
    void _showToast(BuildContext context) {
      final scaffold = Scaffold.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: const Text('Added to cart'),
          action: SnackBarAction(
              label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
        ),
      );
    }

    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
                child: Container(
      height: MediaQuery.of(context).size.height / 0.9,
      child: Stack(
        children: <Widget>[
          Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: SizedBox(),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        _title(_sitename),
                        SizedBox(height: 10.0),
                        _nameWidget(),
                        _emailWidget(),
                        _phoneWidget(),
                        _passwordWidget(),
                        _passwordConfirmWidget(),
                        SizedBox(height: 10.0),
                        StyledFlatButton(
                          'Register',
                          onPressed: submit,
                        ),
                        _divider(),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: _loginAccountLabel(),
                        ),
                        Expanded(
                          flex: 5,
                          child: SizedBox(),
                        ),
                      ],
                    ),
                  )
                ],
              )),
          Positioned(top: 20, left: 0, child: _backButton()),
        ],
      ),
    ))));
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _loginAccountLabel() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Already have an account ?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Text(
              'Login',
              style: TextStyle(
                  color: Color(0xfffada36),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Widget _title(_sitename) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: _sitename != null ? _sitename : '',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headline4,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Color(0xffe46b10),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
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
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontSize: 18,
                    height: 0.6,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54)),
                    hintText: "Enter name",
                  ),
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

  Widget _emailWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Email *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: false,
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontSize: 18,
                    height: 0.6,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54)),
                    hintText: "Enter email",
                  ),
                  validator: (value) {
                    email = value!.trim();
                    return Validate.requiredField(value, 'Email is required.');
                  })
            ],
          ),
        )
      ],
    );
  }

  Widget _phoneWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Phone *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: false,
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 18,
                    height: 0.6,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54)),
                    hintText: "Enter phone",
                  ),
                  validator: (value) {
                    phone = value!.trim();
                    return Validate.requiredField(value, 'Phone is required.');
                  })
            ],
          ),
        )
      ],
    );
  }

  Widget _passwordWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Password *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: true,
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontSize: 18,
                    height: 0.6,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54)),
                    hintText: "Enter password",
                  ),
                  validator: (value) {
                    password = value!.trim();
                    return Validate.requiredField(
                        value, 'Password is required.');
                  })
            ],
          ),
        )
      ],
    );
  }

  Widget _passwordConfirmWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Password Confirm *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                  obscureText: true,
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontSize: 18,
                    height: 0.6,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54)),
                    hintText: "Enter confirm password",
                  ),
                  validator: (value) {
                    passwordConfirm = value!.trim();
                    return Validate.requiredField(
                        value, 'Password confirm is required.');
                  })
            ],
          ),
        )
      ],
    );
  }
}
