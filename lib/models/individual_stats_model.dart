import 'dart:convert';

class IndividualStatsModel {
  final String uid;
  final double totalHours;
  final int totalJobs;
  IndividualStatsModel({
    required this.uid,
    required this.totalHours,
    required this.totalJobs,
  });

  IndividualStatsModel copyWith({
    String? uid,
    double? totalHours,
    int? totalJobs,
    double? totalEarning,
  }) {
    return IndividualStatsModel(
      uid: uid ?? this.uid,
      totalHours: totalHours ?? this.totalHours,
      totalJobs: totalJobs ?? this.totalJobs,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'totalHours': totalHours,
      'totalJobs': totalJobs,
    };
  }

  factory IndividualStatsModel.fromMap(Map<String, dynamic> map) {
    return IndividualStatsModel(
      uid: map['uid'] as String,
      totalHours:
          (map['totalHours'] is int)
              ? (map['totalHours'] as int).toDouble()
              : (map['totalHours'] as num).toDouble(),
      totalJobs:
          (map['totalJobs'] is double)
              ? (map['totalJobs'] as double).toInt()
              : (map['totalJobs'] as num).toInt(),
    );
  }
  String toJson() => json.encode(toMap());

  factory IndividualStatsModel.fromJson(String source) =>
      IndividualStatsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant IndividualStatsModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.totalHours == totalHours &&
        other.totalJobs == totalJobs;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ totalHours.hashCode ^ totalJobs.hashCode;
  }
}
