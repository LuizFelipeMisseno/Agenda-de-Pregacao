import 'dart:async';

import 'package:flutter/material.dart';
import 'package:revisitas/Routes/app_routes.dart';
import 'package:revisitas/User/Users.dart';
import 'package:revisitas/componentes/barra.dart';
import 'package:revisitas/services/Config.dart';
import 'package:revisitas/provider/BaseDeDados.dart';
import 'package:url_launcher/url_launcher.dart';

class NumCardWidget extends StatefulWidget {
  NumCardWidget({
    Key key,
    this.user,
    this.index,
    this.icon,
  }) : super(key: key);

  final NumerosInfo2 user;
  final int index;
  final IconButton icon;

  @override
  _NumCardWidgetState createState() => _NumCardWidgetState();
}

class _NumCardWidgetState extends State<NumCardWidget> {
  final _form = GlobalKey<FormState>();

  final Map<dynamic, dynamic> _formData = {};

  call() {
    String phone = "tel:" + widget.user.number;
    launch(phone);
  }

  timer() {}

  List<NumerosInfo2> users;
  bool isLoading = false;
  Color color;

  @override
  void initState() {
    super.initState();

    refreshUsers();
  }

  Future refreshUsers() async {
    setState(() => isLoading = true);

    this.users = await UsersDatabase.instance.readAllNum2();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final Numeros2 numerosList = ModalRoute.of(context).settings.arguments;
    final user1 = NumerosInfo(
      id: widget.user.id,
      number: widget.user.number.toString(),
    );

    void _loadFormData(Numeros2 numerosList) {
      _formData['id'] = widget.user.id;
      _formData['numero'] = widget.user.number;
    }

    _loadFormData(numerosList);

    return ListTile(
      leading: InkWell(
        onTap: () async {
          call();
          setState(
            () {
              color = Colors.red;
            },
          );
          await timer();
        },
        child: CircleAvatar(
          child: Icon(Icons.phone),
        ),
      ),
      title: Text(
        widget.user.number,
        style: TextStyle(
          color: color,
        ),
      ),
      trailing: Container(
        width: 150,
        child: Row(
          children: <Widget>[
            SizedBox(width: 54),
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.NUM_TO_REV,
                  arguments: user1,
                );
              },
              icon: Icon(Icons.check),
              color: Colors.green,
            ),
            widget.icon,
          ],
        ),
      ),
    );
  }
}

class Ligar extends StatefulWidget {
  @override
  _LigarState createState() => _LigarState();
}

class _LigarState extends State<Ligar> {
  List<NumerosInfo2> users;
  bool isLoading = false;
  Color color;

  @override
  void initState() {
    super.initState();

    refreshUsers();
  }

  Future refreshUsers() async {
    setState(() => isLoading = true);

    this.users = await UsersDatabase.instance.readAllNum2();

    setState(() => isLoading = false);
  }

  refreshPage() async {
    this.users = await UsersDatabase.instance.readAllNum2();
    setState(() {
      color = Colors.black;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Ligar novamente',
            style: TextStyle(fontSize: 24),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Excluir número'),
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
                        onPressed: () async {
                          await UsersDatabase.instance.clearNum2();
                          refreshUsers();
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  ),
                );
              },
              icon: Icon(Icons.delete),
            )
          ],
        ),
        body: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : users.isEmpty
                  ? Text(
                      'Nenhum número',
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 30),
                    )
                  : buildusers2(),
        ),
        drawer: Barra(),
      );

  Widget buildusers() => ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return GestureDetector(
            onTap: () {
              refreshUsers();
            },
            child: NumCardWidget(
              user: user,
              index: index,
              icon: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Excluir número'),
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
                            onPressed: () async {
                              await UsersDatabase.instance.deleteNum2(user.id);
                              Navigator.of(context).pop();
                              setState(() {
                                color = Colors.black;
                              });
                              this.users =
                                  await UsersDatabase.instance.readAllNum2();
                            },
                          )
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.close),
                  color: Colors.red),
            ),
          );
        },
      );

  Widget buildusers2() => ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          call() {
            String phone = "tel:" + user.number;
            launch(phone);
          }

          final user1 = NumerosInfo(
            id: user.id,
            number: user.number.toString(),
          );

          changeColor() async {
            bool called;
            if (user.called == false) {
              called = true;
            } else {
              called = false;
            }
            final user1 = NumerosInfo2(
              id: user.id,
              number: user.number.toString(),
              called: called,
              data: user.data,
            );
            await UsersDatabase.instance.updateNum2(user1);
            refreshPage();
          }

          changeData() async {
            bool called;
            if (user.called == false) {
              called = true;
            } else {
              called = false;
            }
            final user1 = user.copy(
              id: user.id,
              number: user.number,
              called: called,
              data: DateTime.now(),
            );

            await UsersDatabase.instance.updateNum2(user1);
          }

          return GestureDetector(
              onTap: () async {
                changeColor();
              },
              child: ListTile(
                leading: InkWell(
                  onTap: () {
                    call();
                    changeColor();
                    Timer(Duration(seconds: 3), changeData);
                  },
                  child: CircleAvatar(
                    child: Icon(Icons.phone),
                  ),
                ),
                title: Text(
                  user.number,
                  style: TextStyle(
                    color: user.called ? Colors.red : Colors.black,
                  ),
                ),
                trailing: Container(
                  width: 150,
                  child: Row(
                    children: <Widget>[
                      Row(
                        children: [
                          Container(
                            width: 54,
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.NUM_TO_REV,
                                arguments: user1,
                              );
                            },
                            icon: Icon(Icons.check),
                            color: Colors.green,
                          ),
                          IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('Excluir número'),
                                    content: Text('Tem certeza?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Não'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Sim'),
                                        onPressed: () async {
                                          //await _NumCardWidgetState().call();
                                          await UsersDatabase.instance
                                              .deleteNum2(user.id);
                                          Navigator.of(context).pop();
                                          refreshPage();
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
                    ],
                  ),
                ),
              ));
        },
      );
}
