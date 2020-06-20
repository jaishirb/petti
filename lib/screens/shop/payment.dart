import 'package:Petti/screens/shop/webview.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';




class Payment extends StatefulWidget {
  final total;
  final id_venta;
  Payment(this.total, this.id_venta);
  @override
  _PaymentState createState() => _PaymentState(this.total, this.id_venta);
}

class _PaymentState extends State<Payment> {
  final total;
  final id_venta;
  _PaymentState(this.total, this.id_venta);
  String token = "";
  @override
  void initState() {
    super.initState();
  }

  _launchURL() async {
    const publicKey = 'pub_prod_9B8EH9OWXRfrOjIm87f0CgGEolbdfL8x';
    const currency = "COP";
    print('*****************************');
    print(this.total);
    var amountInCents = 100*this.total;
    var reference = "$id_venta";
    var url = 'https://checkout.wompi.co/p/?public-key=$publicKey&&'
        'currency=$currency&&amount-in-cents=$amountInCents&&reference=$reference';
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WebViewContainer(url)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagos',
            style: const TextStyle(
                fontFamily: "Billabong",
                color: Color.fromRGBO(28, 96, 97, 1.0),
                fontSize: 35.0)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(45.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 50.0,
                            child: CircleAvatar(
                              radius: 40.0,
                              backgroundImage: CachedNetworkImageProvider(
                                  "https://pettiapp.s3.us-east-2.amazonaws.com/images/LOGO1.png"),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10.0),
                          ),
                          Text(
                            "Petti",
                            style: TextStyle(
                                color: Color.fromRGBO(28, 96, 97, 1.0),
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 30.0),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Una vez tu pago sea exitoso, \ntu solicitud será procesada por\n"
                                  "un agente. gracias por elegirnos.",
                              style: TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 1.0),
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16.0),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10.0),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Equipo Petti.                               ",
                              style: TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 1.0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 45.0, top: 5.0),
                child:   Align(
                  alignment: Alignment.bottomCenter,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      _launchURL();
                    },
                    icon: Icon(Icons.lock),
                    label: Text("Pagar"),
                    backgroundColor: Color.fromRGBO(28, 96, 97, 1.0),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}