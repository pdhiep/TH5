import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../models/class_model.dart';
import '../models/department.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _studentsRef => _db.collection('students');
  CollectionReference get _classesRef => _db.collection('classes');
  CollectionReference get _departmentsRef => _db.collection('departments');

  // --- Student CRUD ---
  Future<void> addStudent(Student student) => _studentsRef.add(student.toMap());
  Future<void> updateStudent(Student student) => _studentsRef.doc(student.id).update(student.toMap());

  Future<void> deleteStudent(String id) => _studentsRef.doc(id).delete();

  Stream<List<Student>> getStudents({String? classFilter, String? statusFilter, String? classificationFilter}) {
    Query query = _studentsRef;

    if (classFilter != null && classFilter != 'Tất cả') {
      query = query.where('class_name', isEqualTo: classFilter);
    }

  Future<void> updateStudent(Student student) =>
      _studentsRef.doc(student.id).update(student.toMap());
  Future<void> deleteStudent(String id) => _studentsRef.doc(id).delete();

  Stream<List<Student>> getStudents({
    String? classFilter,
    String? statusFilter,
    String? classificationFilter,
  }) {
    Query query = _studentsRef;
    if (classFilter != null && classFilter != 'Tất cả') {
      query = query.where('class_name', isEqualTo: classFilter);
    }
    if (statusFilter != null && statusFilter != 'Tất cả') {
      query = query.where('status', isEqualTo: statusFilter);
    }

    return query.snapshots().map((snapshot) {
      List<Student> students = snapshot.docs.map((doc) {
        return Student.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      if (classificationFilter != null && classificationFilter != 'Tất cả') {
        students = students.where((s) => s.classification == classificationFilter).toList();
      }

      return students;
    });
  }

  Stream<List<Student>> searchStudents(String query) {
    return _studentsRef
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) {
        return Student.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // --- Class CRUD ---
  Future<void> addClass(ClassModel classModel) => _classesRef.add(classModel.toMap());
  Future<void> updateClass(ClassModel classModel) => _classesRef.doc(classModel.id).update(classModel.toMap());
  Future<void> deleteClass(String id) => _classesRef.doc(id).delete();

  Stream<List<ClassModel>> getClasses() {
    return _classesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ClassModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<List<ClassModel>> searchClasses(String query) {
    return _classesRef
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ClassModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // --- Department CRUD ---
  Future<void> addDepartment(Department dept) => _departmentsRef.add(dept.toMap());
  Future<void> updateDepartment(Department dept) => _departmentsRef.doc(dept.id).update(dept.toMap());

  Future<void> deleteDepartment(String id) => _departmentsRef.doc(id).delete();

  Stream<List<Department>> getDepartments() {
    return _departmentsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Department.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // --- Statistics ---
  Stream<Map<String, dynamic>> getStatisticsStream() {
    return _studentsRef.snapshots().map((snapshot) {
      int total = snapshot.docs.length;
      if (total == 0) {
        return {
          'total': 0,
          'averageGpa': 0.0,
          'genderStats': {'Nam': 0, 'Nữ': 0},
          'classStats': <String, int>{},
        };
      }

      double totalGpa = 0;
      Map<String, int> genderStats = {'Nam': 0, 'Nữ': 0, 'Khác': 0};
      Map<String, int> classStats = {};
      Map<String, int> classificationStats = {'Xuất sắc': 0, 'Giỏi': 0, 'Khá': 0, 'Trung bình': 0, 'Yếu': 0};
      Map<String, int> classificationStats = {
        'Xuất sắc': 0,
        'Giỏi': 0,
        'Khá': 0,
        'Trung bình': 0,
        'Yếu': 0,
      };
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        Student student = Student.fromMap(doc.id, data);
        totalGpa += student.gpa;
        
        String gender = student.gender;
        genderStats[gender] = (genderStats[gender] ?? 0) + 1;
        

        totalGpa += student.gpa;

        String gender = student.gender;
        genderStats[gender] = (genderStats[gender] ?? 0) + 1;

        String className = student.className;
        classStats[className] = (classStats[className] ?? 0) + 1;

        String classification = student.classification;
        classificationStats[classification] = (classificationStats[classification] ?? 0) + 1;
      }

      return {
        'total': total,
        'averageGpa': totalGpa / total,
        'genderStats': genderStats,
        'classStats': classStats,
        'classificationStats': classificationStats,
      };
    });
  }

  Future<Map<String, dynamic>> getStatistics() async {
    QuerySnapshot snapshot = await _studentsRef.get();
    // ... implementation same as above or just return first from stream
    return getStatisticsStream().first;
  }
}
