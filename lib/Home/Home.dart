/* import 'dart:ffi';
import 'dart:html'; */
import 'package:flutter/material.dart';
import 'package:revisitas/Routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  whatsapp() {
    String wpp = 'https://api.whatsapp.com/send?phone=55‪62984279316';
    launch(wpp);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    if (mediaQueryData.orientation == Orientation.landscape) {
      return Scaffold(
          appBar: AppBar(
            leading: Icon(Icons.home),
            title: Text('Início'),
          ),
          body: Body(
            quant: 3,
          ));
    }
    return Scaffold(
      appBar: _appBar(170.0),
      body: Body(
        quant: 2,
      ),
    );
  }

  _appBar(height) => PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, height + 80),
        child: Stack(
          children: <Widget>[
            Container(
              // Background
              child: Center(
                child: Container(
                  child: Image.asset(
                    'assets/image/logo.png',
                    width: 180,
                    height: 180,
                    //fit: BoxFit.cover,
                  ),
                ),
              ),

              color: Theme.of(context).primaryColor,
              height: height + 75,
              width: MediaQuery.of(context).size.width,
            ),

            //Container(), // Required some widget in between to float AppBar
          ],
        ),
      );
}

class UserCardWidget extends StatelessWidget {
  UserCardWidget({Key key, this.action, this.icon, this.title})
      : super(key: key);

  final Function action;
  final Icon icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: action,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 5.0,
                    top: 40,
                  ),
                  child: Container(
                    margin: EdgeInsets.all(5),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 28.0,
                          fontFamily: 'PlayfairDisplay',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 5.0,
                top: 20,
              ),
              child: icon,
            ),
          ),
        ],
      ),
    );
  }
}

class Body extends StatelessWidget {
  final int quant;
  const Body({this.quant});

  whatsapp() {
    String wpp = 'https://api.whatsapp.com/send?phone=55‪62984279316';
    launch(wpp);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      childAspectRatio: (76 / 54),
      crossAxisCount: quant,
      children: [
        UserCardWidget(
          icon: Icon(
            Icons.list_alt,
            size: 50,
          ),
          title: 'Listas',
          action: () {
            Navigator.of(context).pushNamed(
              AppRoutes.LIST,
            );
          },
        ),
        UserCardWidget(
          icon: Icon(
            Icons.contact_phone_rounded,
            size: 50,
          ),
          title: 'Revisitas',
          action: () {
            Navigator.of(context).pushNamed(
              AppRoutes.REVPAGE,
            );
          },
        ),
        UserCardWidget(
          icon: Icon(
            Icons.person,
            size: 50,
          ),
          title: 'Estudos',
          action: () {
            Navigator.of(context).pushNamed(
              AppRoutes.EST,
            );
          },
        ),
        UserCardWidget(
          icon: Icon(
            Icons.call_outlined,
            size: 50,
          ),
          title: 'Ligar novamente',
          action: () {
            Navigator.of(context).pushNamed(
              AppRoutes.CXM,
            );
          },
        ),
        UserCardWidget(
          icon: Icon(
            Icons.border_color,
            size: 50,
          ),
          title: 'Feedback',
          action: () {
            whatsapp();
          },
        ),
        UserCardWidget(
          icon: Icon(
            Icons.settings,
            size: 50,
          ),
          title: 'Configurações',
          action: () {
            Navigator.of(context).pushNamed(
              AppRoutes.CONFIG,
            );
          },
        ),
      ],
    );
  }
}
