import 'data.dart';
import 'dart:math';
import 'customIcons.dart';
import 'cards/ui/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:Petti/screens/data.dart';
import 'package:Petti/screens/profile.dart';
import 'package:Petti/screens/shop/app.dart';
import 'package:Petti/services/profile.dart';
import 'package:Petti/screens/posts/feed.dart';
import 'package:Petti/screens/cards/ui/detail/dialog.dart';
import 'package:Petti/shared/shared_preferences_helper.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

var cardAspectRatio = 10.0 / 16.0;
var widgetAspectRatio = cardAspectRatio * 1.2;

class _HomeScreenState extends State<HomeScreen> {
  String name = 'Petti';
  String email = '';
  var currentPage = images.length - 1.0;
  var currentPageFamous = imagesFamous.length - 1.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    this.getUserInfo();
  }

  getUserInfo() {
    Map profile;
    getDataProfileService().then((value) {
      profile = value;
//      print('*******');print(profile);
      SharedPreferencesHelper.setName(profile['username']).then((_value) {
        setState(() {
          this.name = profile['username'];
        });
      });
    });
    SharedPreferencesHelper.getEmail().then((onValue) {
      setState(() {
        this.email = onValue;
      });
      /**
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          title: 'Bienvenido!',
          description:
              '¡Bienvenido a Petti!\nrecuerda actualizar tu perfil y agregar tu número de contacto :)',
          buttonText: "Okay",
        ),
      );
          **/
    });
  }

  @override
  Widget build(BuildContext context) {
    PageController controller =
        new PageController(initialPage: images.length - 1);
    controller.addListener(() {
      setState(() {
        currentPage = controller.page;
      });
    });

    PageController controllerFamous =
        new PageController(initialPage: imagesFamous.length - 1);
    controllerFamous.addListener(() {
      setState(() {
        currentPageFamous = controllerFamous.page;
      });
    });

    void _handleLogout() async {
      SharedPreferencesHelper.removeToken();
      SharedPreferencesHelper.removeEmail();
      SharedPreferencesHelper.removeName();
      Navigator.pushNamedAndRemoveUntil(
          context, '/login', ModalRoute.withName('/login'));
    }

    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
            Colors.white,
            Colors.white,
          ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              tileMode: TileMode.clamp)),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(this.name),
                accountEmail: Text(this.email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? Colors.white
                          : Colors.white,
                  child: Text(
                    name.substring(0, 1),
                    style: TextStyle(
                        fontSize: 40.0,
                        color: Color.fromRGBO(21, 157, 99, 1.0)),
                  ),
                ),
              ),
              ListTile(
                title: Text("Home"),
                leading: Icon(Icons.home),
                /** 
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => NewPage("Page two")));
                  },
                  **/
              ),
              ListTile(
                title: Text("Perfil"),
                leading: Icon(Icons.account_circle),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                  getUserInfo();
                },
              ),
              ListTile(
                title: Text("Cerrar sesión"),
                leading: Icon(Icons.exit_to_app),
                onTap: () {
                  _handleLogout();
                  //logic of sign out
                  /**
                     * Here you put the screen to go after signing out 
                    Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => NewPage("Page two")));
                    **/
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 12.0, right: 12.0, top: 40.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        CustomIcons.menu,
                        color: Color.fromRGBO(28, 96, 97, 1.0),
                        size: 30.0,
                      ),
                      onPressed: () {
                        _scaffoldKey.currentState.openDrawer();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Petti",
                        style: TextStyle(
                            fontFamily: "Billabong",
                            color: Color.fromRGBO(28, 96, 97, 1.0),
                            fontSize: 46.0)),
                    RawMaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.0),
                          side: BorderSide(color: Color.fromRGBO(28,96,97, 1))
                      ),
                      elevation: 2.0,
                      //fillColor: Color.fromRGBO(28,96,97, 1),
                      child: Icon(
                        Icons.headset_mic,
                        size: 30.0,
                        color: Color.fromRGBO(28, 96, 97, 1.0),
                      ),
                      onPressed: () {
                        SharedPreferencesHelper.getGuess().then((value) {
                          if(value){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => CustomDialog(
                                title:'No autorizado',
                                description:'Debes iniciar sesión para poder realizar esta acción.',
                                buttonText: "Okay",
                              ),
                            );
                          }else{
                            FlutterOpenWhatsapp.sendSingleMessage(
                                '573147382820', "Hola!");
                          }
                        });
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 15.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(28, 96, 97, 1.0),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 22.0, vertical: 6.0),
                          child: Text("Principal",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Text("¿Cómo podemos ayudarte hoy?",
                        style:
                            TextStyle(color: Color.fromRGBO(28, 96, 97, 1.0)))
                  ],
                ),
              ),
              Stack(
                children: <Widget>[
                  CardScrollWidget(currentPage),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        String _title = '';
                        switch (currentPage.round()) {
                          case 4:
                            _title = 'Adopción y perdidos';
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Feed(title: '$_title')));
                            break;
                          case 3:
                            _title = 'Compra y venta';
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Feed(title: '$_title')));
                            break;
                          case 2:
                            _title = 'Coupet';
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Feed(title: '$_title')));
                            break;
                          case 1:
                            _title = 'Vet & care';
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()));
                            break;
                          case 0:
                            _title = 'PetShop';
                            //Navigator.pushNamedAndRemoveUntil(context, '/store', ModalRoute.withName('/store'));
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CupertinoStoreApp()));
                            break;
                        }
                        print('index: $currentPage');
                        //Navigator.pushNamedAndRemoveUntil(context, '/posts', ModalRoute.withName('/posts'));
                      },
                      child: PageView.builder(
                        itemCount: images.length,
                        controller: controller,
                        reverse: true,
                        itemBuilder: (context, index) {
                          return Container();
                        },
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardScrollWidget extends StatelessWidget {
  var currentPage;
  var padding = 20.0;
  var verticalInset = 20.0;

  CardScrollWidget(this.currentPage);

  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      aspectRatio: widgetAspectRatio,
      child: LayoutBuilder(builder: (context, contraints) {
        var width = contraints.maxWidth;
        var height = contraints.maxHeight;

        var safeWidth = width - 2 * padding;
        var safeHeight = height - 2 * padding;

        var heightOfPrimaryCard = safeHeight;
        var widthOfPrimaryCard = heightOfPrimaryCard * cardAspectRatio;

        var primaryCardLeft = safeWidth - widthOfPrimaryCard;
        var horizontalInset = primaryCardLeft / 2;

        List<Widget> cardList = new List();

        for (var i = 0; i < images.length; i++) {
          var delta = i - currentPage;
          bool isOnRight = delta > 0;

          var start = padding +
              max(
                  primaryCardLeft -
                      horizontalInset * -delta * (isOnRight ? 15 : 1),
                  0.0);

          var cardItem = Positioned.directional(
            top: padding + verticalInset * max(-delta, 0.0),
            bottom: padding + verticalInset * max(-delta, 0.0),
            start: start,
            textDirection: TextDirection.rtl,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(3.0, 6.0),
                      blurRadius: 10.0)
                ]),
                child: AspectRatio(
                  aspectRatio: cardAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Image.asset(images[i], fit: BoxFit.cover),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0, bottom: 12.0),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 22.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(28, 96, 97, 1.0),
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: Text(title[i],
                                    style: TextStyle(color: Colors.white)),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
          cardList.add(cardItem);
        }
        return Stack(
          children: cardList,
        );
      }),
    );
  }
}

class CardFamousScrollWidget extends StatelessWidget {
  var currentPage;
  var padding = 20.0;
  var verticalInset = 20.0;

  CardFamousScrollWidget(this.currentPage);

  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      aspectRatio: widgetAspectRatio,
      child: LayoutBuilder(builder: (context, contraints) {
        var width = contraints.maxWidth;
        var height = contraints.maxHeight;

        var safeWidth = width - 2 * padding;
        var safeHeight = height - 2 * padding;

        var heightOfPrimaryCard = safeHeight;
        var widthOfPrimaryCard = heightOfPrimaryCard * cardAspectRatio;

        var primaryCardLeft = safeWidth - widthOfPrimaryCard;
        var horizontalInset = primaryCardLeft / 2;

        List<Widget> cardList = new List();

        for (var i = 0; i < images.length; i++) {
          var delta = i - currentPage;
          bool isOnRight = delta > 0;

          var start = padding +
              max(
                  primaryCardLeft -
                      horizontalInset * -delta * (isOnRight ? 15 : 1),
                  0.0);

          var cardItem = Positioned.directional(
            top: padding + verticalInset * max(-delta, 0.0),
            bottom: padding + verticalInset * max(-delta, 0.0),
            start: start,
            textDirection: TextDirection.rtl,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(3.0, 6.0),
                      blurRadius: 10.0)
                ]),
                child: AspectRatio(
                  aspectRatio: cardAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Image.asset(imagesFamous[i], fit: BoxFit.cover),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(titleFamous[i],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25.0,
                                      fontFamily: "SF-Pro-Text-Regular")),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, bottom: 12.0),
                                child: new GestureDetector(
                                  onTap: () {
                                    print("Container clicked $i");
                                  },
                                  child: new Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 22.0, vertical: 6.0),
                                    decoration: BoxDecoration(
                                        color: Color.fromRGBO(28, 96, 97, 1.0),
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    child: Text("Ver más",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
          cardList.add(cardItem);
        }
        return Stack(
          children: cardList,
        );
      }),
    );
  }
}
