// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: avoid_positional_boolean_parameters, lines_longer_than_80_chars, invalid_use_of_internal_member, parameter_assignments, unnecessary_const, prefer_relative_imports, avoid_equals_and_hash_code_on_mutable_classes

part of 'counter_repository.dart';

// **************************************************************************
// TypedDocumentGenerator
// **************************************************************************

mixin _$CounterChange implements TypedDocumentObject<MutableCounterChange> {
  String get counterId;

  List<String> get channels;

  int get delta;

  DateTime get time;
}

abstract class _CounterChangeImplBase<I extends Document>
    with _$CounterChange
    implements CounterChange {
  _CounterChangeImplBase(this.internal);

  @override
  final I internal;

  @override
  String get id => internal.id;

  @override
  String get counterId => TypedDataHelpers.readProperty(
        internal: internal,
        name: 'counterId',
        key: 'counterId',
        converter: TypedDataHelpers.stringConverter,
      );

  @override
  int get delta => TypedDataHelpers.readProperty(
        internal: internal,
        name: 'delta',
        key: 'delta',
        converter: TypedDataHelpers.intConverter,
      );

  @override
  DateTime get time => TypedDataHelpers.readProperty(
        internal: internal,
        name: 'time',
        key: 'time',
        converter: TypedDataHelpers.dateTimeConverter,
      );

  @override
  MutableCounterChange toMutable() =>
      MutableCounterChange.internal(internal.toMutable());

  @override
  String toString({String? indent}) => TypedDataHelpers.renderString(
        indent: indent,
        className: 'CounterChange',
        fields: {
          'id': id,
          'counterId': counterId,
          'channels': channels,
          'delta': delta,
          'time': time,
        },
      );
}

/// DO NOT USE: Internal implementation detail, which might be changed or
/// removed in the future.
class ImmutableCounterChange extends _CounterChangeImplBase {
  ImmutableCounterChange.internal(super.internal);

  static const _channelsConverter = const TypedListConverter(
    converter: TypedDataHelpers.stringConverter,
    isNullable: false,
    isCached: false,
  );

  @override
  late final channels = TypedDataHelpers.readProperty(
    internal: internal,
    name: 'channels',
    key: 'channels',
    converter: _channelsConverter,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterChange &&
          runtimeType == other.runtimeType &&
          internal == other.internal;

  @override
  int get hashCode => internal.hashCode;
}

/// Mutable version of [CounterChange].
class MutableCounterChange extends _CounterChangeImplBase<MutableDocument>
    implements TypedMutableDocumentObject<CounterChange, MutableCounterChange> {
  /// Creates a new mutable [CounterChange].
  MutableCounterChange({
    required String counterId,
    required List<String> channels,
    required int delta,
    required DateTime time,
  }) : super(MutableDocument()) {
    this.counterId = counterId;
    this.channels = channels;
    this.delta = delta;
    this.time = time;
  }

  MutableCounterChange.internal(super.internal);

  static const _channelsConverter = const TypedListConverter(
    converter: TypedDataHelpers.stringConverter,
    isNullable: false,
    isCached: false,
  );

  set counterId(String value) {
    final promoted = TypedDataHelpers.stringConverter.promote(value);
    TypedDataHelpers.writeProperty(
      internal: internal,
      key: 'counterId',
      value: promoted,
      converter: TypedDataHelpers.stringConverter,
    );
  }

  late TypedDataList<String, String> _channels = TypedDataHelpers.readProperty(
    internal: internal,
    name: 'channels',
    key: 'channels',
    converter: _channelsConverter,
  );

  @override
  TypedDataList<String, String> get channels => _channels;

  set channels(List<String> value) {
    final promoted = _channelsConverter.promote(value);
    _channels = promoted;
    TypedDataHelpers.writeProperty(
      internal: internal,
      key: 'channels',
      value: promoted,
      converter: _channelsConverter,
    );
  }

  set delta(int value) {
    final promoted = TypedDataHelpers.intConverter.promote(value);
    TypedDataHelpers.writeProperty(
      internal: internal,
      key: 'delta',
      value: promoted,
      converter: TypedDataHelpers.intConverter,
    );
  }

  set time(DateTime value) {
    final promoted = TypedDataHelpers.dateTimeConverter.promote(value);
    TypedDataHelpers.writeProperty(
      internal: internal,
      key: 'time',
      value: promoted,
      converter: TypedDataHelpers.dateTimeConverter,
    );
  }
}
