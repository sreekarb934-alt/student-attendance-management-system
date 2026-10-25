import 'package:flutter/material.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';

/// Reusable student attendance row widget.
/// Renders a student card with avatar, roll number, department, and status chip/action.
class StudentAttendanceTile extends StatelessWidget {
  final Student student;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onTap;
  final Widget? trailing;

  const StudentAttendanceTile({
    super.key,
    required this.student,
    this.onToggleStatus,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isPresent = student.status == AttendanceStatus.present;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              // Student Initials Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: isPresent
                    ? const Color(0xFFE3F2FD) // Soft blue for present
                    : const Color(0xFFF1F5F9), // Slate 100 for absent
                child: Text(
                  student.initials,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isPresent
                        ? AppTheme.primaryBlue
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Student Information (Name, Roll No, Department)
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
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          student.rollNumber,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const Text(
                          ' • ',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            student.department,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (isPresent && student.timeMarked != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Marked at ${student.timeMarked}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Custom Trailing or Attendance Status Badge
              if (trailing != null)
                trailing!
              else
                _buildStatusBadge(context, isPresent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isPresent) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPresent ? AppTheme.statusPresentBg : AppTheme.statusAbsentBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPresent
              ? AppTheme.statusPresentBorder
              : AppTheme.statusAbsentBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPresent ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: isPresent
                ? AppTheme.statusPresentText
                : AppTheme.statusAbsentText,
          ),
          const SizedBox(width: 4),
          Text(
            isPresent ? 'Present' : 'Absent',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isPresent
                  ? AppTheme.statusPresentText
                  : AppTheme.statusAbsentText,
            ),
          ),
        ],
      ),
    );

    if (onToggleStatus != null) {
      return Tooltip(
        message: 'Tap to switch to ${isPresent ? 'Absent' : 'Present'}',
        child: InkWell(
          onTap: onToggleStatus,
          borderRadius: BorderRadius.circular(20),
          child: badge,
        ),
      );
    }

    return badge;
  }
}
