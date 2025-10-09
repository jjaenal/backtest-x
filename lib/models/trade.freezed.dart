// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trade.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Trade _$TradeFromJson(Map<String, dynamic> json) {
  return _Trade.fromJson(json);
}

/// @nodoc
mixin _$Trade {
  String get id => throw _privateConstructorUsedError;
  TradeDirection get direction => throw _privateConstructorUsedError;
  DateTime get entryTime => throw _privateConstructorUsedError;
  double get entryPrice => throw _privateConstructorUsedError;
  double get lotSize => throw _privateConstructorUsedError;
  DateTime? get exitTime => throw _privateConstructorUsedError;
  double? get exitPrice => throw _privateConstructorUsedError;
  double? get stopLoss => throw _privateConstructorUsedError;
  double? get takeProfit => throw _privateConstructorUsedError;
  TradeStatus? get status => throw _privateConstructorUsedError;
  double? get pnl => throw _privateConstructorUsedError;
  double? get pnlPercentage => throw _privateConstructorUsedError;
  String? get exitReason => throw _privateConstructorUsedError;

  /// Serializes this Trade to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Trade
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TradeCopyWith<Trade> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TradeCopyWith<$Res> {
  factory $TradeCopyWith(Trade value, $Res Function(Trade) then) =
      _$TradeCopyWithImpl<$Res, Trade>;
  @useResult
  $Res call(
      {String id,
      TradeDirection direction,
      DateTime entryTime,
      double entryPrice,
      double lotSize,
      DateTime? exitTime,
      double? exitPrice,
      double? stopLoss,
      double? takeProfit,
      TradeStatus? status,
      double? pnl,
      double? pnlPercentage,
      String? exitReason});
}

/// @nodoc
class _$TradeCopyWithImpl<$Res, $Val extends Trade>
    implements $TradeCopyWith<$Res> {
  _$TradeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Trade
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? direction = null,
    Object? entryTime = null,
    Object? entryPrice = null,
    Object? lotSize = null,
    Object? exitTime = freezed,
    Object? exitPrice = freezed,
    Object? stopLoss = freezed,
    Object? takeProfit = freezed,
    Object? status = freezed,
    Object? pnl = freezed,
    Object? pnlPercentage = freezed,
    Object? exitReason = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      direction: null == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as TradeDirection,
      entryTime: null == entryTime
          ? _value.entryTime
          : entryTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      entryPrice: null == entryPrice
          ? _value.entryPrice
          : entryPrice // ignore: cast_nullable_to_non_nullable
              as double,
      lotSize: null == lotSize
          ? _value.lotSize
          : lotSize // ignore: cast_nullable_to_non_nullable
              as double,
      exitTime: freezed == exitTime
          ? _value.exitTime
          : exitTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      exitPrice: freezed == exitPrice
          ? _value.exitPrice
          : exitPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      stopLoss: freezed == stopLoss
          ? _value.stopLoss
          : stopLoss // ignore: cast_nullable_to_non_nullable
              as double?,
      takeProfit: freezed == takeProfit
          ? _value.takeProfit
          : takeProfit // ignore: cast_nullable_to_non_nullable
              as double?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TradeStatus?,
      pnl: freezed == pnl
          ? _value.pnl
          : pnl // ignore: cast_nullable_to_non_nullable
              as double?,
      pnlPercentage: freezed == pnlPercentage
          ? _value.pnlPercentage
          : pnlPercentage // ignore: cast_nullable_to_non_nullable
              as double?,
      exitReason: freezed == exitReason
          ? _value.exitReason
          : exitReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TradeImplCopyWith<$Res> implements $TradeCopyWith<$Res> {
  factory _$$TradeImplCopyWith(
          _$TradeImpl value, $Res Function(_$TradeImpl) then) =
      __$$TradeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      TradeDirection direction,
      DateTime entryTime,
      double entryPrice,
      double lotSize,
      DateTime? exitTime,
      double? exitPrice,
      double? stopLoss,
      double? takeProfit,
      TradeStatus? status,
      double? pnl,
      double? pnlPercentage,
      String? exitReason});
}

/// @nodoc
class __$$TradeImplCopyWithImpl<$Res>
    extends _$TradeCopyWithImpl<$Res, _$TradeImpl>
    implements _$$TradeImplCopyWith<$Res> {
  __$$TradeImplCopyWithImpl(
      _$TradeImpl _value, $Res Function(_$TradeImpl) _then)
      : super(_value, _then);

  /// Create a copy of Trade
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? direction = null,
    Object? entryTime = null,
    Object? entryPrice = null,
    Object? lotSize = null,
    Object? exitTime = freezed,
    Object? exitPrice = freezed,
    Object? stopLoss = freezed,
    Object? takeProfit = freezed,
    Object? status = freezed,
    Object? pnl = freezed,
    Object? pnlPercentage = freezed,
    Object? exitReason = freezed,
  }) {
    return _then(_$TradeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      direction: null == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as TradeDirection,
      entryTime: null == entryTime
          ? _value.entryTime
          : entryTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      entryPrice: null == entryPrice
          ? _value.entryPrice
          : entryPrice // ignore: cast_nullable_to_non_nullable
              as double,
      lotSize: null == lotSize
          ? _value.lotSize
          : lotSize // ignore: cast_nullable_to_non_nullable
              as double,
      exitTime: freezed == exitTime
          ? _value.exitTime
          : exitTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      exitPrice: freezed == exitPrice
          ? _value.exitPrice
          : exitPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      stopLoss: freezed == stopLoss
          ? _value.stopLoss
          : stopLoss // ignore: cast_nullable_to_non_nullable
              as double?,
      takeProfit: freezed == takeProfit
          ? _value.takeProfit
          : takeProfit // ignore: cast_nullable_to_non_nullable
              as double?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TradeStatus?,
      pnl: freezed == pnl
          ? _value.pnl
          : pnl // ignore: cast_nullable_to_non_nullable
              as double?,
      pnlPercentage: freezed == pnlPercentage
          ? _value.pnlPercentage
          : pnlPercentage // ignore: cast_nullable_to_non_nullable
              as double?,
      exitReason: freezed == exitReason
          ? _value.exitReason
          : exitReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TradeImpl implements _Trade {
  const _$TradeImpl(
      {required this.id,
      required this.direction,
      required this.entryTime,
      required this.entryPrice,
      required this.lotSize,
      this.exitTime,
      this.exitPrice,
      this.stopLoss,
      this.takeProfit,
      this.status,
      this.pnl,
      this.pnlPercentage,
      this.exitReason});

  factory _$TradeImpl.fromJson(Map<String, dynamic> json) =>
      _$$TradeImplFromJson(json);

  @override
  final String id;
  @override
  final TradeDirection direction;
  @override
  final DateTime entryTime;
  @override
  final double entryPrice;
  @override
  final double lotSize;
  @override
  final DateTime? exitTime;
  @override
  final double? exitPrice;
  @override
  final double? stopLoss;
  @override
  final double? takeProfit;
  @override
  final TradeStatus? status;
  @override
  final double? pnl;
  @override
  final double? pnlPercentage;
  @override
  final String? exitReason;

  @override
  String toString() {
    return 'Trade(id: $id, direction: $direction, entryTime: $entryTime, entryPrice: $entryPrice, lotSize: $lotSize, exitTime: $exitTime, exitPrice: $exitPrice, stopLoss: $stopLoss, takeProfit: $takeProfit, status: $status, pnl: $pnl, pnlPercentage: $pnlPercentage, exitReason: $exitReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TradeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.entryTime, entryTime) ||
                other.entryTime == entryTime) &&
            (identical(other.entryPrice, entryPrice) ||
                other.entryPrice == entryPrice) &&
            (identical(other.lotSize, lotSize) || other.lotSize == lotSize) &&
            (identical(other.exitTime, exitTime) ||
                other.exitTime == exitTime) &&
            (identical(other.exitPrice, exitPrice) ||
                other.exitPrice == exitPrice) &&
            (identical(other.stopLoss, stopLoss) ||
                other.stopLoss == stopLoss) &&
            (identical(other.takeProfit, takeProfit) ||
                other.takeProfit == takeProfit) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.pnl, pnl) || other.pnl == pnl) &&
            (identical(other.pnlPercentage, pnlPercentage) ||
                other.pnlPercentage == pnlPercentage) &&
            (identical(other.exitReason, exitReason) ||
                other.exitReason == exitReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      direction,
      entryTime,
      entryPrice,
      lotSize,
      exitTime,
      exitPrice,
      stopLoss,
      takeProfit,
      status,
      pnl,
      pnlPercentage,
      exitReason);

  /// Create a copy of Trade
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TradeImplCopyWith<_$TradeImpl> get copyWith =>
      __$$TradeImplCopyWithImpl<_$TradeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TradeImplToJson(
      this,
    );
  }
}

abstract class _Trade implements Trade {
  const factory _Trade(
      {required final String id,
      required final TradeDirection direction,
      required final DateTime entryTime,
      required final double entryPrice,
      required final double lotSize,
      final DateTime? exitTime,
      final double? exitPrice,
      final double? stopLoss,
      final double? takeProfit,
      final TradeStatus? status,
      final double? pnl,
      final double? pnlPercentage,
      final String? exitReason}) = _$TradeImpl;

  factory _Trade.fromJson(Map<String, dynamic> json) = _$TradeImpl.fromJson;

  @override
  String get id;
  @override
  TradeDirection get direction;
  @override
  DateTime get entryTime;
  @override
  double get entryPrice;
  @override
  double get lotSize;
  @override
  DateTime? get exitTime;
  @override
  double? get exitPrice;
  @override
  double? get stopLoss;
  @override
  double? get takeProfit;
  @override
  TradeStatus? get status;
  @override
  double? get pnl;
  @override
  double? get pnlPercentage;
  @override
  String? get exitReason;

  /// Create a copy of Trade
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TradeImplCopyWith<_$TradeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BacktestResult _$BacktestResultFromJson(Map<String, dynamic> json) {
  return _BacktestResult.fromJson(json);
}

/// @nodoc
mixin _$BacktestResult {
  String get id => throw _privateConstructorUsedError;
  String get strategyId => throw _privateConstructorUsedError;
  String get marketDataId =>
      throw _privateConstructorUsedError; // Add market data ID
  DateTime get executedAt => throw _privateConstructorUsedError;
  List<Trade> get trades => throw _privateConstructorUsedError;
  BacktestSummary get summary => throw _privateConstructorUsedError;
  List<EquityPoint> get equityCurve => throw _privateConstructorUsedError;

  /// Serializes this BacktestResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BacktestResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BacktestResultCopyWith<BacktestResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BacktestResultCopyWith<$Res> {
  factory $BacktestResultCopyWith(
          BacktestResult value, $Res Function(BacktestResult) then) =
      _$BacktestResultCopyWithImpl<$Res, BacktestResult>;
  @useResult
  $Res call(
      {String id,
      String strategyId,
      String marketDataId,
      DateTime executedAt,
      List<Trade> trades,
      BacktestSummary summary,
      List<EquityPoint> equityCurve});

  $BacktestSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$BacktestResultCopyWithImpl<$Res, $Val extends BacktestResult>
    implements $BacktestResultCopyWith<$Res> {
  _$BacktestResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BacktestResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? strategyId = null,
    Object? marketDataId = null,
    Object? executedAt = null,
    Object? trades = null,
    Object? summary = null,
    Object? equityCurve = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      strategyId: null == strategyId
          ? _value.strategyId
          : strategyId // ignore: cast_nullable_to_non_nullable
              as String,
      marketDataId: null == marketDataId
          ? _value.marketDataId
          : marketDataId // ignore: cast_nullable_to_non_nullable
              as String,
      executedAt: null == executedAt
          ? _value.executedAt
          : executedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      trades: null == trades
          ? _value.trades
          : trades // ignore: cast_nullable_to_non_nullable
              as List<Trade>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as BacktestSummary,
      equityCurve: null == equityCurve
          ? _value.equityCurve
          : equityCurve // ignore: cast_nullable_to_non_nullable
              as List<EquityPoint>,
    ) as $Val);
  }

  /// Create a copy of BacktestResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BacktestSummaryCopyWith<$Res> get summary {
    return $BacktestSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BacktestResultImplCopyWith<$Res>
    implements $BacktestResultCopyWith<$Res> {
  factory _$$BacktestResultImplCopyWith(_$BacktestResultImpl value,
          $Res Function(_$BacktestResultImpl) then) =
      __$$BacktestResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String strategyId,
      String marketDataId,
      DateTime executedAt,
      List<Trade> trades,
      BacktestSummary summary,
      List<EquityPoint> equityCurve});

  @override
  $BacktestSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$BacktestResultImplCopyWithImpl<$Res>
    extends _$BacktestResultCopyWithImpl<$Res, _$BacktestResultImpl>
    implements _$$BacktestResultImplCopyWith<$Res> {
  __$$BacktestResultImplCopyWithImpl(
      _$BacktestResultImpl _value, $Res Function(_$BacktestResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of BacktestResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? strategyId = null,
    Object? marketDataId = null,
    Object? executedAt = null,
    Object? trades = null,
    Object? summary = null,
    Object? equityCurve = null,
  }) {
    return _then(_$BacktestResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      strategyId: null == strategyId
          ? _value.strategyId
          : strategyId // ignore: cast_nullable_to_non_nullable
              as String,
      marketDataId: null == marketDataId
          ? _value.marketDataId
          : marketDataId // ignore: cast_nullable_to_non_nullable
              as String,
      executedAt: null == executedAt
          ? _value.executedAt
          : executedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      trades: null == trades
          ? _value._trades
          : trades // ignore: cast_nullable_to_non_nullable
              as List<Trade>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as BacktestSummary,
      equityCurve: null == equityCurve
          ? _value._equityCurve
          : equityCurve // ignore: cast_nullable_to_non_nullable
              as List<EquityPoint>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BacktestResultImpl implements _BacktestResult {
  const _$BacktestResultImpl(
      {required this.id,
      required this.strategyId,
      required this.marketDataId,
      required this.executedAt,
      required final List<Trade> trades,
      required this.summary,
      required final List<EquityPoint> equityCurve})
      : _trades = trades,
        _equityCurve = equityCurve;

  factory _$BacktestResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$BacktestResultImplFromJson(json);

  @override
  final String id;
  @override
  final String strategyId;
  @override
  final String marketDataId;
// Add market data ID
  @override
  final DateTime executedAt;
  final List<Trade> _trades;
  @override
  List<Trade> get trades {
    if (_trades is EqualUnmodifiableListView) return _trades;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trades);
  }

  @override
  final BacktestSummary summary;
  final List<EquityPoint> _equityCurve;
  @override
  List<EquityPoint> get equityCurve {
    if (_equityCurve is EqualUnmodifiableListView) return _equityCurve;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equityCurve);
  }

  @override
  String toString() {
    return 'BacktestResult(id: $id, strategyId: $strategyId, marketDataId: $marketDataId, executedAt: $executedAt, trades: $trades, summary: $summary, equityCurve: $equityCurve)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BacktestResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.strategyId, strategyId) ||
                other.strategyId == strategyId) &&
            (identical(other.marketDataId, marketDataId) ||
                other.marketDataId == marketDataId) &&
            (identical(other.executedAt, executedAt) ||
                other.executedAt == executedAt) &&
            const DeepCollectionEquality().equals(other._trades, _trades) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality()
                .equals(other._equityCurve, _equityCurve));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      strategyId,
      marketDataId,
      executedAt,
      const DeepCollectionEquality().hash(_trades),
      summary,
      const DeepCollectionEquality().hash(_equityCurve));

  /// Create a copy of BacktestResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BacktestResultImplCopyWith<_$BacktestResultImpl> get copyWith =>
      __$$BacktestResultImplCopyWithImpl<_$BacktestResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BacktestResultImplToJson(
      this,
    );
  }
}

abstract class _BacktestResult implements BacktestResult {
  const factory _BacktestResult(
      {required final String id,
      required final String strategyId,
      required final String marketDataId,
      required final DateTime executedAt,
      required final List<Trade> trades,
      required final BacktestSummary summary,
      required final List<EquityPoint> equityCurve}) = _$BacktestResultImpl;

  factory _BacktestResult.fromJson(Map<String, dynamic> json) =
      _$BacktestResultImpl.fromJson;

  @override
  String get id;
  @override
  String get strategyId;
  @override
  String get marketDataId; // Add market data ID
  @override
  DateTime get executedAt;
  @override
  List<Trade> get trades;
  @override
  BacktestSummary get summary;
  @override
  List<EquityPoint> get equityCurve;

  /// Create a copy of BacktestResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BacktestResultImplCopyWith<_$BacktestResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BacktestSummary _$BacktestSummaryFromJson(Map<String, dynamic> json) {
  return _BacktestSummary.fromJson(json);
}

/// @nodoc
mixin _$BacktestSummary {
  int get totalTrades => throw _privateConstructorUsedError;
  int get winningTrades => throw _privateConstructorUsedError;
  int get losingTrades => throw _privateConstructorUsedError;
  double get winRate => throw _privateConstructorUsedError;
  double get totalPnl => throw _privateConstructorUsedError;
  double get totalPnlPercentage => throw _privateConstructorUsedError;
  double get profitFactor => throw _privateConstructorUsedError;
  double get maxDrawdown => throw _privateConstructorUsedError;
  double get maxDrawdownPercentage => throw _privateConstructorUsedError;
  double get sharpeRatio => throw _privateConstructorUsedError;
  double get averageWin => throw _privateConstructorUsedError;
  double get averageLoss => throw _privateConstructorUsedError;
  double get largestWin => throw _privateConstructorUsedError;
  double get largestLoss => throw _privateConstructorUsedError;
  double get expectancy => throw _privateConstructorUsedError;
  Map<String, Map<String, num>>? get tfStats =>
      throw _privateConstructorUsedError;

  /// Serializes this BacktestSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BacktestSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BacktestSummaryCopyWith<BacktestSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BacktestSummaryCopyWith<$Res> {
  factory $BacktestSummaryCopyWith(
          BacktestSummary value, $Res Function(BacktestSummary) then) =
      _$BacktestSummaryCopyWithImpl<$Res, BacktestSummary>;
  @useResult
  $Res call(
      {int totalTrades,
      int winningTrades,
      int losingTrades,
      double winRate,
      double totalPnl,
      double totalPnlPercentage,
      double profitFactor,
      double maxDrawdown,
      double maxDrawdownPercentage,
      double sharpeRatio,
      double averageWin,
      double averageLoss,
      double largestWin,
      double largestLoss,
      double expectancy,
      Map<String, Map<String, num>>? tfStats});
}

/// @nodoc
class _$BacktestSummaryCopyWithImpl<$Res, $Val extends BacktestSummary>
    implements $BacktestSummaryCopyWith<$Res> {
  _$BacktestSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BacktestSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalTrades = null,
    Object? winningTrades = null,
    Object? losingTrades = null,
    Object? winRate = null,
    Object? totalPnl = null,
    Object? totalPnlPercentage = null,
    Object? profitFactor = null,
    Object? maxDrawdown = null,
    Object? maxDrawdownPercentage = null,
    Object? sharpeRatio = null,
    Object? averageWin = null,
    Object? averageLoss = null,
    Object? largestWin = null,
    Object? largestLoss = null,
    Object? expectancy = null,
    Object? tfStats = freezed,
  }) {
    return _then(_value.copyWith(
      totalTrades: null == totalTrades
          ? _value.totalTrades
          : totalTrades // ignore: cast_nullable_to_non_nullable
              as int,
      winningTrades: null == winningTrades
          ? _value.winningTrades
          : winningTrades // ignore: cast_nullable_to_non_nullable
              as int,
      losingTrades: null == losingTrades
          ? _value.losingTrades
          : losingTrades // ignore: cast_nullable_to_non_nullable
              as int,
      winRate: null == winRate
          ? _value.winRate
          : winRate // ignore: cast_nullable_to_non_nullable
              as double,
      totalPnl: null == totalPnl
          ? _value.totalPnl
          : totalPnl // ignore: cast_nullable_to_non_nullable
              as double,
      totalPnlPercentage: null == totalPnlPercentage
          ? _value.totalPnlPercentage
          : totalPnlPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      profitFactor: null == profitFactor
          ? _value.profitFactor
          : profitFactor // ignore: cast_nullable_to_non_nullable
              as double,
      maxDrawdown: null == maxDrawdown
          ? _value.maxDrawdown
          : maxDrawdown // ignore: cast_nullable_to_non_nullable
              as double,
      maxDrawdownPercentage: null == maxDrawdownPercentage
          ? _value.maxDrawdownPercentage
          : maxDrawdownPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      sharpeRatio: null == sharpeRatio
          ? _value.sharpeRatio
          : sharpeRatio // ignore: cast_nullable_to_non_nullable
              as double,
      averageWin: null == averageWin
          ? _value.averageWin
          : averageWin // ignore: cast_nullable_to_non_nullable
              as double,
      averageLoss: null == averageLoss
          ? _value.averageLoss
          : averageLoss // ignore: cast_nullable_to_non_nullable
              as double,
      largestWin: null == largestWin
          ? _value.largestWin
          : largestWin // ignore: cast_nullable_to_non_nullable
              as double,
      largestLoss: null == largestLoss
          ? _value.largestLoss
          : largestLoss // ignore: cast_nullable_to_non_nullable
              as double,
      expectancy: null == expectancy
          ? _value.expectancy
          : expectancy // ignore: cast_nullable_to_non_nullable
              as double,
      tfStats: freezed == tfStats
          ? _value.tfStats
          : tfStats // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, num>>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BacktestSummaryImplCopyWith<$Res>
    implements $BacktestSummaryCopyWith<$Res> {
  factory _$$BacktestSummaryImplCopyWith(_$BacktestSummaryImpl value,
          $Res Function(_$BacktestSummaryImpl) then) =
      __$$BacktestSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalTrades,
      int winningTrades,
      int losingTrades,
      double winRate,
      double totalPnl,
      double totalPnlPercentage,
      double profitFactor,
      double maxDrawdown,
      double maxDrawdownPercentage,
      double sharpeRatio,
      double averageWin,
      double averageLoss,
      double largestWin,
      double largestLoss,
      double expectancy,
      Map<String, Map<String, num>>? tfStats});
}

/// @nodoc
class __$$BacktestSummaryImplCopyWithImpl<$Res>
    extends _$BacktestSummaryCopyWithImpl<$Res, _$BacktestSummaryImpl>
    implements _$$BacktestSummaryImplCopyWith<$Res> {
  __$$BacktestSummaryImplCopyWithImpl(
      _$BacktestSummaryImpl _value, $Res Function(_$BacktestSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of BacktestSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalTrades = null,
    Object? winningTrades = null,
    Object? losingTrades = null,
    Object? winRate = null,
    Object? totalPnl = null,
    Object? totalPnlPercentage = null,
    Object? profitFactor = null,
    Object? maxDrawdown = null,
    Object? maxDrawdownPercentage = null,
    Object? sharpeRatio = null,
    Object? averageWin = null,
    Object? averageLoss = null,
    Object? largestWin = null,
    Object? largestLoss = null,
    Object? expectancy = null,
    Object? tfStats = freezed,
  }) {
    return _then(_$BacktestSummaryImpl(
      totalTrades: null == totalTrades
          ? _value.totalTrades
          : totalTrades // ignore: cast_nullable_to_non_nullable
              as int,
      winningTrades: null == winningTrades
          ? _value.winningTrades
          : winningTrades // ignore: cast_nullable_to_non_nullable
              as int,
      losingTrades: null == losingTrades
          ? _value.losingTrades
          : losingTrades // ignore: cast_nullable_to_non_nullable
              as int,
      winRate: null == winRate
          ? _value.winRate
          : winRate // ignore: cast_nullable_to_non_nullable
              as double,
      totalPnl: null == totalPnl
          ? _value.totalPnl
          : totalPnl // ignore: cast_nullable_to_non_nullable
              as double,
      totalPnlPercentage: null == totalPnlPercentage
          ? _value.totalPnlPercentage
          : totalPnlPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      profitFactor: null == profitFactor
          ? _value.profitFactor
          : profitFactor // ignore: cast_nullable_to_non_nullable
              as double,
      maxDrawdown: null == maxDrawdown
          ? _value.maxDrawdown
          : maxDrawdown // ignore: cast_nullable_to_non_nullable
              as double,
      maxDrawdownPercentage: null == maxDrawdownPercentage
          ? _value.maxDrawdownPercentage
          : maxDrawdownPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      sharpeRatio: null == sharpeRatio
          ? _value.sharpeRatio
          : sharpeRatio // ignore: cast_nullable_to_non_nullable
              as double,
      averageWin: null == averageWin
          ? _value.averageWin
          : averageWin // ignore: cast_nullable_to_non_nullable
              as double,
      averageLoss: null == averageLoss
          ? _value.averageLoss
          : averageLoss // ignore: cast_nullable_to_non_nullable
              as double,
      largestWin: null == largestWin
          ? _value.largestWin
          : largestWin // ignore: cast_nullable_to_non_nullable
              as double,
      largestLoss: null == largestLoss
          ? _value.largestLoss
          : largestLoss // ignore: cast_nullable_to_non_nullable
              as double,
      expectancy: null == expectancy
          ? _value.expectancy
          : expectancy // ignore: cast_nullable_to_non_nullable
              as double,
      tfStats: freezed == tfStats
          ? _value._tfStats
          : tfStats // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, num>>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BacktestSummaryImpl implements _BacktestSummary {
  const _$BacktestSummaryImpl(
      {required this.totalTrades,
      required this.winningTrades,
      required this.losingTrades,
      required this.winRate,
      required this.totalPnl,
      required this.totalPnlPercentage,
      required this.profitFactor,
      required this.maxDrawdown,
      required this.maxDrawdownPercentage,
      required this.sharpeRatio,
      required this.averageWin,
      required this.averageLoss,
      required this.largestWin,
      required this.largestLoss,
      required this.expectancy,
      final Map<String, Map<String, num>>? tfStats})
      : _tfStats = tfStats;

  factory _$BacktestSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$BacktestSummaryImplFromJson(json);

  @override
  final int totalTrades;
  @override
  final int winningTrades;
  @override
  final int losingTrades;
  @override
  final double winRate;
  @override
  final double totalPnl;
  @override
  final double totalPnlPercentage;
  @override
  final double profitFactor;
  @override
  final double maxDrawdown;
  @override
  final double maxDrawdownPercentage;
  @override
  final double sharpeRatio;
  @override
  final double averageWin;
  @override
  final double averageLoss;
  @override
  final double largestWin;
  @override
  final double largestLoss;
  @override
  final double expectancy;
  final Map<String, Map<String, num>>? _tfStats;
  @override
  Map<String, Map<String, num>>? get tfStats {
    final value = _tfStats;
    if (value == null) return null;
    if (_tfStats is EqualUnmodifiableMapView) return _tfStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'BacktestSummary(totalTrades: $totalTrades, winningTrades: $winningTrades, losingTrades: $losingTrades, winRate: $winRate, totalPnl: $totalPnl, totalPnlPercentage: $totalPnlPercentage, profitFactor: $profitFactor, maxDrawdown: $maxDrawdown, maxDrawdownPercentage: $maxDrawdownPercentage, sharpeRatio: $sharpeRatio, averageWin: $averageWin, averageLoss: $averageLoss, largestWin: $largestWin, largestLoss: $largestLoss, expectancy: $expectancy, tfStats: $tfStats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BacktestSummaryImpl &&
            (identical(other.totalTrades, totalTrades) ||
                other.totalTrades == totalTrades) &&
            (identical(other.winningTrades, winningTrades) ||
                other.winningTrades == winningTrades) &&
            (identical(other.losingTrades, losingTrades) ||
                other.losingTrades == losingTrades) &&
            (identical(other.winRate, winRate) || other.winRate == winRate) &&
            (identical(other.totalPnl, totalPnl) ||
                other.totalPnl == totalPnl) &&
            (identical(other.totalPnlPercentage, totalPnlPercentage) ||
                other.totalPnlPercentage == totalPnlPercentage) &&
            (identical(other.profitFactor, profitFactor) ||
                other.profitFactor == profitFactor) &&
            (identical(other.maxDrawdown, maxDrawdown) ||
                other.maxDrawdown == maxDrawdown) &&
            (identical(other.maxDrawdownPercentage, maxDrawdownPercentage) ||
                other.maxDrawdownPercentage == maxDrawdownPercentage) &&
            (identical(other.sharpeRatio, sharpeRatio) ||
                other.sharpeRatio == sharpeRatio) &&
            (identical(other.averageWin, averageWin) ||
                other.averageWin == averageWin) &&
            (identical(other.averageLoss, averageLoss) ||
                other.averageLoss == averageLoss) &&
            (identical(other.largestWin, largestWin) ||
                other.largestWin == largestWin) &&
            (identical(other.largestLoss, largestLoss) ||
                other.largestLoss == largestLoss) &&
            (identical(other.expectancy, expectancy) ||
                other.expectancy == expectancy) &&
            const DeepCollectionEquality().equals(other._tfStats, _tfStats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalTrades,
      winningTrades,
      losingTrades,
      winRate,
      totalPnl,
      totalPnlPercentage,
      profitFactor,
      maxDrawdown,
      maxDrawdownPercentage,
      sharpeRatio,
      averageWin,
      averageLoss,
      largestWin,
      largestLoss,
      expectancy,
      const DeepCollectionEquality().hash(_tfStats));

  /// Create a copy of BacktestSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BacktestSummaryImplCopyWith<_$BacktestSummaryImpl> get copyWith =>
      __$$BacktestSummaryImplCopyWithImpl<_$BacktestSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BacktestSummaryImplToJson(
      this,
    );
  }
}

abstract class _BacktestSummary implements BacktestSummary {
  const factory _BacktestSummary(
      {required final int totalTrades,
      required final int winningTrades,
      required final int losingTrades,
      required final double winRate,
      required final double totalPnl,
      required final double totalPnlPercentage,
      required final double profitFactor,
      required final double maxDrawdown,
      required final double maxDrawdownPercentage,
      required final double sharpeRatio,
      required final double averageWin,
      required final double averageLoss,
      required final double largestWin,
      required final double largestLoss,
      required final double expectancy,
      final Map<String, Map<String, num>>? tfStats}) = _$BacktestSummaryImpl;

  factory _BacktestSummary.fromJson(Map<String, dynamic> json) =
      _$BacktestSummaryImpl.fromJson;

  @override
  int get totalTrades;
  @override
  int get winningTrades;
  @override
  int get losingTrades;
  @override
  double get winRate;
  @override
  double get totalPnl;
  @override
  double get totalPnlPercentage;
  @override
  double get profitFactor;
  @override
  double get maxDrawdown;
  @override
  double get maxDrawdownPercentage;
  @override
  double get sharpeRatio;
  @override
  double get averageWin;
  @override
  double get averageLoss;
  @override
  double get largestWin;
  @override
  double get largestLoss;
  @override
  double get expectancy;
  @override
  Map<String, Map<String, num>>? get tfStats;

  /// Create a copy of BacktestSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BacktestSummaryImplCopyWith<_$BacktestSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EquityPoint _$EquityPointFromJson(Map<String, dynamic> json) {
  return _EquityPoint.fromJson(json);
}

/// @nodoc
mixin _$EquityPoint {
  DateTime get timestamp => throw _privateConstructorUsedError;
  double get equity => throw _privateConstructorUsedError;
  double get drawdown => throw _privateConstructorUsedError;

  /// Serializes this EquityPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EquityPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EquityPointCopyWith<EquityPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EquityPointCopyWith<$Res> {
  factory $EquityPointCopyWith(
          EquityPoint value, $Res Function(EquityPoint) then) =
      _$EquityPointCopyWithImpl<$Res, EquityPoint>;
  @useResult
  $Res call({DateTime timestamp, double equity, double drawdown});
}

/// @nodoc
class _$EquityPointCopyWithImpl<$Res, $Val extends EquityPoint>
    implements $EquityPointCopyWith<$Res> {
  _$EquityPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EquityPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? equity = null,
    Object? drawdown = null,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      equity: null == equity
          ? _value.equity
          : equity // ignore: cast_nullable_to_non_nullable
              as double,
      drawdown: null == drawdown
          ? _value.drawdown
          : drawdown // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EquityPointImplCopyWith<$Res>
    implements $EquityPointCopyWith<$Res> {
  factory _$$EquityPointImplCopyWith(
          _$EquityPointImpl value, $Res Function(_$EquityPointImpl) then) =
      __$$EquityPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime timestamp, double equity, double drawdown});
}

/// @nodoc
class __$$EquityPointImplCopyWithImpl<$Res>
    extends _$EquityPointCopyWithImpl<$Res, _$EquityPointImpl>
    implements _$$EquityPointImplCopyWith<$Res> {
  __$$EquityPointImplCopyWithImpl(
      _$EquityPointImpl _value, $Res Function(_$EquityPointImpl) _then)
      : super(_value, _then);

  /// Create a copy of EquityPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? equity = null,
    Object? drawdown = null,
  }) {
    return _then(_$EquityPointImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      equity: null == equity
          ? _value.equity
          : equity // ignore: cast_nullable_to_non_nullable
              as double,
      drawdown: null == drawdown
          ? _value.drawdown
          : drawdown // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EquityPointImpl implements _EquityPoint {
  const _$EquityPointImpl(
      {required this.timestamp, required this.equity, required this.drawdown});

  factory _$EquityPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$EquityPointImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final double equity;
  @override
  final double drawdown;

  @override
  String toString() {
    return 'EquityPoint(timestamp: $timestamp, equity: $equity, drawdown: $drawdown)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EquityPointImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.equity, equity) || other.equity == equity) &&
            (identical(other.drawdown, drawdown) ||
                other.drawdown == drawdown));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, timestamp, equity, drawdown);

  /// Create a copy of EquityPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EquityPointImplCopyWith<_$EquityPointImpl> get copyWith =>
      __$$EquityPointImplCopyWithImpl<_$EquityPointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EquityPointImplToJson(
      this,
    );
  }
}

abstract class _EquityPoint implements EquityPoint {
  const factory _EquityPoint(
      {required final DateTime timestamp,
      required final double equity,
      required final double drawdown}) = _$EquityPointImpl;

  factory _EquityPoint.fromJson(Map<String, dynamic> json) =
      _$EquityPointImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  double get equity;
  @override
  double get drawdown;

  /// Create a copy of EquityPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EquityPointImplCopyWith<_$EquityPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
