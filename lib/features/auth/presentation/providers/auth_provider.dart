// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobnest/features/auth/data/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

class AuthNotifier extends AsyncNotifier<User?> {
  late final AuthService _authService;

  @override
  Future<User?> build() async {
    _authService = ref.read(authServiceProvider);
    return _authService.currentUser;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _authService.signInWithEmail(email, password);
      return result?.user;
    });
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _authService.signUpWithEmail(email, password, name);
      return result?.user;
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _authService.signInWithGoogle();
      return result?.user;
    });
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);
