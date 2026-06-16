import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/leaderboard_model.dart';
import '../../../data/repositories/leaderboard_repository.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit(this._repo) : super(const LeaderboardState());

  final LeaderboardRepository _repo;

  Future<void> load(String scope) async {
    emit(state.copyWith(status: LbStatus.loading, scope: scope));
    try {
      final data = await _repo.fetch(scope: scope);
      emit(state.copyWith(status: LbStatus.loaded, data: data, scope: scope));
    } catch (e) {
      emit(state.copyWith(status: LbStatus.error, message: e.toString()));
    }
  }
}

enum LbStatus { initial, loading, loaded, error }

class LeaderboardState extends Equatable {
  const LeaderboardState({
    this.status = LbStatus.initial,
    this.data,
    this.scope = 'global',
    this.message,
  });

  final LbStatus status;
  final LeaderboardData? data;
  final String scope;
  final String? message;

  LeaderboardState copyWith({
    LbStatus? status,
    LeaderboardData? data,
    String? scope,
    String? message,
  }) {
    return LeaderboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      scope: scope ?? this.scope,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, data, scope, message];
}
