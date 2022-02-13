import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:revisitas/Routes/app_routes.dart';
import 'package:revisitas/User/Users.dart';
import 'package:revisitas/componentes/barra.dart';
import 'package:revisitas/provider/BaseDeDados.dart';
import 'package:revisitas/services/Dowload_Upload.dart';
import 'package:revisitas/services/NotifyManager.dart';
import 'package:revisitas/services/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Config extends StatefulWidget {
  @override
  _ConfigState createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  bool value = false;

  DDDdataInfo user;
  bool isLoading;
  String ddd;
  bool itsOn;

  @override
  void initState() {
    Provider.of<NotificationService>(context, listen: false).initialize();
    super.initState();
    read();
    onOrOff();
    sharedPrefs();
  }

  Future read() async {
    setState(() => isLoading = true);
    user = await UsersDatabase.instance.readDDD(1);
    setState(() => isLoading = false);
  }

  void notifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('ativo', !prefs.getBool('ativo'));
      itsOn = prefs.getBool('ativo');
    });
  }

  void sharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('ativo') == null) {
      setState(() {
        prefs.setBool('ativo', false);
      });
    }
  }

  onOrOff() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      itsOn = prefs.getBool('ativo');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      drawer: Barra(),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              SizedBox(width: 20),
              Text(
                'Digite seu DDD:',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(width: 30),
              Expanded(
                child: isLoading
                    ? Text('')
                    : user == null
                        ? Text(
                            'No users',
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          )
                        : buildDDD(),
              ),
              SizedBox(
                width: 100,
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          buildCheckBox(),
          ListTile(
            leading: Icon(Icons.backup),
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.LOGIN,
              );
            },
            title: Text(
              'Backup',
              style: TextStyle(fontSize: 18),
            ),
          ),
          ListTile(
            leading: Icon(Icons.info),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Um pouco sobre o app'),
                  content: Text('- Esta é uma versão de testes. \n\n'
                      '- Este aplicativo foi criado tendo como objetivo apenas meu aprendizado. \n\n'
                      '- Por hora não me preocupei com o design do app, primeiramente minha meta é desenvolvimento de funções que possam ser úteis no dia a dia. \n\n'
                      '- Muito provavelmente podem ocorrer bugs que dificilmente são vistos durante o desenvolvimento, se encontrar algum sinta-se a vontade para clicar no botão de feedback que levará diretamente ao meu Whatsapp. \n\n'
                      '- Este aplicativo não está aberto ao público e não será disponibilizado na loja. \n\n'
                      '- Por último e não menos importante, muito obrigado por utilizar meu aplicativo, espero que seja útil :)'),
                ),
              );
            },
            title: Text(
              'Sobre o app',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDDD() {
    return TextFormField(
      inputFormatters: [
        new LengthLimitingTextInputFormatter(2),
      ],
      keyboardType: TextInputType.number,
      initialValue: user.number,
      onChanged: (value) async {
        final user2 = DDDdataInfo(
          id: 1,
          number: value,
        );
        await UsersDatabase.instance.updateDDD(user2);
      },
    );
  }

  Widget buildCheckBox() => Consumer<NotificationService>(
        builder: (context, model, _) => ListTile(
          leading: Icon(Icons.notifications),
          onTap: () async {
            setState(() {
              notifications();
            });
            if (itsOn == false) {
              model.cancelNotification();
              await UsersDatabase.instance.turnOff();
              print('desativou as notificações');
            }
          },
          title: Text(
            'Desativar todas as notificações',
            style: TextStyle(fontSize: 18),
          ),
          trailing: Checkbox(
            value: itsOn == null ? true : itsOn,
            onChanged: (value) {
              setState(() {
                notifications();
              });
            },
          ),
        ),
      );
}
