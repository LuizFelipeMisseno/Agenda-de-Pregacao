import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revisitas/Routes/app_routes.dart';
import 'package:revisitas/User/Users.dart';
import 'package:revisitas/User/user_form.dart';
import 'package:revisitas/componentes/barra.dart';
import 'package:revisitas/provider/BaseDeDados.dart';
import 'package:revisitas/services/Config.dart';
import 'package:sqflite/sqflite.dart';

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
                  '${user.number}',
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

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<UserInfo> users;
  DDDdataInfo ddd;
  bool isLoading = false;
  String search;

  @override
  void initState() {
    super.initState();

    refreshUsers();
    readDDDnow();
  }

  void readDDDnow() async {
    this.ddd = await UsersDatabase.instance.readDDD(1);
  }

  Future refreshUsers() async {
    setState(() => isLoading = true);

    this.users = await UsersDatabase.instance.readAllNotes();

    setState(() => isLoading = false);
  }

  Future refreshPage() async {
    setState(() => isLoading = true);

    this.users = await UsersDatabase.instance.readNote(search);

    setState(() => isLoading = false);
  }

  bool searchClicked = false;

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: searchClicked
            ? null
            : Text(
                'Revisitas',
                style: TextStyle(fontSize: 24),
              ),
        actions: [
          searchClicked
              ? Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        left: 55,
                        right: 5,
                        bottom: 2,
                        /* vertical: 5 */
                        top: 6,
                      ),
                      width: MediaQuery.of(context).size.width - 6,
                      child: new TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Pesquisar',
                          //onSearchTextChanged,
                          suffixIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    searchClicked = false;
                                  });
                                  refreshUsers();
                                },
                                icon: Icon(Icons.close),
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                        onChanged: (String text) {
                          setState(() {
                            search = text;
                          });
                          refreshPage();
                          print(users);
                          if (text == null || text.isEmpty) {
                            refreshUsers();
                          }
                        },
                      ),
                    ),
                  ],
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      searchClicked = true;
                    });
                  },
                  icon: Icon(Icons.search),
                )
        ],
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : users.isEmpty
                ? Text(
                    'Nenhuma revisita',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 30),
                  )
                : mediaQueryData.orientation == Orientation.landscape
                    ? buildusersHorizontal()
                    : buildusers(),
      ),
      drawer: Barra(),
      floatingActionButton: FloatingActionButton(
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
                          Navigator.of(context).pushNamed(
                            AppRoutes.CAD,
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
              AppRoutes.CAD,
            );
          }
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildusers() => ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserForm(userId: user.id),
                ),
              );
              refreshUsers();
            },
            child: UserCardWidget(user: user, index: index),
          );
        },
      );
  Widget buildusersHorizontal() => GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.5,
        ),
        /* gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          mainAxisSpacing: 10,
          maxCrossAxisExtent: 200,
          childAspectRatio: 2.0,
        ), */
        padding: EdgeInsets.all(8),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserForm(userId: user.id),
                ),
              );
              refreshUsers();
            },
            child: UserCardWidget(user: user, index: index),
          );
        },
      );
}
