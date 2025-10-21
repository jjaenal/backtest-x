import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Model untuk user profile yang tersimpan di Supabase
/// Extends dari auth.users dengan data tambahan
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id, // UUID dari auth.users
    required String email,
    String? fullName,
    String? avatarUrl,
    @Default(SubscriptionTier.free) SubscriptionTier subscriptionTier,
    @Default({}) Map<String, dynamic> preferences,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

/// Tier subscription untuk quota management
enum SubscriptionTier {
  @JsonValue('free')
  free,
  @JsonValue('pro')
  pro,
  @JsonValue('enterprise')
  enterprise,
}

/// Extension untuk subscription limits
extension SubscriptionTierLimits on SubscriptionTier {
  /// Maksimal strategies yang bisa dibuat
  int get maxStrategies {
    switch (this) {
      case SubscriptionTier.free:
        return 5;
      case SubscriptionTier.pro:
        return 50;
      case SubscriptionTier.enterprise:
        return -1; // Unlimited
    }
  }

  /// Maksimal backtest results yang bisa disimpan
  int get maxBacktestResults {
    switch (this) {
      case SubscriptionTier.free:
        return 20;
      case SubscriptionTier.pro:
        return 500;
      case SubscriptionTier.enterprise:
        return -1; // Unlimited
    }
  }

  /// Apakah bisa share strategies
  bool get canShareStrategies {
    switch (this) {
      case SubscriptionTier.free:
        return false;
      case SubscriptionTier.pro:
      case SubscriptionTier.enterprise:
        return true;
    }
  }

  /// Apakah bisa akses advanced features
  bool get hasAdvancedFeatures {
    switch (this) {
      case SubscriptionTier.free:
        return false;
      case SubscriptionTier.pro:
      case SubscriptionTier.enterprise:
        return true;
    }
  }
}

/// User preferences structure
@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default('system') String theme, // 'light', 'dark', 'system'
    @Default('en') String language,
    @Default(true) bool enableNotifications,
    @Default(true) bool autoSaveStrategies,
    @Default('USD') String defaultCurrency,
    @Default(10000.0) double defaultInitialCapital,
    @Default({}) Map<String, dynamic> chartSettings,
    @Default({}) Map<String, dynamic> backtestSettings,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}