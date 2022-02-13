import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:path/path.dart' as path;
import 'package:http/io_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:revisitas/provider/BaseDeDados.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;

  GoogleHttpClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<http.Response> head(Object url, {Map<String, String> headers}) =>
      super.head(url, headers: headers..addAll(_headers));
}

class BackupPage extends StatefulWidget {
  BackupPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _BackupPageState createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  final storage = new FlutterSecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn =
      GoogleSignIn(scopes: ['https://www.googleapis.com/auth/drive.appdata']);
  GoogleSignInAccount googleSignInAccount;
  ga.FileList list;
  var signedIn = false;
  var backupMade = true;
  var downloadMade = true;
  var _progressController = true;
  var downloading = false;
  var backingUp = false;
  var cont = 0;
  var hour;
  var count;
  bool isOn = false;
  int alarmId = 1;

  Future<void> loginWithGoogle() async {
    signedIn = await storage.read(key: "signedIn") == "true" ? true : false;
    googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount googleSignInAccount) async {
      if (googleSignInAccount != null) {
        _afterGoogleLogin(googleSignInAccount);
      }
    });
    if (signedIn) {
      try {
        googleSignIn.signInSilently().whenComplete(() => () {});
      } catch (e) {
        storage.write(key: "signedIn", value: "false").then((value) {
          setState(() {
            signedIn = false;
          });
        });
        print('não estava logado');
      }
      checkAutoBackup();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      hour = prefs.getInt('backupTime');
    } else {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn().then((value) => checkAutoBackup());
      _afterGoogleLogin(googleSignInAccount);
    }
  }

  Future<void> _afterGoogleLogin(GoogleSignInAccount gSA) async {
    googleSignInAccount = gSA;
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    print('signInWithGoogle succeeded: $user');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hour = prefs.getInt('backupTime');

    storage.write(key: "signedIn", value: "true").then((value) {
      setState(() {
        signedIn = true;
      });
    });
    setState(() {
      _progressController = true;
    });
    Timer(Duration(seconds: 2), () {
      setState(() {
        _progressController = false;
      });
    });
  }

  void _logoutFromGoogle() async {
    googleSignIn.signOut().then((value) {
      print("User Sign Out");
      storage.write(key: "signedIn", value: "false").then((value) {
        setState(() {
          signedIn = false;
        });
      });
    });
  }

  _uploadFileToGoogleDrive() async {
    final UsersDatabase databaseRepository = new UsersDatabase();
    await databaseRepository.generateBackup(isEncrypted: true);
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/my_file.txt');

    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);
    ga.File fileToUpload = ga.File();
    fileToUpload.parents = ["appDataFolder"];
    fileToUpload.name = path.basename(file.absolute.path);

    var response = await drive.files.create(
      fileToUpload,
      uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
    );

    print(response);
    _listGoogleDriveFiles();
  }

  _uploadFileToGoogleDriveFromOutside() async {
    final UsersDatabase databaseRepository = new UsersDatabase();
    await databaseRepository.generateBackup(isEncrypted: true);
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/my_file.txt');

    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);
    ga.File fileToUpload = ga.File();
    fileToUpload.parents = ["appDataFolder"];
    fileToUpload.name = path.basename(file.absolute.path);

    var response = await drive.files.create(
      fileToUpload,
      uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
    );

    print(response);
  }

  Future<void> updateGoogleDriveFilesFromOutside() async {
    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);
    drive.files.list(spaces: 'appDataFolder').then((value) {
      list = value;
      for (var i = 0; i < list.files.length; i++)
        _deleteGoogleDriveFiles(list.files[i].id);
    });
    _uploadFileToGoogleDriveFromOutside();
    //_listGoogleDriveFiles();
  }

  Future<void> updateGoogleDriveFiles() async {
    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);
    drive.files.list(spaces: 'appDataFolder').then((value) {
      list = value;
      for (var i = 0; i < list.files.length; i++)
        _deleteGoogleDriveFiles(list.files[i].id);
    });
    _uploadFileToGoogleDrive();
    //_listGoogleDriveFiles();
  }

  Future<void> _listGoogleDriveFiles() async {
    if (signedIn == true) {
      var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
      var drive = ga.DriveApi(client);
      drive.files.list(spaces: 'appDataFolder').then((value) {
        setState(() {
          list = value;
        });
        for (var i = 0; i < list.files.length; i++) {
          print("Id: ${list.files[i].id} File Name:${list.files[i].name}");
        }
      });
    }
  }

  Future<void> _deleteGoogleDriveFiles(String id) async {
    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);
    drive.files.delete(id);
  }

  Future<void> _clearGoogleDriveFiles() async {
    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);

    _listGoogleDriveFiles();
    for (var i = 0; i < list.files.length; i++) {
      _deleteGoogleDriveFiles(list.files[i].id);
      print("Id deleted: ${list.files[i].id} File Name:${list.files[i].name}");
    }

    //print('id excluido: ${list.files[0].id}');
  }

  Future<void> _downloadGoogleDriveFile(String gdID) async {
    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);
    ga.Media file = await drive.files
        .get(gdID, downloadOptions: ga.DownloadOptions.FullMedia);
    print(file.stream);

    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    final saveFile = File('${directory.path}/my_file.txt');
    List<int> dataStore = [];
    file.stream.listen((data) {
      print("DataReceived: ${data.length}");
      dataStore.insertAll(dataStore.length, data);
    }, onDone: () {
      print("Task Done");
      saveFile.writeAsBytes(dataStore);
      _restoreBackup();
      print("File saved at ${saveFile.path}");
    }, onError: (error) {
      print("Some Error");
    });
  }

  _restoreBackup() async {
    final UsersDatabase databaseRepository = new UsersDatabase();

    await databaseRepository.clearAllTables();

    await databaseRepository.restoreBackup(isEncrypted: true);
  }

  List<Widget> generateFilesWidget() {
    List<Widget> listItem = List<Widget>();
    if (list != null) {
      for (var i = 0; i < list.files.length; i++) {
        listItem.add(Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.05,
              child: Text('${i + 1}'),
            ),
            Expanded(
              child: Text(list.files[i].name),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              child: FlatButton(
                child: Text(
                  'Download',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.indigo,
                onPressed: () {
                  /* _downloadGoogleDriveFile(
                      list.files[i].name, list.files[i].id); */
                },
              ),
            ),
          ],
        ));
      }
    }
    return listItem;
  }

  checkAutoBackup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getInt('backupTime') == null) {
      prefs.setInt('backupTime', 00);
    }
  }

  @override
  void initState() {
    Timer(Duration(seconds: 3), () {
      setState(() {
        _progressController = false;
      });
    });
    tableIsEmpty();
    loginWithGoogle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup'),
        actions: [
          IconButton(
            onPressed: () {
              _showPopupMenu();
            },
            icon: Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _progressController,
        opacity: 0.2,
        child: FutureBuilder(
          future: getProfileImage(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Center(child: snapshot.data),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 180,
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Nenhum usuário conectado',
                          style: TextStyle(
                            fontSize: 23,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: InkWell(
                          onTap: () {
                            loginWithGoogle();
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(2),
                              ),
                              color: Colors.blue,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/image/google_logo.png',
                                    scale: 2.0,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Entrar com o Google',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _showPopupMenu() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(1, 0, 0, 1),
      items: [
        PopupMenuItem<String>(
          child: TextButton(
            onPressed: () async {
              _clearGoogleDriveFiles();
              setState(() {
                backupMade = true;
              });

              await Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                ModalRoute.withName('/configurações'),
              );
            },
            child: Text(
              'Excluir backup',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
      elevation: 8.0,
    );
  }

  getProfileImage() async {
    final FirebaseUser currentUser = await _auth.currentUser();
    if (currentUser.photoUrl != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 15),
          CircleAvatar(
            radius: 90.0,
            backgroundImage: NetworkImage(currentUser.photoUrl),
          ),
          SizedBox(height: 10),
          Text(
            currentUser.displayName,
            style: TextStyle(fontSize: 25),
          ),
          SizedBox(height: 10),
          Text(
            currentUser.email,
            style: TextStyle(fontSize: 15),
          ),
          hasBackup(),
          SizedBox(height: 10),
          ListTile(
            title: Text('Recuperar dados'),
            leading: downloading
                ? CircularProgressIndicator()
                : Icon(
                    downloadMade
                        ? Icons.cloud_download
                        : Icons.cloud_done_rounded,
                    size: 35.0,
                    color: downloadMade ? Colors.grey : Colors.green,
                  ),
            onTap: () {
              print(count);
              count > 0
                  ? showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Atenção'),
                        content: Text(
                            'Seus dados atuais serão apagados e substituídos pelo backup, deseja prosseguir?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              downloading = true;

                              _listGoogleDriveFiles();
                              _downloadGoogleDriveFile(list.files[0].id);
                              Navigator.of(context).pop();
                              Timer(Duration(seconds: 2, milliseconds: 50), () {
                                setState(() {
                                  downloadMade = false;
                                  downloading = false;
                                });
                              });
                            },
                            child: Text('Sim'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancelar'),
                          ),
                        ],
                      ),
                    )
                  : recuperar();
            },
          ),
          ListTile(
            title: Text('Fazer backup agora'),
            leading: backingUp
                ? CircularProgressIndicator()
                : Icon(
                    backupMade ? Icons.backup : Icons.cloud_done_rounded,
                    size: 35.0,
                    color: backupMade ? Colors.grey : Colors.green,
                  ),
            subtitle: list.files.isEmpty ? Text('Recomendado!') : null,
            onTap: () {
              backingUp = true;

              Timer(Duration(seconds: 2, milliseconds: 50), () {
                setState(() {
                  backupMade = false;
                  backingUp = false;
                });
              });
              updateGoogleDriveFiles();
              setState(() {
                backupMade = false;
                cont = 0;
              });
            },
          ),
          /* ListTile(
            title: Text(
              'Backup para o Drive',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              'O backup é feito diariamente às 00:00',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            leading: Icon(
              Icons.access_time,
              size: 35.0,
            ),
            onTap: () {},
          ), */
          SizedBox(
            height: 10,
          ),
          /* Align(
            child: Text(
              '              Backup automático às:',
              style: TextStyle(fontSize: 16),
            ),
            alignment: Alignment.centerLeft,
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            width: MediaQuery.of(context).size.width,
            child: dropList(),
          ), */
          SizedBox(
            height: 10,
          ),
          TextButton(
            child: Text(
              'Sair da Conta',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onPressed: () {
              _logoutFromGoogle();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    } else {
      return Icon(Icons.account_circle, size: 100);
    }
  }

  recuperar() {
    downloading = true;

    Timer(Duration(seconds: 2, milliseconds: 50), () {
      setState(() {
        downloadMade = false;
        downloading = false;
      });
    });
    _listGoogleDriveFiles();
    _downloadGoogleDriveFile(list.files[0].id);
  }

  Future<int> tableIsEmpty() async {
    final db = await openDatabase('notes.db');
    count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM notes'),
        ) +
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM notes_est'),
        ) +
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM numbers'),
        ) +
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM numbers2'),
        );
    return count;
  }

  test() async {}

  dropList() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.access_time,
          size: 36,
        ),
      ),
      hint: hour < 10
          ? Text(
              '0' '$hour' ':00',
              style: TextStyle(
                fontSize: 16,
              ),
            )
          : Text(
              '$hour' ':00',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
      style: const TextStyle(color: Colors.black),
      onChanged: (int newValue) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('backupTime', newValue);
/*         AndroidAlarmManager.cancel(alarmId).then(
          (value) => AndroidAlarmManager.periodic(
            Duration(hours: 24),
            alarmId,
            fireAlarm,
            startAt: DateTime(
              DateTime.now().year,
              DateTime.now().month,
              newValue > DateTime.now().hour
                  ? DateTime.now().day
                  : DateTime.now().day + 1,
              newValue,
              00,
            ),
          ),
        );

        AndroidAlarmManager.cancel(alarmId);
 */
      },
      items: <int>[00, 07, 12, 17, 22].map<DropdownMenuItem<int>>(
        (int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: value < 10 ? Text('0' '$value' ':00') : Text('$value' ':00'),
          );
        },
      ).toList(),
    );
  }

  hasBackup() {
    if (list == null) {
      _listGoogleDriveFiles();
    }

    if (list.files.isNotEmpty) {
      return Icon(
        Icons.cloud_done_outlined,
        color: Colors.green,
        size: 70.0,
      );
    } else {
      return Icon(
        Icons.cloud_off,
        color: Colors.red,
        size: 70.0,
      );
    }
  }
}

_uploadFileToGoogleDrive(GoogleSignInAccount googleSignInAccount) async {
  final UsersDatabase databaseRepository = new UsersDatabase();
  await databaseRepository.generateBackup(isEncrypted: true);
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/my_file.txt');

  var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
  var drive = ga.DriveApi(client);
  ga.File fileToUpload = ga.File();
  fileToUpload.parents = ["appDataFolder"];
  fileToUpload.name = path.basename(file.absolute.path);

  var response = await drive.files.create(
    fileToUpload,
    uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
  );

  print(response);
}

Future<void> _afterGoogleLogin(
    GoogleSignInAccount gSA, FirebaseAuth _auth, storage) async {
  var signedIn;
  GoogleSignInAccount googleSignInAccount;

  googleSignInAccount = gSA;
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  print('signInWithGoogle succeeded: $user');
  uploadFiles(googleSignInAccount);

  storage.write(key: "signedIn", value: "true").then((value) {
    signedIn = true;
  });
}

Future<void> _deleteGoogleDriveFiles(
    String id, GoogleSignInAccount googleSignInAccount) async {
  var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
  var drive = ga.DriveApi(client);
  drive.files.delete(id);
}

Future<void> uploadFiles(GoogleSignInAccount googleSignInAccount) async {
  var list;
  var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
  var drive = ga.DriveApi(client);
  drive.files.list(spaces: 'appDataFolder').then((value) {
    list = value;
    for (var i = 0; i < list.files.length; i++)
      _deleteGoogleDriveFiles(list.files[i].id, googleSignInAccount);
  });
  _uploadFileToGoogleDrive(googleSignInAccount);
  //_listGoogleDriveFiles();
}

automaticUpload() async {
  final storage = new FlutterSecureStorage();
  final GoogleSignIn googleSignIn =
      GoogleSignIn(scopes: ['https://www.googleapis.com/auth/drive.appdata']);
  ga.FileList list;
  var signedIn = false;
  GoogleSignInAccount googleSignInAccount;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  signedIn = await storage.read(key: "signedIn") == "true" ? true : false;
  googleSignIn.onCurrentUserChanged
      .listen((GoogleSignInAccount googleSignInAccount) async {
    if (googleSignInAccount != null) {
      _afterGoogleLogin(googleSignInAccount, _auth, storage);
    }
  });
  if (signedIn) {
    try {
      googleSignIn.signInSilently().whenComplete(() => () {});
    } catch (e) {
      storage.write(key: "signedIn", value: "false").then((value) {
        signedIn = false;
      });
      print('não estava logado');
    }
  } else {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    _afterGoogleLogin(googleSignInAccount, _auth, storage);
  }
}

void fireAlarm() {
  automaticUpload();
  print('Upload feito');
}
