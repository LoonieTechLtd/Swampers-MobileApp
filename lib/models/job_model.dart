// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:swamper_solution/models/assigned_staff.dart';

class JobModel {
  final String jobId;
  final String role;
  final int noOfWorkers;
  final List<String> shifts;
  final String location;
  final String description;
  final List<String> images;
  final String postedDate;
  final String companyId;
  final double hourlyIncome;
  final String jobStatus;
  final String days;
  final String? messageToAdmin;
  final List<AssignedStaff> assignedStaffs;
  final List<String>? appliedUsers;
  JobModel({
    required this.jobId,
    required this.role,
    required this.noOfWorkers,
    required this.shifts,
    required this.location,
    required this.description,
    required this.images,
    required this.postedDate,
    required this.companyId,
    required this.hourlyIncome,
    required this.jobStatus,
    required this.days,
    this.messageToAdmin,
    required this.assignedStaffs,
    this.appliedUsers,
  });

  JobModel copyWith({
    String? jobId,
    String? role,
    int? noOfWorkers,
    List<String>? shifts,
    String? location,
    String? description,
    List<String>? images,
    String? postedDate,
    String? companyId,
    double? hourlyIncome,
    String? jobStatus,
    String? days,
    String? messageToAdmin,
    List<AssignedStaff>? assignedStaffs,
    List<String>? appliedUsers,
  }) {
    return JobModel(
      jobId: jobId ?? this.jobId,
      role: role ?? this.role,
      noOfWorkers: noOfWorkers ?? this.noOfWorkers,
      shifts: shifts ?? this.shifts,
      location: location ?? this.location,
      description: description ?? this.description,
      images: images ?? this.images,
      postedDate: postedDate ?? this.postedDate,
      companyId: companyId ?? this.companyId,
      hourlyIncome: hourlyIncome ?? this.hourlyIncome,
      jobStatus: jobStatus ?? this.jobStatus,
      days: days ?? this.days,
      messageToAdmin: messageToAdmin ?? this.messageToAdmin,
      assignedStaffs: assignedStaffs ?? this.assignedStaffs,
      appliedUsers: appliedUsers ?? this.appliedUsers,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'jobId': jobId,
      'role': role,
      'noOfWorkers': noOfWorkers,
      'shifts': shifts,
      'location': location,
      'description': description,
      'images': images,
      'postedDate': postedDate,
      'companyId': companyId,
      'hourlyIncome': hourlyIncome,
      'jobStatus': jobStatus,
      'days': days,
      'messageToAdmin': messageToAdmin ?? "",
      'assignedStaffs': assignedStaffs.map((s) => s.toMap()).toList(),
      'appliedUsers': appliedUsers ?? [],
    };
  }

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      jobId: map['jobId'] as String,
      role: map['role'] as String,
      noOfWorkers: map['noOfWorkers'] as int,
      shifts: List<String>.from(
        (map['shifts'] as List<dynamic>).map((e) => e.toString()).toList(),
      ),
      location: map['location'] as String,
      description: map['description'] as String,
      images: List<String>.from(
        (map['images'] as List<dynamic>).map((e) => e.toString()).toList(),
      ),
      postedDate: map['postedDate'] as String,
      companyId: map['companyId'] as String,
      hourlyIncome:
          (map['hourlyIncome'] is int)
              ? (map['hourlyIncome'] as int).toDouble()
              : (map['hourlyIncome'] as num).toDouble(),
      jobStatus: map['jobStatus'] as String,
      days: map['days'] as String,
      messageToAdmin: map['messageToAdmin'] as String? ?? "",
      assignedStaffs:
          (map['assignedStaffs'] as List<dynamic>? ?? [])
              .map((e) => AssignedStaff.fromMap(e as Map<String, dynamic>))
              .toList(),
      appliedUsers: List<String>.from(
        (map['appliedUsers'] as List<dynamic>)
            .map((e) => e.toString())
            .toList(),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory JobModel.fromJson(String source) =>
      JobModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'JobModel(jobId: $jobId, role: $role, noOfWorkers: $noOfWorkers, shifts: $shifts, location: $location, description: $description, images: $images, postedDate: $postedDate, companyId: $companyId, hourlyIncome: $hourlyIncome, jobStatus: $jobStatus, days: $days, messageToAdmin: $messageToAdmin, assignedStaffs: $assignedStaffs, appliedUsers: $appliedUsers)';
  }

  @override
  bool operator ==(covariant JobModel other) {
    if (identical(this, other)) return true;

    return other.jobId == jobId &&
        other.role == role &&
        other.noOfWorkers == noOfWorkers &&
        listEquals(other.shifts, shifts) &&
        other.location == location &&
        other.description == description &&
        listEquals(other.images, images) &&
        other.postedDate == postedDate &&
        other.companyId == companyId &&
        other.hourlyIncome == hourlyIncome &&
        other.jobStatus == jobStatus &&
        other.days == days &&
        other.messageToAdmin == messageToAdmin &&
        listEquals(other.assignedStaffs, assignedStaffs) &&
        listEquals(other.appliedUsers, appliedUsers);
  }

  @override
  int get hashCode {
    return jobId.hashCode ^
        role.hashCode ^
        noOfWorkers.hashCode ^
        shifts.hashCode ^
        location.hashCode ^
        description.hashCode ^
        images.hashCode ^
        postedDate.hashCode ^
        companyId.hashCode ^
        hourlyIncome.hashCode ^
        jobStatus.hashCode ^
        days.hashCode ^
        messageToAdmin.hashCode ^
        assignedStaffs.hashCode ^
        appliedUsers.hashCode;
  }
}
