import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revisitas/Routes/app_routes.dart';
import 'package:revisitas/User/UserEst.dart';
import 'package:revisitas/User/Users.dart';
import 'package:revisitas/provider/BaseDeDados.dart';
import 'package:revisitas/services/NotifyManager.dart';

class CadastroEst extends StatefulWidget {
  final EstInfo user;

  const CadastroEst({Key key, this.user}) : super(key: key);

  @override
  _CadastroEst createState() => _CadastroEst();
}

class _CadastroEst extends State<CadastroEst> {
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
      notif: false,
      number: _formData['number'],
      name: _formData['name'],
      description: _formData['description'],
      data: _formData['data'],
      day: _formData['day'],
      idN: _formData['idN'],
    );

    await UsersDatabase.instance.updateEst(user);
  }

  Future addEst() async {
    if (_formData['data'] == null) {
      _formData['data'] = DateTime.now();
    }
    final user = EstInfo(
      notif: false,
      number: _formData['number'],
      name: _formData['name'],
      description: _formData['description'],
      data: _formData['data'],
      day: _formData['day'],
      idN: _formData['idN'],
    );

    await UsersDatabase.instance.createEst(user);
  }
}
