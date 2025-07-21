import 'dart:convert';

class ShiftModel {
  final String shiftId;
  final String uid;
  final String jobId;
  final String startedTime;
  final String? endTime;
  final String latLong;
  final String? endLatLong; // Location when shift ends
  final String shiftDate; // Date in yyyy-MM-dd format for easy filtering
  final bool isVerified;

  ShiftModel({
    required this.shiftId,
    required this.uid,
    required this.jobId,
    required this.startedTime,
    this.endTime,
    required this.latLong,
    this.endLatLong,
    required this.shiftDate,
    required this.isVerified,
  });

  ShiftModel copyWith({
    String? shiftId,
    String? uid,
    String? jobId,
    String? startedTime,
    String? endTime,
    String? latLong,
    String? endLatLong,
    String? shiftDate,
    bool? isVerified,
  }) {
    return ShiftModel(
      shiftId: shiftId ?? this.shiftId,
      uid: uid ?? this.uid,
      jobId: jobId ?? this.jobId,
      startedTime: startedTime ?? this.startedTime,
      endTime: endTime ?? this.endTime,
      latLong: latLong ?? this.latLong,
      endLatLong: endLatLong ?? this.endLatLong,
      shiftDate: shiftDate ?? this.shiftDate,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'shiftId': shiftId,
      'uid': uid,
      'jobId': jobId,
      'startedTime': startedTime,
      'endTime': endTime,
      'latLong': latLong,
      'endLatLong': endLatLong,
      'shiftDate': shiftDate,
      'isVerified': isVerified,
    };
  }

  factory ShiftModel.fromMap(Map<String, dynamic> map) {
    return ShiftModel(
      shiftId: map['shiftId'] as String,
      uid: map['uid'] as String,
      jobId: map['jobId'] as String,
      startedTime: map['startedTime'] as String,
      endTime: map['endTime'] != null ? map['endTime'] as String : null,
      latLong: map['latLong'] as String,
      endLatLong:
          map['endLatLong'] != null ? map['endLatLong'] as String : null,
      shiftDate:
          map['shiftDate'] as String? ??
          DateTime.parse(
            map['startedTime'] as String,
          ).toIso8601String().substring(0, 10),
      isVerified: map['isVerified'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ShiftModel.fromJson(String source) =>
      ShiftModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant ShiftModel other) {
    if (identical(this, other)) return true;

    return other.shiftId == shiftId &&
        other.uid == uid &&
        other.jobId == jobId &&
        other.startedTime == startedTime &&
        other.endTime == endTime &&
        other.latLong == latLong &&
        other.endLatLong == endLatLong &&
        other.shiftDate == shiftDate &&
        other.isVerified == isVerified;
  }

  @override
  int get hashCode {
    return shiftId.hashCode ^
        uid.hashCode ^
        jobId.hashCode ^
        startedTime.hashCode ^
        endTime.hashCode ^
        latLong.hashCode ^
        endLatLong.hashCode ^
        shiftDate.hashCode ^
        isVerified.hashCode;
  }

  /// Check if this shift is for today
  bool get isToday {
    final now = DateTime.now();
    final todayStr = now.toIso8601String().substring(0, 10);
    return shiftDate == todayStr;
  }

  /// Check if this shift is completed
  bool get isCompleted {
    return endTime != null && endTime!.isNotEmpty;
  }

  /// Check if this shift is active (started but not ended)
  bool get isActive {
    return !isCompleted;
  }

  /// Get shift duration if completed
  Duration? get shiftDuration {
    if (!isCompleted) return null;

    try {
      final start = DateTime.parse(startedTime);
      final end = DateTime.parse(endTime!);
      return end.difference(start);
    } catch (e) {
      return null;
    }
  }
}
