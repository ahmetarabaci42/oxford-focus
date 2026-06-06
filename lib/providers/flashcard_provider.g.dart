// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recordCardResultHash() => r'075df8a1141ec05ae04a93d803e29efe392ac603';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [recordCardResult].
@ProviderFor(recordCardResult)
const recordCardResultProvider = RecordCardResultFamily();

/// See also [recordCardResult].
class RecordCardResultFamily extends Family<AsyncValue<void>> {
  /// See also [recordCardResult].
  const RecordCardResultFamily();

  /// See also [recordCardResult].
  RecordCardResultProvider call({
    required String wordId,
    required String result,
  }) {
    return RecordCardResultProvider(
      wordId: wordId,
      result: result,
    );
  }

  @override
  RecordCardResultProvider getProviderOverride(
    covariant RecordCardResultProvider provider,
  ) {
    return call(
      wordId: provider.wordId,
      result: provider.result,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recordCardResultProvider';
}

/// See also [recordCardResult].
class RecordCardResultProvider extends AutoDisposeFutureProvider<void> {
  /// See also [recordCardResult].
  RecordCardResultProvider({
    required String wordId,
    required String result,
  }) : this._internal(
          (ref) => recordCardResult(
            ref as RecordCardResultRef,
            wordId: wordId,
            result: result,
          ),
          from: recordCardResultProvider,
          name: r'recordCardResultProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$recordCardResultHash,
          dependencies: RecordCardResultFamily._dependencies,
          allTransitiveDependencies:
              RecordCardResultFamily._allTransitiveDependencies,
          wordId: wordId,
          result: result,
        );

  RecordCardResultProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.wordId,
    required this.result,
  }) : super.internal();

  final String wordId;
  final String result;

  @override
  Override overrideWith(
    FutureOr<void> Function(RecordCardResultRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecordCardResultProvider._internal(
        (ref) => create(ref as RecordCardResultRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        wordId: wordId,
        result: result,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _RecordCardResultProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecordCardResultProvider &&
        other.wordId == wordId &&
        other.result == result;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, wordId.hashCode);
    hash = _SystemHash.combine(hash, result.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RecordCardResultRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `wordId` of this provider.
  String get wordId;

  /// The parameter `result` of this provider.
  String get result;
}

class _RecordCardResultProviderElement
    extends AutoDisposeFutureProviderElement<void> with RecordCardResultRef {
  _RecordCardResultProviderElement(super.provider);

  @override
  String get wordId => (origin as RecordCardResultProvider).wordId;
  @override
  String get result => (origin as RecordCardResultProvider).result;
}

String _$flashcardIndexHash() => r'2b94936b8e76c173fd84c1184635d4c4905d75a9';

/// See also [FlashcardIndex].
@ProviderFor(FlashcardIndex)
final flashcardIndexProvider =
    AutoDisposeNotifierProvider<FlashcardIndex, int>.internal(
  FlashcardIndex.new,
  name: r'flashcardIndexProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$flashcardIndexHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FlashcardIndex = AutoDisposeNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
