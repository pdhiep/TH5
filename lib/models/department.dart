class Department {
  String? id;
  String name;

  Department({
    this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory Department.fromMap(String id, Map<String, dynamic> map) {
    return Department(
      id: id,
      name: map['name'] ?? '',
    );
  }
}
