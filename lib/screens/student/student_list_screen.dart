import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student.dart';
import '../../models/class_model.dart';
import '../../services/database_service.dart';
import '../../widgets/student_card.dart';
import 'add_edit_student_screen.dart';
import 'student_detail_screen.dart';

class StudentListScreen extends StatefulWidget {
  final String? initialClassFilter;
  const StudentListScreen({super.key, this.initialClassFilter});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  String _searchQuery = '';
  late String _classFilter;
  String _statusFilter = 'Tất cả';
  String _classificationFilter = 'Tất cả';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _classFilter = widget.initialClassFilter ?? 'Tất cả';
  }
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sinh viên'),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, 
                color: (_classFilter != 'Tất cả' || _statusFilter != 'Tất cả' || _classificationFilter != 'Tất cả') 
                    ? colorScheme.primary 
                    : null),
            onPressed: () => _showFilterSheet(context, dbService),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Fixed Search Bar at Top
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sinh viên...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
          ),
          
          // Filter Chips Summary
          if (_classFilter != 'Tất cả' || _statusFilter != 'Tất cả' || _classificationFilter != 'Tất cả')
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  if (_classFilter != 'Tất cả') _buildActiveFilterChip(_classFilter, () => setState(() => _classFilter = 'Tất cả')),
                  if (_statusFilter != 'Tất cả') _buildActiveFilterChip(_statusFilter, () => setState(() => _statusFilter = 'Tất cả')),
                  if (_classificationFilter != 'Tất cả') _buildActiveFilterChip(_classificationFilter, () => setState(() => _classificationFilter = 'Tất cả')),
                ],
              ),
            ),

          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: _searchQuery.isEmpty 
                ? dbService.getStudents(
                    classFilter: _classFilter, 
                    statusFilter: _statusFilter,
                    classificationFilter: _classificationFilter) 
                : dbService.searchStudents(_searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
                }
                
                final students = snapshot.data ?? [];
                
                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('Không tìm thấy sinh viên nào', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }
  
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return StudentCard(
                      student: student,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentDetailScreen(student: student),
                          ),
                        );
                      },
                      onDelete: () {
                        _confirmDelete(context, dbService, student);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditStudentScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm mới'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onDeleted) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onDeleted,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Theme.of(context).dividerColor)),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, DatabaseService dbService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bộ lọc sinh viên', 
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _classFilter = 'Tất cả';
                            _statusFilter = 'Tất cả';
                            _classificationFilter = 'Tất cả';
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Đặt lại'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Lớp học', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  StreamBuilder<List<ClassModel>>(
                    stream: dbService.getClasses(),
                    builder: (context, snapshot) {
                      List<String> classes = ['Tất cả'];
                      if (snapshot.hasData) {
                        classes.addAll(snapshot.data!.map((c) => c.name));
                      }
                      
                      return Wrap(
                        spacing: 8,
                        children: classes.map((c) => ChoiceChip(
                          label: Text(c, style: TextStyle(
                            color: _classFilter == c ? Theme.of(context).colorScheme.onPrimary : null,
                          )),
                          selected: _classFilter == c,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          onSelected: (selected) {
                            setModalState(() => _classFilter = c);
                            setState(() => _classFilter = c);
                          },
                        )).toList(),
                      );
                    }
                  ),
                  const SizedBox(height: 20),
                  const Text('Học lực', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: ['Tất cả', 'Xuất sắc', 'Giỏi', 'Khá', 'Trung bình', 'Yếu']
                        .map((c) => ChoiceChip(
                      label: Text(c, style: TextStyle(
                        color: _classificationFilter == c ? Theme.of(context).colorScheme.onPrimary : null,
                      )),
                      selected: _classificationFilter == c,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      onSelected: (selected) {
                        setModalState(() => _classificationFilter = c);
                        setState(() => _classificationFilter = c);
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: ['Tất cả', 'Đang học', 'Bảo lưu', 'Đã tốt nghiệp', 'Thôi học']
                        .map((s) => ChoiceChip(
                      label: Text(s, style: TextStyle(
                        color: _statusFilter == s ? Theme.of(context).colorScheme.onPrimary : null,
                      )),
                      selected: _statusFilter == s,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      onSelected: (selected) {
                        setModalState(() => _statusFilter = s);
                        setState(() => _statusFilter = s);
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Áp dụng'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, DatabaseService dbService, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sinh viên ${student.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              dbService.deleteStudent(student.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa ${student.name}')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
