// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      subscriptionTier: $enumDecodeNullable(
              _$SubscriptionTierEnumMap, json['subscriptionTier']) ??
          SubscriptionTier.free,
      preferences: json['preferences'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'avatarUrl': instance.avatarUrl,
      'subscriptionTier': _$SubscriptionTierEnumMap[instance.subscriptionTier]!,
      'preferences': instance.preferences,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$SubscriptionTierEnumMap = {
  SubscriptionTier.free: 'free',
  SubscriptionTier.pro: 'pro',
  SubscriptionTier.enterprise: 'enterprise',
};

_$UserPreferencesImpl _$$UserPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$UserPreferencesImpl(
      theme: json['theme'] as String? ?? 'system',
      language: json['language'] as String? ?? 'en',
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      autoSaveStrategies: json['autoSaveStrategies'] as bool? ?? true,
      defaultCurrency: json['defaultCurrency'] as String? ?? 'USD',
      defaultInitialCapital:
          (json['defaultInitialCapital'] as num?)?.toDouble() ?? 10000.0,
      chartSettings: json['chartSettings'] as Map<String, dynamic>? ?? const {},
      backtestSettings:
          json['backtestSettings'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$UserPreferencesImplToJson(
        _$UserPreferencesImpl instance) =>
    <String, dynamic>{
      'theme': instance.theme,
      'language': instance.language,
      'enableNotifications': instance.enableNotifications,
      'autoSaveStrategies': instance.autoSaveStrategies,
      'defaultCurrency': instance.defaultCurrency,
      'defaultInitialCapital': instance.defaultInitialCapital,
      'chartSettings': instance.chartSettings,
      'backtestSettings': instance.backtestSettings,
    };
