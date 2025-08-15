import 'dart:convert';

class CompanyStatsModel {
  final String uid;
  final int totalJobs;
  final int totalHired;
  CompanyStatsModel({
    required this.uid,
    required this.totalJobs,
    required this.totalHired,
  });

  CompanyStatsModel copyWith({
    String? uid,
    int? totalJobs,
    int? totalHired,
  }) {
    return CompanyStatsModel(
      uid: uid ?? this.uid,
      totalJobs: totalJobs ?? this.totalJobs,
      totalHired: totalHired ?? this.totalHired,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'totalJobs': totalJobs,
      'totalHired': totalHired,
    };
  }

  factory CompanyStatsModel.fromMap(Map<String, dynamic> map) {
    return CompanyStatsModel(
      uid: map['uid'] as String,
      totalJobs:
          (map['totalJobs'] is double)
              ? (map['totalJobs'] as double).toInt()
              : (map['totalJobs'] as num).toInt(),

      totalHired:
          (map['totalHired'] is double)
              ? (map['totalHired'] as double).toInt()
              : (map['totalHired'] as num).toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory CompanyStatsModel.fromJson(String source) =>
      CompanyStatsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant CompanyStatsModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.totalJobs == totalJobs &&
        other.totalHired == totalHired;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ totalJobs.hashCode ^ totalHired.hashCode;
  }
}
