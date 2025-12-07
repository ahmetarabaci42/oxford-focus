// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProgress _$UserProgressFromJson(Map<String, dynamic> json) {
  return _UserProgress.fromJson(json);
}

/// @nodoc
mixin _$UserProgress {
  @JsonKey(name: 'current_week')
  int get currentWeek => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_word_ids')
  List<String> get activeWordIds => throw _privateConstructorUsedError;
  @JsonKey(name: 'learned_word_ids')
  List<String> get learnedWordIds => throw _privateConstructorUsedError;
  @JsonKey(name: 'saved_notes_ids')
  List<String> get savedNotesIds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProgressCopyWith<UserProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProgressCopyWith<$Res> {
  factory $UserProgressCopyWith(
          UserProgress value, $Res Function(UserProgress) then) =
      _$UserProgressCopyWithImpl<$Res, UserProgress>;
  @useResult
  $Res call(
      {@JsonKey(name: 'current_week') int currentWeek,
      @JsonKey(name: 'active_word_ids') List<String> activeWordIds,
      @JsonKey(name: 'learned_word_ids') List<String> learnedWordIds,
      @JsonKey(name: 'saved_notes_ids') List<String> savedNotesIds});
}

/// @nodoc
class _$UserProgressCopyWithImpl<$Res, $Val extends UserProgress>
    implements $UserProgressCopyWith<$Res> {
  _$UserProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentWeek = null,
    Object? activeWordIds = null,
    Object? learnedWordIds = null,
    Object? savedNotesIds = null,
  }) {
    return _then(_value.copyWith(
      currentWeek: null == currentWeek
          ? _value.currentWeek
          : currentWeek // ignore: cast_nullable_to_non_nullable
              as int,
      activeWordIds: null == activeWordIds
          ? _value.activeWordIds
          : activeWordIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      learnedWordIds: null == learnedWordIds
          ? _value.learnedWordIds
          : learnedWordIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      savedNotesIds: null == savedNotesIds
          ? _value.savedNotesIds
          : savedNotesIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProgressImplCopyWith<$Res>
    implements $UserProgressCopyWith<$Res> {
  factory _$$UserProgressImplCopyWith(
          _$UserProgressImpl value, $Res Function(_$UserProgressImpl) then) =
      __$$UserProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'current_week') int currentWeek,
      @JsonKey(name: 'active_word_ids') List<String> activeWordIds,
      @JsonKey(name: 'learned_word_ids') List<String> learnedWordIds,
      @JsonKey(name: 'saved_notes_ids') List<String> savedNotesIds});
}

/// @nodoc
class __$$UserProgressImplCopyWithImpl<$Res>
    extends _$UserProgressCopyWithImpl<$Res, _$UserProgressImpl>
    implements _$$UserProgressImplCopyWith<$Res> {
  __$$UserProgressImplCopyWithImpl(
      _$UserProgressImpl _value, $Res Function(_$UserProgressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentWeek = null,
    Object? activeWordIds = null,
    Object? learnedWordIds = null,
    Object? savedNotesIds = null,
  }) {
    return _then(_$UserProgressImpl(
      currentWeek: null == currentWeek
          ? _value.currentWeek
          : currentWeek // ignore: cast_nullable_to_non_nullable
              as int,
      activeWordIds: null == activeWordIds
          ? _value._activeWordIds
          : activeWordIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      learnedWordIds: null == learnedWordIds
          ? _value._learnedWordIds
          : learnedWordIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      savedNotesIds: null == savedNotesIds
          ? _value._savedNotesIds
          : savedNotesIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProgressImpl implements _UserProgress {
  const _$UserProgressImpl(
      {@JsonKey(name: 'current_week') this.currentWeek = 1,
      @JsonKey(name: 'active_word_ids')
      final List<String> activeWordIds = const [],
      @JsonKey(name: 'learned_word_ids')
      final List<String> learnedWordIds = const [],
      @JsonKey(name: 'saved_notes_ids')
      final List<String> savedNotesIds = const []})
      : _activeWordIds = activeWordIds,
        _learnedWordIds = learnedWordIds,
        _savedNotesIds = savedNotesIds;

  factory _$UserProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProgressImplFromJson(json);

  @override
  @JsonKey(name: 'current_week')
  final int currentWeek;
  final List<String> _activeWordIds;
  @override
  @JsonKey(name: 'active_word_ids')
  List<String> get activeWordIds {
    if (_activeWordIds is EqualUnmodifiableListView) return _activeWordIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeWordIds);
  }

  final List<String> _learnedWordIds;
  @override
  @JsonKey(name: 'learned_word_ids')
  List<String> get learnedWordIds {
    if (_learnedWordIds is EqualUnmodifiableListView) return _learnedWordIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_learnedWordIds);
  }

  final List<String> _savedNotesIds;
  @override
  @JsonKey(name: 'saved_notes_ids')
  List<String> get savedNotesIds {
    if (_savedNotesIds is EqualUnmodifiableListView) return _savedNotesIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_savedNotesIds);
  }

  @override
  String toString() {
    return 'UserProgress(currentWeek: $currentWeek, activeWordIds: $activeWordIds, learnedWordIds: $learnedWordIds, savedNotesIds: $savedNotesIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProgressImpl &&
            (identical(other.currentWeek, currentWeek) ||
                other.currentWeek == currentWeek) &&
            const DeepCollectionEquality()
                .equals(other._activeWordIds, _activeWordIds) &&
            const DeepCollectionEquality()
                .equals(other._learnedWordIds, _learnedWordIds) &&
            const DeepCollectionEquality()
                .equals(other._savedNotesIds, _savedNotesIds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentWeek,
      const DeepCollectionEquality().hash(_activeWordIds),
      const DeepCollectionEquality().hash(_learnedWordIds),
      const DeepCollectionEquality().hash(_savedNotesIds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProgressImplCopyWith<_$UserProgressImpl> get copyWith =>
      __$$UserProgressImplCopyWithImpl<_$UserProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProgressImplToJson(
      this,
    );
  }
}

abstract class _UserProgress implements UserProgress {
  const factory _UserProgress(
          {@JsonKey(name: 'current_week') final int currentWeek,
          @JsonKey(name: 'active_word_ids') final List<String> activeWordIds,
          @JsonKey(name: 'learned_word_ids') final List<String> learnedWordIds,
          @JsonKey(name: 'saved_notes_ids') final List<String> savedNotesIds}) =
      _$UserProgressImpl;

  factory _UserProgress.fromJson(Map<String, dynamic> json) =
      _$UserProgressImpl.fromJson;

  @override
  @JsonKey(name: 'current_week')
  int get currentWeek;
  @override
  @JsonKey(name: 'active_word_ids')
  List<String> get activeWordIds;
  @override
  @JsonKey(name: 'learned_word_ids')
  List<String> get learnedWordIds;
  @override
  @JsonKey(name: 'saved_notes_ids')
  List<String> get savedNotesIds;
  @override
  @JsonKey(ignore: true)
  _$$UserProgressImplCopyWith<_$UserProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
