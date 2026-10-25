import 'package:flutter/material.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';

/// Screen enabling faculty to mark daily class attendance with Present and Absent states,
/// supporting both individual student toggles and batch actions (Mark All Present / Absent).
class AttendanceScreen extends StatefulWidget {
  final List<Student> students;
  final void Function(String studentId, AttendanceStatus newStatus) onUpdateStatus;
  final void Function(AttendanceStatus newStatus) onMarkAllStatus;

  const AttendanceScreen({
    super.key,
    required this.students,
    required this.onUpdateStatus,
    required this.onMarkAllStatus,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _totalCount => widget.students.length;
  int get _presentCount =>
      widget.students.where((s) => s.status == AttendanceStatus.present).length;
  int get _absentCount =>
      widget.students.where((s) => s.status == AttendanceStatus.absent).length;
  double get _attendanceRate =>
      _totalCount > 0 ? (_presentCount / _totalCount) * 100 : 0.0;

  List<Student> get _filteredStudents {
    if (_searchQuery.isEmpty) return widget.students;
    final query = _searchQuery.toLowerCase();
    return widget.students.where((student) {
      return student.name.toLowerCase().contains(query) ||
          student.rollNumber.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 720;
        final horizontalPadding = isWideScreen ? 24.0 : 16.0;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16.0,
              ),
              children: [
                // 1. Session Information & Batch Actions Header
                _buildSessionHeader(isWideScreen),
                const SizedBox(height: 16),

                // 2. Real-time Attendance Metrics
                _buildSummaryCards(isWideScreen),
                const SizedBox(height: 16),

                // 3. Search Bar
                _buildSearchBar(),
                const SizedBox(height: 16),

                // 4. Section Subheader with Count
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Roll Call Register (${_filteredStudents.length} of $_totalCount)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Text(
                      'Tap Present or Absent to mark',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 5. Interactive Student Attendance Roster
                _buildAttendanceList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionHeader(bool isWideScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.how_to_reg_rounded,
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
                      'Mark Today\'s Attendance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Session: Morning Roll Call • CSE Section A',
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
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),

          // Batch Action Buttons
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  widget.onMarkAllStatus(AttendanceStatus.present);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Marked all students as Present!'),
                      backgroundColor: Color(0xFF2E7D32),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF2E7D32)),
                label: const Text('Mark All Present'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                  side: const BorderSide(color: Color(0xFFA5D6A7)),
                  backgroundColor: const Color(0xFFE8F5E9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  widget.onMarkAllStatus(AttendanceStatus.absent);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Marked all students as Absent!'),
                      backgroundColor: Color(0xFFC62828),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.cancel_outlined, size: 16, color: Color(0xFFC62828)),
                label: const Text('Mark All Absent'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC62828),
                  side: const BorderSide(color: Color(0xFFEF9A9A)),
                  backgroundColor: const Color(0xFFFFEBEE),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(bool isWideScreen) {
    final presentCard = StatCard(
      title: 'Present Today',
      value: '$_presentCount',
      icon: Icons.check_circle_rounded,
      iconColor: const Color(0xFF2E7D32),
      iconBackgroundColor: const Color(0xFFE8F5E9),
      badgeText: '${_attendanceRate.toStringAsFixed(0)}%',
      badgeColor: const Color(0xFFC8E6C9),
    );

    final absentCard = StatCard(
      title: 'Absent Today',
      value: '$_absentCount',
      icon: Icons.cancel_rounded,
      iconColor: const Color(0xFFC62828),
      iconBackgroundColor: const Color(0xFFFFEBEE),
      badgeText: '${(100 - _attendanceRate).toStringAsFixed(0)}%',
      badgeColor: const Color(0xFFFFCDD2),
    );

    final totalCard = StatCard(
      title: 'Total Enrolled',
      value: '$_totalCount',
      icon: Icons.groups_rounded,
      iconColor: AppTheme.primaryBlue,
      iconBackgroundColor: AppTheme.primaryLightBlue,
    );

    if (isWideScreen) {
      return Row(
        children: [
          Expanded(child: presentCard),
          const SizedBox(width: 12),
          Expanded(child: absentCard),
          const SizedBox(width: 12),
          Expanded(child: totalCard),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: presentCard),
          const SizedBox(width: 10),
          Expanded(child: absentCard),
        ],
      );
    }
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value.trim()),
      decoration: InputDecoration(
        hintText: 'Filter students by name or roll number...',
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

  Widget _buildAttendanceList() {
    if (_filteredStudents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: const Text(
          'No matching students found.',
          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
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
        final isPresent = student.status == AttendanceStatus.present;

        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              children: [
                // Initials Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isPresent
                      ? const Color(0xFFE3F2FD)
                      : const Color(0xFFF1F5F9),
                  child: Text(
                    student.initials,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isPresent
                          ? AppTheme.primaryBlue
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Roll Number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        student.rollNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Interactive Toggle Controls: Present vs Absent
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusToggleButton(
                      label: 'Present',
                      icon: Icons.check_circle_rounded,
                      isActive: isPresent,
                      activeColor: const Color(0xFF2E7D32),
                      activeBgColor: const Color(0xFFE8F5E9),
                      activeBorderColor: const Color(0xFFA5D6A7),
                      onTap: () => widget.onUpdateStatus(
                        student.id,
                        AttendanceStatus.present,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildStatusToggleButton(
                      label: 'Absent',
                      icon: Icons.cancel_rounded,
                      isActive: !isPresent,
                      activeColor: const Color(0xFFC62828),
                      activeBgColor: const Color(0xFFFFEBEE),
                      activeBorderColor: const Color(0xFFEF9A9A),
                      onTap: () => widget.onUpdateStatus(
                        student.id,
                        AttendanceStatus.absent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusToggleButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required Color activeBgColor,
    required Color activeBorderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeBgColor : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? activeBorderColor : AppTheme.borderLight,
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? activeColor : AppTheme.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeColor : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
