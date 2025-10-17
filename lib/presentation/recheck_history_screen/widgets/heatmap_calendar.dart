import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../core/utils/date_time_utils.dart';

/// Custom calendar widget with heatmap coloring based on activity levels
class HeatmapCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateChanged;
  final Map<String, int>? dailyActivityMap;

  const HeatmapCalendar({
    Key? key,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
    this.dailyActivityMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: appTheme.gray_300, width: 1),
      ),
      padding: EdgeInsets.all(16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMonthHeader(context),
          SizedBox(height: 16.h),
          _buildWeekdayLabels(context),
          SizedBox(height: 12.h),
          _buildCalendarGrid(context),
          SizedBox(height: 16.h),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    final monthName = DateTimeUtils.formatMonthYear(selectedDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: appTheme.black_900),
          onPressed: () {
            final newDate = DateTime(
              selectedDate.year,
              selectedDate.month - 1,
              1,
            );
            if (newDate.isAfter(firstDate) ||
                newDate.year == firstDate.year && newDate.month == firstDate.month) {
              onDateChanged(newDate);
            }
          },
        ),
        Text(
          monthName,
          style: TextStyleHelper.instance.title16SemiBoldInter
              .copyWith(color: appTheme.black_900),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, color: appTheme.black_900),
          onPressed: () {
            final newDate = DateTime(
              selectedDate.year,
              selectedDate.month + 1,
              1,
            );
            if (newDate.isBefore(lastDate) ||
                newDate.year == lastDate.year && newDate.month == lastDate.month) {
              onDateChanged(newDate);
            }
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels(BuildContext context) {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyleHelper.instance.body12SemiBoldInter
                  .copyWith(color: appTheme.gray_600),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final startWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    final List<Widget> dayWidgets = [];

    // Add empty cells for days before month starts
    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(Container());
    }

    // Add day cells
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(selectedDate.year, selectedDate.month, day);
      dayWidgets.add(_buildDayCell(context, date));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8.h,
      crossAxisSpacing: 8.h,
      childAspectRatio: 1.0,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date) {
    final isSelected = date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;

    final isToday = _isToday(date);
    final dateStr = _formatDate(date);
    final activityCount = dailyActivityMap?[dateStr] ?? 0;

    // Determine colors based on activity level
    final colors = _getActivityColors(activityCount);

    return GestureDetector(
      onTap: () => onDateChanged(date),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? appTheme.black_900 : colors.backgroundColor,
          borderRadius: BorderRadius.circular(8.h),
          border: isToday
              ? Border.all(color: appTheme.black_900, width: 2.h)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyleHelper.instance.body14MediumInter.copyWith(
                color: isSelected
                    ? appTheme.white_A700
                    : (activityCount > 0 ? colors.textColor : appTheme.gray_900),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (activityCount > 0 && !isSelected)
              SizedBox(height: 2.h),
            if (activityCount > 0 && !isSelected)
              Container(
                width: 4.h,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.dotColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.h),
      decoration: BoxDecoration(
        color: appTheme.gray_100,
        borderRadius: BorderRadius.circular(8.h),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(context, 'None', appTheme.gray_100, appTheme.gray_600),
          _buildLegendItem(context, 'Low', Color(0xFFD1FAE5), appTheme.teal_600),
          _buildLegendItem(context, 'Medium', Color(0xFF6EE7B7), appTheme.teal_600),
          _buildLegendItem(context, 'High', appTheme.red_500.withAlpha((0.2 * 255).round()), appTheme.red_500),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.h,
          height: 12.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.h),
          ),
        ),
        SizedBox(width: 4.h),
        Text(
          label,
          style: TextStyleHelper.instance.body12MediumInter
              .copyWith(color: appTheme.gray_600),
        ),
      ],
    );
  }

  ActivityColors _getActivityColors(int count) {
    if (count == 0) {
      return ActivityColors(
        backgroundColor: appTheme.gray_100,
        textColor: appTheme.gray_900,
        dotColor: Colors.transparent,
      );
    }

    // Calculate dynamic thresholds based on all available data
    if (dailyActivityMap != null && dailyActivityMap!.isNotEmpty) {
      final counts = dailyActivityMap!.values.where((c) => c > 0).toList();

      if (counts.isNotEmpty) {
        counts.sort();

        // Calculate percentiles for better color distribution
        final p33 = counts[(counts.length * 0.33).floor()];
        final p66 = counts[(counts.length * 0.66).floor()];

        if (count <= p33) {
          // Low activity (bottom 33%) - light teal
          return ActivityColors(
            backgroundColor: Color(0xFFD1FAE5),
            textColor: appTheme.teal_600,
            dotColor: appTheme.teal_600,
          );
        } else if (count <= p66) {
          // Medium activity (middle 33%) - medium teal
          return ActivityColors(
            backgroundColor: Color(0xFF6EE7B7),
            textColor: appTheme.teal_600,
            dotColor: appTheme.teal_600,
          );
        } else {
          // High activity (top 33%) - light red
          return ActivityColors(
            backgroundColor: appTheme.red_500.withAlpha((0.2 * 255).round()),
            textColor: appTheme.red_500,
            dotColor: appTheme.red_500,
          );
        }
      }
    }

    // Fallback to simple thresholds if no data available
    if (count < 50) {
      return ActivityColors(
        backgroundColor: Color(0xFFD1FAE5),
        textColor: appTheme.teal_600,
        dotColor: appTheme.teal_600,
      );
    } else if (count < 100) {
      return ActivityColors(
        backgroundColor: Color(0xFF6EE7B7),
        textColor: appTheme.teal_600,
        dotColor: appTheme.teal_600,
      );
    } else {
      return ActivityColors(
        backgroundColor: appTheme.red_500.withAlpha((0.2 * 255).round()),
        textColor: appTheme.red_500,
        dotColor: appTheme.red_500,
      );
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class ActivityColors {
  final Color backgroundColor;
  final Color textColor;
  final Color dotColor;

  ActivityColors({
    required this.backgroundColor,
    required this.textColor,
    required this.dotColor,
  });
}
