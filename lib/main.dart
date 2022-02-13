import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:revisitas/Home/Home.dart';
import 'package:revisitas/Home/HomePage.dart';
import 'package:revisitas/Routes/CadEst.dart';
import 'package:revisitas/provider/BaseDeDados.dart';
import 'package:revisitas/services/Config.dart';
import 'package:revisitas/Routes/app_routes.dart';
import 'package:revisitas/Routes/cad_estudo.dart';
import 'package:revisitas/Routes/cadastro.dart';
import 'package:revisitas/Routes/est_form.dart';
import 'package:revisitas/Routes/estudos.dart';
import 'package:revisitas/Routes/ligar.dart';
import 'package:revisitas/Routes/list_form.dart';
import 'package:revisitas/Routes/listas.dart';
import 'package:revisitas/Routes/num_to_rev.dart';
import 'package:revisitas/User/user_form.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:revisitas/services/Dowload_Upload.dart';
import 'package:revisitas/services/NotifyManager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //era MyApp
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NotificationService(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale("pt", "BR")],
        title: 'Agenda de Pregação',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Home(),
        routes: {
          AppRoutes.LIST: (_) => NumPage(),
          AppRoutes.HOMEPAGE: (_) => Home(),
          AppRoutes.REVPAGE: (_) => UsersPage(),
          AppRoutes.USER: (_) => UserForm3(),
          AppRoutes.EST: (_) => Estudos(),
          AppRoutes.CAD: (_) => Cadastro(),
          AppRoutes.CAD2: (_) => Cadastro2(),
          AppRoutes.REV: (_) => UserForm(),
          AppRoutes.LISTFORM: (_) => ListForm(),
          AppRoutes.NUM_TO_REV: (_) => Cadastro3(),
          AppRoutes.CXM: (_) => Ligar(),
          AppRoutes.CONFIG: (_) => Config(),
          AppRoutes.CADEST: (_) => CadastroEst(),
          AppRoutes.LOGIN: (_) => BackupPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
