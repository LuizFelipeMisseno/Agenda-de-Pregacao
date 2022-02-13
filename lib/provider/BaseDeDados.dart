import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:revisitas/User/UserEst.dart';
import 'package:revisitas/User/Users.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:convert' as convert;
import 'package:encrypt/encrypt.dart' as encrypt;

class UsersDatabase {
  UsersDatabase();
  static final UsersDatabase instance = UsersDatabase._init();

  static Database _database;
  static const SECRET_KEY = "2021_PRIVATE_KEY";
  static const DATABASE_VERSION = 1;

  UsersDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDB('notes.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path,
        version: 1, onCreate: _createDB, onUpgrade: onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT';
    final boolType = 'BOOLEAN';
    final integerType = 'INTEGER';

    await db.execute('''
CREATE TABLE $tableNotes ( 
  ${UsersData.id} $idType, 
  ${UsersData.notif} $boolType,
  ${UsersData.number} $textType,
  ${UsersData.name} $textType,
  ${UsersData.description} $textType,
  ${UsersData.data} $textType,
  ${UsersData.day} $integerType,
  ${UsersData.idN} $integerType,
  ${UsersData.hour} $integerType,
  ${UsersData.minute} $integerType
  )
  ''');
    await db.execute('''CREATE TABLE $tableEstNotes ( 
  ${EstData.id} $idType, 
  ${EstData.notif} $boolType,
  ${EstData.number} $textType,
  ${EstData.name} $textType,
  ${EstData.description} $textType,
  ${EstData.data} $textType,
  ${EstData.day} $integerType,
  ${EstData.idN} $integerType,
  ${EstData.hour} $integerType,
  ${EstData.minute} $integerType
  )
  ''');
    await db.execute('''CREATE TABLE $tableNum ( 
  ${Numeros.id} $idType, 
  ${Numeros.number} $textType,
  ${Numeros.called} $boolType
  )
  ''');
    await db.execute('''CREATE TABLE $tableNum2 ( 
  ${Numeros2.id} $idType, 
  ${Numeros2.number} $textType,
  ${Numeros2.called} $boolType,
  ${Numeros2.data} $textType
  )
  ''');
    await db.execute('''CREATE TABLE $tableDDD ( 
  ${DDDdata.id} $idType, 
  ${DDDdata.number} $textType
  )
  ''');
    final user = DDDdataInfo(
      id: 1,
      number: '',
    );
    final id = await db.insert(tableDDD, user.toJson());
    return user.copy(id: id);
  }

  List<String> tables = [
    tableNotes,
    tableEstNotes,
    tableNum,
    tableNum2,
    tableDDD,
  ];

  FutureOr<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (var migration = oldVersion; migration < newVersion; migration++) {
      this._onUpgrades["from_version_${migration}_to_version_${migration + 1}"](
          db);
    }
  }

  Map<String, Function> _onUpgrades = {
    'from_version_1_to_version_2': (Database db) async {
      print('from_version_1_to_version_2');
    },
    'from_version_2_to_version_3': (Database db) async {
      print('from_version_2_to_version_3');
    },
  };

  //Criar Revisita

  Future<UserInfo> create(UserInfo user) async {
    final db = await instance.database;

    // final json = note.toJson();
    // final columns =
    //     '${UsersData.title}, ${UsersData.description}, ${UsersData.time}';
    // final values =
    //     '${json[UsersData.title]}, ${json[UsersData.description]}, ${json[UsersData.time]}';
    // final id = await db
    //     .rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');

    final id = await db.insert(tableNotes, user.toJson());
    return user.copy(id: id);
  }

  //Criar Estudo

  Future<EstInfo> createEst(EstInfo user) async {
    final db = await instance.database;
    final id = await db.insert(tableEstNotes, user.toJson());
    return user.copy(id: id);
  }

  //Criar números

  Future<NumerosInfo> createNum(NumerosInfo user) async {
    final db = await instance.database;
    final id = await db.insert(tableNum, user.toJson());
    return user.copy(id: id);
  }

  //Criar números 2

  Future<NumerosInfo2> createNum2(NumerosInfo2 user) async {
    final db = await instance.database;
    final id = await db.insert(tableNum2, user.toJson());
    return user.copy(id: id);
  }

  //Criar DDD

  Future<DDDdataInfo> createDDD(DDDdataInfo user) async {
    final db = await instance.database;
    final id = await db.insert(tableDDD, user.toJson());
    return user.copy(id: id);
  }

  //Ler revisita

  Future<List<UserInfo>> readNote(String name) async {
    final db = await instance.database;

    final result = await db.query(
      tableNotes,
      columns: UsersData.values,
      where: "name || number LIKE ?",
      whereArgs: ['%$name%'],
    );

    return result.map((json) => UserInfo.fromJson(json)).toList();
  }

  //Ler estudo

  Future<List<EstInfo>> readEst(String name) async {
    final db = await instance.database;

    final result = await db.query(
      tableEstNotes,
      columns: EstData.values,
      where: "name || number LIKE ?",
      whereArgs: ['%$name%'],
    );

    return result.map((json) => EstInfo.fromJson(json)).toList();
  }

  //Ler número

  Future<NumerosInfo> readNum(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableNum,
      columns: Numeros.values,
      where: '${Numeros.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return NumerosInfo.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  //Ler número 2

  Future<NumerosInfo2> readNum2(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableNum2,
      columns: Numeros2.values,
      where: '${Numeros2.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return NumerosInfo2.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  //Ler DDD

  Future<DDDdataInfo> readDDD(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableDDD,
      columns: DDDdata.values,
      where: '${DDDdata.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DDDdataInfo.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  //Ler todas as revisitas

  Future<List<UserInfo>> readAllNotes() async {
    final db = await instance.database;

    final orderBy = '${UsersData.data} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableNotes, orderBy: orderBy);

    return result.map((json) => UserInfo.fromJson(json)).toList();
  }

  //Ler todos os estudos

  Future<List<EstInfo>> readAllEst() async {
    final db = await instance.database;

    final orderBy = '${EstData.data} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableEstNotes, orderBy: orderBy);

    return result.map((json) => EstInfo.fromJson(json)).toList();
  }

  //Ler todos os números

  Future<List<NumerosInfo>> readAllNum() async {
    final db = await instance.database;

    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableNum);

    return result.map((json) => NumerosInfo.fromJson(json)).toList();
  }

  //Ler todos os números 2

  Future<List<NumerosInfo2>> readAllNum2() async {
    final db = await instance.database;

    final orderBy = '${UsersData.data} ASC';

    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableNum2, orderBy: orderBy);

    return result.map((json) => NumerosInfo2.fromJson(json)).toList();
  }

  //Ler todos os DDD

  Future<List<DDDdataInfo>> readAllDDD() async {
    final db = await instance.database;

    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableDDD);

    return result.map((json) => DDDdataInfo.fromJson(json)).toList();
  }

  //Atualizar Revisita

  Future<int> update(UserInfo note) async {
    final db = await instance.database;

    return db.update(
      tableNotes,
      note.toJson(),
      where: '${UsersData.id} = ?',
      whereArgs: [note.id],
    );
  }

  //Atualizar Estudo

  Future<int> updateEst(EstInfo note) async {
    final db = await instance.database;

    return db.update(
      tableEstNotes,
      note.toJson(),
      where: '${EstData.id} = ?',
      whereArgs: [note.id],
    );
  }

  //Atualizar Número

  Future<int> updateNum(NumerosInfo note) async {
    final db = await instance.database;

    return db.update(
      tableNum,
      note.toJson(),
      where: '${Numeros.id} = ?',
      whereArgs: [note.id],
    );
  }

  //Atualizar Número 2

  Future<int> updateNum2(NumerosInfo2 note) async {
    final db = await instance.database;

    return db.update(
      tableNum2,
      note.toJson(),
      where: '${Numeros2.id} = ?',
      whereArgs: [note.id],
    );
  }

  //Atualizar DDD

  Future<int> updateDDD(DDDdataInfo note) async {
    final db = await instance.database;

    return db.update(
      tableDDD,
      note.toJson(),
      where: '${DDDdata.id} = ?',
      whereArgs: [note.id],
    );
  }

  //Deletar revisita

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableNotes,
      where: '${UsersData.id} = ?',
      whereArgs: [id],
    );
  }

  //Deletar estudos

  Future<int> deleteEst(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableEstNotes,
      where: '${EstData.id} = ?',
      whereArgs: [id],
    );
  }

  //Deletar números

  Future<int> deleteNum(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableNum,
      where: '${Numeros.id} = ?',
      whereArgs: [id],
    );
  }

  //Deletar números 2

  Future<int> deleteNum2(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableNum2,
      where: '${Numeros2.id} = ?',
      whereArgs: [id],
    );
  }

  //Deletar DDD

  Future<int> deleteDDD(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableNum,
      where: '${DDDdata.id} = ?',
      whereArgs: [id],
    );
  }

  //Limpar lista

  Future<int> clearNum() async {
    final db = await instance.database;

    return await db.delete(tableNum);
  }

  //Limpar lista de caixa de mensagem

  Future<int> clearNum2() async {
    final db = await instance.database;

    return await db.delete(tableNum2);
  }

  //Desativar todas as notificações

  Future<int> turnOff() async {
    final db = await instance.database;
    int count = await db
        .rawUpdate('UPDATE $tableNotes SET notif = ? WHERE notif = ?', [0, 1]);
    print('updated: $count');
  }

  Future<int> turnOffNotifications(UserInfo note) async {
    final db = await instance.database;

    return db.update(
      tableNotes,
      note.toJson(),
      where: '${UsersData.id} = ?',
      whereArgs: [note.id],
    );
  }

  //Limpar base de Dados

  Future clearAllTables() async {
    try {
      var dbs = await this.database;
      for (String table in [
        tableNotes,
        tableEstNotes,
        tableNum,
        tableNum2,
        tableDDD,
      ]) {
        await dbs.delete(table);
        await dbs.rawQuery("DELETE FROM sqlite_sequence where name='$table'");
      }

      print('------ CLEAR ALL TABLE');
    } catch (e) {}
  }

  //Backup

  Future<String> generateBackup({bool isEncrypted = true}) async {
    print('GENERATE BACKUP');

    var dbs = await this.database;

    List data = [];

    List<Map<String, dynamic>> listMaps = [];

    for (var i = 0; i < tables.length; i++) {
      listMaps = await dbs.query(tables[i]);

      data.add(listMaps);
    }

    List backups = [tables, data];

    String json = convert.jsonEncode(backups);

    if (isEncrypted) {
      var key = encrypt.Key.fromUtf8(SECRET_KEY);
      var iv = encrypt.IV.fromLength(16);
      var encrypter = encrypt.Encrypter(encrypt.AES(key));
      var encrypted = encrypter.encrypt(json, iv: iv);

      print('aqui ou');
      createFile(encrypted.base64);

      return encrypted.base64;
    } else {
      print('aqui');
      createFile(json);
      return json;
    }
  }

  void createFile(text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/my_file.txt');
    await file.writeAsString(text);
  }

  Future<String> readFile() async {
    String text;
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/my_file.txt');
      text = await file.readAsString();
    } catch (e) {
      print("Erro");
    }

    return text;
  }

  Future<void> restoreBackup({bool isEncrypted = true}) async {
    String backup = await readFile();
    var dbs = await this.database;

    Batch batch = dbs.batch();

    var key = encrypt.Key.fromUtf8(SECRET_KEY);
    var iv = encrypt.IV.fromLength(16);
    var encrypter = encrypt.Encrypter(encrypt.AES(key));

    List json = convert
        .jsonDecode(isEncrypted ? encrypter.decrypt64(backup, iv: iv) : backup);

    for (var i = 0; i < json[0].length; i++) {
      for (var k = 0; k < json[1][i].length; k++) {
        batch.insert(json[0][i], json[1][i][k]);
      }
    }

    await batch.commit(continueOnError: false, noResult: true);

    print('RESTORE BACKUP');

    //Fechar Base de Dados

    Future close() async {
      final db = await instance.database;

      db.close();
    }
  }
}

class UsersData1 {
  Database _db;

  static const SECRET_KEY = "2021_PRIVATE_KEY_ENCRYPT_2021";
  static const DATABASE_VERSION = 1;

  List<String> tables = [];

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb(DATABASE_VERSION);
      return _db;
    }
  }

  Future<String> _databasePath() async {
    String databasesPath = await getDatabasesPath();
    return join(databasesPath, "database.db");
  }

  Future<Database> initDb(int version) async {
    String path = await _databasePath();
    return await openDatabase(path,
        version: version, onCreate: onCreate, onUpgrade: onUpgrade);
  }

  Future deleteDB() async {
    String path = await _databasePath();
    await deleteDatabase(path);
  }

  FutureOr onCreate(Database db, int newerVersion) =>
      this._onCreates[newerVersion](db);

  Map<int, Function> _onCreates = {
    1: (Database db) async {
      print("DATABASE CREATE v1");
    },
    2: (Database db) async {
      print("DATABASE CREATE v2");
    },
    3: (Database db) async {
      print("DATABASE CREATE v3");
    },
  };

  FutureOr<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (var migration = oldVersion; migration < newVersion; migration++) {
      this._onUpgrades["from_version_${migration}_to_version_${migration + 1}"](
          db);
    }
  }

  Map<String, Function> _onUpgrades = {
    'from_version_1_to_version_2': (Database db) async {
      print('from_version_1_to_version_2');
    },
    'from_version_2_to_version_3': (Database db) async {
      print('from_version_2_to_version_3');
    },
  };

  Future clearAllTables() async {
    try {
      var dbs = await this.db;
      for (String table in []) {
        await dbs.delete(table);
        await dbs.rawQuery("DELETE FROM sqlite_sequence where name='$table'");
      }

      print('------ CLEAR ALL TABLE');
    } catch (e) {}
  }

  Future<String> generateBackup({bool isEncrypted = true}) async {
    print('GENERATE BACKUP');

    var dbs = await this.db;

    List data = [];

    List<Map<String, dynamic>> listMaps = [];

    for (var i = 0; i < tables.length; i++) {
      listMaps = await dbs.query(tables[i]);

      data.add(listMaps);
    }

    List backups = [tables, data];

    String json = convert.jsonEncode(backups);

    if (isEncrypted) {
      var key = encrypt.Key.fromUtf8(SECRET_KEY);
      var iv = encrypt.IV.fromLength(16);
      var encrypter = encrypt.Encrypter(encrypt.AES(key));
      var encrypted = encrypter.encrypt(json, iv: iv);

      return encrypted.base64;
    } else {
      return json;
    }
  }

  Future<void> restoreBackup(String backup, {bool isEncrypted = true}) async {
    var dbs = await this.db;

    Batch batch = dbs.batch();

    var key = encrypt.Key.fromUtf8(SECRET_KEY);
    var iv = encrypt.IV.fromLength(16);
    var encrypter = encrypt.Encrypter(encrypt.AES(key));

    List json = convert
        .jsonDecode(isEncrypted ? encrypter.decrypt64(backup, iv: iv) : backup);

    for (var i = 0; i < json[0].length; i++) {
      for (var k = 0; k < json[1][i].length; k++) {
        batch.insert(json[0][i], json[1][i][k]);
      }
    }

    await batch.commit(continueOnError: false, noResult: true);

    print('RESTORE BACKUP');
  }
}
