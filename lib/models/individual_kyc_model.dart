// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:swamper_solution/models/crimers_model.dart';
import 'package:swamper_solution/models/individual_model.dart';

class IndividualKycModel {
  final IndividualModel userInfo;
  final String dob;
  final String gender;
  final String sinNumber;
  final String sinExpery;
  final String transitNumber;
  final String institutionNumber;
  final String institutionName;
  final String voidCheque;
  final String banckCode;
  final String backAccNumber;
  final String statusInCanada;
  final String permitImage;
  final String govDocImage;
  final String aptNo;
  final String emergencyContactNo;
  final String emergencyContactName;
  final String modeOfTravel;
  final String postalCode;
  final bool haveCriminalRecord;
  final List<CrimersModel>? crimes;
  IndividualKycModel({
    required this.userInfo,
    required this.dob,
    required this.gender,
    required this.sinNumber,
    required this.sinExpery,
    required this.transitNumber,
    required this.institutionNumber,
    required this.institutionName,
    required this.voidCheque,
    required this.banckCode,
    required this.backAccNumber,
    required this.statusInCanada,
    required this.permitImage,
    required this.govDocImage,
    required this.aptNo,
    required this.emergencyContactNo,
    required this.emergencyContactName,
    required this.modeOfTravel,
    required this.postalCode,
    required this.haveCriminalRecord,
    this.crimes,
  });

  IndividualKycModel copyWith({
    IndividualModel? userInfo,
    String? dob,
    String? gender,
    String? sinNumber,
    String? sinExpery,
    String? transitNumber,
    String? institutionNumber,
    String? institutionName,
    String? voidCheque,
    String? banckCode,
    String? backAccNumber,
    String? statusInCanada,
    String? permitImage,
    String? govDocImage,
    String? aptNo,
    String? emergencyContactNo,
    String? emergencyContactName,
    String? modeOfTravel,
    String? postalCode,
    bool? haveCriminalRecord,
    List<CrimersModel>? crimes,
  }) {
    return IndividualKycModel(
      userInfo: userInfo ?? this.userInfo,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      sinNumber: sinNumber ?? this.sinNumber,
      sinExpery: sinExpery ?? this.sinExpery,
      transitNumber: transitNumber ?? this.transitNumber,
      institutionNumber: institutionNumber ?? this.institutionNumber,
      institutionName: institutionName ?? this.institutionName,
      voidCheque: voidCheque ?? this.voidCheque,
      banckCode: banckCode ?? this.banckCode,
      backAccNumber: backAccNumber ?? this.backAccNumber,
      statusInCanada: statusInCanada ?? this.statusInCanada,
      permitImage: permitImage ?? this.permitImage,
      govDocImage: govDocImage ?? this.govDocImage,
      aptNo: aptNo ?? this.aptNo,
      emergencyContactNo: emergencyContactNo ?? this.emergencyContactNo,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      modeOfTravel: modeOfTravel ?? this.modeOfTravel,
      postalCode: postalCode ?? this.postalCode,
      haveCriminalRecord: haveCriminalRecord ?? this.haveCriminalRecord,
      crimes: crimes ?? this.crimes,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userInfo': userInfo.toMap(),
      'dob': dob,
      'gender': gender,
      'sinNumber': sinNumber,
      'sinExpery': sinExpery,
      'transitNumber': transitNumber,
      'institutionNumber': institutionNumber,
      'institutionName': institutionName,
      'voidCheque': voidCheque,
      'banckCode': banckCode,
      'backAccNumber': backAccNumber,
      'statusInCanada': statusInCanada,
      'permitImage': permitImage,
      'govDocImage': govDocImage,
      'aptNo': aptNo,
      'emergencyContactNo': emergencyContactNo,
      'emergencyContactName': emergencyContactName,
      'modeOfTravel': modeOfTravel,
      'postalCode': postalCode,
      'haveCriminalRecord': haveCriminalRecord,
      'crimes': crimes?.map((x) => x.toMap()).toList(),
    };
  }

  factory IndividualKycModel.fromMap(Map<String, dynamic> map) {
    return IndividualKycModel(
      userInfo: IndividualModel.fromMap(map['userInfo'] as Map<String,dynamic>),
      dob: map['dob'] as String,
      gender: map['gender'] as String,
      sinNumber: map['sinNumber'] as String,
      sinExpery: map['sinExpery'] as String,
      transitNumber: map['transitNumber'] as String,
      institutionNumber: map['institutionNumber'] as String,
      institutionName: map['institutionName'] as String,
      voidCheque: map['voidCheque'] as String,
      banckCode: map['banckCode'] as String,
      backAccNumber: map['backAccNumber'] as String,
      statusInCanada: map['statusInCanada'] as String,
      permitImage: map['permitImage'] as String,
      govDocImage: map['govDocImage'] as String,
      aptNo: map['aptNo'] as String,
      emergencyContactNo: map['emergencyContactNo'] as String,
      emergencyContactName: map['emergencyContactName'] as String,
      modeOfTravel: map['modeOfTravel'] as String,
      postalCode: map['postalCode'] as String,
      haveCriminalRecord: map['haveCriminalRecord'] as bool,
      crimes: map['crimes'] != null ? List<CrimersModel>.from((map['crimes'] as List<int>).map<CrimersModel?>((x) => CrimersModel.fromMap(x as Map<String,dynamic>),),) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory IndividualKycModel.fromJson(String source) => IndividualKycModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'IndividualKycModel(userInfo: $userInfo, dob: $dob, gender: $gender, sinNumber: $sinNumber, sinExpery: $sinExpery, transitNumber: $transitNumber, institutionNumber: $institutionNumber, institutionName: $institutionName, voidCheque: $voidCheque, banckCode: $banckCode, backAccNumber: $backAccNumber, statusInCanada: $statusInCanada, permitImage: $permitImage, govDocImage: $govDocImage, aptNo: $aptNo, emergencyContactNo: $emergencyContactNo, emergencyContactName: $emergencyContactName, modeOfTravel: $modeOfTravel, postalCode: $postalCode, haveCriminalRecord: $haveCriminalRecord, crimes: $crimes)';
  }

  @override
  bool operator ==(covariant IndividualKycModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.userInfo == userInfo &&
      other.dob == dob &&
      other.gender == gender &&
      other.sinNumber == sinNumber &&
      other.sinExpery == sinExpery &&
      other.transitNumber == transitNumber &&
      other.institutionNumber == institutionNumber &&
      other.institutionName == institutionName &&
      other.voidCheque == voidCheque &&
      other.banckCode == banckCode &&
      other.backAccNumber == backAccNumber &&
      other.statusInCanada == statusInCanada &&
      other.permitImage == permitImage &&
      other.govDocImage == govDocImage &&
      other.aptNo == aptNo &&
      other.emergencyContactNo == emergencyContactNo &&
      other.emergencyContactName == emergencyContactName &&
      other.modeOfTravel == modeOfTravel &&
      other.postalCode == postalCode &&
      other.haveCriminalRecord == haveCriminalRecord &&
      listEquals(other.crimes, crimes);
  }

  @override
  int get hashCode {
    return userInfo.hashCode ^
      dob.hashCode ^
      gender.hashCode ^
      sinNumber.hashCode ^
      sinExpery.hashCode ^
      transitNumber.hashCode ^
      institutionNumber.hashCode ^
      institutionName.hashCode ^
      voidCheque.hashCode ^
      banckCode.hashCode ^
      backAccNumber.hashCode ^
      statusInCanada.hashCode ^
      permitImage.hashCode ^
      govDocImage.hashCode ^
      aptNo.hashCode ^
      emergencyContactNo.hashCode ^
      emergencyContactName.hashCode ^
      modeOfTravel.hashCode ^
      postalCode.hashCode ^
      haveCriminalRecord.hashCode ^
      crimes.hashCode;
  }
}
