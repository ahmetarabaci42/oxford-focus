import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

// Mock Auth State for local-only app
@riverpod
Stream<String?> authState(AuthStateRef ref) {
  return Stream.value('local_user');
}

@riverpod
Future<String> currentUserId(CurrentUserIdRef ref) async {
  return 'local_user';
}
