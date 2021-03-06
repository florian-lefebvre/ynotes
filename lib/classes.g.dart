// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classes.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class alarmTypeAdapter extends TypeAdapter<alarmType> {
  @override
  final int typeId = 7;

  @override
  alarmType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return alarmType.none;
      case 1:
        return alarmType.exactly;
      case 2:
        return alarmType.fiveMinutes;
      case 3:
        return alarmType.fifteenMinutes;
      case 4:
        return alarmType.thirtyMinutes;
      case 5:
        return alarmType.oneDay;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, alarmType obj) {
    switch (obj) {
      case alarmType.none:
        writer.writeByte(0);
        break;
      case alarmType.exactly:
        writer.writeByte(1);
        break;
      case alarmType.fiveMinutes:
        writer.writeByte(2);
        break;
      case alarmType.fifteenMinutes:
        writer.writeByte(3);
        break;
      case alarmType.thirtyMinutes:
        writer.writeByte(4);
        break;
      case alarmType.oneDay:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is alarmTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HomeworkAdapter extends TypeAdapter<Homework> {
  @override
  final int typeId = 0;

  @override
  Homework read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Homework(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as DateTime,
      fields[6] as DateTime,
      fields[7] as bool,
      fields[8] as bool,
      fields[9] as bool,
      (fields[10] as List)?.cast<Document>(),
      (fields[11] as List)?.cast<Document>(),
      fields[12] as String,
      fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Homework obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.matiere)
      ..writeByte(1)
      ..write(obj.codeMatiere)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.contenu)
      ..writeByte(4)
      ..write(obj.contenuDeSeance)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.datePost)
      ..writeByte(7)
      ..write(obj.done)
      ..writeByte(8)
      ..write(obj.rendreEnLigne)
      ..writeByte(9)
      ..write(obj.interrogation)
      ..writeByte(10)
      ..write(obj.documents)
      ..writeByte(11)
      ..write(obj.documentsContenuDeSeance)
      ..writeByte(12)
      ..write(obj.nomProf)
      ..writeByte(13)
      ..write(obj.loaded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeworkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentAdapter extends TypeAdapter<Document> {
  @override
  final int typeId = 1;

  @override
  Document read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Document(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Document obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.libelle)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.length);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GradeAdapter extends TypeAdapter<Grade> {
  @override
  final int typeId = 2;

  @override
  Grade read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Grade(
      max: fields[17] as String,
      min: fields[18] as String,
      devoir: fields[0] as String,
      codePeriode: fields[1] as String,
      codeMatiere: fields[2] as String,
      codeSousMatiere: fields[3] as String,
      libelleMatiere: fields[4] as String,
      letters: fields[5] as bool,
      valeur: fields[6] as String,
      coef: fields[7] as String,
      noteSur: fields[8] as String,
      moyenneClasse: fields[9] as String,
      typeDevoir: fields[10] as String,
      date: fields[16] as DateTime,
      dateSaisie: fields[15] as DateTime,
      nonSignificatif: fields[13] as bool,
      nomPeriode: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Grade obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.devoir)
      ..writeByte(1)
      ..write(obj.codePeriode)
      ..writeByte(2)
      ..write(obj.codeMatiere)
      ..writeByte(3)
      ..write(obj.codeSousMatiere)
      ..writeByte(4)
      ..write(obj.libelleMatiere)
      ..writeByte(5)
      ..write(obj.letters)
      ..writeByte(6)
      ..write(obj.valeur)
      ..writeByte(7)
      ..write(obj.coef)
      ..writeByte(8)
      ..write(obj.noteSur)
      ..writeByte(9)
      ..write(obj.moyenneClasse)
      ..writeByte(10)
      ..write(obj.typeDevoir)
      ..writeByte(16)
      ..write(obj.date)
      ..writeByte(15)
      ..write(obj.dateSaisie)
      ..writeByte(13)
      ..write(obj.nonSignificatif)
      ..writeByte(14)
      ..write(obj.nomPeriode)
      ..writeByte(17)
      ..write(obj.max)
      ..writeByte(18)
      ..write(obj.min);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DisciplineAdapter extends TypeAdapter<Discipline> {
  @override
  final int typeId = 3;

  @override
  Discipline read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Discipline(
      gradesList: (fields[12] as List)?.cast<Grade>(),
      moyenneGeneralClasseMax: fields[1] as String,
      moyenneGeneraleClasse: fields[2] as String,
      moyenneGenerale: fields[0] as String,
      moyenneClasse: fields[7] as String,
      moyenneMin: fields[8] as String,
      moyenneMax: fields[9] as String,
      codeMatiere: fields[3] as String,
      codeSousMatiere: (fields[4] as List)?.cast<String>(),
      moyenne: fields[6] as String,
      professeurs: (fields[10] as List)?.cast<String>(),
      nomDiscipline: fields[5] as String,
      periode: fields[11] as String,
      color: fields[13] as int,
      rangDiscipline: fields[14] as int,
      effectifClasse: fields[15] as String,
      rangGeneral: fields[16] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Discipline obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.moyenneGenerale)
      ..writeByte(1)
      ..write(obj.moyenneGeneralClasseMax)
      ..writeByte(2)
      ..write(obj.moyenneGeneraleClasse)
      ..writeByte(3)
      ..write(obj.codeMatiere)
      ..writeByte(4)
      ..write(obj.codeSousMatiere)
      ..writeByte(5)
      ..write(obj.nomDiscipline)
      ..writeByte(6)
      ..write(obj.moyenne)
      ..writeByte(7)
      ..write(obj.moyenneClasse)
      ..writeByte(8)
      ..write(obj.moyenneMin)
      ..writeByte(9)
      ..write(obj.moyenneMax)
      ..writeByte(10)
      ..write(obj.professeurs)
      ..writeByte(11)
      ..write(obj.periode)
      ..writeByte(12)
      ..write(obj.gradesList)
      ..writeByte(13)
      ..write(obj.color)
      ..writeByte(14)
      ..write(obj.rangDiscipline)
      ..writeByte(15)
      ..write(obj.effectifClasse)
      ..writeByte(16)
      ..write(obj.rangGeneral);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisciplineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LessonAdapter extends TypeAdapter<Lesson> {
  @override
  final int typeId = 4;

  @override
  Lesson read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lesson(
      room: fields[0] as String,
      teachers: (fields[1] as List)?.cast<String>(),
      start: fields[2] as DateTime,
      duration: fields[4] as int,
      canceled: fields[5] as bool,
      status: fields[6] as String,
      groups: (fields[7] as List)?.cast<String>(),
      content: fields[8] as String,
      matiere: fields[9] as String,
      codeMatiere: fields[10] as String,
      end: fields[3] as DateTime,
      id: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Lesson obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.room)
      ..writeByte(1)
      ..write(obj.teachers)
      ..writeByte(2)
      ..write(obj.start)
      ..writeByte(3)
      ..write(obj.end)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.canceled)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.groups)
      ..writeByte(8)
      ..write(obj.content)
      ..writeByte(9)
      ..write(obj.matiere)
      ..writeByte(10)
      ..write(obj.codeMatiere)
      ..writeByte(11)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PollInfoAdapter extends TypeAdapter<PollInfo> {
  @override
  final int typeId = 5;

  @override
  PollInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PollInfo(
      fields[0] as String,
      fields[1] as DateTime,
      (fields[2] as List)?.cast<String>(),
      fields[3] as bool,
      fields[4] as String,
      fields[5] as String,
      (fields[6] as List)?.cast<Document>(),
      (fields[7] as Map)?.cast<dynamic, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, PollInfo obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.auteur)
      ..writeByte(1)
      ..write(obj.datedebut)
      ..writeByte(2)
      ..write(obj.questions)
      ..writeByte(3)
      ..write(obj.read)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.id)
      ..writeByte(6)
      ..write(obj.documents)
      ..writeByte(7)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PollInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AgendaReminderAdapter extends TypeAdapter<AgendaReminder> {
  @override
  final int typeId = 6;

  @override
  AgendaReminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AgendaReminder(
      fields[0] as String,
      fields[1] as String,
      fields[3] as alarmType,
      fields[5] as String,
      description: fields[2] as String,
      tagColor: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AgendaReminder obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.lessonID)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.alarm)
      ..writeByte(4)
      ..write(obj.tagColor)
      ..writeByte(5)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgendaReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AgendaEventAdapter extends TypeAdapter<AgendaEvent> {
  @override
  final int typeId = 8;

  @override
  AgendaEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AgendaEvent(
      fields[0] as DateTime,
      fields[1] as DateTime,
      fields[2] as String,
      fields[3] as String,
      fields[4] as double,
      fields[5] as double,
      fields[7] as bool,
      fields[8] as String,
      fields[6] as double,
      wholeDay: fields[14] as bool,
      isLesson: fields[10] as bool,
      lesson: fields[11] as Lesson,
      reminders: (fields[9] as List)?.cast<AgendaReminder>(),
      description: fields[12] as String,
      alarm: fields[13] as alarmType,
      color: fields[15] as int,
      recurrenceScheme: fields[16] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AgendaEvent obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.end)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.left)
      ..writeByte(5)
      ..write(obj.height)
      ..writeByte(6)
      ..write(obj.width)
      ..writeByte(7)
      ..write(obj.canceled)
      ..writeByte(8)
      ..write(obj.id)
      ..writeByte(9)
      ..write(obj.reminders)
      ..writeByte(10)
      ..write(obj.isLesson)
      ..writeByte(11)
      ..write(obj.lesson)
      ..writeByte(12)
      ..write(obj.description)
      ..writeByte(13)
      ..write(obj.alarm)
      ..writeByte(14)
      ..write(obj.wholeDay)
      ..writeByte(15)
      ..write(obj.color)
      ..writeByte(16)
      ..write(obj.recurrenceScheme);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgendaEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecipientAdapter extends TypeAdapter<Recipient> {
  @override
  final int typeId = 9;

  @override
  Recipient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recipient(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[4] as bool,
      fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Recipient obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.surname)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.discipline)
      ..writeByte(4)
      ..write(obj.isTeacher);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Homework _$HomeworkFromJson(Map<String, dynamic> json) {
  return Homework(
    json['matiere'] as String,
    json['codeMatiere'] as String,
    json['id'] as String,
    json['contenu'] as String,
    json['contenuDeSeance'] as String,
    DateTime.parse(json['date'] as String),
    DateTime.parse(json['datePost'] as String),
    json['done'] as bool,
    json['rendreEnLigne'] as bool,
    json['interrogation'] as bool,
    (json['documents'] as List)
        .map((e) => Document.fromJson(e as Map<String, dynamic>))
        .toList(),
    (json['documentsContenuDeSeance'] as List)
        .map((e) => Document.fromJson(e as Map<String, dynamic>))
        .toList(),
    json['nomProf'] as String,
    json['loaded'] as bool,
  );
}

Map<String, dynamic> _$HomeworkToJson(Homework instance) => <String, dynamic>{
      'matiere': instance.matiere,
      'codeMatiere': instance.codeMatiere,
      'id': instance.id,
      'contenu': instance.contenu,
      'contenuDeSeance': instance.contenuDeSeance,
      'date': instance.date.toIso8601String(),
      'datePost': instance.datePost.toIso8601String(),
      'done': instance.done,
      'rendreEnLigne': instance.rendreEnLigne,
      'interrogation': instance.interrogation,
      'documents': instance.documents,
      'documentsContenuDeSeance': instance.documentsContenuDeSeance,
      'nomProf': instance.nomProf,
      'loaded': instance.loaded,
    };

Document _$DocumentFromJson(Map<String, dynamic> json) {
  return Document(
    json['libelle'] as String,
    json['id'] as String,
    json['type'] as String,
    json['length'] as int,
  );
}

Map<String, dynamic> _$DocumentToJson(Document instance) => <String, dynamic>{
      'libelle': instance.libelle,
      'id': instance.id,
      'type': instance.type,
      'length': instance.length,
    };

Lesson _$LessonFromJson(Map<String, dynamic> json) {
  return Lesson(
    room: json['room'] as String,
    teachers: (json['teachers'] as List).map((e) => e as String).toList(),
    start: DateTime.parse(json['start'] as String),
    duration: json['duration'] as int,
    canceled: json['canceled'] as bool,
    status: json['status'] as String,
    groups: (json['groups'] as List).map((e) => e as String).toList(),
    content: json['content'] as String,
    matiere: json['matiere'] as String,
    codeMatiere: json['codeMatiere'] as String,
    end: DateTime.parse(json['end'] as String),
    id: json['id'] as String,
  );
}

Map<String, dynamic> _$LessonToJson(Lesson instance) => <String, dynamic>{
      'room': instance.room,
      'teachers': instance.teachers,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'duration': instance.duration,
      'canceled': instance.canceled,
      'status': instance.status,
      'groups': instance.groups,
      'content': instance.content,
      'matiere': instance.matiere,
      'codeMatiere': instance.codeMatiere,
      'id': instance.id,
    };

AgendaReminder _$AgendaReminderFromJson(Map<String, dynamic> json) {
  return AgendaReminder(
    json['lessonID'] as String,
    json['name'] as String,
    _$enumDecode(_$alarmTypeEnumMap, json['alarm']),
    json['id'] as String,
    description: json['description'] as String,
    tagColor: json['tagColor'] as int,
  );
}

Map<String, dynamic> _$AgendaReminderToJson(AgendaReminder instance) =>
    <String, dynamic>{
      'lessonID': instance.lessonID,
      'name': instance.name,
      'description': instance.description,
      'alarm': _$alarmTypeEnumMap[instance.alarm],
      'tagColor': instance.tagColor,
      'id': instance.id,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

const _$alarmTypeEnumMap = {
  alarmType.none: 'none',
  alarmType.exactly: 'exactly',
  alarmType.fiveMinutes: 'fiveMinutes',
  alarmType.fifteenMinutes: 'fifteenMinutes',
  alarmType.thirtyMinutes: 'thirtyMinutes',
  alarmType.oneDay: 'oneDay',
};

AgendaEvent _$AgendaEventFromJson(Map<String, dynamic> json) {
  return AgendaEvent(
    DateTime.parse(json['start'] as String),
    DateTime.parse(json['end'] as String),
    json['name'] as String,
    json['location'] as String,
    (json['left'] as num).toDouble(),
    (json['height'] as num).toDouble(),
    json['canceled'] as bool,
    json['id'] as String,
    (json['width'] as num).toDouble(),
    wholeDay: json['wholeDay'] as bool,
    isLesson: json['isLesson'] as bool,
    lesson: Lesson.fromJson(json['lesson'] as Map<String, dynamic>),
    reminders: (json['reminders'] as List)
        .map((e) => AgendaReminder.fromJson(e as Map<String, dynamic>))
        .toList(),
    description: json['description'] as String,
    alarm: _$enumDecode(_$alarmTypeEnumMap, json['alarm']),
    color: json['color'] as int,
    recurrenceScheme: json['recurrenceScheme'] as String,
  );
}

Map<String, dynamic> _$AgendaEventToJson(AgendaEvent instance) =>
    <String, dynamic>{
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'name': instance.name,
      'location': instance.location,
      'left': instance.left,
      'height': instance.height,
      'width': instance.width,
      'canceled': instance.canceled,
      'id': instance.id,
      'reminders': instance.reminders,
      'isLesson': instance.isLesson,
      'lesson': instance.lesson,
      'description': instance.description,
      'alarm': _$alarmTypeEnumMap[instance.alarm],
      'wholeDay': instance.wholeDay,
      'color': instance.color,
      'recurrenceScheme': instance.recurrenceScheme,
    };
