class Student {
  String? id;
  String studentCode;
  String name;
  String birthday;
  String gender;
  String phone;
  String email;
  String className;
  double gpa;
  String status;

  Student({
    this.id,
    required this.studentCode,
    required this.name,
    required this.birthday,
    required this.gender,
    required this.phone,
    required this.email,
    required this.className,
    required this.gpa,
    required this.status,
  });

  // Convert a Student object into a Map
  Map<String, dynamic> toMap() {
    return {
      'student_code': studentCode,
      'name': name,
      'birthday': birthday,
      'gender': gender,
      'phone': phone,
      'email': email,
      'class_name': className,
      'gpa': gpa,
      'status': status,
    };
  }

  // Extract a Student object from a Map
  factory Student.fromMap(String id, Map<String, dynamic> map) {
    // Helper function to safely parse GPA
    double parseGpa(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Student(
      id: id,
      studentCode: map['student_code'] ?? '',
      name: map['name'] ?? '',
      birthday: map['birthday'] ?? '',
      gender: map['gender'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? map['e-mail'] ?? '',
      className: map['class_name'] ?? '',
      gpa: parseGpa(map['gpa']),
      status: map['status'] ?? '',
    );
  }

  String get classification {
    if (gpa >= 3.6) return 'Xuất sắc';
    if (gpa >= 3.2) return 'Giỏi';
    if (gpa >= 2.5) return 'Khá';
    if (gpa >= 2.0) return 'Trung bình';
    return 'Yếu';
  }
}
