import 'dart:convert';
import 'dart:io';
import 'package:eBazaarMerchant/config/api.dart';
import 'package:eBazaarMerchant/providers/auth.dart';
import 'package:eBazaarMerchant/src/shared/colors.dart';
import 'package:eBazaarMerchant/src/utils/CustomTextStyle.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

class PaymentStripe extends StatefulWidget {
  String? orderID;
  String? amount;
  String? customerToken;

  PaymentStripe({Key? key, this.amount, this.orderID, this.customerToken})
      : super(key: key);

  @override
  _PaymentStripeState createState() => _PaymentStripeState();
}

class _PaymentStripeState extends State<PaymentStripe> {
  String? currency;
  String api = FoodApi.baseApi;

  @override
  void initState() {
    super.initState();
    final stripesecret =
        Provider.of<AuthProvider>(context, listen: false).stripesecret;
    final stripekey =
        Provider.of<AuthProvider>(context, listen: false).stripekey;
    print(stripekey);
    print(stripesecret);
    Stripe.publishableKey = stripekey!;
    Stripe.instance.applySettings();
  }

  Map<String, dynamic>? paymentIntentData;
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final currency = Provider.of<AuthProvider>(context).currency;
    print(currency);
    final sitename = Provider.of<AuthProvider>(context).sitename;
    final stripesecret =
        Provider.of<AuthProvider>(context, listen: false).stripesecret;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text('Stripe Payment'),
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
                  'Payment',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyle.textFormFieldMedium.copyWith(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Click your Payment '),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    image: new DecorationImage(
                      image: new ExactAssetImage('assets/images/stripe.png'),
                      fit: BoxFit.cover,
                    ),
                  )),
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
                  'Total Amount $currency ${widget.amount}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyle.textFormFieldMedium.copyWith(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                await makePayment(stripesecret!, currency);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18),
                child: Container(
                  width: MediaQuery.of(context).size.width - 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: primaryColor),
                  child: Center(
                    child: Text(
                      'Payment',
                      style: TextStyle(
                          fontFamily: 'nunito',
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makePayment(stripeSecret, currency) async {
    try {
      paymentIntentData =
          await createPaymentIntent(stripeSecret, widget.amount!, 'usd');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret:
                      paymentIntentData!['client_secret'],
                  applePay: true,
                  googlePay: true,
                  testEnv: true,
                  style: ThemeMode.dark,
                  merchantCountryCode: 'US',
                  merchantDisplayName: 'MOKTADIR'))
          .then((value) {});
      displayPaymentSheet();
    } catch (e) {
      print('exception' + e.toString());
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance
          .presentPaymentSheet(
              parameters: PresentPaymentSheetParameters(
        clientSecret: paymentIntentData!['client_secret'],
        confirmPayment: true,
      ))
          .then((newValue) async {
        //orderPlaceApi(paymentIntentData!['id'].toString());
        print('payment id =================================>');
        print(paymentIntentData!['id'].toString());
        final url = "$api/orders/payment";

        Map<String, String> body = {
          'order_id': widget.orderID!,
          'amount': widget.amount!,
          'payment_method': '15',
          'payment_transaction_id': '',
        };

        final response = await http.post(Uri.parse(url), body: body, headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + widget.customerToken!
        });
        print(jsonDecode(response.body));
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("paid successfully")));

        paymentIntentData = null;
      }).onError((error, stackTrace) {
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });
    } on StripeException catch (e) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

  createPaymentIntent(stripeSecret, String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer ' + stripeSecret,
            'Content-Type': 'application/x-www-form-urlencoded'
          });

      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (double.parse(amount).toInt()) * 100;
    return a.toString();
  }
}
