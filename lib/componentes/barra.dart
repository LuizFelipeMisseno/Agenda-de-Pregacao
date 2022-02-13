import 'package:flutter/material.dart';
import 'package:revisitas/Home/Home.dart';
import 'package:revisitas/Routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class Barra extends StatelessWidget {
  whatsapp() {
    String wpp = 'https://api.whatsapp.com/send?phone=55‪62984279316';
    launch(wpp);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 28,
            color: Colors.blue,
          ),
          Stack(
            children: [
              Container(
                child: Container(
                  child: Image.asset(
                    'assets/image/logo.png',
                    fit: BoxFit.fitHeight,
                    alignment: Alignment(-0.2, 0),
                  ),
                  width: 500,
                  height: 200,
                ),
                color: Colors.blue,
              ),
            ],
          ),
          Container(
            height: 10,
            color: Colors.blue,
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Início'),
            onTap: () => {
              /* Navigator.of(context).pushReplacementNamed(
                AppRoutes.HOMEPAGE,
              ), */
              Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.HOMEPAGE, (Route<dynamic> route) => false),
            },
          ),
          ListTile(
            leading: Icon(Icons.list_alt),
            title: Text('Listas'),
            onTap: () => {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.LIST,
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_phone_rounded),
            title: Text('Revisitas'),
            onTap: () => {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.REVPAGE,
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Estudos'),
            onTap: () => {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.EST,
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.call_outlined),
            title: Text('Ligar novamente'),
            onTap: () => {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.CXM,
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('Feedback'),
            onTap: () => {
              whatsapp(),
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configurações'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.CONFIG,
              );
            },
          ),
        ],
      ),
    );
  }
}
