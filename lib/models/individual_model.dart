import 'dart:convert';

class IndividualModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String contactNo;
  final String profilePic;
  final String role;
  final String address;
  final String kycVerified;
  final String interestedWork;
  final String createdAt;
  final String oneTimeResume;
  IndividualModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.contactNo,
    required this.profilePic,
    required this.role,
    required this.address,
    required this.kycVerified,
    required this.interestedWork,
    required this.createdAt,
    required this.oneTimeResume,
  });

  IndividualModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? contactNo,
    String? profilePic,
    String? role,
    String? address,
    String? kycVerified,
    String? interestedWork,
    String? createdAt,
    String? oneTimeResume,
  }) {
    return IndividualModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      contactNo: contactNo ?? this.contactNo,
      profilePic: profilePic ?? this.profilePic,
      role: role ?? this.role,
      address: address ?? this.address,
      kycVerified: kycVerified ?? this.kycVerified,
      interestedWork: interestedWork ?? this.interestedWork,
      createdAt: createdAt ?? this.createdAt,
      oneTimeResume: oneTimeResume ?? this.oneTimeResume,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'contactNo': contactNo,
      'profilePic': profilePic,
      'role': role,
      'address': address,
      'kycVerified': kycVerified,
      'interestedWork': interestedWork,
      'createdAt': createdAt,
      'oneTimeResume': oneTimeResume,
    };
  }

  factory IndividualModel.fromMap(Map<String, dynamic> map) {
    return IndividualModel(
      uid: map['uid'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      email: map['email'] as String,
      contactNo: map['contactNo'] as String,
      profilePic: map['profilePic'] as String,
      role: map['role'] as String,
      address: map['address'] as String,
      kycVerified: map['kycVerified'] as String,
      interestedWork: map['interestedWork'] as String,
      createdAt: map['createdAt'] as String,
      oneTimeResume: map['oneTimeResume'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory IndividualModel.fromJson(String source) =>
      IndividualModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant IndividualModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.email == email &&
        other.contactNo == contactNo &&
        other.profilePic == profilePic &&
        other.role == role &&
        other.address == address &&
        other.kycVerified == kycVerified &&
        other.interestedWork == interestedWork &&
        other.createdAt == createdAt &&
        other.oneTimeResume == oneTimeResume;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        email.hashCode ^
        contactNo.hashCode ^
        profilePic.hashCode ^
        role.hashCode ^
        address.hashCode ^
        kycVerified.hashCode ^
        interestedWork.hashCode ^
        createdAt.hashCode ^
        oneTimeResume.hashCode;
  }
}
