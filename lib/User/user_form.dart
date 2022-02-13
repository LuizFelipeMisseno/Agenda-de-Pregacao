import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:revisitas/Routes/app_routes.dart';
import 'package:revisitas/User/Users.dart';
import 'package:revisitas/componentes/dayPicker.dart';
import 'package:revisitas/provider/BaseDeDados.dart';
import 'package:revisitas/services/NotifyManager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class UserForm extends StatefulWidget {
  final UserInfo user;
  final int userId;

  const UserForm({
    Key key,
    this.user,
    this.userId,
  }) : super(key: key);

  @override
  UserFormState createState() => UserFormState();
}

class UserFormState extends State<UserForm> {
  final _form = GlobalKey<FormState>();
  final Map<dynamic, dynamic> _formData = {};
  DDDdataInfo ddd;

  @override
  void initState() {
    Provider.of<NotificationService>(context, listen: false).initialize();
    super.initState();
    read();
  }

  Future read() async {
    ddd = await UsersDatabase.instance.readDDD(1);
  }

  void _loadFormData(UserInfo user) {
    if (user != null) {
      _formData['id'] = user.id;
      _formData['name'] = user.name;
      _formData['number'] = user.number;
      _formData['description'] = user.description;
      _formData['data'] = user.data;
      _formData['day'] = user.day;
      _formData['idN'] = user.id;
      _formData['notif'] = user.notif;
      _formData['hour'] = user.hour;
      _formData['minute'] = user.minute;
    }
  }

  call() {
    String phone = "tel:" + _formData['number'];
    launch(phone);
  }

  whatsapp() {
    String wpp;
    if (_formData['number'].toString().length > 9) {
      wpp = 'https://api.whatsapp.com/send?phone=55‪${_formData['number']}';
    } else {
      wpp =
          'https://api.whatsapp.com/send?phone=55‪${ddd.number}${_formData['number']}';
    }
    launch(wpp);
  }

  DateTime _dateTime;
  DateTime dateTime = DateTime.now();

  var dayOfWeek;
  var hour;
  var minute;
  bool isPressed;
  var data1;
  bool saved = true;

  day() {
    if (dayOfWeek == null) {
      dayOfWeek = _formData['day'];
    }
    if (dayOfWeek == 1) {
      data1 = Day.monday;
    }
    if (dayOfWeek == 2) {
      data1 = Day.tuesday;
    }
    if (dayOfWeek == 3) {
      data1 = Day.wednesday;
    }
    if (dayOfWeek == 4) {
      data1 = Day.thursday;
    }
    if (dayOfWeek == 5) {
      data1 = Day.friday;
    }
    if (dayOfWeek == 6) {
      data1 = Day.saturday;
    }
    if (dayOfWeek == 0) {
      data1 = Day.sunday;
    }
    return data1;
  }

  change(bool value) {
    isPressed = value;
  }

  var agora1 =
      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

  @override
  Widget build(BuildContext context) {
    final UserInfo user = ModalRoute.of(context).settings.arguments;
    _loadFormData(user);

    if (isPressed == null) {
      isPressed = _formData['notif'];
    }

    if (dayOfWeek == null) {
      dayOfWeek = _formData['day'];
    }

    if (_dateTime != null) {
      _formData['data'] = _dateTime;
    }

    if (_formData['data'] == null) {
      _formData['data'] = _dateTime;
    }

    popScope() async {
      if (saved == false) {
        final value = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Deseja sair sem salvar?'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Salvar'),
                  onPressed: () async {
                    save();
                    await Navigator.of(context).pushNamedAndRemoveUntil(
                      '/rev_page',
                      ModalRoute.withName('/'),
                    );
                  },
                ),
                FlatButton(
                  child: Text('Sair'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      }
      {
        await Navigator.of(context).pushNamedAndRemoveUntil(
          '/rev_page',
          ModalRoute.withName('/'),
        );
      }
    }

    String hourAndMinute = '0${DateTime.now().minute}';
    String anotacao =
        '[${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}   ${DateTime.now().hour}:${DateTime.now().minute.toString().length == 2 ? DateTime.now().minute : hourAndMinute}]';
    String text = '${_formData['description']}\n\n$anotacao: ';

    return WillPopScope(
      onWillPop: () {
        return popScope();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Editar revisita'),
          actions: <Widget>[
            Consumer<NotificationService>(
              builder: (context, model, _) => SwitchTile(
                user: user,
                userId: user.id,
                status: isPressed,
              ),
            ),
            IconButton(
              onPressed: () async {
                await save();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/rev_page',
                  ModalRoute.withName('/'),
                );
              },
              icon: Icon(Icons.save),
            ),
            Consumer<NotificationService>(
              builder: (context, model, _) => IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Excluir revisita'),
                      content: Text('Tem certeza?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Não'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          onPressed: () async {
                            await UsersDatabase.instance.delete(user.id);
                            model.cancel(_formData['idN']);
                            Navigator.of(context).pop();
                            await Navigator.of(context).pushNamedAndRemoveUntil(
                              '/rev_page',
                              ModalRoute.withName('/'),
                            );
                          },
                          child: Text('Sim'),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Form(
              key: _form,
              child: Column(
                children: [
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
                    onChanged: (value) => saved = false,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    initialValue: _formData['number'],
                    decoration: InputDecoration(labelText: 'Número'),
                    onSaved: (value) => _formData['number'] = value,
                    onChanged: (value) => saved = false,
                  ),
                  TextFormField(
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    initialValue: text,
                    decoration: InputDecoration(
                      /* contentPadding: EdgeInsets.all(15), */
                      labelText: 'Anotações',
                    ),
                    onSaved: (value) => _formData['description'] = value,
                    onChanged: (value) => saved = false,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: <Widget>[
                      Text('Último contato:'),
                      SizedBox(
                        width: 70,
                      ),
                    ],
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            showDatePicker(
                              context: context,
                              initialDate: _formData['data'] == null
                                  ? DateTime.now()
                                  : _formData['data'],
                              firstDate: DateTime(2018),
                              lastDate: DateTime(2040),
                              locale: Locale("pt", "BR"),
                            ).then((date) async {
                              setState(() {
                                _formData['data'] = date;
                                _dateTime = date;
                              });
                              final user1 = user.copy(
                                data: date,
                              );
                              await UsersDatabase.instance.update(user1);
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
                        ),
                        SizedBox(
                          width: 70,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).size.height * 0.6,
                    child: Consumer<NotificationService>(
                      builder: (context, model, _) => Align(
                        alignment: Alignment.bottomCenter,
                        child: TextButton(
                          onPressed: () {
                            _form.currentState.save();

                            final user1 = EstInfo(
                              id: _formData['id'],
                              notif: _formData['notif'],
                              number: _formData['number'],
                              name: _formData['name'],
                              description: _formData['description'],
                              data: _formData['data'],
                              day: _formData['day'],
                              idN: _formData['idN'],
                              hour: _formData['hour'],
                              minute: _formData['minute'],
                            );

                            Navigator.of(context).pushNamed(
                              AppRoutes.CAD2,
                              arguments: user1,
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                          ),
                          child: Text(
                            'Cadastrar como \n'
                            'estudo',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              child: Icon(Icons.phone),
              onPressed: () async {
                call();
                setState(() {
                  _dateTime = DateTime.now();
                });
                final user1 = user.copy(
                  data: _dateTime,
                );
                await UsersDatabase.instance.update(user1);
              },
              heroTag: null,
            ),
            SizedBox(
              height: 10,
            ),
            FloatingActionButton(
              elevation: 3.0,
              child: Image.asset('assets/image/whatsapp.png'),
              backgroundColor: Colors.green,
              onPressed: () {
                whatsapp();
              },
              heroTag: null,
            ),
          ],
        ),
      ),
    );
  }

  timer() {
    Timer searchOnStoppedTyping;
    const duration = Duration(
        seconds: 3); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping.cancel()); // clear timer
    }
    {
      setState(() => searchOnStoppedTyping = new Timer(duration, () => save()));
    }
  }

  save() async {
    final UserInfo user = ModalRoute.of(context).settings.arguments;
    _loadFormData(user);
    saved = true;
    final isValid = _form.currentState.validate();
    if (_formData['data'] == null) {
      _formData['data'] = DateTime.now();
    }

    _formData['day'] = dayOfWeek;
    _formData['hour'] = hour;
    _formData['minute'] = minute;
    _formData['data'] = _dateTime;

    if (isPressed != null) {
      _formData['notif'] = isPressed;
    }

    if (isValid) {
      _form.currentState.save();
      final isUpdating = user != null;
      if (isUpdating) {
        final user1 = user.copy(
          notif: _formData['notif'],
          number: _formData['number'],
          name: _formData['name'],
          description: _formData['description'],
          data: _formData['data'],
          day: _formData['day'],
          idN: _formData['idN'],
          hour: _formData['hour'],
          minute: _formData['minute'],
        );
        await UsersDatabase.instance.update(user1);
      }
      print('salvo');
    }
  }
}

class SwitchTile extends StatefulWidget {
  final UserInfo user;
  final int userId;
  final bool status;

  const SwitchTile({
    Key key,
    this.user,
    this.userId,
    this.status,
  }) : super(key: key);
  @override
  _SwitchTileState createState() => _SwitchTileState();
}

class _SwitchTileState extends State<SwitchTile> {
  final _form = GlobalKey<FormState>();
  final Map<dynamic, dynamic> _formData = {};

  DateTime _dateTime;
  DateTime dateTime = DateTime.now();

  bool _toggled;
  var dayOfWeek;
  var hour;
  var minute;
  bool isPressed;
  var data1;
  var _color;

  day() {
    if (dayOfWeek == null) {
      dayOfWeek = _formData['day'] == null ? 3 : _formData['day'];
    }
    if (dayOfWeek == 1) {
      data1 = DateTime.monday;
    }
    if (dayOfWeek == 2) {
      data1 = DateTime.tuesday;
    }
    if (dayOfWeek == 3) {
      data1 = DateTime.wednesday;
    }
    if (dayOfWeek == 4) {
      data1 = DateTime.thursday;
    }
    if (dayOfWeek == 5) {
      data1 = DateTime.friday;
    }
    if (dayOfWeek == 6) {
      data1 = DateTime.saturday;
    }
    if (dayOfWeek == 0) {
      data1 = DateTime.sunday;
    }
    return data1;
  }

  timer() {
    Timer searchOnStoppedTyping;
    const duration = Duration(
        seconds: 3); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping.cancel()); // clear timer
    }
    {
      setState(() => searchOnStoppedTyping = new Timer(duration, () => save()));
    }
  }

  save() async {
    final UserInfo user = ModalRoute.of(context).settings.arguments;
    _loadFormData(user);
    if (_formData['data'] == null) {
      _formData['data'] = DateTime.now();
    }

    _formData['day'] = dayOfWeek;
    _formData['hour'] = hour;
    _formData['minute'] = minute;

    if (_toggled != null) {
      _formData['notif'] = _toggled;
    }

    _form.currentState == null ? null : _form.currentState.save();
    final user1 = user.copy(
      notif: _formData['notif'],
      number: _formData['number'],
      name: _formData['name'],
      description: _formData['description'],
      data: _formData['data'],
      day: _formData['day'],
      idN: _formData['idN'],
      hour: _formData['hour'],
      minute: _formData['minute'],
    );
    await UsersDatabase.instance.update(user1);
  }

  dayOfTheWeek() => SizedBox(
        height: 170,
        width: 170,
        child: CupertinoTheme(
          data: CupertinoThemeData(
            textTheme: CupertinoTextThemeData(
              pickerTextStyle: TextStyle(
                fontSize: 35,
                color: Colors.black,
              ),
            ),
          ),
          child: Consumer<NotificationService>(
            builder: (context, model, _) => CupertinoPicker(
              scrollController: new FixedExtentScrollController(
                initialItem:
                    _formData['day'] == null ? dayOfWeek : _formData['day'],
              ),
              itemExtent: 40,
              children: [
                Center(child: Text('Dom.')),
                Center(child: Text('Seg.')),
                Center(child: Text('Ter.')),
                Center(child: Text('Qua.')),
                Center(child: Text('Qui.')),
                Center(child: Text('Sex.')),
                Center(child: Text('Sáb.')),
              ],
              onSelectedItemChanged: (dateTime) {
                dayOfWeek = dateTime;
                timer();

                // model.cancel(_formData['idN']);

                day();
                if (_toggled == null && widget.user.notif == true ||
                    _toggled == true) {
                  setState(
                    () {
                      model.scheduleNotification(
                        _formData['idN'],
                        'Dia de revisita',
                        'Hoje é dia da revisita de ${_formData['name']}',
                        data1 == null ? _formData['day'] : data1,
                        hour == null ? _formData['hour'] : hour,
                        minute == null ? _formData['minute'] : minute,
                      );
                    },
                  );
                } else {
                  print('Falha');
                }
              },
            ),
          ),
        ),
      );

  Widget buildTimePicker() => SizedBox(
        height: 170,
        width: 170,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              ':',
              style: TextStyle(
                fontSize: 40,
              ),
            ),
            CupertinoTheme(
              data: CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(
                    fontSize: 35,
                    color: Colors.black,
                  ),
                ),
              ),
              child: Center(
                child: Consumer<NotificationService>(
                  builder: (context, model, _) => CupertinoDatePicker(
                      use24hFormat: true,
                      initialDateTime: DateTime(
                          0,
                          0,
                          0,
                          _formData['hour'] == null ? 12 : _formData['hour'],
                          _formData['minute'] == null
                              ? 30
                              : _formData['minute'],
                          0),
                      mode: CupertinoDatePickerMode.time,
                      minuteInterval: 1,
                      onDateTimeChanged: (dateTime) {
                        hour = dateTime.hour;
                        minute = dateTime.minute;
                        timer();
                        // model.cancel(_formData['idN']);
                        if (_toggled == null && widget.user.notif == true ||
                            _toggled == true) {
                          setState(
                            () {
                              model.scheduleNotification(
                                _formData['idN'],
                                'Dia de revisita',
                                'Hoje é dia da revisita de ${_formData['name']}',
                                day(),
                                dateTime.hour,
                                dateTime.minute,
                              );
                            },
                          );
                        } else {
                          print('Falhou');
                        }
                      }),
                ),
              ),
            ),
          ],
        ),
      );

  DateTime getDateTime() {
    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day, now.hour, 0);
  }

  void _loadFormData(UserInfo user) {
    if (user != null) {
      _formData['id'] = user.id;
      _formData['name'] = user.name;
      _formData['number'] = user.number;
      _formData['description'] = user.description;
      _formData['data'] = user.data;
      _formData['day'] = user.day;
      _formData['idN'] = user.id;
      _formData['notif'] = user.notif;
      _formData['hour'] = user.hour;
      _formData['minute'] = user.minute;
    }
  }

  void _changeColor(value) {
    setState(() {
      _toggled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadFormData(widget.user);
    _color = _formData['notif'];
    bool itsOn;
    if (isPressed == null) {
      isPressed = _formData['notif'];
    }

    if (dayOfWeek == null && _formData['day'] != null) {
      dayOfWeek = _formData['day'];
    }
    if (dayOfWeek == null && _formData['day'] == null) {
      dayOfWeek = DateTime.wednesday;
    }

    if (_dateTime != null) {
      _formData['data'] = _dateTime;
    }

    if (_formData['data'] == null) {
      _formData['data'] = _dateTime;
    }

    return IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Consumer<NotificationService>(
              builder: (context, model, _) => StatefulBuilder(
                builder: (context, setState) => AlertDialog(
                  title: Row(
                    children: [
                      Text('Notificações'),
                      Expanded(
                        child: SwitchListTile(
                          value:
                              _toggled == null ? widget.user.notif : _toggled,
                          onChanged: (bool value) async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            itsOn = prefs.getBool('ativo');
                            if (itsOn == false || itsOn == null) {
                              setState(() {
                                _toggled = value;
                              });
                              _changeColor(value);
                              save();
                              if (_toggled == false) {
                                model.cancel(_formData['idN']);
                              } else {
                                model.scheduleNotification(
                                  _formData['idN'],
                                  'Dia de revisita',
                                  'Hoje é dia da revisita de ${_formData['name']}',
                                  day(),
                                  _formData['hour'] == null
                                      ? hour == null
                                          ? 12
                                          : hour
                                      : _formData['hour'],
                                  _formData['minute'] == null
                                      ? minute == null
                                          ? 30
                                          : minute
                                      : _formData['minute'],
                                );
                                print('Notificação marcada');
                              }
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    Consumer<NotificationService>(
                                  builder: (context, model, _) => AlertDialog(
                                    title: Text('Notificações desativadas'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Deseja ativar novamente?')
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () async {
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                setState(() {
                                                  prefs.setBool('ativo',
                                                      !prefs.getBool('ativo'));
                                                });
                                                setState(() {
                                                  _toggled = value;
                                                });
                                                _changeColor(value);
                                                save();

                                                model.scheduleNotification(
                                                  _formData['idN'],
                                                  'Dia de revisita',
                                                  'Hoje é dia da revisita de ${_formData['name']}',
                                                  day(),
                                                  _formData['hour'] == null
                                                      ? hour == null
                                                          ? 12
                                                          : hour
                                                      : _formData['hour'],
                                                  _formData['minute'] == null
                                                      ? minute == null
                                                          ? 30
                                                          : minute
                                                      : _formData['minute'],
                                                );
                                                Navigator.pop(context);
                                              },
                                              child: Text('Ativar'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('Cancelar'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  content: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: buildTimePicker(),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: dayOfTheWeek(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        icon: Icon(Icons.notifications),
        color: _toggled == null
            ? widget.user.notif
                ? Colors.yellow
                : Colors.white
            : _toggled
                ? Colors.yellow
                : Colors.white //widget.status ? Colors.yellow : Colors.white,
        );
  }

  testDayPicker() {
    return DayPickerSpinner(
      minutesInterval: 5,
      is24HourMode: true,
      normalTextStyle: TextStyle(fontSize: 20, color: Colors.grey),
      highlightedTextStyle: TextStyle(fontSize: 20, color: Colors.black),
      spacing: 40,
      itemHeight: 40,
      isForce2Digits: true,
      onTimeChange: (time) {
        setState(() {
          _dateTime = time;
        });
      },
    );
  }

  testTimePicker() {
    return new Container(
      margin: EdgeInsets.all(7),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            ':',
            style: TextStyle(
              fontSize: 40,
            ),
          ),
          TimePickerSpinner(
            minutesInterval: 5,
            is24HourMode: true,
            normalTextStyle: TextStyle(fontSize: 40, color: Colors.grey),
            highlightedTextStyle: TextStyle(fontSize: 40, color: Colors.black),
            itemHeight: 51,
            isForce2Digits: true,
            onTimeChange: (time) {
              setState(() {
                _dateTime = time;
              });
            },
          ),
        ],
      ),
    );
  }
}
