// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get id => throw _privateConstructorUsedError; // UUID dari auth.users
  String get email => throw _privateConstructorUsedError;
  String? get fullName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  SubscriptionTier get subscriptionTier => throw _privateConstructorUsedError;
  Map<String, dynamic> get preferences => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {String id,
      String email,
      String? fullName,
      String? avatarUrl,
      SubscriptionTier subscriptionTier,
      Map<String, dynamic> preferences,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? fullName = freezed,
    Object? avatarUrl = freezed,
    Object? subscriptionTier = null,
    Object? preferences = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      subscriptionTier: null == subscriptionTier
          ? _value.subscriptionTier
          : subscriptionTier // ignore: cast_nullable_to_non_nullable
              as SubscriptionTier,
      preferences: null == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String? fullName,
      String? avatarUrl,
      SubscriptionTier subscriptionTier,
      Map<String, dynamic> preferences,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? fullName = freezed,
    Object? avatarUrl = freezed,
    Object? subscriptionTier = null,
    Object? preferences = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$UserProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      subscriptionTier: null == subscriptionTier
          ? _value.subscriptionTier
          : subscriptionTier // ignore: cast_nullable_to_non_nullable
              as SubscriptionTier,
      preferences: null == preferences
          ? _value._preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {required this.id,
      required this.email,
      this.fullName,
      this.avatarUrl,
      this.subscriptionTier = SubscriptionTier.free,
      final Map<String, dynamic> preferences = const {},
      required this.createdAt,
      required this.updatedAt})
      : _preferences = preferences;

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String id;
// UUID dari auth.users
  @override
  final String email;
  @override
  final String? fullName;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final SubscriptionTier subscriptionTier;
  final Map<String, dynamic> _preferences;
  @override
  @JsonKey()
  Map<String, dynamic> get preferences {
    if (_preferences is EqualUnmodifiableMapView) return _preferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_preferences);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, fullName: $fullName, avatarUrl: $avatarUrl, subscriptionTier: $subscriptionTier, preferences: $preferences, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.subscriptionTier, subscriptionTier) ||
                other.subscriptionTier == subscriptionTier) &&
            const DeepCollectionEquality()
                .equals(other._preferences, _preferences) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      email,
      fullName,
      avatarUrl,
      subscriptionTier,
      const DeepCollectionEquality().hash(_preferences),
      createdAt,
      updatedAt);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {required final String id,
      required final String email,
      final String? fullName,
      final String? avatarUrl,
      final SubscriptionTier subscriptionTier,
      final Map<String, dynamic> preferences,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get id; // UUID dari auth.users
  @override
  String get email;
  @override
  String? get fullName;
  @override
  String? get avatarUrl;
  @override
  SubscriptionTier get subscriptionTier;
  @override
  Map<String, dynamic> get preferences;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) {
  return _UserPreferences.fromJson(json);
}

/// @nodoc
mixin _$UserPreferences {
  String get theme =>
      throw _privateConstructorUsedError; // 'light', 'dark', 'system'
  String get language => throw _privateConstructorUsedError;
  bool get enableNotifications => throw _privateConstructorUsedError;
  bool get autoSaveStrategies => throw _privateConstructorUsedError;
  String get defaultCurrency => throw _privateConstructorUsedError;
  double get defaultInitialCapital => throw _privateConstructorUsedError;
  Map<String, dynamic> get chartSettings => throw _privateConstructorUsedError;
  Map<String, dynamic> get backtestSettings =>
      throw _privateConstructorUsedError;

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPreferencesCopyWith<UserPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesCopyWith<$Res> {
  factory $UserPreferencesCopyWith(
          UserPreferences value, $Res Function(UserPreferences) then) =
      _$UserPreferencesCopyWithImpl<$Res, UserPreferences>;
  @useResult
  $Res call(
      {String theme,
      String language,
      bool enableNotifications,
      bool autoSaveStrategies,
      String defaultCurrency,
      double defaultInitialCapital,
      Map<String, dynamic> chartSettings,
      Map<String, dynamic> backtestSettings});
}

/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res, $Val extends UserPreferences>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? theme = null,
    Object? language = null,
    Object? enableNotifications = null,
    Object? autoSaveStrategies = null,
    Object? defaultCurrency = null,
    Object? defaultInitialCapital = null,
    Object? chartSettings = null,
    Object? backtestSettings = null,
  }) {
    return _then(_value.copyWith(
      theme: null == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      enableNotifications: null == enableNotifications
          ? _value.enableNotifications
          : enableNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      autoSaveStrategies: null == autoSaveStrategies
          ? _value.autoSaveStrategies
          : autoSaveStrategies // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultCurrency: null == defaultCurrency
          ? _value.defaultCurrency
          : defaultCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      defaultInitialCapital: null == defaultInitialCapital
          ? _value.defaultInitialCapital
          : defaultInitialCapital // ignore: cast_nullable_to_non_nullable
              as double,
      chartSettings: null == chartSettings
          ? _value.chartSettings
          : chartSettings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      backtestSettings: null == backtestSettings
          ? _value.backtestSettings
          : backtestSettings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserPreferencesImplCopyWith<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  factory _$$UserPreferencesImplCopyWith(_$UserPreferencesImpl value,
          $Res Function(_$UserPreferencesImpl) then) =
      __$$UserPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String theme,
      String language,
      bool enableNotifications,
      bool autoSaveStrategies,
      String defaultCurrency,
      double defaultInitialCapital,
      Map<String, dynamic> chartSettings,
      Map<String, dynamic> backtestSettings});
}

/// @nodoc
class __$$UserPreferencesImplCopyWithImpl<$Res>
    extends _$UserPreferencesCopyWithImpl<$Res, _$UserPreferencesImpl>
    implements _$$UserPreferencesImplCopyWith<$Res> {
  __$$UserPreferencesImplCopyWithImpl(
      _$UserPreferencesImpl _value, $Res Function(_$UserPreferencesImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? theme = null,
    Object? language = null,
    Object? enableNotifications = null,
    Object? autoSaveStrategies = null,
    Object? defaultCurrency = null,
    Object? defaultInitialCapital = null,
    Object? chartSettings = null,
    Object? backtestSettings = null,
  }) {
    return _then(_$UserPreferencesImpl(
      theme: null == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      enableNotifications: null == enableNotifications
          ? _value.enableNotifications
          : enableNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      autoSaveStrategies: null == autoSaveStrategies
          ? _value.autoSaveStrategies
          : autoSaveStrategies // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultCurrency: null == defaultCurrency
          ? _value.defaultCurrency
          : defaultCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      defaultInitialCapital: null == defaultInitialCapital
          ? _value.defaultInitialCapital
          : defaultInitialCapital // ignore: cast_nullable_to_non_nullable
              as double,
      chartSettings: null == chartSettings
          ? _value._chartSettings
          : chartSettings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      backtestSettings: null == backtestSettings
          ? _value._backtestSettings
          : backtestSettings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesImpl implements _UserPreferences {
  const _$UserPreferencesImpl(
      {this.theme = 'system',
      this.language = 'en',
      this.enableNotifications = true,
      this.autoSaveStrategies = true,
      this.defaultCurrency = 'USD',
      this.defaultInitialCapital = 10000.0,
      final Map<String, dynamic> chartSettings = const {},
      final Map<String, dynamic> backtestSettings = const {}})
      : _chartSettings = chartSettings,
        _backtestSettings = backtestSettings;

  factory _$UserPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesImplFromJson(json);

  @override
  @JsonKey()
  final String theme;
// 'light', 'dark', 'system'
  @override
  @JsonKey()
  final String language;
  @override
  @JsonKey()
  final bool enableNotifications;
  @override
  @JsonKey()
  final bool autoSaveStrategies;
  @override
  @JsonKey()
  final String defaultCurrency;
  @override
  @JsonKey()
  final double defaultInitialCapital;
  final Map<String, dynamic> _chartSettings;
  @override
  @JsonKey()
  Map<String, dynamic> get chartSettings {
    if (_chartSettings is EqualUnmodifiableMapView) return _chartSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_chartSettings);
  }

  final Map<String, dynamic> _backtestSettings;
  @override
  @JsonKey()
  Map<String, dynamic> get backtestSettings {
    if (_backtestSettings is EqualUnmodifiableMapView) return _backtestSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_backtestSettings);
  }

  @override
  String toString() {
    return 'UserPreferences(theme: $theme, language: $language, enableNotifications: $enableNotifications, autoSaveStrategies: $autoSaveStrategies, defaultCurrency: $defaultCurrency, defaultInitialCapital: $defaultInitialCapital, chartSettings: $chartSettings, backtestSettings: $backtestSettings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesImpl &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.enableNotifications, enableNotifications) ||
                other.enableNotifications == enableNotifications) &&
            (identical(other.autoSaveStrategies, autoSaveStrategies) ||
                other.autoSaveStrategies == autoSaveStrategies) &&
            (identical(other.defaultCurrency, defaultCurrency) ||
                other.defaultCurrency == defaultCurrency) &&
            (identical(other.defaultInitialCapital, defaultInitialCapital) ||
                other.defaultInitialCapital == defaultInitialCapital) &&
            const DeepCollectionEquality()
                .equals(other._chartSettings, _chartSettings) &&
            const DeepCollectionEquality()
                .equals(other._backtestSettings, _backtestSettings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      theme,
      language,
      enableNotifications,
      autoSaveStrategies,
      defaultCurrency,
      defaultInitialCapital,
      const DeepCollectionEquality().hash(_chartSettings),
      const DeepCollectionEquality().hash(_backtestSettings));

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      __$$UserPreferencesImplCopyWithImpl<_$UserPreferencesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesImplToJson(
      this,
    );
  }
}

abstract class _UserPreferences implements UserPreferences {
  const factory _UserPreferences(
      {final String theme,
      final String language,
      final bool enableNotifications,
      final bool autoSaveStrategies,
      final String defaultCurrency,
      final double defaultInitialCapital,
      final Map<String, dynamic> chartSettings,
      final Map<String, dynamic> backtestSettings}) = _$UserPreferencesImpl;

  factory _UserPreferences.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesImpl.fromJson;

  @override
  String get theme; // 'light', 'dark', 'system'
  @override
  String get language;
  @override
  bool get enableNotifications;
  @override
  bool get autoSaveStrategies;
  @override
  String get defaultCurrency;
  @override
  double get defaultInitialCapital;
  @override
  Map<String, dynamic> get chartSettings;
  @override
  Map<String, dynamic> get backtestSettings;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
