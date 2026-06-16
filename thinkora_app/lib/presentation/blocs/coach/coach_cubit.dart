import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/coach_repository.dart';

class CoachMessage extends Equatable {
  const CoachMessage({
    required this.content,
    required this.isCoach,
    required this.timestamp,
    this.suggestion,
  });

  final String content;
  final bool isCoach;
  final DateTime timestamp;
  final String? suggestion;

  @override
  List<Object?> get props => [content, isCoach, timestamp, suggestion];
}

class CoachCubit extends Cubit<CoachState> {
  CoachCubit(this._repo) : super(CoachState(messages: _seed));

  final CoachRepository _repo;

  static final List<CoachMessage> _seed = [
    CoachMessage(
      content:
          'Hello! I\'m Aura, your personal AI cognitive coach. 🧠\n\nI\'ve analyzed your training data and have insights ready for you.',
      isCoach: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    CoachMessage(
      content:
          '📊 **Performance Summary**\n\n• Strongest: **Mathematics** (TCI 1650)\n• Growth area: **Creativity** (1390)\n• 7-day streak — excellent consistency!\n\nFocus on the Creativity Realm this week for a more balanced profile.',
      isCoach: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      suggestion: 'Train Creativity Realm',
    ),
  ];

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    final messages = List<CoachMessage>.from(state.messages)
      ..add(CoachMessage(
        content: text,
        isCoach: false,
        timestamp: DateTime.now(),
      ));
    emit(state.copyWith(messages: messages, isTyping: true));

    try {
      final reply = await _repo.sendMessage(text);
      final updated = List<CoachMessage>.from(state.messages)
        ..add(CoachMessage(
          content: reply,
          isCoach: true,
          timestamp: DateTime.now(),
        ));
      emit(state.copyWith(messages: updated, isTyping: false));
    } catch (e) {
      emit(state.copyWith(isTyping: false));
    }
  }
}

class CoachState extends Equatable {
  const CoachState({required this.messages, this.isTyping = false});

  final List<CoachMessage> messages;
  final bool isTyping;

  CoachState copyWith({List<CoachMessage>? messages, bool? isTyping}) {
    return CoachState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  @override
  List<Object?> get props => [messages, isTyping];
}
