import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class User {
  String nome;
  String numero;
  String id;
  String anotacoes;
  DateTime data;
  String dia;
  int idN;
  bool not;

  User(this.nome, this.numero, this.id, this.anotacoes, this.data, this.dia,
      this.idN, this.not);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'nome': nome,
      'numero': numero,
      'anotacoes': anotacoes,
      'data': data,
      'dia': dia,
      'idN': idN,
      'not': not,
    };
    return map;
  }

  User.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    nome = map['nome'];
    numero = map['numero'];
    anotacoes = map['anotacoes'];
    data = map['data'];
    dia = map['dia'];
    idN = map['idN'];
    not = map['not'];
  }
}

class NumerosList {
  final String numero;
  final String id;

  const NumerosList(
    this.numero,
    this.id,
  );

  void remove(int i) {}
}

final String tableNotes = 'notes';

class UsersData {
  static final List<String> values = [
    /// Add all fields
    id, notif, number, name, description, data, day, idN, hour, minute,
  ];

  static final String id = '_id';
  static final String notif = 'notif';
  static final String number = 'number';
  static final String name = 'name';
  static final String description = 'description';
  static final String data = 'data';
  static final String day = 'day';
  static final String idN = 'idN';
  static final String hour = 'hour';
  static final String minute = 'minute';
}

class UserInfo {
  final int id;
  final bool notif;
  final String number;
  final String name;
  final String description;
  final DateTime data;
  final int day;
  final int idN;
  final int hour;
  final int minute;

  const UserInfo({
    this.id,
    this.notif,
    this.number,
    this.name,
    this.description,
    this.data,
    this.day,
    this.idN,
    this.hour,
    this.minute,
  });

  UserInfo copy({
    int id,
    bool notif,
    String number,
    String name,
    String description,
    DateTime data,
    int day,
    int idN,
    int hour,
    int minute,
  }) =>
      UserInfo(
        id: id ?? this.id,
        notif: notif ?? this.notif,
        number: number ?? this.number,
        name: name ?? this.name,
        description: description ?? this.description,
        data: data ?? this.data,
        day: day ?? this.day,
        idN: idN ?? this.idN,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );

  static UserInfo fromJson(Map<String, Object> json) => UserInfo(
        id: json[UsersData.id] as int,
        notif: json[UsersData.notif] == 1,
        number: json[UsersData.number] as String,
        name: json[UsersData.name] as String,
        description: json[UsersData.description] as String,
        data: DateTime.parse(json[UsersData.data] as String),
        day: json[UsersData.day] as int,
        idN: json[UsersData.idN] as int,
        hour: json[UsersData.hour] as int,
        minute: json[UsersData.minute] as int,
      );

  Map<String, Object> toJson() => {
        UsersData.id: id,
        UsersData.name: name,
        UsersData.notif: notif ? 1 : 0,
        UsersData.number: number,
        UsersData.description: description,
        UsersData.data: data.toIso8601String(),
        UsersData.day: day,
        UsersData.idN: idN,
        UsersData.hour: hour,
        UsersData.minute: minute,
      };
}

final String tableEstNotes = 'notes_est';

class EstData {
  static final List<String> values = [
    /// Add all fields
    id, notif, number, name, description, data, day, idN, hour, minute,
  ];

  static final String id = '_id';
  static final String notif = 'notif';
  static final String number = 'number';
  static final String name = 'name';
  static final String description = 'description';
  static final String data = 'data';
  static final String day = 'day';
  static final String idN = 'idN';
  static final String hour = 'hour';
  static final String minute = 'minute';
}

class EstInfo {
  final int id;
  final bool notif;
  final String number;
  final String name;
  final String description;
  final DateTime data;
  final int day;
  final int idN;
  final int hour;
  final int minute;

  const EstInfo({
    this.id,
    this.notif,
    this.number,
    this.name,
    this.description,
    this.data,
    this.day,
    this.idN,
    this.hour,
    this.minute,
  });

  EstInfo copy({
    int id,
    bool notif,
    String number,
    String name,
    String description,
    DateTime data,
    int day,
    int idN,
    int hour,
    int minute,
  }) =>
      EstInfo(
        id: id ?? this.id,
        notif: notif ?? this.notif,
        number: number ?? this.number,
        name: name ?? this.name,
        description: description ?? this.description,
        data: data ?? this.data,
        day: day ?? this.day,
        idN: idN ?? this.idN,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );

  static EstInfo fromJson(Map<String, Object> json) => EstInfo(
        id: json[EstData.id] as int,
        notif: json[EstData.notif] == 1,
        number: json[EstData.number] as String,
        name: json[EstData.name] as String,
        description: json[EstData.description] as String,
        data: DateTime.parse(json[EstData.data] as String),
        day: json[EstData.day] as int,
        idN: json[EstData.idN] as int,
        hour: json[EstData.hour] as int,
        minute: json[EstData.minute] as int,
      );

  Map<String, Object> toJson() => {
        EstData.id: id,
        EstData.name: name,
        EstData.notif: notif ? 1 : 0,
        EstData.number: number,
        EstData.description: description,
        EstData.data: data.toIso8601String(),
        EstData.day: day,
        EstData.idN: idN,
        EstData.hour: hour,
        EstData.minute: minute,
      };
}

final String tableNum = 'numbers';

class Numeros {
  static final List<dynamic> values = [
    /// Add all fields
    id, number, called,
  ];

  static final String id = '_id';
  static final String number = 'number';
  static final String called = 'false';
}

class NumerosInfo {
  final int id;
  final String number;
  final bool called;

  const NumerosInfo({
    this.id,
    this.number,
    this.called,
  });

  NumerosInfo copy({
    int id,
    String number,
    bool called,
  }) =>
      NumerosInfo(
        id: id ?? this.id,
        number: number ?? this.number,
        called: called ?? this.called,
      );

  static NumerosInfo fromJson(Map<String, Object> json) => NumerosInfo(
        id: json[Numeros.id] as int,
        number: json[Numeros.number] as String,
        called: json[Numeros.called] == 1,
      );

  Map<String, Object> toJson() => {
        Numeros.id: id,
        Numeros.number: number,
        Numeros.called: called ? 1 : 0,
      };
}

final String tableNum2 = 'numbers2';

class Numeros2 {
  static final List<String> values = [
    /// Add all fields
    id, number, called, data,
  ];

  static final String id = '_id';
  static final String number = 'number';
  static final String called = 'false';
  static final String data = 'data';
}

class NumerosInfo2 {
  final int id;
  final String number;
  final bool called;
  final DateTime data;

  const NumerosInfo2({
    this.id,
    this.number,
    this.called,
    this.data,
  });

  NumerosInfo2 copy({
    int id,
    String number,
    bool called,
    DateTime data,
  }) =>
      NumerosInfo2(
        id: id ?? this.id,
        number: number ?? this.number,
        called: called ?? this.called,
        data: data ?? this.data,
      );

  static NumerosInfo2 fromJson(Map<String, Object> json) => NumerosInfo2(
        id: json[Numeros2.id] as int,
        number: json[Numeros2.number] as String,
        called: json[Numeros2.called] == 1,
        data: DateTime.parse(json[Numeros2.data] as String),
      );

  Map<String, Object> toJson() => {
        Numeros2.id: id,
        Numeros2.number: number,
        Numeros2.called: called ? 1 : 0,
        Numeros2.data: data.toIso8601String(),
      };
}

final String tableDDD = 'table_ddd';

class DDDdata {
  static final List<String> values = [
    /// Add all fields
    id, number,
  ];

  static final String id = '_id';
  static final String number = 'number';
}

class DDDdataInfo {
  final int id;
  final String number;

  const DDDdataInfo({
    this.id,
    this.number,
  });
  DDDdataInfo copy({
    int id,
    String number,
  }) =>
      DDDdataInfo(
        id: id ?? this.id,
        number: number ?? this.number,
      );

  static DDDdataInfo fromJson(Map<String, Object> json) => DDDdataInfo(
        id: json[DDDdata.id] as int,
        number: json[DDDdata.number] as String,
      );

  Map<String, Object> toJson() => {
        DDDdata.id: id,
        DDDdata.number: number,
      };
}
