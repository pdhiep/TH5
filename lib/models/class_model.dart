class ClassModel {
  String? id;
  String name;
  String departmentId;
  ClassModel({
    this.id,
    required this.name,
    required this.departmentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'departmentId': departmentId,
    };
  }

  factory ClassModel.fromMap(String id, Map<String, dynamic> map) {
    return ClassModel(
      id: id,
      name: map['name'] ?? '',
      departmentId: map['departmentId'] ?? '',
    );
  }
}
