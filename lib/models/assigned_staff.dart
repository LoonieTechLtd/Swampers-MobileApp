import 'dart:convert';

class AssignedStaff {
  final String id;
  final String email;
  AssignedStaff({
    required this.id,
    required this.email,
  });

  AssignedStaff copyWith({
    String? id,
    String? email,
  }) {
    return AssignedStaff(
      id: id ?? this.id,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
    };
  }

  factory AssignedStaff.fromMap(Map<String, dynamic> map) {
    return AssignedStaff(
      id: map['id'] as String? ?? "",
      email: map['email'] as String? ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory AssignedStaff.fromJson(String source) => AssignedStaff.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'AssignedStaff(id: $id, email: $email)';

  @override
  bool operator ==(covariant AssignedStaff other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
