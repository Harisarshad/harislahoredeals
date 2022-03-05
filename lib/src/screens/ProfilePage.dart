import 'dart:io';
import 'package:flutter/material.dart';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/Widget/CircularLoadingWidget.dart';
import 'package:eBazaarMerchant/src/screens/ChangePasswordPage.dart';
import 'package:eBazaarMerchant/src/screens/EditProfilePage.dart';
import 'package:eBazaarMerchant/src/shared/colors.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({
    Key? key,
  }) : super(key: key);
  @override
  _ProfilePageState createState() {
    return new _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {
  GlobalKey<RefreshIndicatorState>? refreshKey;

  String api = FoodApi.baseApi;
  Map<String, dynamic> result = {
    "name": '',
    "email": '',
    "balance": '',
    "image": '',
    "username": '',
    "phone": ' ',
    "address": ' '
  };
  Future<String> getmyProfile(token) async {
    final url = "$api/me";

    var response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: "application/json; charset=utf-8"
    });
    var resBody = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        result['name'] = resBody['data']['name'];
        result['email'] = resBody['data']['email'];
        result['username'] = resBody['data']['username'];
        result['phone'] = resBody['data']['phone'];
        result['address'] = resBody['data']['address'];
        result['image'] = resBody['data']['image'];
        result['balance'] = resBody['data']['balance'];
        result['mystatus'] = resBody['data']['mystatus'];
      });
    } else {
      throw Exception('Failed to data');
    }
    return "Success";
  }

  Future<Null> refreshList(String? token) async {
    setState(() {
      getmyProfile(token);
    });
  }

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    getmyProfile(token);
  }

  final double circleRadius = 120.0;

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final currency = Provider.of<AuthProvider>(context, listen: false).currency;
    return Scaffold(
      backgroundColor: primaryColor2,
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: () async {
          await refreshList(token);
        },
        child: result['name'] == ''
            ? CircularLoadingWidget(
                height: 400,
                subtitleText: 'profile not found',
                img: 'assets/shopping.png',
              )
            : ListView(
                children: <Widget>[
                  Container(
                    height: 270,
                    width: 180,
                    color: primaryColor2,
                    child: Stack(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                top: circleRadius / 2.0,
                              ),

                              ///here we create space for the circle avatar to get ut of the box
                              child: Container(
                                height: 180.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.white,
                                ),
                                width: double.infinity,
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15.0, bottom: 15.0),
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: circleRadius / 2,
                                        ),
                                        Text(
                                          result['name'],
                                          style: TextStyle(
                                              fontFamily: 'Google Sans',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22.0),
                                        ),
                                        // SizedBox(
                                        //   height: 10.0,
                                        // ),
                                        // Padding(
                                        //   padding: const EdgeInsets.symmetric(
                                        //       horizontal: 10.0),
                                        //   child: Row(
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment.center,
                                        //     children: <Widget>[
                                        //       Column(
                                        //         children: <Widget>[
                                        //           Text(
                                        //             result['balance'] != ''
                                        //                 ? result['balance']
                                        //                 : '',
                                        //             style: TextStyle(
                                        //               fontFamily: 'Google Sans',
                                        //               fontSize: 20.0,
                                        //               fontWeight:
                                        //                   FontWeight.bold,
                                        //               color: Colors.black87,
                                        //             ),
                                        //           ),
                                        //           Text(
                                        //             'Credit',
                                        //             style: TextStyle(
                                        //               fontFamily: 'Google Sans',
                                        //               fontSize: 15.0,
                                        //               color: Colors.black54,
                                        //             ),
                                        //           ),
                                        //         ],
                                        //       ),
                                        //     ],
                                        //   ),
                                        // )
                                      ],
                                    )),
                              ),
                            ),

                            ///Image Avatar
                            Container(
                              width: circleRadius,
                              height: circleRadius,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Center(
                                  child: Container(
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage: (result['image'] != null
                                              ? NetworkImage(result['image'])
                                              : AssetImage('assets/steak.png'))
                                          as ImageProvider<Object>?,
                                    ),

                                    /// replace your image with the Icon
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InfoCard(
                        text: result['username'],
                        icon: Icons.perm_identity,
                        onPressed: () async {},
                      ),
                      InfoCard(
                        text: result['email'],
                        icon: Icons.mail_outline,
                        onPressed: () async {},
                      ),
                      InfoCard(
                        text: result['phone'],
                        icon: Icons.phone,
                        onPressed: () async {},
                      ),
                      // InfoCard(
                      //   text: result['address'] != '' ? result['address'] : '',
                      //   icon: Icons.location_on,
                      //   onPressed: () {},
                      // ),
                      createPasswordItem(),
                      createEditItem(),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  createPasswordItem() {
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => ChangePasswordPage()));
        },
        child: Card(
          color: primaryColor2,
          elevation: 0.8,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
          child: Row(
            children: <Widget>[
              SizedBox(
                height: 58,
                width: 20,
              ),
              Icon(Icons.lock_outline),
              SizedBox(
                width: 20,
              ),
              Text('Change Password',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  )),
              Spacer(
                flex: 1,
              ),
              Icon(
                Icons.navigate_next,
                color: Colors.black87,
              )
            ],
          ),
        ),
      );
    });
  }

  createEditItem() {
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                        userdata: result,
                      )));
        },
        child: Card(
          color: primaryColor2,
          elevation: 0.8,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
          child: Row(
            children: <Widget>[
              SizedBox(
                height: 58,
                width: 20,
              ),
              Icon(Icons.edit),
              SizedBox(
                width: 20,
              ),
              Text('Edit Profile',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  )),
              Spacer(
                flex: 1,
              ),
              Icon(
                Icons.navigate_next,
                color: Colors.black87,
              )
            ],
          ),
        ),
      );
    });
  }
}

class InfoCard extends StatelessWidget {
  final String? text;
  final IconData icon;
  Function? onPressed;

  InfoCard({required this.text, required this.icon, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed as void Function()?,
      child: Card(
        color: primaryColor2,
        elevation: 0.8,
        margin: const EdgeInsets.only(bottom: 10, left: 25, right: 25),
        child: ListTile(
          leading: Icon(
            icon,
            color: Color(0xff0E0F19),
          ),
          title: Text(
            text!,
            style: TextStyle(
              fontFamily: 'Google Sans',
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
