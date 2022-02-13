import 'dart:async';
import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
    this.iconDelete,
    this.iconCx,
  }) : super(key: key);

  final NumerosInfo user;
  final int index;
  final IconButton iconDelete;
  final IconButton iconCx;

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

  changeColor() async {
    bool called;
    if (widget.user.called == false) {
      called = true;
    } else {
      called = false;
    }
    final user = NumerosInfo(
      id: widget.user.id,
      number: widget.user.number.toString(),
      called: called,
    );
    await UsersDatabase.instance.updateNum(user);
  }

  List<NumerosInfo> users;
  bool isLoading = false;
  bool pressed = false;
  Color color;

  @override
  Widget build(BuildContext context) {
    final Numeros numerosList = ModalRoute.of(context).settings.arguments;

    void _loadFormData(Numeros numerosList) {
      _formData['id'] = widget.user.id;
      _formData['numero'] = widget.user.number;
    }

    _loadFormData(numerosList);

    return /* GestureDetector(
      onTap: () {
        changeColor();
      },
      child: */
        ListTile(
      leading: InkWell(
        onTap: () async {
          call();
          changeColor();
          setState(() {
            //color = Colors.red;
          });
        },
        child: CircleAvatar(
          child: Icon(Icons.phone),
        ),
      ),
      title: Text(
        widget.user.number,
        style: TextStyle(
          color: widget.user.called ? Colors.red : Colors.black,
        ),
      ),
      trailing: Container(
        width: 150,
        child: Row(
          children: <Widget>[
            widget.iconCx,
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.NUM_TO_REV,
                  arguments: widget.user,
                );
              },
              icon: Icon(Icons.check),
              color: Colors.green,
            ),
            widget.iconDelete,
          ],
        ),
      ),
    );
  }
}

class NumPage extends StatefulWidget {
  @override
  _NumPageState createState() => _NumPageState();
}

class _NumPageState extends State<NumPage> with TickerProviderStateMixin {
  List<NumerosInfo> users;
  DDDdataInfo ddd;
  bool isLoading = false;
  AnimationController controller;
  Animation animation;
  Color color;
  AnimationController _hideFabAnimation;

  @override
  void initState() {
    super.initState();

    refreshUsers();

    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    animation =
        ColorTween(begin: Colors.red, end: Colors.black).animate(controller);

    animation.addListener(() {
      if (mounted) {
        setState(() {
          color = animation.value;
        });
      }
    });

    changeColors();
    _hideFabAnimation =
        AnimationController(vsync: this, duration: kThemeAnimationDuration);
    _hideFabAnimation.forward();
  }

  @override
  void dispose() {
    _hideFabAnimation.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;
        switch (userScroll.direction) {
          case ScrollDirection.forward:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
              _hideFabAnimation.forward();
            }
            break;
          case ScrollDirection.reverse:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
              _hideFabAnimation.reverse();
            }
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  Future changeColors() async {
    while (true) {
      await new Future.delayed(const Duration(seconds: 2), () {
        if (controller.status == AnimationStatus.completed) {
          controller.reverse();
        } else {
          controller.forward();
        }
      });
    }
  }

  Future refreshUsers() async {
    setState(() => isLoading = true);
    this.ddd = await UsersDatabase.instance.readDDD(1);

    this.users = await UsersDatabase.instance.readAllNum();

    setState(() => isLoading = false);
  }

  refreshPage() async {
    this.users = await UsersDatabase.instance.readAllNum();
    setState(() {
      color = Colors.black;
    });
  }

  var help = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(
              'Lista',
              style: TextStyle(fontSize: 24),
            ),
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  if (help == false) {
                    setState(() {
                      help = true;
                    });
                  } else {
                    setState(() {
                      help = false;
                    });
                  }
                },
                icon: Icon(Icons.help),
              ),
              IconButton(
                onPressed: () async {
                  if (users.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Aviso'),
                        content: Text('A lista já está vazia'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Ok'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Excluir lista'),
                        content: Text(
                            'Essa ação removerá todos os números desta página, deseja prosseguir?'),
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
                              await UsersDatabase.instance.clearNum();
                              refreshUsers();
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ),
                    );
                  }
                },
                icon: Icon(Icons.delete),
              )
            ]),
        body: NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: Container(
            height: 900,
            child: isLoading
                ? Text('')
                : help
                    ? SingleChildScrollView(
                        child: Container(
                          height: 600,
                          child: Stack(
                            children: [
                              Container(
                                height: 60,
                                color: Colors.blue.shade200,
                              ),
                              Positioned(
                                left: 25,
                                top: 15,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    'Entenda a função de cada botão',
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              ListView(
                                children: [],
                              ),
                              Positioned(
                                top: 250,
                                bottom: 0,
                                left: 10,
                                right: 10,
                                child: example(),
                              ),
                              Positioned(
                                top: 70,
                                bottom: 0,
                                left: 15,
                                right: 60,
                                child: Text(
                                  'Abre o teclado do telefone com o número discado',
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.black54),
                                ),
                              ),
                              Positioned(
                                top: 125,
                                left: 32,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Container(
                                    height: 120.0,
                                    width: 5.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 135,
                                left: 110,
                                right: 10,
                                child: Text(
                                  'Coloca o número na lista de "Ligar Novamente"',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.black54),
                                ),
                              ),
                              Positioned(
                                top: 187,
                                right: 140,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Container(
                                    height: 70.0,
                                    width: 5.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 295,
                                right: 92,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Container(
                                    height: 60.0,
                                    width: 5.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 360,
                                left: 132,
                                right: 80,
                                child: Text(
                                  'Abre a página para cadastrar o número como revisita',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black54),
                                ),
                              ),
                              Positioned(
                                top: 295,
                                right: 42,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Container(
                                    height: 130.0,
                                    width: 5.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 430,
                                left: 110,
                                right: 50,
                                child: Text(
                                  'Exclui o número',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.black54),
                                ),
                              ),
                              Positioned(
                                top: 295,
                                left: 80,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Container(
                                    height: 170.0,
                                    width: 5.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 470,
                                left: 30,
                                right: 100,
                                child: Text(
                                  'O número ficará em vermelho ao discar, caso queira mudar ele para preto novamente basta clicar em cima.',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : users.isEmpty
                        ? Stack(
                            children: [
                              Positioned(
                                top: 270,
                                left: 110,
                                child: Text(
                                  'Nenhuma lista',
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : buildusers(),
          ),
        ),
        drawer: Barra(),
        floatingActionButton: ScaleTransition(
          scale: _hideFabAnimation, // set it to false
          child: FloatingActionButton(
            onPressed: () {
              if (ddd.number == '') {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Configuração adicional'),
                    content: Text('Antes de prosseguir digite seu DDD'),
                    actions: <Widget>[
                      Row(
                        children: [
                          SizedBox(width: 30),
                          Expanded(
                            child: TextFormField(
                              inputFormatters: [
                                new LengthLimitingTextInputFormatter(2),
                              ],
                              keyboardType: TextInputType.number,
                              initialValue: ddd.number,
                              onChanged: (value) async {
                                final user2 = DDDdataInfo(
                                  id: 1,
                                  number: value,
                                );
                                await UsersDatabase.instance.updateDDD(user2);
                              },
                            ),
                          ),
                          SizedBox(width: 30),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushReplacementNamed(
                                AppRoutes.LISTFORM,
                              );
                            },
                            child: Text('Salvar'),
                          )
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.of(context).pushNamed(
                  AppRoutes.LISTFORM,
                );
              }
            },
            backgroundColor: Colors.blue,
            child: Icon(Icons.add),
          ),
        ),
      );

  Widget example() => ListTile(
        leading: InkWell(
          onTap: () async {},
          child: CircleAvatar(
            child: Icon(Icons.phone),
          ),
        ),
        title: Text(
          'xxxxx - xxxx',
          textScaleFactor: 3,
          style: TextStyle(color: color, fontSize: 7),
        ),
        trailing: Container(
          width: 150,
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.phone_callback),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.check),
                color: Colors.green,
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.delete),
                color: Colors.red,
              ),
            ],
          ),
        ),
      );

  Widget buildusers() => ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          call() {
            String phone = "tel:" + user.number;
            launch(phone);
          }

          changeColor() async {
            bool called;
            if (user.called == false) {
              called = true;
            } else {
              called = false;
            }
            final user1 = NumerosInfo(
              id: user.id,
              number: user.number.toString(),
              called: called,
            );
            await UsersDatabase.instance.updateNum(user1);
            refreshPage();
          }

          return GestureDetector(
              onTap: () async {
                changeColor();
              },
              child: ListTile(
                leading: InkWell(
                  onTap: () async {
                    call();
                    changeColor();
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
                      IconButton(
                        onPressed: () async {
                          final dateTime = DateTime.now();
                          final user1 = NumerosInfo2(
                            number: user.number.toString(),
                            called: false,
                            data: DateTime.now(),
                          );
                          final user2 = NumerosInfo(
                            id: user.id,
                            number: user.number.toString(),
                            called: true,
                          );
                          await UsersDatabase.instance.updateNum(user2);
                          await UsersDatabase.instance.createNum2(user1);
                          await UsersDatabase.instance.deleteNum(user.id);
                          //refreshUsers();
                          setState(() {
                            color = Colors.black;
                          });
                          await refreshPage();
                        },
                        icon: Icon(Icons.phone_callback),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.NUM_TO_REV,
                            arguments: user,
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
                                  FlatButton(
                                    child: Text('Não'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('Sim'),
                                    onPressed: () async {
                                      //await _NumCardWidgetState().call();
                                      await UsersDatabase.instance
                                          .deleteNum(user.id);
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
                ),
              ));
        },
      );
}
