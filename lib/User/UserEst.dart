/* final String tableEstNotes = 'notes_est';

class EstData {
  static final List<String> values = [
    /// Add all fields
    id, notif, number, name, description, data, day, idN
  ];

  static final String id = '_id';
  static final String notif = 'notif';
  static final String number = 'number';
  static final String name = 'name';
  static final String description = 'description';
  static final String data = 'data';
  static final String day = 'day';
  static final String idN = 'idN';
}

class EstInfo {
  final int id;
  final bool notif;
  final String number;
  final String name;
  final String description;
  final DateTime data;
  final String day;
  final int idN;

  const EstInfo(
      {this.id,
      this.notif,
      this.number,
      this.name,
      this.description,
      this.data,
      this.day,
      this.idN});

  EstInfo copy({
    int id,
    bool notif,
    String number,
    String name,
    String description,
    DateTime data,
    String day,
    int idN,
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
      );

  static EstInfo fromJson(Map<String, Object> json) => EstInfo(
        id: json[EstData.id] as int,
        notif: json[EstData.notif] == 1,
        number: json[EstData.number] as String,
        name: json[EstData.name] as String,
        description: json[EstData.description] as String,
        data: DateTime.parse(json[EstData.data] as String),
        day: json[EstData.day] as String,
        idN: json[EstData.idN] as int,
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
      };
}
 */
