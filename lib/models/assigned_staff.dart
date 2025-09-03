import 'dart:convert';

class AssignedStaff {
  final String id;
  final String email;
  final bool hasAccepted;
  AssignedStaff({
    required this.id,
    required this.email,
    required this.hasAccepted,
  });

  AssignedStaff copyWith({String? id, String? email, bool? hasAccepted}) {
    return AssignedStaff(
      id: id ?? this.id,
      email: email ?? this.email,
      hasAccepted: hasAccepted ?? this.hasAccepted,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'hasAccepted': hasAccepted,
    };
  }

  factory AssignedStaff.fromMap(Map<String, dynamic> map) {
    return AssignedStaff(
      id: map['id'] as String? ?? "",
      email: map['email'] as String? ?? "",
      hasAccepted: map['hasAccepted'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory AssignedStaff.fromJson(String source) =>
      AssignedStaff.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'AssignedStaff(id: $id, email: $email, hasAccepted: $hasAccepted)';

  @override
  bool operator ==(covariant AssignedStaff other) {
    if (identical(this, other)) return true;

    return other.id == id && other.email == email && other.hasAccepted;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ hasAccepted.hashCode;
}
