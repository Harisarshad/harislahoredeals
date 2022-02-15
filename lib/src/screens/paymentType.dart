import 'package:flutter/material.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/Widget/PaymentMethodListItemWidget.dart';
import 'package:eBazaarMerchant/src/screens/payment_strip.dart';
import 'package:eBazaarMerchant/src/utils/CustomTextStyle.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class PaymentMethodsPage extends StatefulWidget {
  final orderID;
  final amount;
  PaymentMethodsPage({Key? key, this.orderID, this.amount}) : super(key: key);

  @override
  _PaymentMethodsWidgetState createState() => _PaymentMethodsWidgetState();
}

class _PaymentMethodsWidgetState extends State<PaymentMethodsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: true).token;
    final currencyName =
        Provider.of<AuthProvider>(context, listen: true).currencyname;
    final stripeKey =
        Provider.of<AuthProvider>(context, listen: true).stripekey;
    final stripeSecret =
        Provider.of<AuthProvider>(context, listen: true).stripesecret;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff44c662),
        elevation: 0,
        centerTitle: true,
        title: Text('Payment Type'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                leading: Icon(
                  Icons.payment,
                  color: Theme.of(context).hintColor,
                ),
                title: Text(
                  'Payment Options',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyle.textFormFieldMedium.copyWith(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text('select your preferred payment mode'),
              ),
            ),
            SizedBox(height: 10),
            ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              primary: false,
              children: <Widget>[
                PaymentMethodListItemWidget(
                  paymentMethod: 'Stripe',
                  logo: 'assets/images/stripe.png',
                  description: 'Click to pay with your Stripe',
                  route: PaymentStripe(
                    amount: widget.amount,
                    orderID: widget.orderID,
                    customerToken: token,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                leading: Icon(
                  Icons.monetization_on,
                  color: Theme.of(context).hintColor,
                ),
                title: Text(
                  'Cash on delivery',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyle.textFormFieldMedium.copyWith(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text('select your preferred payment mode'),
              ),
            ),
            ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              primary: false,
              children: <Widget>[
                PaymentMethodListItemWidget(
                  paymentMethod: 'Cash on Delivery',
                  logo: 'assets/images/cash_delivery.jpg',
                  description: 'Click to pay cash on delivery',
                  route: MyHomePage(
                    title: 'My Order',
                    tabsIndex: 1,
                  ),
                ),
                SizedBox(height: 10),
                PaymentMethodListItemWidget(
                  paymentMethod: 'Pay on Pickup',
                  logo: 'assets/images/pay_pickup.png',
                  description: 'Click to pay on pickup',
                  route: MyHomePage(
                    title: 'My Order',
                    tabsIndex: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
