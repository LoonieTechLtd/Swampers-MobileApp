import 'dart:convert';

class JobsTemplateModel {
  final String jobRoleId;
  final String roleName;
  final String prefixImage;
  final String createdAt;
  JobsTemplateModel({
    required this.jobRoleId,
    required this.roleName,
    required this.prefixImage,
    required this.createdAt,
  });

  JobsTemplateModel copyWith({
    String? jobRoleId,
    String? roleName,
    String? prefixImage,
    String? createdAt,
  }) {
    return JobsTemplateModel(
      jobRoleId: jobRoleId ?? this.jobRoleId,
      roleName: roleName ?? this.roleName,
      prefixImage: prefixImage ?? this.prefixImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'jobRoleId': jobRoleId,
      'roleName': roleName,
      'prefixImage': prefixImage,
      'createdAt': createdAt,
    };
  }

  factory JobsTemplateModel.fromMap(Map<String, dynamic> map) {
    return JobsTemplateModel(
      jobRoleId: map['jobRoleId'] as String,
      roleName: map['roleName'] as String,
      prefixImage: map['prefixImage'] as String,
      createdAt: map['createdAt'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory JobsTemplateModel.fromJson(String source) => JobsTemplateModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'JobsTemplateModel(jobRoleId: $jobRoleId, roleName: $roleName, prefixImage: $prefixImage, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant JobsTemplateModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.jobRoleId == jobRoleId &&
      other.roleName == roleName &&
      other.prefixImage == prefixImage &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return jobRoleId.hashCode ^
      roleName.hashCode ^
      prefixImage.hashCode ^
      createdAt.hashCode;
  }
}
