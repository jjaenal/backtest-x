// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'strategy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Strategy _$StrategyFromJson(Map<String, dynamic> json) {
  return _Strategy.fromJson(json);
}

/// @nodoc
mixin _$Strategy {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get initialCapital => throw _privateConstructorUsedError;
  RiskManagement get riskManagement => throw _privateConstructorUsedError;
  List<StrategyRule> get entryRules => throw _privateConstructorUsedError;
  List<StrategyRule> get exitRules => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Strategy to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Strategy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StrategyCopyWith<Strategy> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StrategyCopyWith<$Res> {
  factory $StrategyCopyWith(Strategy value, $Res Function(Strategy) then) =
      _$StrategyCopyWithImpl<$Res, Strategy>;
  @useResult
  $Res call(
      {String id,
      String name,
      double initialCapital,
      RiskManagement riskManagement,
      List<StrategyRule> entryRules,
      List<StrategyRule> exitRules,
      DateTime createdAt,
      DateTime? updatedAt});

  $RiskManagementCopyWith<$Res> get riskManagement;
}

/// @nodoc
class _$StrategyCopyWithImpl<$Res, $Val extends Strategy>
    implements $StrategyCopyWith<$Res> {
  _$StrategyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Strategy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? initialCapital = null,
    Object? riskManagement = null,
    Object? entryRules = null,
    Object? exitRules = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      initialCapital: null == initialCapital
          ? _value.initialCapital
          : initialCapital // ignore: cast_nullable_to_non_nullable
              as double,
      riskManagement: null == riskManagement
          ? _value.riskManagement
          : riskManagement // ignore: cast_nullable_to_non_nullable
              as RiskManagement,
      entryRules: null == entryRules
          ? _value.entryRules
          : entryRules // ignore: cast_nullable_to_non_nullable
              as List<StrategyRule>,
      exitRules: null == exitRules
          ? _value.exitRules
          : exitRules // ignore: cast_nullable_to_non_nullable
              as List<StrategyRule>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of Strategy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RiskManagementCopyWith<$Res> get riskManagement {
    return $RiskManagementCopyWith<$Res>(_value.riskManagement, (value) {
      return _then(_value.copyWith(riskManagement: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StrategyImplCopyWith<$Res>
    implements $StrategyCopyWith<$Res> {
  factory _$$StrategyImplCopyWith(
          _$StrategyImpl value, $Res Function(_$StrategyImpl) then) =
      __$$StrategyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      double initialCapital,
      RiskManagement riskManagement,
      List<StrategyRule> entryRules,
      List<StrategyRule> exitRules,
      DateTime createdAt,
      DateTime? updatedAt});

  @override
  $RiskManagementCopyWith<$Res> get riskManagement;
}

/// @nodoc
class __$$StrategyImplCopyWithImpl<$Res>
    extends _$StrategyCopyWithImpl<$Res, _$StrategyImpl>
    implements _$$StrategyImplCopyWith<$Res> {
  __$$StrategyImplCopyWithImpl(
      _$StrategyImpl _value, $Res Function(_$StrategyImpl) _then)
      : super(_value, _then);

  /// Create a copy of Strategy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? initialCapital = null,
    Object? riskManagement = null,
    Object? entryRules = null,
    Object? exitRules = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$StrategyImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      initialCapital: null == initialCapital
          ? _value.initialCapital
          : initialCapital // ignore: cast_nullable_to_non_nullable
              as double,
      riskManagement: null == riskManagement
          ? _value.riskManagement
          : riskManagement // ignore: cast_nullable_to_non_nullable
              as RiskManagement,
      entryRules: null == entryRules
          ? _value._entryRules
          : entryRules // ignore: cast_nullable_to_non_nullable
              as List<StrategyRule>,
      exitRules: null == exitRules
          ? _value._exitRules
          : exitRules // ignore: cast_nullable_to_non_nullable
              as List<StrategyRule>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StrategyImpl implements _Strategy {
  const _$StrategyImpl(
      {required this.id,
      required this.name,
      required this.initialCapital,
      required this.riskManagement,
      required final List<StrategyRule> entryRules,
      required final List<StrategyRule> exitRules,
      required this.createdAt,
      this.updatedAt})
      : _entryRules = entryRules,
        _exitRules = exitRules;

  factory _$StrategyImpl.fromJson(Map<String, dynamic> json) =>
      _$$StrategyImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double initialCapital;
  @override
  final RiskManagement riskManagement;
  final List<StrategyRule> _entryRules;
  @override
  List<StrategyRule> get entryRules {
    if (_entryRules is EqualUnmodifiableListView) return _entryRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entryRules);
  }

  final List<StrategyRule> _exitRules;
  @override
  List<StrategyRule> get exitRules {
    if (_exitRules is EqualUnmodifiableListView) return _exitRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exitRules);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Strategy(id: $id, name: $name, initialCapital: $initialCapital, riskManagement: $riskManagement, entryRules: $entryRules, exitRules: $exitRules, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StrategyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.initialCapital, initialCapital) ||
                other.initialCapital == initialCapital) &&
            (identical(other.riskManagement, riskManagement) ||
                other.riskManagement == riskManagement) &&
            const DeepCollectionEquality()
                .equals(other._entryRules, _entryRules) &&
            const DeepCollectionEquality()
                .equals(other._exitRules, _exitRules) &&
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
      name,
      initialCapital,
      riskManagement,
      const DeepCollectionEquality().hash(_entryRules),
      const DeepCollectionEquality().hash(_exitRules),
      createdAt,
      updatedAt);

  /// Create a copy of Strategy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StrategyImplCopyWith<_$StrategyImpl> get copyWith =>
      __$$StrategyImplCopyWithImpl<_$StrategyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StrategyImplToJson(
      this,
    );
  }
}

abstract class _Strategy implements Strategy {
  const factory _Strategy(
      {required final String id,
      required final String name,
      required final double initialCapital,
      required final RiskManagement riskManagement,
      required final List<StrategyRule> entryRules,
      required final List<StrategyRule> exitRules,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$StrategyImpl;

  factory _Strategy.fromJson(Map<String, dynamic> json) =
      _$StrategyImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get initialCapital;
  @override
  RiskManagement get riskManagement;
  @override
  List<StrategyRule> get entryRules;
  @override
  List<StrategyRule> get exitRules;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Strategy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StrategyImplCopyWith<_$StrategyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RiskManagement _$RiskManagementFromJson(Map<String, dynamic> json) {
  return _RiskManagement.fromJson(json);
}

/// @nodoc
mixin _$RiskManagement {
  RiskType get riskType => throw _privateConstructorUsedError;
  double get riskValue =>
      throw _privateConstructorUsedError; // Fixed lot atau % risk
  double? get stopLoss =>
      throw _privateConstructorUsedError; // in pips/points atau %
  double? get takeProfit => throw _privateConstructorUsedError;
  bool get useTrailingStop => throw _privateConstructorUsedError;
  double? get trailingStopDistance => throw _privateConstructorUsedError;

  /// Serializes this RiskManagement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RiskManagement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RiskManagementCopyWith<RiskManagement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RiskManagementCopyWith<$Res> {
  factory $RiskManagementCopyWith(
          RiskManagement value, $Res Function(RiskManagement) then) =
      _$RiskManagementCopyWithImpl<$Res, RiskManagement>;
  @useResult
  $Res call(
      {RiskType riskType,
      double riskValue,
      double? stopLoss,
      double? takeProfit,
      bool useTrailingStop,
      double? trailingStopDistance});
}

/// @nodoc
class _$RiskManagementCopyWithImpl<$Res, $Val extends RiskManagement>
    implements $RiskManagementCopyWith<$Res> {
  _$RiskManagementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RiskManagement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? riskType = null,
    Object? riskValue = null,
    Object? stopLoss = freezed,
    Object? takeProfit = freezed,
    Object? useTrailingStop = null,
    Object? trailingStopDistance = freezed,
  }) {
    return _then(_value.copyWith(
      riskType: null == riskType
          ? _value.riskType
          : riskType // ignore: cast_nullable_to_non_nullable
              as RiskType,
      riskValue: null == riskValue
          ? _value.riskValue
          : riskValue // ignore: cast_nullable_to_non_nullable
              as double,
      stopLoss: freezed == stopLoss
          ? _value.stopLoss
          : stopLoss // ignore: cast_nullable_to_non_nullable
              as double?,
      takeProfit: freezed == takeProfit
          ? _value.takeProfit
          : takeProfit // ignore: cast_nullable_to_non_nullable
              as double?,
      useTrailingStop: null == useTrailingStop
          ? _value.useTrailingStop
          : useTrailingStop // ignore: cast_nullable_to_non_nullable
              as bool,
      trailingStopDistance: freezed == trailingStopDistance
          ? _value.trailingStopDistance
          : trailingStopDistance // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RiskManagementImplCopyWith<$Res>
    implements $RiskManagementCopyWith<$Res> {
  factory _$$RiskManagementImplCopyWith(_$RiskManagementImpl value,
          $Res Function(_$RiskManagementImpl) then) =
      __$$RiskManagementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {RiskType riskType,
      double riskValue,
      double? stopLoss,
      double? takeProfit,
      bool useTrailingStop,
      double? trailingStopDistance});
}

/// @nodoc
class __$$RiskManagementImplCopyWithImpl<$Res>
    extends _$RiskManagementCopyWithImpl<$Res, _$RiskManagementImpl>
    implements _$$RiskManagementImplCopyWith<$Res> {
  __$$RiskManagementImplCopyWithImpl(
      _$RiskManagementImpl _value, $Res Function(_$RiskManagementImpl) _then)
      : super(_value, _then);

  /// Create a copy of RiskManagement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? riskType = null,
    Object? riskValue = null,
    Object? stopLoss = freezed,
    Object? takeProfit = freezed,
    Object? useTrailingStop = null,
    Object? trailingStopDistance = freezed,
  }) {
    return _then(_$RiskManagementImpl(
      riskType: null == riskType
          ? _value.riskType
          : riskType // ignore: cast_nullable_to_non_nullable
              as RiskType,
      riskValue: null == riskValue
          ? _value.riskValue
          : riskValue // ignore: cast_nullable_to_non_nullable
              as double,
      stopLoss: freezed == stopLoss
          ? _value.stopLoss
          : stopLoss // ignore: cast_nullable_to_non_nullable
              as double?,
      takeProfit: freezed == takeProfit
          ? _value.takeProfit
          : takeProfit // ignore: cast_nullable_to_non_nullable
              as double?,
      useTrailingStop: null == useTrailingStop
          ? _value.useTrailingStop
          : useTrailingStop // ignore: cast_nullable_to_non_nullable
              as bool,
      trailingStopDistance: freezed == trailingStopDistance
          ? _value.trailingStopDistance
          : trailingStopDistance // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RiskManagementImpl implements _RiskManagement {
  const _$RiskManagementImpl(
      {required this.riskType,
      required this.riskValue,
      this.stopLoss,
      this.takeProfit,
      this.useTrailingStop = false,
      this.trailingStopDistance});

  factory _$RiskManagementImpl.fromJson(Map<String, dynamic> json) =>
      _$$RiskManagementImplFromJson(json);

  @override
  final RiskType riskType;
  @override
  final double riskValue;
// Fixed lot atau % risk
  @override
  final double? stopLoss;
// in pips/points atau %
  @override
  final double? takeProfit;
  @override
  @JsonKey()
  final bool useTrailingStop;
  @override
  final double? trailingStopDistance;

  @override
  String toString() {
    return 'RiskManagement(riskType: $riskType, riskValue: $riskValue, stopLoss: $stopLoss, takeProfit: $takeProfit, useTrailingStop: $useTrailingStop, trailingStopDistance: $trailingStopDistance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RiskManagementImpl &&
            (identical(other.riskType, riskType) ||
                other.riskType == riskType) &&
            (identical(other.riskValue, riskValue) ||
                other.riskValue == riskValue) &&
            (identical(other.stopLoss, stopLoss) ||
                other.stopLoss == stopLoss) &&
            (identical(other.takeProfit, takeProfit) ||
                other.takeProfit == takeProfit) &&
            (identical(other.useTrailingStop, useTrailingStop) ||
                other.useTrailingStop == useTrailingStop) &&
            (identical(other.trailingStopDistance, trailingStopDistance) ||
                other.trailingStopDistance == trailingStopDistance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, riskType, riskValue, stopLoss,
      takeProfit, useTrailingStop, trailingStopDistance);

  /// Create a copy of RiskManagement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RiskManagementImplCopyWith<_$RiskManagementImpl> get copyWith =>
      __$$RiskManagementImplCopyWithImpl<_$RiskManagementImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RiskManagementImplToJson(
      this,
    );
  }
}

abstract class _RiskManagement implements RiskManagement {
  const factory _RiskManagement(
      {required final RiskType riskType,
      required final double riskValue,
      final double? stopLoss,
      final double? takeProfit,
      final bool useTrailingStop,
      final double? trailingStopDistance}) = _$RiskManagementImpl;

  factory _RiskManagement.fromJson(Map<String, dynamic> json) =
      _$RiskManagementImpl.fromJson;

  @override
  RiskType get riskType;
  @override
  double get riskValue; // Fixed lot atau % risk
  @override
  double? get stopLoss; // in pips/points atau %
  @override
  double? get takeProfit;
  @override
  bool get useTrailingStop;
  @override
  double? get trailingStopDistance;

  /// Create a copy of RiskManagement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RiskManagementImplCopyWith<_$RiskManagementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StrategyRule _$StrategyRuleFromJson(Map<String, dynamic> json) {
  return _StrategyRule.fromJson(json);
}

/// @nodoc
mixin _$StrategyRule {
  IndicatorType get indicator => throw _privateConstructorUsedError;
  ComparisonOperator get operator => throw _privateConstructorUsedError;
  ConditionValue get value => throw _privateConstructorUsedError;
  LogicalOperator? get logicalOperator => throw _privateConstructorUsedError;

  /// Serializes this StrategyRule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StrategyRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StrategyRuleCopyWith<StrategyRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StrategyRuleCopyWith<$Res> {
  factory $StrategyRuleCopyWith(
          StrategyRule value, $Res Function(StrategyRule) then) =
      _$StrategyRuleCopyWithImpl<$Res, StrategyRule>;
  @useResult
  $Res call(
      {IndicatorType indicator,
      ComparisonOperator operator,
      ConditionValue value,
      LogicalOperator? logicalOperator});

  $ConditionValueCopyWith<$Res> get value;
}

/// @nodoc
class _$StrategyRuleCopyWithImpl<$Res, $Val extends StrategyRule>
    implements $StrategyRuleCopyWith<$Res> {
  _$StrategyRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StrategyRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? indicator = null,
    Object? operator = null,
    Object? value = null,
    Object? logicalOperator = freezed,
  }) {
    return _then(_value.copyWith(
      indicator: null == indicator
          ? _value.indicator
          : indicator // ignore: cast_nullable_to_non_nullable
              as IndicatorType,
      operator: null == operator
          ? _value.operator
          : operator // ignore: cast_nullable_to_non_nullable
              as ComparisonOperator,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as ConditionValue,
      logicalOperator: freezed == logicalOperator
          ? _value.logicalOperator
          : logicalOperator // ignore: cast_nullable_to_non_nullable
              as LogicalOperator?,
    ) as $Val);
  }

  /// Create a copy of StrategyRule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConditionValueCopyWith<$Res> get value {
    return $ConditionValueCopyWith<$Res>(_value.value, (value) {
      return _then(_value.copyWith(value: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StrategyRuleImplCopyWith<$Res>
    implements $StrategyRuleCopyWith<$Res> {
  factory _$$StrategyRuleImplCopyWith(
          _$StrategyRuleImpl value, $Res Function(_$StrategyRuleImpl) then) =
      __$$StrategyRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {IndicatorType indicator,
      ComparisonOperator operator,
      ConditionValue value,
      LogicalOperator? logicalOperator});

  @override
  $ConditionValueCopyWith<$Res> get value;
}

/// @nodoc
class __$$StrategyRuleImplCopyWithImpl<$Res>
    extends _$StrategyRuleCopyWithImpl<$Res, _$StrategyRuleImpl>
    implements _$$StrategyRuleImplCopyWith<$Res> {
  __$$StrategyRuleImplCopyWithImpl(
      _$StrategyRuleImpl _value, $Res Function(_$StrategyRuleImpl) _then)
      : super(_value, _then);

  /// Create a copy of StrategyRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? indicator = null,
    Object? operator = null,
    Object? value = null,
    Object? logicalOperator = freezed,
  }) {
    return _then(_$StrategyRuleImpl(
      indicator: null == indicator
          ? _value.indicator
          : indicator // ignore: cast_nullable_to_non_nullable
              as IndicatorType,
      operator: null == operator
          ? _value.operator
          : operator // ignore: cast_nullable_to_non_nullable
              as ComparisonOperator,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as ConditionValue,
      logicalOperator: freezed == logicalOperator
          ? _value.logicalOperator
          : logicalOperator // ignore: cast_nullable_to_non_nullable
              as LogicalOperator?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StrategyRuleImpl implements _StrategyRule {
  const _$StrategyRuleImpl(
      {required this.indicator,
      required this.operator,
      required this.value,
      this.logicalOperator});

  factory _$StrategyRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$StrategyRuleImplFromJson(json);

  @override
  final IndicatorType indicator;
  @override
  final ComparisonOperator operator;
  @override
  final ConditionValue value;
  @override
  final LogicalOperator? logicalOperator;

  @override
  String toString() {
    return 'StrategyRule(indicator: $indicator, operator: $operator, value: $value, logicalOperator: $logicalOperator)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StrategyRuleImpl &&
            (identical(other.indicator, indicator) ||
                other.indicator == indicator) &&
            (identical(other.operator, operator) ||
                other.operator == operator) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.logicalOperator, logicalOperator) ||
                other.logicalOperator == logicalOperator));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, indicator, operator, value, logicalOperator);

  /// Create a copy of StrategyRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StrategyRuleImplCopyWith<_$StrategyRuleImpl> get copyWith =>
      __$$StrategyRuleImplCopyWithImpl<_$StrategyRuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StrategyRuleImplToJson(
      this,
    );
  }
}

abstract class _StrategyRule implements StrategyRule {
  const factory _StrategyRule(
      {required final IndicatorType indicator,
      required final ComparisonOperator operator,
      required final ConditionValue value,
      final LogicalOperator? logicalOperator}) = _$StrategyRuleImpl;

  factory _StrategyRule.fromJson(Map<String, dynamic> json) =
      _$StrategyRuleImpl.fromJson;

  @override
  IndicatorType get indicator;
  @override
  ComparisonOperator get operator;
  @override
  ConditionValue get value;
  @override
  LogicalOperator? get logicalOperator;

  /// Create a copy of StrategyRule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StrategyRuleImplCopyWith<_$StrategyRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConditionValue _$ConditionValueFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'number':
      return _NumberValue.fromJson(json);
    case 'indicator':
      return _IndicatorValue.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'ConditionValue',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$ConditionValue {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double value) number,
    required TResult Function(IndicatorType type, int? period) indicator,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double value)? number,
    TResult? Function(IndicatorType type, int? period)? indicator,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double value)? number,
    TResult Function(IndicatorType type, int? period)? indicator,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NumberValue value) number,
    required TResult Function(_IndicatorValue value) indicator,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NumberValue value)? number,
    TResult? Function(_IndicatorValue value)? indicator,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NumberValue value)? number,
    TResult Function(_IndicatorValue value)? indicator,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this ConditionValue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConditionValueCopyWith<$Res> {
  factory $ConditionValueCopyWith(
          ConditionValue value, $Res Function(ConditionValue) then) =
      _$ConditionValueCopyWithImpl<$Res, ConditionValue>;
}

/// @nodoc
class _$ConditionValueCopyWithImpl<$Res, $Val extends ConditionValue>
    implements $ConditionValueCopyWith<$Res> {
  _$ConditionValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConditionValue
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$NumberValueImplCopyWith<$Res> {
  factory _$$NumberValueImplCopyWith(
          _$NumberValueImpl value, $Res Function(_$NumberValueImpl) then) =
      __$$NumberValueImplCopyWithImpl<$Res>;
  @useResult
  $Res call({double value});
}

/// @nodoc
class __$$NumberValueImplCopyWithImpl<$Res>
    extends _$ConditionValueCopyWithImpl<$Res, _$NumberValueImpl>
    implements _$$NumberValueImplCopyWith<$Res> {
  __$$NumberValueImplCopyWithImpl(
      _$NumberValueImpl _value, $Res Function(_$NumberValueImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConditionValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_$NumberValueImpl(
      null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NumberValueImpl implements _NumberValue {
  const _$NumberValueImpl(this.value, {final String? $type})
      : $type = $type ?? 'number';

  factory _$NumberValueImpl.fromJson(Map<String, dynamic> json) =>
      _$$NumberValueImplFromJson(json);

  @override
  final double value;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ConditionValue.number(value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NumberValueImpl &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value);

  /// Create a copy of ConditionValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NumberValueImplCopyWith<_$NumberValueImpl> get copyWith =>
      __$$NumberValueImplCopyWithImpl<_$NumberValueImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double value) number,
    required TResult Function(IndicatorType type, int? period) indicator,
  }) {
    return number(value);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double value)? number,
    TResult? Function(IndicatorType type, int? period)? indicator,
  }) {
    return number?.call(value);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double value)? number,
    TResult Function(IndicatorType type, int? period)? indicator,
    required TResult orElse(),
  }) {
    if (number != null) {
      return number(value);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NumberValue value) number,
    required TResult Function(_IndicatorValue value) indicator,
  }) {
    return number(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NumberValue value)? number,
    TResult? Function(_IndicatorValue value)? indicator,
  }) {
    return number?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NumberValue value)? number,
    TResult Function(_IndicatorValue value)? indicator,
    required TResult orElse(),
  }) {
    if (number != null) {
      return number(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$NumberValueImplToJson(
      this,
    );
  }
}

abstract class _NumberValue implements ConditionValue {
  const factory _NumberValue(final double value) = _$NumberValueImpl;

  factory _NumberValue.fromJson(Map<String, dynamic> json) =
      _$NumberValueImpl.fromJson;

  double get value;

  /// Create a copy of ConditionValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NumberValueImplCopyWith<_$NumberValueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$IndicatorValueImplCopyWith<$Res> {
  factory _$$IndicatorValueImplCopyWith(_$IndicatorValueImpl value,
          $Res Function(_$IndicatorValueImpl) then) =
      __$$IndicatorValueImplCopyWithImpl<$Res>;
  @useResult
  $Res call({IndicatorType type, int? period});
}

/// @nodoc
class __$$IndicatorValueImplCopyWithImpl<$Res>
    extends _$ConditionValueCopyWithImpl<$Res, _$IndicatorValueImpl>
    implements _$$IndicatorValueImplCopyWith<$Res> {
  __$$IndicatorValueImplCopyWithImpl(
      _$IndicatorValueImpl _value, $Res Function(_$IndicatorValueImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConditionValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? period = freezed,
  }) {
    return _then(_$IndicatorValueImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as IndicatorType,
      period: freezed == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IndicatorValueImpl implements _IndicatorValue {
  const _$IndicatorValueImpl(
      {required this.type, this.period, final String? $type})
      : $type = $type ?? 'indicator';

  factory _$IndicatorValueImpl.fromJson(Map<String, dynamic> json) =>
      _$$IndicatorValueImplFromJson(json);

  @override
  final IndicatorType type;
  @override
  final int? period;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ConditionValue.indicator(type: $type, period: $period)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IndicatorValueImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.period, period) || other.period == period));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, period);

  /// Create a copy of ConditionValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IndicatorValueImplCopyWith<_$IndicatorValueImpl> get copyWith =>
      __$$IndicatorValueImplCopyWithImpl<_$IndicatorValueImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double value) number,
    required TResult Function(IndicatorType type, int? period) indicator,
  }) {
    return indicator(type, period);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double value)? number,
    TResult? Function(IndicatorType type, int? period)? indicator,
  }) {
    return indicator?.call(type, period);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double value)? number,
    TResult Function(IndicatorType type, int? period)? indicator,
    required TResult orElse(),
  }) {
    if (indicator != null) {
      return indicator(type, period);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NumberValue value) number,
    required TResult Function(_IndicatorValue value) indicator,
  }) {
    return indicator(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NumberValue value)? number,
    TResult? Function(_IndicatorValue value)? indicator,
  }) {
    return indicator?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NumberValue value)? number,
    TResult Function(_IndicatorValue value)? indicator,
    required TResult orElse(),
  }) {
    if (indicator != null) {
      return indicator(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$IndicatorValueImplToJson(
      this,
    );
  }
}

abstract class _IndicatorValue implements ConditionValue {
  const factory _IndicatorValue(
      {required final IndicatorType type,
      final int? period}) = _$IndicatorValueImpl;

  factory _IndicatorValue.fromJson(Map<String, dynamic> json) =
      _$IndicatorValueImpl.fromJson;

  IndicatorType get type;
  int? get period;

  /// Create a copy of ConditionValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IndicatorValueImplCopyWith<_$IndicatorValueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
