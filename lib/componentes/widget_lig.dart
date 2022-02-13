/* import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revisitas/Routes/app_routes.dart';
import 'package:revisitas/User/Users.dart';
import 'package:revisitas/provider/lista.dart';
import 'package:url_launcher/url_launcher.dart';

class UserTile6 extends StatefulWidget {
  final NumerosList numerosList2;

  const UserTile6(this.numerosList2);

  @override
  _UserTile6State createState() => _UserTile6State();
}

class _UserTile6State extends State<UserTile6> {
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
          width: 100,
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.NUM_TO_REV,
                    arguments: widget.numerosList2,
                  );
                  Provider.of<NumerosList3>(context, listen: false)
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
                          TextButton(
                            child: Text('Não'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Sim'),
                            onPressed: () {
                              Provider.of<NumerosList3>(context, listen: false)
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
        ));
  }
}
 */