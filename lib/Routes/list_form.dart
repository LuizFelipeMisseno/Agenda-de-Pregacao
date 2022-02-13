import 'package:flutter/material.dart';
import 'package:revisitas/Routes/app_routes.dart';
import 'package:revisitas/Routes/listas.dart';
import 'package:revisitas/User/Users.dart';
import 'package:revisitas/provider/BaseDeDados.dart';
import 'package:loading_overlay/loading_overlay.dart';

class ListForm extends StatefulWidget {
  @override
  _UserFormState3 createState() => _UserFormState3();
}

class _UserFormState3 extends State<ListForm> {
  final _form = GlobalKey<FormState>();
  final Map<dynamic, dynamic> _formData = {};

  void _loadFormData(NumerosInfo numerosList) {
    if (numerosList != null) {
      _formData['id'] = numerosList.id;
      _formData['number'] = numerosList.number;
    }
    var number = _formData['number'];
  }

  var quant;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final NumerosInfo numerosList = ModalRoute.of(context).settings.arguments;
    _loadFormData(numerosList);

    return Scaffold(
      appBar: AppBar(
        title: Text('Criar nova lista'),
      ),
      body: LoadingOverlay(
        opacity: 0.2,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Form(
                  key: _form,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                          keyboardType: TextInputType.number,
                          initialValue: _formData['number'],
                          decoration: InputDecoration(
                              labelText: 'Digite aqui o primeiro número'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Insira um número';
                            }
                            if (value.trim().length < 9) {
                              return 'No mínimo 9 dígitos';
                            }
                            return null;
                          },
                          onSaved: (value) => _formData['number'] =
                              value.replaceAll(new RegExp(r'[^\w\s]+'), '')),
                      SizedBox(
                        height: 30,
                      ),
                      DropdownButtonFormField(
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Selecione uma quantidade';
                          }
                          return null;
                        },
                        value: quant,
                        items: <String>[
                          '1',
                          '10',
                          '50',
                          '100',
                          '500',
                          '1000',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        hint: Text('Selecione a quantidade'),
                        onChanged: (value1) {
                          setState(
                            () {
                              quant = value1;
                            },
                          );
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        height: 50,
                        width: 180,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                          ),
                          child: Text(
                            'Criar Lista',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                          onPressed: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            final isValid = _form.currentState.validate();
                            _form.currentState.save();

                            if (isValid) {
                              var quant1 = int.parse(quant);
                              var number = int.parse(_formData['number']);
                              var numero = number;
                              var i = 0;
                              while (i <= quant1 - 1) {
                                setState(() {
                                  isLoading = true;
                                });
                                final user = NumerosInfo(
                                  number: numero.toString(),
                                  called: false,
                                );
                                await UsersDatabase.instance.createNum(user);

                                i++;
                                numero++;
                              }
                              setState(() {
                                isLoading = false;
                              });

                              await Navigator.of(context)
                                  .pushNamedAndRemoveUntil(
                                '/listas',
                                ModalRoute.withName('/'),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
        isLoading: isLoading,
      ),
    );
  }
}
