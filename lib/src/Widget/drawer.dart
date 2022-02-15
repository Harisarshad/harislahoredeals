import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/screens/ProductRequestList.dart';
import 'package:eBazaarMerchant/src/screens/RequestWithdrawList.dart';
import 'package:eBazaarMerchant/src/screens/Shopdetails.dart';
import 'package:eBazaarMerchant/src/screens/Transaction.dart';
import 'package:eBazaarMerchant/src/screens/salesReport.dart';
import 'package:eBazaarMerchant/src/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final shop = Provider.of<AuthProvider>(context, listen: false).shopName;
    final opening =
        Provider.of<AuthProvider>(context, listen: false).openingTime;
    final closing =
        Provider.of<AuthProvider>(context, listen: false).closingTime;
    final charge =
        Provider.of<AuthProvider>(context, listen: false).deliveryCharge;
    final address =
        Provider.of<AuthProvider>(context, listen: false).shopAddress;
    final shopImg = Provider.of<AuthProvider>(context, listen: false).shopImg;
    final currency = Provider.of<AuthProvider>(context, listen: false).currency;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
              height: 220.0,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 30.0),
                    Container(
                        margin: EdgeInsets.all(10.0),
                        width: 100.0,
                        height: 100.0,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: (shopImg != null
                                        ? NetworkImage(shopImg)
                                        : ExactAssetImage(
                                            'assets/images/profile.png'))
                                    as ImageProvider<Object>))),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text(
                        shop != null ? shop.toString() : " ",
                        overflow: TextOverflow.fade,
                        maxLines: 2,
                        softWrap: true,
                        style: TextStyle(
                          color: Color(0xffffffff),
                          fontFamily: 'Montserrat',
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            size: 17.0,
                            color: Color(0xffffffff),
                          ),
                          Text(
                            address != null ? address.toString() : " ",
                            style: TextStyle(
                                color: Color(0xffffffff),
                                fontFamily: 'Varela',
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0),
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                    )
                  ]),
              decoration: BoxDecoration(color: primaryColor)),
          new ListTile(
            leading: Icon(Icons.home),
            title: new Text("Home"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MyHomePage(title: null, tabsIndex: 0),
              ));
            },
          ),
          new ListTile(
            leading: Icon(Icons.shopping_basket),
            title: new Text("My Order"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyHomePage(
                            title: 'Order',
                            tabsIndex: 1,
                          )));
            },
          ),
          new ListTile(
            leading: Icon(Icons.shopping_cart),
            title: new Text("My Shop"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ShopDetailsWidget(),
              ));
            },
          ),
          new ListTile(
            leading: Icon(Icons.receipt),
            title: new Text("My Product"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyHomePage(
                            title: 'My Product',
                            tabsIndex: 2,
                          )));
            },
          ),
          new ListTile(
            leading: Icon(Icons.fastfood),
            title: new Text("Product Request"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProductRequestList(),
              ));
            },
          ),
          new ListTile(
            leading: Icon(Icons.playlist_play),
            title: new Text("Transaction"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Transaction(),
              ));
            },
          ),
          new ListTile(
            leading: Icon(Icons.attach_money),
            title: new Text("Request Withdraw"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => RequestWithdrawList(),
              ));
            },
          ),
          new ListTile(
            leading: Icon(Icons.library_books),
            title: new Text("Sales Report"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SalesReport(),
              ));
            },
          ),
          new ListTile(
            leading: Icon(Icons.contact_mail),
            title: new Text("Profile"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyHomePage(
                            title: 'Profile',
                            tabsIndex: 3,
                          )));
            },
          ),
          new ListTile(
            leading: Icon(Icons.exit_to_app),
            title: new Text("Logout"),
            onTap: () {
              Navigator.of(context).pop();
              print(Provider.of<AuthProvider>(context, listen: false).logOut());
            },
          ),
        ],
      ),
    );
  }
}
