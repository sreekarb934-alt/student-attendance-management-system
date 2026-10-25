import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Clean placeholder screen for navigation destinations under development.
/// Used for Students, Attendance, and Reports screens in Commit 1.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onReturnHome;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.onReturnHome,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon Header
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLightBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 36,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Screen Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Commit Indicator Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: AppTheme.primaryBlue,
                        ),
                        Text(
                          'Coming in Future Updates',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Return to Dashboard Action
                  if (onReturnHome != null)
                    OutlinedButton.icon(
                      onPressed: onReturnHome,
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Return to Dashboard'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                        side: const BorderSide(color: AppTheme.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
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
