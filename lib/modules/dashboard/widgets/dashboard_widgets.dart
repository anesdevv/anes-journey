import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionHeader({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF453A), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class PrayerIndicator extends StatelessWidget {
  final String name;
  final String status; // 'on_time', 'late', 'missed', 'pending'

  const PrayerIndicator({super.key, required this.name, required this.status});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'on_time':
        statusColor = const Color(0xFF10B981); // Green
        statusIcon = Icons.check_circle;
        break;
      case 'late':
        statusColor = const Color(0xFFF59E0B); // Amber
        statusIcon = Icons.warning_rounded;
        break;
      case 'missed':
        statusColor = const Color(0xFFFF453A); // Neon Red
        statusIcon = Icons.cancel;
        break;
      case 'pending':
      default:
        statusColor = const Color(0xFF9E9E9E); // Grey
        statusIcon = Icons.access_time_filled;
        break;
    }

    return Column(
      children: [
        Icon(statusIcon, color: statusColor, size: 28),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
        ),
      ],
    );
  }
}

class HabitStreakBadge extends StatelessWidget {
  final String habitName;
  final int streak;

  const HabitStreakBadge({
    super.key,
    required this.habitName,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            habitName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Color(0xFFFF453A),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '$streak days',
                style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final String label;
  final double progress; // 0.0 to 1.0
  final String trailingText;

  const ProgressBar({
    super.key,
    required this.label,
    required this.progress,
    required this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            Text(
              trailingText,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: const Color(0xFF222222),
          color: const Color(0xFFFF453A),
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
