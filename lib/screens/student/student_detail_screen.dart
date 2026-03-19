import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student.dart';
import '../../services/database_service.dart';
import 'add_edit_student_screen.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ học tập'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditStudentScreen(student: student),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profile Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'avatar_${student.id}',
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    student.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.studentCode,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildChip(student.className, Icons.class_outlined, Colors.blue),
                      const SizedBox(width: 8),
                      _buildChip(student.status, Icons.info_outline, Colors.orange),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin chi tiết',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailCard(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInfoRow(context, Icons.calendar_today_rounded, 'Ngày sinh', student.birthday),
            _buildDivider(),
            _buildInfoRow(context, student.gender == 'Nam' ? Icons.male_rounded : Icons.female_rounded, 'Giới tính', student.gender),
            _buildDivider(),
            _buildInfoRow(context, Icons.phone_android_rounded, 'Số điện thoại', student.phone),
            _buildDivider(),
            _buildInfoRow(context, Icons.alternate_email_rounded, 'Email', student.email),
            _buildDivider(),
            _buildInfoRow(context, Icons.ads_click_rounded, 'Điểm GPA', student.gpa.toStringAsFixed(2), 
                valueStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _getGpaColor(student.gpa))),
            _buildDivider(),
            _buildInfoRow(context, Icons.verified_rounded, 'Xếp loại', student.classification, 
                valueStyle: TextStyle(fontWeight: FontWeight.bold, color: _getGpaColor(student.gpa))),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 32, color: Colors.grey.shade100);

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {TextStyle? valueStyle}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: valueStyle ?? const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Color _getGpaColor(double gpa) {
    if (gpa >= 3.6) return Colors.teal;
    if (gpa >= 3.2) return Colors.green;
    if (gpa >= 2.5) return Colors.orange;
    return Colors.red;
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sinh viên ${student.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              final dbService = Provider.of<DatabaseService>(context, listen: false);
              dbService.deleteStudent(student.id!);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close detail screen
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
