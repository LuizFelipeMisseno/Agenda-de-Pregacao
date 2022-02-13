import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revisitas/Routes/app_routes.dart';
import 'package:revisitas/User/UserEst.dart';
import 'package:revisitas/User/Users.dart';
import 'package:revisitas/provider/BaseDeDados.dart';
import 'package:revisitas/services/NotifyManager.dart';

class Cadastro2 extends StatefulWidget {
  final EstInfo user;

  const Cadastro2({Key key, this.user}) : super(key: key);

  @override
  _Cadastro2 createState() => _Cadastro2();
}

class _Cadastro2 extends State<Cadastro2> {
  final _formKey = GlobalKey<FormState>();
  final Map<dynamic, dynamic> _formData = {};

  void _loadFormData(EstInfo user) {
    if (user != null) {
      _formData['id'] = user.id;
      _formData['name'] = user.name;
      _formData['number'] = user.number;
      _formData['description'] = user.description;
      _formData['data'] = user.data;
      _formData['day'] = user.day;
      _formData['idN'] = user.idN;
      _formData['notif'] = user.notif;
    }
  }

  DateTime _dateTime;

  var agora1 =
      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

  @override
  Widget build(BuildContext context) {
    final EstInfo user = ModalRoute.of(context).settings.arguments;

    UserInfo user1 = UserInfo(id: user.id, idN: user.idN);
    _loadFormData(user);

    if (_formData['notif'] == null) {
      _formData['notif'] = false;
    }

    if (_dateTime != null) {
      _formData['data'] = _dateTime;
    }

    if (_formData['data'] == null) {
      _formData['data'] = _dateTime;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Estudo'),
        actions: <Widget>[
          Consumer<NotificationService>(
            builder: (context, model, _) => IconButton(
              onPressed: () async {
                addOrUpdateUser();
                await UsersDatabase.instance.delete(user1.id);
                model.cancel(user1.idN);
              },
              icon: Icon(Icons.save),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: _formData['name'],
                  decoration: InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Insira um nome';
                    }
                    return null;
                  },
                  onSaved: (value) => _formData['name'] = value,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: _formData['number'],
                  decoration: InputDecoration(labelText: 'Número'),
                  onSaved: (value) => _formData['number'] = value,
                ),
                TextFormField(
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  initialValue: _formData['description'],
                  decoration: InputDecoration(
                    /* contentPadding: EdgeInsets.all(15), */
                    labelText: 'Anotações',
                  ),
                  onSaved: (value) => _formData['description'] = value,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate:
                                _dateTime == null ? DateTime.now() : _dateTime,
                            firstDate: DateTime(2018),
                            lastDate: DateTime(2040),
                            locale: Locale("pt", "BR"),
                          ).then((date) {
                            setState(() {
                              _formData['data'] = date;
                              _dateTime = date;
                            });
                          });
                        },
                        icon: Icon(
                          Icons.date_range_rounded,
                        ),
                      ),
                      Text(
                        _formData['data'] == null
                            ? '$agora1'
                            : '${_formData['data'].day}/${_formData['data'].month}/${_formData['data'].year}',
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addOrUpdateUser() async {
    final isValid = _formKey.currentState.validate();

    if (isValid) {
      _formKey.currentState.save();
      final isUpdating = widget.user != null;

      if (isUpdating) {
        await updateEst();
      } else {
        await addEst();
      }

      await Navigator.of(context).pushNamedAndRemoveUntil(
        '/estudos',
        ModalRoute.withName('/'),
      );
    }
  }

  Future updateEst() async {
    final user = widget.user.copy(
      id: _formData['id'],
      notif: false,
      number: _formData['number'],
      name: _formData['name'],
      description: _formData['description'],
      data: _formData['data'],
      day: _formData['day'],
      idN: _formData['idN'],
      hour: _formData['hour'],
      minute: _formData['minute'],
    );

    await UsersDatabase.instance.updateEst(user);
  }

  Future addEst() async {
    if (_formData['data'] == null) {
      _formData['data'] = DateTime.now();
    }
    final user = EstInfo(
      id: _formData['id'],
      notif: false,
      number: _formData['number'],
      name: _formData['name'],
      description: _formData['description'],
      data: _formData['data'],
      day: _formData['day'],
      idN: _formData['idN'],
      hour: _formData['hour'],
      minute: _formData['minute'],
    );

    await UsersDatabase.instance.createEst(user);
  }
}




/* import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revisitas/User/Users.dart';
import 'package:revisitas/provider/lista.dart';

class Cadastro2 extends StatefulWidget {
  @override
  _Cadastro2 createState() => _Cadastro2();
}

class _Cadastro2 extends State<Cadastro2> {
  final _form = GlobalKey<FormState>();
  final Map<dynamic, dynamic> _formData = {};

  void _loadFormData(User user) {
    if (user != null) {
      _formData['id'] = user.id;
      _formData['nome'] = user.nome;
      _formData['numero'] = user.numero;
      _formData['anotacoes'] = user.anotacoes;
      _formData['data'] = user.data;
      _formData['dia'] = user.dia;
      _formData['not'] = user.idN;
      _formData['active'] = user.not;
    }
  }

  DateTime _dateTime;

  var agora1 =
      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

  @override
  Widget build(BuildContext context) {
    final User user = ModalRoute.of(context).settings.arguments;
    _loadFormData(user);

    if (_dateTime != null) {
      _formData['data'] = _dateTime;
    }

    if (_formData['data'] == null) {
      _formData['data'] = _dateTime;
    } else {}

    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Revisita'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              final isValid = _form.currentState.validate();

              if (_formData['data'] == null) {
                _formData['data'] = DateTime.now();
              }

              if (isValid) {
                _form.currentState.save();
                Provider.of<Users>(context, listen: false).put(
                  User(
                    _formData['nome'],
                    _formData['numero'],
                    _formData['id'],
                    _formData['anotacoes'],
                    _formData['data'],
                    _formData['dia'],
                    _formData['not'],
                    _formData['active'],
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Form(
            key: _form,
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: _formData['nome'],
                  decoration: InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Insira um nome';
                    }
                    return null;
                  },
                  onSaved: (value) => _formData['nome'] = value,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: _formData['numero'],
                  decoration: InputDecoration(labelText: 'Número'),
                  onSaved: (value) => _formData['numero'] = value,
                ),
                TextFormField(
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  initialValue: _formData['anotacoes'],
                  decoration: InputDecoration(
                    /* contentPadding: EdgeInsets.all(15), */
                    labelText: 'Anotações',
                  ),
                  onSaved: (value) => _formData['anotacoes'] = value,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate:
                                _dateTime == null ? DateTime.now() : _dateTime,
                            firstDate: DateTime(2018),
                            lastDate: DateTime(2040),
                            locale: Locale("pt", "BR"),
                          ).then((date) {
                            setState(() {
                              _formData['data'] = date;
                              _dateTime = date;
                            });
                          });
                        },
                        icon: Icon(
                          Icons.date_range_rounded,
                        ),
                      ),
                      Text(
                        _formData['data'] == null
                            ? '$agora1'
                            : '${_formData['data'].day}/${_formData['data'].month}/${_formData['data'].year}',
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 */