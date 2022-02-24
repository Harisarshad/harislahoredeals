import 'dart:ffi';
import 'dart:async';
import 'dart:io';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:device_info/device_info.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/Widget/drawer.dart';
import 'package:eBazaarMerchant/src/Widget/loading.dart';
import 'package:eBazaarMerchant/src/screens/ProfilePage.dart';
import 'package:eBazaarMerchant/src/screens/SearchPage.dart';
import 'package:eBazaarMerchant/src/screens/ShopAddPage.dart';
import 'package:eBazaarMerchant/src/screens/ShopProductList.dart';
import 'package:eBazaarMerchant/src/screens/cartpage.dart';
import 'package:eBazaarMerchant/src/screens/loginPage.dart';
import 'package:eBazaarMerchant/src/screens/orderhistory.dart';
import 'package:eBazaarMerchant/src/screens/shopPage.dart';
import 'package:eBazaarMerchant/src/screens/shopPages.dart';
import 'package:eBazaarMerchant/src/screens/signupPage.dart';
import 'package:eBazaarMerchant/src/shared/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import './src/shared/fryo_icons.dart';
import 'config/api.dart';
import 'package:overlay_support/overlay_support.dart';

import 'models/cartmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final AuthProvider _auth = AuthProvider();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _auth),
      ],
      child: ScopedModel(
          model: CartModel(),
          child: OverlaySupport.global(
              child: MaterialApp(
            title: 'LahoreDealz',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primarySwatch: Colors.green, primaryColor: primaryColor),
            initialRoute: '/',
            routes: {
              '/': (context) => Router(),
              '/home': (BuildContext context) => MyHomePage(),
              '/cart': (BuildContext context) => CartPage(),
              '/register': (BuildContext context) => Register(),
              '/login': (BuildContext context) => LoginPage(),
            },
          ))),
    );
  }
}

class Router extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, user, child) {
        if (user.status == Status.Uninitialized) {
          return Loading();
        } else if (user.status == Status.Unauthenticated) {
          return LoginPage();
        } else if (user.status == Status.Authenticated) {
          print(user.shopID);
          if (user.shopID != null) {
            return MyHomePage();
          } else {
            return MyHomePage();
          }
        } else {
          return LoginPage();
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  String? title;
  int? tabsIndex;
  MyHomePage({Key? key, this.title, this.tabsIndex}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String? _title;
  String? _sitename;
  Status? authenticated;
  String? deviceId;
  String? token;
  String api = FoodApi.baseApi;

  Future<void> setting() async {
    await Provider.of<AuthProvider>(context, listen: false).setting();
  }

  Future<String> _getId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.device; // unique ID on Android
    }
  }

  Future<Void?> deviceTokenUpdate(token) async {
    final url = "$api/device?device_token=$token";
    final response = await http.put(Uri.parse(url), headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });
    print(response);
    return null;
  }

  @override
  void initState() {
    super.initState();
    this.setting();
    token = Provider.of<AuthProvider>(context, listen: false).token;
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      print('getInitialMessage data: ${message!.data}');
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage data: ${message.data}");
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp data: ${message.data}');
      showOverlayNotification((context) {
        return Card(
          semanticContainer: true,
          elevation: 5,
          margin: EdgeInsets.all(10),
          child: SafeArea(
            child: ListTile(
              leading: SizedBox.fromSize(
                size: const Size(40, 40),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: message.data == null
                      ? Image.asset(
                          'assets/images/icon.png',
                          height: 35,
                          width: 35,
                        )
                      : Image.network(
                          message.data['iamge'],
                          fit: BoxFit.contain,
                          height: 35,
                          width: 35,
                        ),
                ),
              ),
              title: Text(message.notification!.title!),
              subtitle: Text(message.notification!.body!),
              trailing: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    OverlaySupportEntry.of(context)!.dismiss();
                  }),
            ),
          ),
        );
      }, duration: Duration(milliseconds: 4000));
    });

    FirebaseMessaging.instance.getToken().then((token) {
      update(token);
    });
  }

  update(String? token) async {
    deviceTokenUpdate(token);
    deviceId = await _getId();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _sitename = Provider.of<AuthProvider>(context, listen: false).sitename;
    final _tabs = [
      //ShopPages(),
      SearchPage(),

      ProductList(),
      ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Color(0xffF4F7FA),
      drawer: AppDrawer(),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        iconTheme: new IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
        title: Text(
            widget.title != null
                ? widget.title!
                : _sitename != null
                    ? _sitename!
                    : '',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
          child: _tabs[
              widget.tabsIndex != null ? widget.tabsIndex! : _selectedIndex]),
      bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.white,
          color: primaryColor,
          buttonBackgroundColor: primaryColor,
          height: 60,
          animationDuration: Duration(
            milliseconds: 200,
          ),
          index: widget.tabsIndex != null ? widget.tabsIndex! : _selectedIndex,
          items: <Widget>[
            Icon(Fryo.shop, size: 30, color: Colors.white),

            Icon(Icons.fastfood, size: 30, color: Colors.white),
            Icon(Fryo.user_1, size: 30, color: Colors.white),
          ],
          onTap: _onItemTapped),
    );
  }

  Void? _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
       if (index == 1) {
        widget.tabsIndex = null;
        widget.title = 'My Product';
      } else if (index == 2) {
        widget.tabsIndex = null;
        widget.title = 'Profile';
      } else {
        widget.tabsIndex = null;
        widget.title = _sitename;
      }
    });
    return null;
  }
}
