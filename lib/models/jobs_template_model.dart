import 'dart:convert';

class JobsTemplateModel {
  final String jobId;
  final String roleName;
  final String prefixImage;
  JobsTemplateModel({
    required this.jobId,
    required this.roleName,
    required this.prefixImage,
  });

  JobsTemplateModel copyWith({
    String? jobId,
    String? roleName,
    String? prefixImage,
  }) {
    return JobsTemplateModel(
      jobId: jobId ?? this.jobId,
      roleName: roleName ?? this.roleName,
      prefixImage: prefixImage ?? this.prefixImage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'jobId': jobId,
      'roleName': roleName,
      'prefixImage': prefixImage,
    };
  }

  factory JobsTemplateModel.fromMap(Map<String, dynamic> map) {
    return JobsTemplateModel(
      jobId: map['jobId'] as String,
      roleName: map['roleName'] as String,
      prefixImage: map['prefixImage'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory JobsTemplateModel.fromJson(String source) => JobsTemplateModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'JobsTemplateModel(jobId: $jobId, roleName: $roleName, prefixImage: $prefixImage)';

  @override
  bool operator ==(covariant JobsTemplateModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.jobId == jobId &&
      other.roleName == roleName &&
      other.prefixImage == prefixImage;
  }

  @override
  int get hashCode => jobId.hashCode ^ roleName.hashCode ^ prefixImage.hashCode;
}
