import 'dart:convert';

class CompanyStatsModel {
  final String uid;
  final int totalJobs;
  final int totalHired;
  final int totalPay;
  CompanyStatsModel({
    required this.uid,
    required this.totalJobs,
    required this.totalHired,
    required this.totalPay,
  });

  CompanyStatsModel copyWith({
    String? uid,
    int? totalJobs,
    int? totalHired,
    int? totalPay,
  }) {
    return CompanyStatsModel(
      uid: uid ?? this.uid,
      totalJobs: totalJobs ?? this.totalJobs,
      totalHired: totalHired ?? this.totalHired,
      totalPay: totalPay ?? this.totalPay,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'totalJobs': totalJobs,
      'totalHired': totalHired,
      'totalPay': totalPay,
    };
  }

  factory CompanyStatsModel.fromMap(Map<String, dynamic> map) {
    return CompanyStatsModel(
      uid: map['uid'] as String,
      totalJobs:
          (map['totalJobs'] is double)
              ? (map['totalJobs'] as double).toInt()
              : (map['totalJobs'] as num).toInt(),
      totalPay:
          (map['totalPay'] is double)
              ? (map['totalPay'] as double).toInt()
              : (map['totalPay'] as num).toInt(),
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
  String toString() {
    return 'CompanyStatsModel(uid: $uid, totalJobs: $totalJobs, totalHired: $totalHired, totalPay: $totalPay)';
  }

  @override
  bool operator ==(covariant CompanyStatsModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.totalJobs == totalJobs &&
        other.totalHired == totalHired &&
        other.totalPay == totalPay;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        totalJobs.hashCode ^
        totalHired.hashCode ^
        totalPay.hashCode;
  }
}
