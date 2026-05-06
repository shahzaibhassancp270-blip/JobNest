// lib/features/onboarding/data/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _jobCategoryKey = 'pref_job_category';
  static const _cityKey = 'pref_city';
  static const _employmentTypeKey = 'pref_employment_type';
  static const _onboardingDoneKey = 'onboarding_done';

  Future<void> savePreferences({
    required String jobCategory,
    required String city,
    required String employmentType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jobCategoryKey, jobCategory);
    await prefs.setString(_cityKey, city);
    await prefs.setString(_employmentTypeKey, employmentType);
    await prefs.setBool(_onboardingDoneKey, true);
  }

  Future<String> getJobCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jobCategoryKey) ?? 'Software Engineer';
  }

  Future<String> getCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cityKey) ?? '';
  }

  Future<String> getEmploymentType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_employmentTypeKey) ?? 'FULLTIME';
  }

  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingDoneKey) ?? false;
  }

  Future<void> updateCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cityKey, city);
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingDoneKey);
  }
}
