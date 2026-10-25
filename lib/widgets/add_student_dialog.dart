import 'package:flutter/material.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';

/// Modal dialog providing a validated form to enroll a new student.
/// Prevents duplicate roll numbers and enforces required fields.
class AddStudentDialog extends StatefulWidget {
  final List<Student> existingStudents;
  final ValueChanged<Student> onStudentAdded;

  const AddStudentDialog({
    super.key,
    required this.existingStudents,
    required this.onStudentAdded,
  });

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();

  String _selectedDepartment = 'CSE - Section A';
  AttendanceStatus _initialStatus = AttendanceStatus.present;

  final List<String> _departments = const [
    'CSE - Section A',
    'CSE - Section B',
    'ECE - Section A',
    'IT - Section A',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final rollNumber = _rollController.text.trim().toUpperCase();

      final now = DateTime.now();
      final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
      final period = now.hour >= 12 ? 'PM' : 'AM';
      final formattedTime =
          '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period';

      final newStudent = Student(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        rollNumber: rollNumber,
        department: _selectedDepartment,
        status: _initialStatus,
        timeMarked: _initialStatus == AttendanceStatus.present ? formattedTime : null,
      );

      widget.onStudentAdded(newStudent);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppTheme.surfaceWhite,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dialog Title Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLightBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: AppTheme.primaryBlue,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add New Student',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Enroll student and set initial status',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 14),

                  // Student Name Field
                  const Text(
                    'Full Name *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'e.g., Rohan Gupta',
                      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) {
                        return 'Please enter the student\'s name';
                      }
                      if (trimmed.length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Roll Number Field (with Duplicate Check)
                  const Text(
                    'Roll Number *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _rollController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'e.g., 21A91A0511',
                      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) {
                        return 'Please enter the roll number';
                      }
                      if (trimmed.length < 3) {
                        return 'Roll number must be at least 3 characters';
                      }
                      final isDuplicate = widget.existingStudents.any(
                        (s) => s.rollNumber.trim().toUpperCase() == trimmed.toUpperCase(),
                      );
                      if (isDuplicate) {
                        return 'A student with roll number "$trimmed" already exists';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Department Dropdown
                  const Text(
                    'Department / Section',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDepartment,
                    isExpanded: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.domain_outlined, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                      ),
                    ),
                    items: _departments.map((dept) {
                      return DropdownMenuItem<String>(
                        value: dept,
                        child: Text(dept, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedDepartment = val);
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // Initial Attendance Status Option
                  const Text(
                    'Initial Attendance Status',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<AttendanceStatus>(
                      segments: const [
                        ButtonSegment(
                          value: AttendanceStatus.present,
                          label: Text('Present'),
                          icon: Icon(Icons.check_circle_rounded, size: 16),
                        ),
                        ButtonSegment(
                          value: AttendanceStatus.absent,
                          label: Text('Absent'),
                          icon: Icon(Icons.cancel_rounded, size: 16),
                        ),
                      ],
                      selected: {_initialStatus},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _initialStatus = newSelection.first;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons (Cancel / Add Student)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Student'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
