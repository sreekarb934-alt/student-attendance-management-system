import 'package:flutter/material.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';
import '../widgets/add_student_dialog.dart';
import '../widgets/student_attendance_tile.dart';

/// Screen displaying the complete student roster with search functionality
/// and a validated form dialog to register new students.
class StudentsScreen extends StatefulWidget {
  final List<Student> students;
  final ValueChanged<Student> onAddStudent;
  final ValueChanged<String>? onToggleAttendance;

  const StudentsScreen({
    super.key,
    required this.students,
    required this.onAddStudent,
    this.onToggleAttendance,
  });

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Student> get _filteredStudents {
    if (_searchQuery.isEmpty) return widget.students;
    final query = _searchQuery.toLowerCase();
    return widget.students.where((student) {
      final nameMatches = student.name.toLowerCase().contains(query);
      final rollMatches = student.rollNumber.toLowerCase().contains(query);
      final deptMatches = student.department.toLowerCase().contains(query);
      return nameMatches || rollMatches || deptMatches;
    }).toList();
  }

  void _openAddStudentDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddStudentDialog(
        existingStudents: widget.students,
        onStudentAdded: (newStudent) {
          widget.onAddStudent(newStudent);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${newStudent.name} (${newStudent.rollNumber}) added successfully!'),
              backgroundColor: AppTheme.primaryBlue,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 720;
        final horizontalPadding = isWideScreen ? 24.0 : 16.0;

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openAddStudentDialog,
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Add Student'),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16.0,
                ),
                children: [
                  // 1. Directory Header with Action
                  _buildHeader(isWideScreen),
                  const SizedBox(height: 16),

                  // 2. Search & Filter Bar
                  _buildSearchBar(),
                  const SizedBox(height: 16),

                  // 3. Student Count Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _searchQuery.isEmpty
                            ? 'All Enrolled Students (${widget.students.length})'
                            : 'Search Results (${_filteredStudents.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                          child: const Text('Clear Search'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 4. Student Roster List
                  _buildStudentRoster(),
                  const SizedBox(height: 80), // Extra space for FloatingActionButton
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isWideScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryLightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: AppTheme.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Directory',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Manage registered students, view sections, and enroll new students',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isWideScreen)
            ElevatedButton.icon(
              onPressed: _openAddStudentDialog,
              icon: const Icon(Icons.person_add_alt_1, size: 16),
              label: const Text('Add Student'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value.trim()),
      decoration: InputDecoration(
        hintText: 'Search by student name, roll number, or department...',
        hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
        prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.textSecondary),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              )
            : null,
        filled: true,
        fillColor: AppTheme.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildStudentRoster() {
    if (_filteredStudents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(36),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isEmpty
                  ? 'No students enrolled yet.'
                  : 'No students found matching "$_searchQuery".',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Click "Add Student" to register a new student.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredStudents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        return StudentAttendanceTile(
          student: student,
          onToggleStatus: widget.onToggleAttendance != null
              ? () => widget.onToggleAttendance!(student.id)
              : null,
        );
      },
    );
  }
}
