import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revisitas/Routes/app_routes.dart';
import 'package:revisitas/User/Users.dart';

class UserTile4 extends StatelessWidget {
  final NumerosList numerosList;

  const UserTile4(this.numerosList);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.LISTNUM,
          arguments: numerosList,
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
                    padding: EdgeInsets.only(left: 80.0, bottom: 25.0, top: 25),
                    child: Text(
                      '${numerosList.numero}',
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
          ],
        ),
      ),
    );
  }
}
