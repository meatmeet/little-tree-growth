class AppConstants {
  static const String appName = '小树成长';
  static const String apiBaseUrl = 'http://www.meetmeat.com.cn/api/v1';

  // Default values
  static const double defaultTaskDuration = 15;
  static const int maxBabyCount = 5;
  static const int freeTrialDays = 7;

  // Pricing
  static const double monthlyPrice = 29.0;
  static const double yearlyPrice = 299.0;

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String babyKey = 'baby_data';
  static const String taskKey = 'task_cache';
  static const String assessmentKey = 'assessment_cache';
  static const String settingsKey = 'app_settings';

  // Assessment
  static const int assessmentAgeGroups = 28;
  static const List<int> ageGroups = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
    15, 18, 21, 24, 27, 30, 33, 36,
    42, 48, 54, 60, 66, 72, 78, 84,
  ];

  // DQ assessment levels
  static const double dqExcellent = 130;
  static const double dqGood = 110;
  static const double dqAverage = 80;
  static const double dqBorderline = 70;
}
