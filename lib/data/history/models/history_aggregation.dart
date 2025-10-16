/// Represents aggregated history data for a time period
class HistoryAggregation {
  final String period; // e.g., "2025-01-15" or "2025-01-15T14:00:00Z"
  final int count; // Number of alerts in this period
  final int? yesReactions; // Total yes reactions (if mode=reactions)
  final int? noReactions; // Total no reactions (if mode=reactions)
  final String? activityLevel; // 'high', 'moderate', 'none'

  const HistoryAggregation({
    required this.period,
    required this.count,
    this.yesReactions,
    this.noReactions,
    this.activityLevel,
  });

  factory HistoryAggregation.fromJson(Map<String, dynamic> json) {
    final count = json['count'] as int? ?? 0;

    // Calculate activity level based on count
    String activityLevel;
    if (count >= 10) {
      activityLevel = 'high';
    } else if (count >= 5) {
      activityLevel = 'moderate';
    } else {
      activityLevel = 'none';
    }

    // Parse the _id field which can be a String or Object
    String period;
    final id = json['_id'];
    if (id is String) {
      period = id;
    } else if (id is Map<String, dynamic>) {
      // Handle groupBy=hour format: {date: "2025-10-16", hour: 0}
      if (id.containsKey('hour')) {
        final date = id['date'] ?? '';
        final hour = id['hour'] ?? 0;
        period = '${date}T${hour.toString().padLeft(2, '0')}:00:00';
      } else if (id.containsKey('date')) {
        // Handle groupBy=date format
        period = id['date'] ?? '';
      } else {
        period = id.toString();
      }
    } else {
      period = json['period'] ?? '';
    }

    return HistoryAggregation(
      period: period,
      count: count,
      yesReactions: json['yesReactions'] as int?,
      noReactions: json['noReactions'] as int?,
      activityLevel: activityLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'count': count,
      if (yesReactions != null) 'yesReactions': yesReactions,
      if (noReactions != null) 'noReactions': noReactions,
      if (activityLevel != null) 'activityLevel': activityLevel,
    };
  }
}
