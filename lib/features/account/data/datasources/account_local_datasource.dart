// lib/features/account/data/datasources/account_local_datasource.dart

import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/storage/storage_preference_manager.dart';
import 'package:my_wellness/features/account/data/models/health_profile_model.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';

@lazySingleton
class AccountLocalDatasource {
  final SharedPreferencesManager _prefs;

  AccountLocalDatasource(this._prefs);

  // ── Health profile cache ─────────────────────────────────────────────────

  Future<void> cacheHealthProfile(HealthProfile profile) async {
    final model = _toModel(profile);
    await _prefs.putString(
      SharedPreferencesManager.user,
      jsonEncode(model.toJson()),
    );
  }

  HealthProfile? getCachedProfile() {
    final jsonStr = _prefs.getString(SharedPreferencesManager.user);
    if (jsonStr == null) return null;
    try {
      return HealthProfileModel.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      ).toEntity();
    } catch (_) {
      // Corrupt cache — drop it.
      _prefs.clearKey(SharedPreferencesManager.user);
      return null;
    }
  }

  // ── Settings ─────────────────────────────────────────────────────────────

  Future<void> cacheLanguage(String code) async =>
      await _prefs.putString(SharedPreferencesManager.language, code);

  String getLanguage() =>
      _prefs.getString(SharedPreferencesManager.language) ?? 'en';

  // ── Teardown ─────────────────────────────────────────────────────────────

  Future<void> clearAllData() async {
    // Only non-sensitive data. Tokens are owned by AuthLocalDataSource.
    await _prefs.clearKey(SharedPreferencesManager.user);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Field-by-field mapping; keeps the model as the sole owner of JSON keys
  /// and avoids an `extends`-based model that breaks json_serializable.
  HealthProfileModel _toModel(HealthProfile p) => HealthProfileModel(
    email: p.email,
    fullName: p.fullName,
    phone: p.phone,
    age: p.age,
    ageStale: p.ageStale,
    dateOfBirth: p.dateOfBirth,
    weightKg: p.weightKg,
    heightCm: p.heightCm,
    bmiStale: p.bmiStale,
    gender: p.gender,
    county: p.county,
    subCounty: p.subCounty,
    constituency: p.constituency,
    ward: p.ward,
    occupation: p.occupation,
    memberCode: p.memberCode,
    healthProfileCompleted: p.healthProfileCompleted,
    hasHypertension: p.hasHypertension,
    onHtnMedication: p.onHtnMedication,
    htnMedications: p.htnMedications,
    hasDiabetes: p.hasDiabetes,
    onDmMedication: p.onDmMedication,
    dmMedications: p.dmMedications,
    htnOnboardingSeen: p.htnOnboardingSeen,
    dmOnboardingSeen: p.dmOnboardingSeen,
    shaBeneficiaryId: p.shaBeneficiaryId,
    shaBeneficiaryIdType: p.shaBeneficiaryIdType,
    nationalIdNumber: p.nationalIdNumber,
    analyticsOptOut: p.analyticsOptOut,
    shaDataSharingConsent: p.shaDataSharingConsent,
  );
}
