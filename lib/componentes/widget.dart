/* import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:revisitas/Routes/app_routes.dart';
import 'package:revisitas/User/Users.dart';
import 'package:revisitas/provider/lista.dart';
import 'package:revisitas/services/NotifyManager.dart';
import 'package:url_launcher/url_launcher.dart';

class UserTile extends StatefulWidget {
  final NumerosList numerosList2;

  const UserTile(this.numerosList2);

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  final _form = GlobalKey<FormState>();
  final Map<String, String> _formData = {};

  call() {
    String phone = "tel:" + widget.numerosList2.numero;
    launch(phone);
  }

  @override
  Widget build(BuildContext context) {
    final NumerosList numerosList = ModalRoute.of(context).settings.arguments;
    final User user = ModalRoute.of(context).settings.arguments;

    void _loadFormData(NumerosList numerosList) {
      _formData['id'] = widget.numerosList2.id;
      _formData['numero'] = widget.numerosList2.numero;
    }

    _loadFormData(numerosList);

    return ListTile(
      leading: InkWell(
        onTap: () {
          call();
          /* setState(() {
              pressed = true;
            });

             Timer(Duration(seconds: 3), () {
              setState(() {
                orgColor = Colors.black;
              });
            }); */
        },
        child: CircleAvatar(
          child: Icon(Icons.phone),
        ),
      ),
      title: Text(
        widget.numerosList2.numero,
        style: TextStyle(),
      ),
      trailing: Container(
        width: 150,
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () {
                print(_formData['numero']);
                Provider.of<NumerosList3>(context, listen: false).put(
                  NumerosList(
                    _formData['numero'],
                    _formData['id'],
                  ),
                );
                Provider.of<NumerosList2>(context, listen: false)
                    .remove(widget.numerosList2);
              },
              icon: Icon(Icons.phone_callback),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.NUM_TO_REV,
                  arguments: widget.numerosList2,
                );
                Provider.of<NumerosList2>(context, listen: false)
                    .remove(widget.numerosList2);
              },
              icon: Icon(Icons.check),
              color: Colors.green,
            ),
            IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Excluir Usuário'),
                      content: Text('Tem certeza?'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Não'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text('Sim'),
                          onPressed: () {
                            Provider.of<NumerosList2>(context, listen: false)
                                .remove(widget.numerosList2);
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.close),
                color: Colors.red),
          ],
        ),
      ),
    );
  }
}

void setState(Null Function() param0) {}

class UserTile2 extends StatefulWidget {
  final User user;

  const UserTile2(this.user);

  @override
  _UserTile2State createState() => _UserTile2State();
}

class _UserTile2State extends State<UserTile2> {
  @override
  void initState() {
    Provider.of<NotificationService>(context, listen: false).initialize();
    super.initState();
  }

  final _form = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  void _loadFormData(User user) {
    if (user != null) {
      _formData['id'] = user.id;
      _formData['nome'] = user.nome;
      _formData['numero'] = user.numero;
      _formData['anotacoes'] = user.anotacoes;
      _formData['data'] = user.data;
      _formData['dia'] = user.dia;
      _formData['not'] = user.idN;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User user = ModalRoute.of(context).settings.arguments;
    _loadFormData(user);
    var _color = Color(0xff9e9e9e);

    return new GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.USER,
          arguments: widget.user,
        );
      },
      child: Container(
        width: 135.0,
        height: 80.0,
        margin: EdgeInsets.only(
          right: 5.0,
          left: 5.0,
          top: 5.0,
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 500.0,
                height: 150.0,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.rectangle,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 80.0, bottom: 20.0, top: 12),
                    child: Text(
                      '${widget.user.nome}',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'PlayfairDisplay',
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 12.0, bottom: 5.0, top: 0),
                child: Icon(
                  Icons.account_circle_rounded,
                  size: 50,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 80.0, bottom: 5.0, top: 40),
                child: Text(
                  '${widget.user.numero}',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontFamily: 'PlayfairDisplay',
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//widget revisita
class UserTile3 extends StatelessWidget {
  final User user;

  const UserTile3(this.user);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.REV,
          arguments: user,
        );
      },
      child: Container(
        width: 135.0,
        height: 80.0,
        margin: EdgeInsets.only(
          right: 5.0,
          left: 5.0,
          top: 5.0,
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 500.0,
                height: 150.0,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.rectangle,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 80.0, bottom: 20.0, top: 12),
                    child: Text(
                      '${user.nome}',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'PlayfairDisplay',
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 12.0, bottom: 5.0, top: 0),
                child: Icon(
                  Icons.account_circle_rounded,
                  size: 50,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 80.0, bottom: 5.0, top: 40),
                child: Text(
                  '${user.numero}',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontFamily: 'PlayfairDisplay',
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserCardWidget extends StatelessWidget {
  UserCardWidget({
    Key key,
    this.user,
    this.index,
  }) : super(key: key);

  final UserInfo user;
  final int index;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.REV,
          arguments: user,
        );
        /* Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserDetailPage(userId: user.id),
          ),
        ); */
      },
      child: Container(
        width: 135.0,
        height: 80.0,
        margin: EdgeInsets.only(
          right: 5.0,
          left: 5.0,
          top: 5.0,
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 500.0,
                height: 150.0,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.rectangle,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 80.0, bottom: 20.0, top: 12),
                    child: Text(
                      '${user.name}',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'PlayfairDisplay',
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 12.0, bottom: 5.0, top: 0),
                child: Icon(
                  Icons.account_circle_rounded,
                  size: 50,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 80.0, bottom: 5.0, top: 40),
                child: Text(
                  '${user.description}',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontFamily: 'PlayfairDisplay',
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 */