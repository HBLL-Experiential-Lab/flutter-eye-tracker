part of 'session_bloc.dart';

@immutable
abstract class SessionEvent {}

class SessionEventLoad extends SessionEvent {
  final Session session;

  SessionEventLoad(this.session);
}
