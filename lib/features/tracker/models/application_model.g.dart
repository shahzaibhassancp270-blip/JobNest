// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApplicationModelAdapter extends TypeAdapter<ApplicationModel> {
  @override
  final int typeId = 0;

  @override
  ApplicationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApplicationModel(
      id: fields[0] as String,
      jobTitle: fields[1] as String,
      companyName: fields[2] as String,
      jobUrl: fields[3] as String,
      status: fields[4] as String,
      notes: fields[5] as String,
      resumeLink: fields[6] as String,
      appliedDate: fields[7] as DateTime,
      interviewDate: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ApplicationModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.jobTitle)
      ..writeByte(2)
      ..write(obj.companyName)
      ..writeByte(3)
      ..write(obj.jobUrl)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.resumeLink)
      ..writeByte(7)
      ..write(obj.appliedDate)
      ..writeByte(8)
      ..write(obj.interviewDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
