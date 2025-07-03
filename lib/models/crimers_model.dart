import 'dart:convert';

class CrimersModel {
  String offence;
  DateTime dateOfSentence;
  String courtLocation;
  CrimersModel({
    required this.offence,
    required this.dateOfSentence,
    required this.courtLocation,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'offence': offence,
      'dateOfSentence': dateOfSentence.millisecondsSinceEpoch,
      'courtLocation': courtLocation,
    };
  }

  factory CrimersModel.fromMap(Map<String, dynamic> map) {
    return CrimersModel(
      offence: map['offence'] as String,
      dateOfSentence: DateTime.fromMillisecondsSinceEpoch(
        map['dateOfSentence'] as int,
      ),
      courtLocation: map['courtLocation'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CrimersModel.fromJson(String source) =>
      CrimersModel.fromMap(json.decode(source) as Map<String, dynamic>);

  CrimersModel copyWith({
    String? offence,
    DateTime? dateOfSentence,
    String? courtLocation,
  }) {
    return CrimersModel(
      offence: offence ?? this.offence,
      dateOfSentence: dateOfSentence ?? this.dateOfSentence,
      courtLocation: courtLocation ?? this.courtLocation,
    );
  }

  @override
  String toString() =>
      'CrimersModel(offence: $offence, dateOfSentence: $dateOfSentence, courtLocation: $courtLocation)';

  @override
  bool operator ==(covariant CrimersModel other) {
    if (identical(this, other)) return true;

    return other.offence == offence &&
        other.dateOfSentence == dateOfSentence &&
        other.courtLocation == courtLocation;
  }

  @override
  int get hashCode =>
      offence.hashCode ^ dateOfSentence.hashCode ^ courtLocation.hashCode;
}
