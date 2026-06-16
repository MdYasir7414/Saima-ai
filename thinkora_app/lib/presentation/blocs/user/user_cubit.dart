import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

/// Holds the signed-in user across the whole app. Screens read TCI, stats,
/// and progress from here, and challenge results flow back in via [applyResult].
class UserCubit extends Cubit<UserState> {
  UserCubit(this._repo) : super(const UserState.initial());

  final UserRepository _repo;

  void setUser(UserModel user) {
    _repo.cache(user);
    emit(UserState.loaded(user));
  }

  Future<void> refresh() async {
    final current = state.user;
    emit(UserState(status: UserStatus.loading, user: current));
    try {
      final user = await _repo.getMe();
      if (user != null) {
        emit(UserState.loaded(user));
      } else if (current != null) {
        emit(UserState.loaded(current));
      } else {
        emit(const UserState(status: UserStatus.error, message: 'No user'));
      }
    } catch (e) {
      if (current != null) {
        emit(UserState.loaded(current));
      } else {
        emit(UserState(status: UserStatus.error, message: e.toString()));
      }
    }
  }

  /// Apply a graded challenge result to the live user state.
  void applyResult({
    required bool isCorrect,
    required int xpEarned,
    required int tciChange,
    required Map<String, int> dimensionChanges,
  }) {
    final current = state.user;
    if (current == null) return;
    final updated = _repo.applyProgress(
      user: current,
      isCorrect: isCorrect,
      xpEarned: xpEarned,
      tciChange: tciChange,
      dimensionChanges: dimensionChanges,
    );
    emit(UserState.loaded(updated));
  }

  void clear() => emit(const UserState.initial());
}

enum UserStatus { initial, loading, loaded, error }

class UserState extends Equatable {
  const UserState({
    this.status = UserStatus.initial,
    this.user,
    this.message,
  });

  const UserState.initial() : this(status: UserStatus.initial);
  const UserState.loaded(UserModel user)
      : this(status: UserStatus.loaded, user: user);

  final UserStatus status;
  final UserModel? user;
  final String? message;

  bool get hasUser => user != null;

  @override
  List<Object?> get props => [status, user, message];
}
