import '../constants/app_strings.dart';

enum ChartRange {
  oneWeek(label: AppStrings.chartRange1w, days: 7),
  oneMonth(label: AppStrings.chartRange1m, days: 30),
  threeMonths(label: AppStrings.chartRange3m, days: 90),
  sixMonths(label: AppStrings.chartRange6m, days: 180),
  oneYear(label: AppStrings.chartRange1y, days: 365),
  fiveYears(label: AppStrings.chartRange5y, days: 365 * 5);

  const ChartRange({required this.label, required this.days});

  final String label;
  final int days;
}
