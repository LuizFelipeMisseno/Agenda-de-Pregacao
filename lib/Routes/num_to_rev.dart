import 'package:flutter/material.dart';
import 'package:revisitas/Routes/app_routes.dart';
import 'package:revisitas/User/Users.dart';
import 'package:revisitas/provider/BaseDeDados.dart';

class Cadastro3 extends StatefulWidget {
  final NumerosInfo user;

  const Cadastro3({Key key, this.user}) : super(key: key);

  @override
  _Cadastro3 createState() => _Cadastro3();
}

class _Cadastro3 extends State<Cadastro3> {
  final _formKey = GlobalKey<FormState>();
  final Map<dynamic, dynamic> _formData = {};

  void _loadFormData(NumerosInfo user) {
    if (user != null) {
      _formData['id'] = user.id;
      _formData['number'] = user.number;
    }
  }

  DateTime _dateTime;

  var agora1 =
      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

  @override
  Widget build(BuildContext context) {
    final NumerosInfo user = ModalRoute.of(context).settings.arguments;

    NumerosInfo2 user2 = NumerosInfo2(id: user.id);

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
        title: Text('Nova Revisita'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              addOrUpdateUser();
              UsersDatabase.instance.deleteNum(user.id);
              UsersDatabase.instance.deleteNum2(user2.id);
            },
            icon: Icon(Icons.save),
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
        await updateUser();
      } else {
        await addUser();
      }

      await Navigator.of(context).pushNamedAndRemoveUntil(
        '/rev_page',
        ModalRoute.withName('/'),
      );
    }
  }

  Future updateUser() async {
    /* final user = widget.user.copy(
      notif: _formData['notif'],
      number: _formData['number'],
      name: _formData['name'],
      description: _formData['description'],
      data: _formData['data'],
      day: _formData['day'],
      idN: _formData['idN'],
    );

    await UsersDatabase.instance.update(user); */
  }

  Future addUser() async {
    if (_formData['data'] == null) {
      _formData['data'] = DateTime.now();
    }
    final user = UserInfo(
      notif: _formData['notif'],
      number: _formData['number'],
      name: _formData['name'],
      description: _formData['description'],
      data: _formData['data'],
      day: _formData['day'],
      idN: _formData['idN'],
    );

    await UsersDatabase.instance.create(user);
  }
}
