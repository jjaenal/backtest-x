// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'candle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Candle _$CandleFromJson(Map<String, dynamic> json) {
  return _Candle.fromJson(json);
}

/// @nodoc
mixin _$Candle {
  DateTime get timestamp => throw _privateConstructorUsedError;
  double get open => throw _privateConstructorUsedError;
  double get high => throw _privateConstructorUsedError;
  double get low => throw _privateConstructorUsedError;
  double get close => throw _privateConstructorUsedError;
  double get volume => throw _privateConstructorUsedError;

  /// Serializes this Candle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Candle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CandleCopyWith<Candle> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CandleCopyWith<$Res> {
  factory $CandleCopyWith(Candle value, $Res Function(Candle) then) =
      _$CandleCopyWithImpl<$Res, Candle>;
  @useResult
  $Res call(
      {DateTime timestamp,
      double open,
      double high,
      double low,
      double close,
      double volume});
}

/// @nodoc
class _$CandleCopyWithImpl<$Res, $Val extends Candle>
    implements $CandleCopyWith<$Res> {
  _$CandleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Candle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? open = null,
    Object? high = null,
    Object? low = null,
    Object? close = null,
    Object? volume = null,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      open: null == open
          ? _value.open
          : open // ignore: cast_nullable_to_non_nullable
              as double,
      high: null == high
          ? _value.high
          : high // ignore: cast_nullable_to_non_nullable
              as double,
      low: null == low
          ? _value.low
          : low // ignore: cast_nullable_to_non_nullable
              as double,
      close: null == close
          ? _value.close
          : close // ignore: cast_nullable_to_non_nullable
              as double,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CandleImplCopyWith<$Res> implements $CandleCopyWith<$Res> {
  factory _$$CandleImplCopyWith(
          _$CandleImpl value, $Res Function(_$CandleImpl) then) =
      __$$CandleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime timestamp,
      double open,
      double high,
      double low,
      double close,
      double volume});
}

/// @nodoc
class __$$CandleImplCopyWithImpl<$Res>
    extends _$CandleCopyWithImpl<$Res, _$CandleImpl>
    implements _$$CandleImplCopyWith<$Res> {
  __$$CandleImplCopyWithImpl(
      _$CandleImpl _value, $Res Function(_$CandleImpl) _then)
      : super(_value, _then);

  /// Create a copy of Candle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? open = null,
    Object? high = null,
    Object? low = null,
    Object? close = null,
    Object? volume = null,
  }) {
    return _then(_$CandleImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      open: null == open
          ? _value.open
          : open // ignore: cast_nullable_to_non_nullable
              as double,
      high: null == high
          ? _value.high
          : high // ignore: cast_nullable_to_non_nullable
              as double,
      low: null == low
          ? _value.low
          : low // ignore: cast_nullable_to_non_nullable
              as double,
      close: null == close
          ? _value.close
          : close // ignore: cast_nullable_to_non_nullable
              as double,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CandleImpl implements _Candle {
  const _$CandleImpl(
      {required this.timestamp,
      required this.open,
      required this.high,
      required this.low,
      required this.close,
      required this.volume});

  factory _$CandleImpl.fromJson(Map<String, dynamic> json) =>
      _$$CandleImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final double open;
  @override
  final double high;
  @override
  final double low;
  @override
  final double close;
  @override
  final double volume;

  @override
  String toString() {
    return 'Candle(timestamp: $timestamp, open: $open, high: $high, low: $low, close: $close, volume: $volume)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CandleImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.open, open) || other.open == open) &&
            (identical(other.high, high) || other.high == high) &&
            (identical(other.low, low) || other.low == low) &&
            (identical(other.close, close) || other.close == close) &&
            (identical(other.volume, volume) || other.volume == volume));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, timestamp, open, high, low, close, volume);

  /// Create a copy of Candle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CandleImplCopyWith<_$CandleImpl> get copyWith =>
      __$$CandleImplCopyWithImpl<_$CandleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CandleImplToJson(
      this,
    );
  }
}

abstract class _Candle implements Candle {
  const factory _Candle(
      {required final DateTime timestamp,
      required final double open,
      required final double high,
      required final double low,
      required final double close,
      required final double volume}) = _$CandleImpl;

  factory _Candle.fromJson(Map<String, dynamic> json) = _$CandleImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  double get open;
  @override
  double get high;
  @override
  double get low;
  @override
  double get close;
  @override
  double get volume;

  /// Create a copy of Candle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CandleImplCopyWith<_$CandleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MarketData _$MarketDataFromJson(Map<String, dynamic> json) {
  return _MarketData.fromJson(json);
}

/// @nodoc
mixin _$MarketData {
  String get id => throw _privateConstructorUsedError;
  String get symbol => throw _privateConstructorUsedError;
  String get timeframe => throw _privateConstructorUsedError;
  List<Candle> get candles => throw _privateConstructorUsedError;
  DateTime get uploadedAt => throw _privateConstructorUsedError;

  /// Serializes this MarketData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketDataCopyWith<MarketData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketDataCopyWith<$Res> {
  factory $MarketDataCopyWith(
          MarketData value, $Res Function(MarketData) then) =
      _$MarketDataCopyWithImpl<$Res, MarketData>;
  @useResult
  $Res call(
      {String id,
      String symbol,
      String timeframe,
      List<Candle> candles,
      DateTime uploadedAt});
}

/// @nodoc
class _$MarketDataCopyWithImpl<$Res, $Val extends MarketData>
    implements $MarketDataCopyWith<$Res> {
  _$MarketDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? symbol = null,
    Object? timeframe = null,
    Object? candles = null,
    Object? uploadedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      timeframe: null == timeframe
          ? _value.timeframe
          : timeframe // ignore: cast_nullable_to_non_nullable
              as String,
      candles: null == candles
          ? _value.candles
          : candles // ignore: cast_nullable_to_non_nullable
              as List<Candle>,
      uploadedAt: null == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MarketDataImplCopyWith<$Res>
    implements $MarketDataCopyWith<$Res> {
  factory _$$MarketDataImplCopyWith(
          _$MarketDataImpl value, $Res Function(_$MarketDataImpl) then) =
      __$$MarketDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String symbol,
      String timeframe,
      List<Candle> candles,
      DateTime uploadedAt});
}

/// @nodoc
class __$$MarketDataImplCopyWithImpl<$Res>
    extends _$MarketDataCopyWithImpl<$Res, _$MarketDataImpl>
    implements _$$MarketDataImplCopyWith<$Res> {
  __$$MarketDataImplCopyWithImpl(
      _$MarketDataImpl _value, $Res Function(_$MarketDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? symbol = null,
    Object? timeframe = null,
    Object? candles = null,
    Object? uploadedAt = null,
  }) {
    return _then(_$MarketDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      timeframe: null == timeframe
          ? _value.timeframe
          : timeframe // ignore: cast_nullable_to_non_nullable
              as String,
      candles: null == candles
          ? _value._candles
          : candles // ignore: cast_nullable_to_non_nullable
              as List<Candle>,
      uploadedAt: null == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketDataImpl implements _MarketData {
  const _$MarketDataImpl(
      {required this.id,
      required this.symbol,
      required this.timeframe,
      required final List<Candle> candles,
      required this.uploadedAt})
      : _candles = candles;

  factory _$MarketDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketDataImplFromJson(json);

  @override
  final String id;
  @override
  final String symbol;
  @override
  final String timeframe;
  final List<Candle> _candles;
  @override
  List<Candle> get candles {
    if (_candles is EqualUnmodifiableListView) return _candles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_candles);
  }

  @override
  final DateTime uploadedAt;

  @override
  String toString() {
    return 'MarketData(id: $id, symbol: $symbol, timeframe: $timeframe, candles: $candles, uploadedAt: $uploadedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.timeframe, timeframe) ||
                other.timeframe == timeframe) &&
            const DeepCollectionEquality().equals(other._candles, _candles) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, symbol, timeframe,
      const DeepCollectionEquality().hash(_candles), uploadedAt);

  /// Create a copy of MarketData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketDataImplCopyWith<_$MarketDataImpl> get copyWith =>
      __$$MarketDataImplCopyWithImpl<_$MarketDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketDataImplToJson(
      this,
    );
  }
}

abstract class _MarketData implements MarketData {
  const factory _MarketData(
      {required final String id,
      required final String symbol,
      required final String timeframe,
      required final List<Candle> candles,
      required final DateTime uploadedAt}) = _$MarketDataImpl;

  factory _MarketData.fromJson(Map<String, dynamic> json) =
      _$MarketDataImpl.fromJson;

  @override
  String get id;
  @override
  String get symbol;
  @override
  String get timeframe;
  @override
  List<Candle> get candles;
  @override
  DateTime get uploadedAt;

  /// Create a copy of MarketData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketDataImplCopyWith<_$MarketDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
