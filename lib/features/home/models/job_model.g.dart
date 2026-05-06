// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedJobModelAdapter extends TypeAdapter<SavedJobModel> {
  @override
  final int typeId = 1;

  @override
  SavedJobModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedJobModel(
      jobId: fields[0] as String,
      jobTitle: fields[1] as String,
      companyName: fields[2] as String,
      companyLogo: fields[3] as String?,
      location: fields[4] as String,
      applyLink: fields[5] as String,
      employmentType: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SavedJobModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.jobId)
      ..writeByte(1)
      ..write(obj.jobTitle)
      ..writeByte(2)
      ..write(obj.companyName)
      ..writeByte(3)
      ..write(obj.companyLogo)
      ..writeByte(4)
      ..write(obj.location)
      ..writeByte(5)
      ..write(obj.applyLink)
      ..writeByte(6)
      ..write(obj.employmentType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedJobModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
