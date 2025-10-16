import '../models/recheck_history_model.dart';
import '../../../core/app_export.dart';
import '../../../data/history/history_repository.dart';
import '../../../data/history/models/history_alert.dart';

part 'recheck_history_state.dart';

final recheckHistoryNotifier = StateNotifierProvider.autoDispose<
    RecheckHistoryNotifier, RecheckHistoryState>(
  (ref) {
    final historyRepo = ref.watch(historyRepositoryProvider);
    return RecheckHistoryNotifier(
      RecheckHistoryState(
        recheckHistoryModel: RecheckHistoryModel(),
      ),
      historyRepo,
    );
  },
);

class RecheckHistoryNotifier extends StateNotifier<RecheckHistoryState> {
  final HistoryRepository _historyRepository;

  RecheckHistoryNotifier(RecheckHistoryState state, this._historyRepository)
      : super(state) {
    initialize();
  }

  void initialize() async {
    state = state.copyWith(
      isLoading: false,
      recheckHistoryModel: RecheckHistoryModel(),
    );

    // Load monthly heatmap data
    await _loadMonthlyHeatmap(DateTime.now());

    // Load initial data for today
    await _loadHistoryForDate(DateTime.now());
  }

  void onMonthChanged(String month) {
    final updatedModel = state.recheckHistoryModel?.copyWith(
      selectedMonth: month,
    );

    state = state.copyWith(
      recheckHistoryModel: updatedModel,
    );
  }

  void onDateChanged(DateTime date) async {
    final updatedModel = state.recheckHistoryModel?.copyWith(
      selectedDate: date,
    );

    state = state.copyWith(
      recheckHistoryModel: updatedModel,
    );

    // Check if we need to load heatmap data for a new month
    final currentSelectedDate = state.recheckHistoryModel?.selectedDate;
    if (currentSelectedDate == null ||
        currentSelectedDate.year != date.year ||
        currentSelectedDate.month != date.month) {
      await _loadMonthlyHeatmap(date);
    }

    // Load history data for the selected date
    await _loadHistoryForDate(date);
  }

  /// Load monthly heatmap data for the calendar
  Future<void> _loadMonthlyHeatmap(DateTime date) async {
    try {
      // Get first and last day of the month
      final firstDayOfMonth = DateTime(date.year, date.month, 1);
      final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

      print('📅 Loading heatmap for ${date.year}-${date.month.toString().padLeft(2, '0')}');

      final result = await _historyRepository.fetchHistory(
        startDate: firstDayOfMonth,
        endDate: lastDayOfMonth.add(Duration(days: 1)),
        groupBy: 'date',
        mode: 'count',
      );

      if (result.success) {
        // Build a map of date -> count
        final dailyMap = <String, int>{};
        for (final agg in result.aggregations) {
          // Extract date from period (e.g., "2025-10-15" or "2025-10-15T00:00:00")
          final dateStr = agg.period.split('T')[0]; // Get YYYY-MM-DD part
          dailyMap[dateStr] = agg.count;
        }

        print('📅 Loaded heatmap data for ${dailyMap.length} days');

        state = state.copyWith(
          dailyActivityMap: dailyMap,
        );
      } else {
        print('⚠️ Failed to load monthly heatmap: ${result.error}');
      }
    } catch (e) {
      print('⚠️ Error loading monthly heatmap: $e');
    }
  }

  Future<void> _loadHistoryForDate(DateTime date) async {
    state = state.copyWith(isLoading: true);

    try {
      // Fetch history details for the selected date
      // We'll fetch hourly data for the entire day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      final result = await _historyRepository.fetchHistory(
        startDate: startOfDay,
        endDate: endOfDay,
        groupBy: 'hour',
        mode: 'count',
      );

      if (result.success) {
        print('📊 Processing ${result.aggregations.length} aggregations for ${date.toString().split(' ')[0]}');

        // Filter aggregations to only include the selected date
        final filteredAggregations = result.aggregations.where((agg) {
          try {
            final aggDate = DateTime.parse(agg.period.split('T')[0]);
            return aggDate.year == date.year &&
                aggDate.month == date.month &&
                aggDate.day == date.day;
          } catch (e) {
            print('⚠️ Failed to parse aggregation period: ${agg.period}');
            return false;
          }
        }).toList();

        print('📊 Filtered to ${filteredAggregations.length} aggregations for selected date');

        // Convert aggregations to activity items with sorting data
        final activityItemsWithHour = filteredAggregations.map((agg) {
          // Extract hour from period (e.g., "2025-01-15T14:00:00" -> 14)
          final periodDate = DateTime.parse(agg.period);
          final hour = periodDate.hour;

          // Format as 12hr time with am/pm
          final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
          final amPm = hour < 12 ? 'am' : 'pm';
          final timeStr = '$hour12:00 $amPm';

          // Determine activity type based on count
          ActivityType activityType;
          String status;
          if (agg.count >= 10) {
            activityType = ActivityType.high;
            status = 'High Activity';
          } else if (agg.count >= 5) {
            activityType = ActivityType.moderate;
            status = 'Moderate Activity';
          } else {
            activityType = ActivityType.none;
            status = 'No Activity';
          }

          return {
            'hour': hour,
            'item': ActivityItemModel(
              time: timeStr,
              status: status,
              quantity: agg.count > 0 ? 'Qty:${agg.count}' : '',
              activityType: activityType,
            ),
          };
        }).toList();

        // Sort by 24hr hour value
        activityItemsWithHour.sort((a, b) => (a['hour'] as int).compareTo(b['hour'] as int));

        // Extract just the items
        final activityItems = activityItemsWithHour
            .map((item) => item['item'] as ActivityItemModel)
            .toList();

        // Separate by activity type
        final highItems = activityItems
            .where((item) => item.activityType == ActivityType.high)
            .toList();
        final moderateItems = activityItems
            .where((item) => item.activityType == ActivityType.moderate)
            .toList();
        final noActivityItems = activityItems
            .where((item) => item.activityType == ActivityType.none)
            .toList();

        final updatedModel = state.recheckHistoryModel?.copyWith(
          highActivityItems: highItems,
          moderateActivityItems: moderateItems,
          noActivityItems: noActivityItems,
        );

        state = state.copyWith(
          isLoading: false,
          recheckHistoryModel: updatedModel,
        );
      } else {
        print('⚠️ Failed to load history: ${result.error}');
        state = state.copyWith(
          isLoading: false,
          recheckHistoryModel: state.recheckHistoryModel?.copyWith(
            highActivityItems: [],
            moderateActivityItems: [],
            noActivityItems: [],
          ),
        );
      }
    } catch (e) {
      print('⚠️ Error loading history: $e');
      state = state.copyWith(
        isLoading: false,
        recheckHistoryModel: state.recheckHistoryModel?.copyWith(
          highActivityItems: [],
          moderateActivityItems: [],
          noActivityItems: [],
        ),
      );
    }
  }

  Future<void> onActivityItemTapped(ActivityItemModel item) async {
    // Handle activity item selection logic
    state = state.copyWith(
      selectedActivityItem: item,
    );

    // Fetch detailed history for the selected hour
    await fetchHistoryDetailsForItem(item);
  }

  /// Fetch detailed history alerts for a specific activity item
  Future<void> fetchHistoryDetailsForItem(ActivityItemModel item) async {
    // Extract hour from time string (e.g., "2:00 pm" -> 14, "12:00 am" -> 0)
    final timeStr = item.time ?? '12:00 am';
    final parts = timeStr.split(' ');
    final timePart = parts[0];
    final amPm = parts.length > 1 ? parts[1] : 'am';

    var hour = int.tryParse(timePart.split(':')[0]) ?? 12;

    // Convert 12hr to 24hr format
    if (amPm == 'am') {
      if (hour == 12) hour = 0; // 12am is 0
    } else { // pm
      if (hour != 12) hour += 12; // 1pm-11pm becomes 13-23, 12pm stays 12
    }

    final selectedDate = state.recheckHistoryModel?.selectedDate ?? DateTime.now();

    state = state.copyWith(
      isLoadingDetails: true,
      historyDetails: null,
      detailsError: null,
    );

    try {
      print('📊 Fetching history details for ${selectedDate.toString().split(' ')[0]} at $hour:00');

      final result = await _historyRepository.fetchHistoryDetails(
        date: selectedDate,
        hour: hour,
        limit: 100,
      );

      if (result.success) {
        print('📊 Loaded ${result.alerts.length} detailed alerts');
        state = state.copyWith(
          isLoadingDetails: false,
          historyDetails: result.alerts,
          detailsError: null,
        );
      } else {
        print('⚠️ Failed to fetch history details: ${result.error}');
        state = state.copyWith(
          isLoadingDetails: false,
          historyDetails: [],
          detailsError: result.error,
        );
      }
    } catch (e) {
      print('⚠️ Error fetching history details: $e');
      state = state.copyWith(
        isLoadingDetails: false,
        historyDetails: [],
        detailsError: 'Error loading details: $e',
      );
    }
  }

  void onSearchChanged(String searchText) {
    state = state.copyWith(
      searchText: searchText,
    );
  }

  void refreshData() async {
    final currentDate = state.recheckHistoryModel?.selectedDate ?? DateTime.now();
    await _loadHistoryForDate(currentDate);
  }
}
