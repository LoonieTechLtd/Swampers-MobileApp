import 'dart:convert';
import 'package:swamper_solution/models/job_model.dart';

class JobApplicationModel {
  final String applicationId;
  final String applicantId;
  final String appliedDate;
  final String selectedShift;
  final String resume;
  final String applicationStatus;
  final JobModel jobDetails;
  final bool isQuickApplied;
  JobApplicationModel({
    required this.applicationId,
    required this.applicantId,
    required this.appliedDate,
    required this.selectedShift,
    required this.resume,
    required this.applicationStatus,
    required this.jobDetails,
    required this.isQuickApplied,
  });

  JobApplicationModel copyWith({
    String? applicationId,
    String? applicantId,
    String? appliedDate,
    String? selectedShift,
    String? resume,
    String? applicationStatus,
    JobModel? jobDetails,
    bool? isQuickApplied,
  }) {
    return JobApplicationModel(
      applicationId: applicationId ?? this.applicationId,
      applicantId: applicantId ?? this.applicantId,
      appliedDate: appliedDate ?? this.appliedDate,
      selectedShift: selectedShift ?? this.selectedShift,
      resume: resume ?? this.resume,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      jobDetails: jobDetails ?? this.jobDetails,
      isQuickApplied: isQuickApplied ?? this.isQuickApplied,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'applicationId': applicationId,
      'applicantId': applicantId,
      'appliedDate': appliedDate,
      'selectedShift': selectedShift,
      'resume': resume,
      'applicationStatus': applicationStatus,
      'jobDetails': jobDetails.toMap(),
      'isQuickApplied': isQuickApplied,
    };
  }

  factory JobApplicationModel.fromMap(Map<String, dynamic> map) {
    return JobApplicationModel(
      applicationId: map['applicationId'] as String,
      applicantId: map['applicantId'] as String,
      appliedDate: map['appliedDate'] as String,
      selectedShift: map['selectedShift'] as String,
      resume: map['resume'] as String,
      applicationStatus: map['applicationStatus'] as String,
      jobDetails: JobModel.fromMap(map['jobDetails'] as Map<String, dynamic>),
      isQuickApplied: map['isQuickApplied'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory JobApplicationModel.fromJson(String source) =>
      JobApplicationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant JobApplicationModel other) {
    if (identical(this, other)) return true;

    return other.applicationId == applicationId &&
        other.applicantId == applicantId &&
        other.appliedDate == appliedDate &&
        other.selectedShift == selectedShift &&
        other.resume == resume &&
        other.applicationStatus == applicationStatus &&
        other.jobDetails == jobDetails &&
        other.isQuickApplied == isQuickApplied;
  }

  @override
  int get hashCode {
    return applicationId.hashCode ^
        applicantId.hashCode ^
        appliedDate.hashCode ^
        selectedShift.hashCode ^
        resume.hashCode ^
        applicationStatus.hashCode ^
        jobDetails.hashCode ^
        isQuickApplied.hashCode;
  }
}
