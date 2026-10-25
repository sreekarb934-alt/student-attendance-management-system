import 'package:flutter/material.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/student_attendance_tile.dart';

/// The primary Dashboard screen for the Student Attendance system.
/// Displays high-level attendance metrics, quick navigation shortcuts,
/// and the real-time student attendance list.
class DashboardScreen extends StatefulWidget {
  final List<Student>? students;
  final ValueChanged<int>? onNavigateToTab;
  final ValueChanged<String>? onToggleAttendance;

  const DashboardScreen({
    super.key,
    this.students,
    this.onNavigateToTab,
    this.onToggleAttendance,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Active filter: null = All, present, or absent
  AttendanceStatus? _filterStatus;

  // Use passed-in students if available, otherwise fall back to sample dataset
  List<Student> get _currentStudents =>
      widget.students ?? MockStudentData.students;

  int get _totalCount => _currentStudents.length;
  int get _presentCount =>
      _currentStudents.where((s) => s.status == AttendanceStatus.present).length;
  int get _absentCount =>
      _currentStudents.where((s) => s.status == AttendanceStatus.absent).length;

  double get _attendanceRate =>
      _totalCount > 0 ? (_presentCount / _totalCount) * 100 : 0.0;

  List<Student> get _filteredStudents {
    if (_filterStatus == null) return _currentStudents;
    return _currentStudents.where((s) => s.status == _filterStatus).toList();
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
                // 1. Welcome & Session Banner with Quick Actions
                _buildWelcomeHeader(isWideScreen),
                const SizedBox(height: 16),

                // 2. Summary Metric Cards (Total, Present, Absent)
                _buildSummaryCards(isWideScreen),
                const SizedBox(height: 16),

                // 3. Attendance Progress Indicator Card
                _buildProgressSummaryCard(),
                const SizedBox(height: 20),

                // 4. Section Title & Filter Chips
                _buildListHeader(isWideScreen),
                const SizedBox(height: 12),

                // 5. Student Attendance List
                _buildStudentList(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Header with date, class section, and quick navigation shortcuts
  Widget _buildWelcomeHeader(bool isWideScreen) {
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
                  Icons.calendar_today_rounded,
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
                      "Today's Attendance Overview",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Department of CSE • Section A',
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
          if (widget.onNavigateToTab != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                OutlinedButton.icon(
                  onPressed: () => widget.onNavigateToTab!(2), // Index 2 = Attendance
                  icon: const Icon(Icons.how_to_reg_rounded, size: 14),
                  label: const Text('Mark Attendance', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    side: const BorderSide(color: AppTheme.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => widget.onNavigateToTab!(1), // Index 1 = Students
                  icon: const Icon(Icons.people_alt_rounded, size: 14),
                  label: const Text('Students', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.borderLight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => widget.onNavigateToTab!(3), // Index 3 = Reports
                  icon: const Icon(Icons.analytics_rounded, size: 14),
                  label: const Text('Reports', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.borderLight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Responsive summary cards for Total, Present, and Absent counts
  Widget _buildSummaryCards(bool isWideScreen) {
    final totalCard = StatCard(
      title: 'Total Students',
      value: '$_totalCount',
      icon: Icons.groups_rounded,
      iconColor: AppTheme.primaryBlue,
      iconBackgroundColor: AppTheme.primaryLightBlue,
      badgeText: 'Enrolled',
    );

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

    if (isWideScreen) {
      // Wide layout: 3 cards in a horizontal Row
      return Row(
        children: [
          Expanded(child: totalCard),
          const SizedBox(width: 12),
          Expanded(child: presentCard),
          const SizedBox(width: 12),
          Expanded(child: absentCard),
        ],
      );
    } else {
      // Mobile layout: Total on top, Present & Absent side-by-side
      return Column(
        children: [
          totalCard,
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: presentCard),
              const SizedBox(width: 10),
              Expanded(child: absentCard),
            ],
          ),
        ],
      );
    }
  }

  /// Progress bar card showing overall attendance percentage
  Widget _buildProgressSummaryCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attendance Rate',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '$_presentCount/$_totalCount (${_attendanceRate.toStringAsFixed(0)}%)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _totalCount > 0 ? (_presentCount / _totalCount) : 0,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }

  /// Header for the student list with title and interactive filter chips
  Widget _buildListHeader(bool isWideScreen) {
    final titleWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Student Records',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primaryLightBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_filteredStudents.length}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
      ],
    );

    final filtersWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFilterChip(
          label: 'All',
          count: _totalCount,
          isSelected: _filterStatus == null,
          onSelected: () => setState(() => _filterStatus = null),
        ),
        const SizedBox(width: 6),
        _buildFilterChip(
          label: 'Present',
          count: _presentCount,
          isSelected: _filterStatus == AttendanceStatus.present,
          onSelected: () =>
              setState(() => _filterStatus = AttendanceStatus.present),
          activeColor: const Color(0xFF2E7D32),
        ),
        const SizedBox(width: 6),
        _buildFilterChip(
          label: 'Absent',
          count: _absentCount,
          isSelected: _filterStatus == AttendanceStatus.absent,
          onSelected: () =>
              setState(() => _filterStatus = AttendanceStatus.absent),
          activeColor: const Color(0xFFC62828),
        ),
      ],
    );

    if (isWideScreen) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          titleWidget,
          filtersWidget,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: filtersWidget,
          ),
        ],
      );
    }
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onSelected,
    Color? activeColor,
  }) {
    final effectiveColor = activeColor ?? AppTheme.primaryBlue;

    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? effectiveColor : AppTheme.borderLight,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? effectiveColor : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  /// List of students using reusable StudentAttendanceTile widgets
  Widget _buildStudentList() {
    if (_filteredStudents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: const Text(
          'No students match the selected filter.',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
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
