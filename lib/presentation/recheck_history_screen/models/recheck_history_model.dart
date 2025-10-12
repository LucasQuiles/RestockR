import '../../../core/app_export.dart';

/// This class is used in the [recheck_history_screen] screen.

// ignore_for_file: must_be_immutable
class RecheckHistoryModel extends Equatable {
  RecheckHistoryModel({
    this.selectedMonth,
    this.monthOptions,
    this.selectedDate,
    this.highActivityItems,
    this.noActivityItems,
    this.moderateActivityItems,
  }) {
    selectedMonth = selectedMonth ?? "September 2025";
    monthOptions = monthOptions ??
        [
          "January 2025",
          "February 2025",
          "March 2025",
          "April 2025",
          "May 2025",
          "June 2025",
          "July 2025",
          "August 2025",
          "September 2025",
          "October 2025",
          "November 2025",
          "December 2025"
        ];
    selectedDate = selectedDate ?? DateTime.now();
    highActivityItems = highActivityItems ??
        [
          ActivityItemModel(
            time: "0:00",
            status: "High Activity",
            quantity: "Qty:88",
            activityType: ActivityType.high,
            isFirstHour: true,
          ),
          ActivityItemModel(
            time: "01:00",
            status: "High Activity",
            quantity: "Qty:88",
            activityType: ActivityType.high,
            isSecondHour: true,
          ),
          ActivityItemModel(
            time: "02:00",
            status: "High Activity",
            quantity: "Qty:88",
            activityType: ActivityType.high,
          ),
        ];
    noActivityItems = noActivityItems ??
        [
          ActivityItemModel(
            time: "03:00",
            status: "No Activity",
            activityType: ActivityType.none,
          ),
          ActivityItemModel(
            time: "04:00",
            status: "No Activity",
            activityType: ActivityType.none,
          ),
          ActivityItemModel(
            time: "05:00",
            status: "No Activity",
            activityType: ActivityType.none,
          ),
          ActivityItemModel(
            time: "10:00",
            status: "No Activity",
            activityType: ActivityType.none,
          ),
          ActivityItemModel(
            time: "11:00",
            status: "No Activity",
            activityType: ActivityType.none,
          ),
          ActivityItemModel(
            time: "12:00",
            status: "No Activity",
            activityType: ActivityType.none,
          ),
          ActivityItemModel(
            time: "01:00",
            status: "No Activity",
            activityType: ActivityType.none,
          ),
          ActivityItemModel(
            time: "02:00",
            status: "No Activity",
            activityType: ActivityType.none,
          ),
          ActivityItemModel(
            time: "03:00",
            status: "No Activity",
            activityType: ActivityType.none,
          ),
        ];
    moderateActivityItems = moderateActivityItems ??
        [
          ActivityItemModel(
            time: "06:00",
            status: "Moderate Activity",
            quantity: "Qty:88",
            activityType: ActivityType.moderate,
          ),
          ActivityItemModel(
            time: "07:00",
            status: "Moderate Activity",
            quantity: "Qty:88",
            activityType: ActivityType.moderate,
          ),
          ActivityItemModel(
            time: "08:00",
            status: "Moderate Activity",
            quantity: "Qty:88",
            activityType: ActivityType.moderate,
          ),
          ActivityItemModel(
            time: "09:00",
            status: "Moderate Activity",
            quantity: "Qty:88",
            activityType: ActivityType.moderate,
          ),
        ];
  }

  String? selectedMonth;
  List<String>? monthOptions;
  DateTime? selectedDate;
  List<ActivityItemModel>? highActivityItems;
  List<ActivityItemModel>? noActivityItems;
  List<ActivityItemModel>? moderateActivityItems;

  RecheckHistoryModel copyWith({
    String? selectedMonth,
    List<String>? monthOptions,
    DateTime? selectedDate,
    List<ActivityItemModel>? highActivityItems,
    List<ActivityItemModel>? noActivityItems,
    List<ActivityItemModel>? moderateActivityItems,
  }) {
    return RecheckHistoryModel(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      monthOptions: monthOptions ?? this.monthOptions,
      selectedDate: selectedDate ?? this.selectedDate,
      highActivityItems: highActivityItems ?? this.highActivityItems,
      noActivityItems: noActivityItems ?? this.noActivityItems,
      moderateActivityItems:
          moderateActivityItems ?? this.moderateActivityItems,
    );
  }

  @override
  List<Object?> get props => [
        selectedMonth,
        monthOptions,
        selectedDate,
        highActivityItems,
        noActivityItems,
        moderateActivityItems,
      ];
}

enum ActivityType {
  high,
  moderate,
  none,
}

// ignore_for_file: must_be_immutable
class ActivityItemModel extends Equatable {
  ActivityItemModel({
    this.time,
    this.status,
    this.quantity,
    this.activityType,
    this.isFirstHour,
    this.isSecondHour,
  }) {
    time = time ?? '';
    status = status ?? '';
    quantity = quantity ?? '';
    activityType = activityType ?? ActivityType.none;
    isFirstHour = isFirstHour ?? false;
    isSecondHour = isSecondHour ?? false;
  }

  String? time;
  String? status;
  String? quantity;
  ActivityType? activityType;
  bool? isFirstHour;
  bool? isSecondHour;

  ActivityItemModel copyWith({
    String? time,
    String? status,
    String? quantity,
    ActivityType? activityType,
    bool? isFirstHour,
    bool? isSecondHour,
  }) {
    return ActivityItemModel(
      time: time ?? this.time,
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      activityType: activityType ?? this.activityType,
      isFirstHour: isFirstHour ?? this.isFirstHour,
      isSecondHour: isSecondHour ?? this.isSecondHour,
    );
  }

  @override
  List<Object?> get props => [
        time,
        status,
        quantity,
        activityType,
        isFirstHour,
        isSecondHour,
      ];
}
