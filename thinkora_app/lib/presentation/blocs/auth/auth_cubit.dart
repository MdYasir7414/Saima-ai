import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../user/user_cubit.dart';

/// Drives sign-in, sign-up, and sign-out. On success it pushes the resulting
/// user into [UserCubit] so the rest of the app sees it immediately.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo, this._userCubit) : super(const AuthState.initial());

  final AuthRepository _repo;
  final UserCubit _userCubit;

  Future<void> login({required String email, required String password}) async {
    emit(const AuthState(status: AuthStatus.submitting));
    try {
      final result = await _repo.login(email: email, password: password);
      _userCubit.setUser(result.user);
      emit(AuthState(status: AuthStatus.authenticated, user: result.user));
    } catch (e) {
      emit(AuthState(status: AuthStatus.error, message: e.toString()));
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    int age = 18,
    String ageGroup = 'pioneer',
  }) async {
    emit(const AuthState(status: AuthStatus.submitting));
    try {
      final result = await _repo.register(
        username: username,
        email: email,
        password: password,
        age: age,
        ageGroup: ageGroup,
      );
      _userCubit.setUser(result.user);
      emit(AuthState(status: AuthStatus.authenticated, user: result.user));
    } catch (e) {
      emit(AuthState(status: AuthStatus.error, message: e.toString()));
    }
  }

  Future<void> googleSignIn() async {
    emit(const AuthState(status: AuthStatus.submitting));
    try {
      // Real Google SDK wiring would supply these; we pass sensible defaults.
      final result = await _repo.googleSignIn(
        email: 'google.user@thinkora.ai',
        displayName: 'Google User',
      );
      _userCubit.setUser(result.user);
      emit(AuthState(status: AuthStatus.authenticated, user: result.user));
    } catch (e) {
      emit(AuthState(status: AuthStatus.error, message: e.toString()));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _userCubit.clear();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}

enum AuthStatus {
  initial,
  submitting,
  authenticated,
  unauthenticated,
  error,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.message,
  });

  const AuthState.initial() : this(status: AuthStatus.initial);

  final AuthStatus status;
  final UserModel? user;
  final String? message;

  bool get isSubmitting => status == AuthStatus.submitting;

  @override
  List<Object?> get props => [status, user, message];
}
