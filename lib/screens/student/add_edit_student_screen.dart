import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/student.dart';
import '../../services/database_service.dart';
import '../../utils/utils.dart';

class AddEditStudentScreen extends StatefulWidget {
  final Student? student;

  const AddEditStudentScreen({super.key, this.student});

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _birthdayController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _gpaController;
  
  String _gender = 'Nam';
  String _className = 'IT01';
  String _status = 'Đang học';
  
  bool _isLoading = false;

  List<String> _classes = ['IT01', 'IT02', 'BA01', 'BA02', 'MK01'];
  final List<String> _statuses = ['Đang học', 'Bảo lưu', 'Đã tốt nghiệp', 'Thôi học'];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.student?.studentCode ?? '');
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _birthdayController = TextEditingController(text: widget.student?.birthday ?? '');
    _phoneController = TextEditingController(text: widget.student?.phone ?? '');
    _emailController = TextEditingController(text: widget.student?.email ?? '');
    _gpaController = TextEditingController(text: widget.student?.gpa.toString() ?? '');
    
    if (widget.student != null) {
      _gender = widget.student!.gender;
      _className = widget.student!.className;
      _status = widget.student!.status;
    }

    _loadClasses();
  }

  void _loadClasses() {
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    dbService.getClasses().listen((classes) {
      if (mounted) {
        setState(() {
          if (classes.isNotEmpty) {
            _classes = classes.map((c) => c.name).toList();
            // Ensure current class is in the list
            if (!_classes.contains(_className)) {
              _classes.add(_className);
            }
          }
        });
      }
    });
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      
      final student = Student(
        id: widget.student?.id,
        studentCode: _codeController.text.trim(),
        name: _nameController.text.trim(),
        birthday: _birthdayController.text.trim(),
        gender: _gender,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        className: _className,
        gpa: double.parse(_gpaController.text),
        status: _status,
      );

      try {
        if (widget.student == null) {
          await dbService.addStudent(student);
        } else {
          await dbService.updateStudent(student);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.student != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Cập nhật thông tin' : 'Thêm sinh viên mới'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Thông tin cơ bản'),
              const SizedBox(height: 16),
              _buildTextField(_codeController, 'Mã sinh viên', Icons.badge_outlined),
              _buildTextField(_nameController, 'Họ và tên', Icons.person_outline),
              _buildDateField(),
              _buildGenderRadio(),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Liên hệ'),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, 'Số điện thoại', Icons.phone_android_outlined, keyboardType: TextInputType.phone),
              _buildTextField(_emailController, 'Email', Icons.alternate_email_outlined, keyboardType: TextInputType.emailAddress, validator: ValidationUtils.validateEmail),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Học tập'),
              const SizedBox(height: 16),
              _buildDropdown('Lớp', _className, _classes, (val) => setState(() => _className = val!)),
              _buildTextField(_gpaController, 'GPA', Icons.analytics_outlined, keyboardType: TextInputType.number),
              _buildDropdown('Trạng thái', _status, _statuses, (val) => setState(() => _status = val!)),
              
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEdit ? 'Lưu thay đổi' : 'Thêm sinh viên', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, 
      {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
        ),
        validator: validator ?? (value) => ValidationUtils.validateNotEmpty(value, label),
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: _birthdayController,
        readOnly: true,
        onTap: _selectDate,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: 'Ngày sinh',
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          prefixIcon: const Icon(Icons.calendar_month_outlined, size: 20),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        validator: (value) => ValidationUtils.validateNotEmpty(value, 'Ngày sinh'),
      ),
    );
  }

  Widget _buildGenderRadio() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.wc_outlined, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text('Giới tính', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const Spacer(),
          _genderOption('Nam'),
          _genderOption('Nữ'),
        ],
      ),
    );
  }

  Widget _genderOption(String label) {
    bool isSelected = _gender == label;
    return GestureDetector(
      onTap: () => setState(() => _gender = label),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: value,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          prefixIcon: const Icon(Icons.layers_outlined, size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
