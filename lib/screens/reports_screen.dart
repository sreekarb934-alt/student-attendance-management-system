import 'package:flutter/material.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/student_attendance_tile.dart';

/// Screen displaying comprehensive attendance analytics, department-level summaries,
/// and student-wise attendance status breakdowns for the active session.
class ReportsScreen extends StatefulWidget {
  final List<Student> students;
  final ValueChanged<int>? onNavigateToTab;

  const ReportsScreen({
    super.key,
    required this.students,
    this.onNavigateToTab,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // Status filter for the student breakdown: null = All, present, or absent
  AttendanceStatus? _filterStatus;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Aggregate Metrics (Guarded against division-by-zero) ---
  int get _totalCount => widget.students.length;
  int get _presentCount =>
      widget.students.where((s) => s.status == AttendanceStatus.present).length;
  int get _absentCount =>
      widget.students.where((s) => s.status == AttendanceStatus.absent).length;

  double get _overallAttendanceRate =>
      _totalCount > 0 ? (_presentCount / _totalCount) * 100 : 0.0;

  // --- Department Grouping ---
  Map<String, List<Student>> get _studentsByDepartment {
    final grouped = <String, List<Student>>{};
    for (final student in widget.students) {
      grouped.putIfAbsent(student.department, () => []).add(student);
    }
    return grouped;
  }

  // --- Filtered Student List ---
  List<Student> get _filteredStudents {
    return widget.students.where((student) {
      final matchesStatus =
          _filterStatus == null || student.status == _filterStatus;
      if (!matchesStatus) return false;

      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final nameMatches = student.name.toLowerCase().contains(q);
      final rollMatches = student.rollNumber.toLowerCase().contains(q);
      final deptMatches = student.department.toLowerCase().contains(q);
      return nameMatches || rollMatches || deptMatches;
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
                // 1. Session Snapshot Scope Notice
                _buildSessionNoticeHeader(),
                const SizedBox(height: 16),

                // 2. High-Level Summary KPI Cards
                _buildMetricCards(isWideScreen),
                const SizedBox(height: 16),

                // 3. Overall Attendance Distribution Bar & Chart
                _buildDistributionChartCard(isWideScreen),
                const SizedBox(height: 18),

                // 4. Department-Wise Attendance Summaries
                _buildDepartmentBreakdownSection(isWideScreen),
                const SizedBox(height: 22),

                // 5. Student-Wise Attendance Breakdown Register
                _buildStudentWiseBreakdownHeader(isWideScreen),
                const SizedBox(height: 12),

                // 6. Student Roster with Filters
                _buildStudentList(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Informational header clarifying that reports reflect the current in-memory session snapshot.
  Widget _buildSessionNoticeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryLightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: AppTheme.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    const Text(
                      'Attendance Analytics & Reports',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLightBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Session Snapshot',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Metrics reflect live class attendance records. In-memory data updates in real-time as students are enrolled or statuses are marked.',
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
    );
  }

  /// High-level summary KPI cards for Total, Present, Absent, and Percentage.
  Widget _buildMetricCards(bool isWideScreen) {
    final rateString = _totalCount > 0
        ? '${_overallAttendanceRate.toStringAsFixed(1)}%'
        : '0.0%';

    final totalCard = StatCard(
      title: 'Total Enrolled',
      value: '$_totalCount',
      icon: Icons.groups_rounded,
      iconColor: AppTheme.primaryBlue,
      iconBackgroundColor: AppTheme.primaryLightBlue,
      badgeText: 'Active',
    );

    final presentCard = StatCard(
      title: 'Present Today',
      value: '$_presentCount',
      icon: Icons.check_circle_rounded,
      iconColor: const Color(0xFF2E7D32),
      iconBackgroundColor: const Color(0xFFE8F5E9),
      badgeText: _totalCount > 0 ? '${_overallAttendanceRate.toStringAsFixed(0)}%' : '0%',
      badgeColor: const Color(0xFFC8E6C9),
    );

    final absentCard = StatCard(
      title: 'Absent Today',
      value: '$_absentCount',
      icon: Icons.cancel_rounded,
      iconColor: const Color(0xFFC62828),
      iconBackgroundColor: const Color(0xFFFFEBEE),
      badgeText: _totalCount > 0 ? '${(100 - _overallAttendanceRate).toStringAsFixed(0)}%' : '0%',
      badgeColor: const Color(0xFFFFCDD2),
    );

    final rateCard = StatCard(
      title: 'Attendance Rate',
      value: rateString,
      icon: Icons.pie_chart_rounded,
      iconColor: _overallAttendanceRate >= 75.0
          ? const Color(0xFF2E7D32)
          : (_overallAttendanceRate >= 50.0
              ? const Color(0xFFE65100)
              : const Color(0xFFC62828)),
      iconBackgroundColor: _overallAttendanceRate >= 75.0
          ? const Color(0xFFE8F5E9)
          : (_overallAttendanceRate >= 50.0
              ? const Color(0xFFFFF3E0)
              : const Color(0xFFFFEBEE)),
      badgeText: _overallAttendanceRate >= 75.0
          ? 'Healthy'
          : (_totalCount == 0 ? 'No Data' : 'Shortage'),
      badgeColor: _overallAttendanceRate >= 75.0
          ? const Color(0xFFC8E6C9)
          : (_totalCount == 0
              ? const Color(0xFFE2E8F0)
              : const Color(0xFFFFCDD2)),
    );

    if (isWideScreen) {
      return Row(
        children: [
          Expanded(child: totalCard),
          const SizedBox(width: 12),
          Expanded(child: presentCard),
          const SizedBox(width: 12),
          Expanded(child: absentCard),
          const SizedBox(width: 12),
          Expanded(child: rateCard),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: totalCard),
              const SizedBox(width: 10),
              Expanded(child: rateCard),
            ],
          ),
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

  /// Visual stacked progress chart illustrating the ratio of present vs. absent students.
  Widget _buildDistributionChartCard(bool isWideScreen) {
    final presentFraction = _totalCount > 0 ? (_presentCount / _totalCount) : 0.0;
    final absentFraction = _totalCount > 0 ? (_absentCount / _totalCount) : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              const Text(
                'Overall Attendance Ratio',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _overallAttendanceRate >= 75.0
                      ? AppTheme.statusPresentBg
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _overallAttendanceRate >= 75.0
                        ? AppTheme.statusPresentBorder
                        : const Color(0xFFFFB74D),
                  ),
                ),
                child: Text(
                  _totalCount == 0
                      ? 'No Data'
                      : (_overallAttendanceRate >= 75.0
                          ? 'Standard Met (≥75%)'
                          : 'Attendance Shortage (<75%)'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _overallAttendanceRate >= 75.0
                        ? AppTheme.statusPresentText
                        : const Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Visual Segmented Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: _totalCount == 0
                  ? Container(color: const Color(0xFFE2E8F0))
                  : Row(
                      children: [
                        if (presentFraction > 0)
                          Expanded(
                            flex: (_presentCount * 100).toInt(),
                            child: Container(
                              color: const Color(0xFF2E7D32), // Green for present
                            ),
                          ),
                        if (absentFraction > 0)
                          Expanded(
                            flex: (_absentCount * 100).toInt(),
                            child: Container(
                              color: const Color(0xFFC62828), // Red for absent
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // Chart Legends
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _buildChartLegend(
                color: const Color(0xFF2E7D32),
                label: 'Present: $_presentCount (${_totalCount > 0 ? _overallAttendanceRate.toStringAsFixed(1) : '0.0'}%)',
              ),
              _buildChartLegend(
                color: const Color(0xFFC62828),
                label: 'Absent: $_absentCount (${_totalCount > 0 ? (100 - _overallAttendanceRate).toStringAsFixed(1) : '0.0'}%)',
              ),
              _buildChartLegend(
                color: AppTheme.textSecondary,
                label: 'Total Enrolled: $_totalCount',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Department-wise breakdown cards grouped by actual student department data.
  Widget _buildDepartmentBreakdownSection(bool isWideScreen) {
    if (widget.students.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Column(
          children: [
            const Icon(Icons.school_outlined, size: 40, color: AppTheme.textMuted),
            const SizedBox(height: 8),
            const Text(
              'No Department Data Available',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enroll students in the Students directory to view department statistics.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (widget.onNavigateToTab != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => widget.onNavigateToTab!(1),
                icon: const Icon(Icons.person_add_alt_1, size: 16),
                label: const Text('Add Students'),
              ),
            ],
          ],
        ),
      );
    }

    final departments = _studentsByDepartment.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            const Text(
              'Department-Wise Attendance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryLightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${departments.length} Department${departments.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Responsive grid / column of Department Cards
        if (isWideScreen && departments.length >= 2)
          LayoutBuilder(
            builder: (context, deptConstraints) {
              final cardWidth = (deptConstraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: departments.map((entry) {
                  return SizedBox(
                    width: cardWidth > 320 ? cardWidth : deptConstraints.maxWidth,
                    child: _buildDepartmentCard(entry.key, entry.value),
                  );
                }).toList(),
              );
            },
          )
        else
          Column(
            children: departments.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _buildDepartmentCard(entry.key, entry.value),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildDepartmentCard(String departmentName, List<Student> studentsInDept) {
    final deptTotal = studentsInDept.length;
    final deptPresent =
        studentsInDept.where((s) => s.status == AttendanceStatus.present).length;
    final deptAbsent =
        studentsInDept.where((s) => s.status == AttendanceStatus.absent).length;
    final deptRate = deptTotal > 0 ? (deptPresent / deptTotal) * 100 : 0.0;
    final isHealthy = deptRate >= 75.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Department Name & Status Pill
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLightBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.domain_rounded,
                        size: 18,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 190),
                      child: Text(
                        departmentName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isHealthy ? AppTheme.statusPresentBg : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isHealthy
                          ? AppTheme.statusPresentBorder
                          : const Color(0xFFEF9A9A),
                    ),
                  ),
                  child: Text(
                    isHealthy ? 'Healthy' : 'Below 75%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isHealthy
                          ? AppTheme.statusPresentText
                          : const Color(0xFFC62828),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: deptTotal > 0 ? (deptPresent / deptTotal) : 0,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isHealthy ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                ),
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 10),

            // Metrics Row
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                Text(
                  'Present: $deptPresent of $deptTotal',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Text(
                  'Absent: $deptAbsent',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFC62828),
                  ),
                ),
                Text(
                  '${deptRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isHealthy ? AppTheme.primaryBlue : const Color(0xFFC62828),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Header for the student-wise breakdown with search bar and filter chips.
  Widget _buildStudentWiseBreakdownHeader(bool isWideScreen) {
    final titleWidget = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        const Text(
          'Student-Wise Attendance Register',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isWideScreen)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [titleWidget, filtersWidget],
          )
        else ...[
          titleWidget,
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: filtersWidget,
          ),
        ],
        const SizedBox(height: 12),

        // Search Field
        TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val.trim()),
          decoration: InputDecoration(
            hintText: 'Search breakdown by student name or roll number...',
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
        ),
      ],
    );
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

  /// List of student attendance records using the reusable StudentAttendanceTile.
  Widget _buildStudentList() {
    if (_filteredStudents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 36, color: AppTheme.textMuted),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'No students found for the selected status filter.'
                  : 'No students found matching "$_searchQuery".',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
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
        return StudentAttendanceTile(student: student);
      },
    );
  }
}
