import 'dart:convert';

class CompanyModel {
  final String uid;
  final String companyName;
  final String email;
  final String contactNo;
  final String profilePic;
  final String role;
  final String address;
  final String createdAt;
  final bool isSuspended;
  CompanyModel({
    required this.uid,
    required this.companyName,
    required this.email,
    required this.contactNo,
    required this.profilePic,
    required this.role,
    required this.address,
    required this.createdAt,
    required this.isSuspended,
  });

  CompanyModel copyWith({
    String? uid,
    String? companyName,
    String? email,
    String? contactNo,
    String? profilePic,
    String? role,
    String? address,
    String? createdAt,
    bool? isSuspended,
  }) {
    return CompanyModel(
      uid: uid ?? this.uid,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      contactNo: contactNo ?? this.contactNo,
      profilePic: profilePic ?? this.profilePic,
      role: role ?? this.role,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      isSuspended: isSuspended ?? this.isSuspended,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'companyName': companyName,
      'email': email,
      'contactNo': contactNo,
      'profilePic': profilePic,
      'role': role,
      'address': address,
      'createdAt': createdAt,
      'isSuspended': isSuspended,
    };
  }

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      uid: map['uid'] as String,
      companyName: map['companyName'] as String,
      email: map['email'] as String,
      contactNo: map['contactNo'] as String,
      profilePic: map['profilePic'] as String,
      role: map['role'] as String,
      address: map['address'] as String,
      createdAt: map['createdAt'] as String,
      isSuspended: map['isSuspended'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory CompanyModel.fromJson(String source) =>
      CompanyModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CompanyModel(uid: $uid, companyName: $companyName, email: $email, contactNo: $contactNo, profilePic: $profilePic, role: $role, address: $address, createdAt: $createdAt, isSuspended: $isSuspended)';
  }

  @override
  bool operator ==(covariant CompanyModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.companyName == companyName &&
        other.email == email &&
        other.contactNo == contactNo &&
        other.profilePic == profilePic &&
        other.role == role &&
        other.address == address &&
        other.createdAt == createdAt &&
        other.isSuspended == isSuspended;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        companyName.hashCode ^
        email.hashCode ^
        contactNo.hashCode ^
        profilePic.hashCode ^
        role.hashCode ^
        address.hashCode ^
        createdAt.hashCode ^
        isSuspended.hashCode;
  }
}
