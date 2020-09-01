import 'package:equatable/equatable.dart';

abstract class TimerState extends Equatable {
  static const INITIAL = 'initial';
  static const PAUSED = 'paused';
  static const RUNNING = 'running';
  static const COMPLETE = 'complete';

  final int duration;

  const TimerState(this.duration);

  @override
  List<Object> get props => [duration];
}

class TimerInitial extends TimerState {
  const TimerInitial(int duration) : super(duration);

  @override
  String toString() => 'TimerInitial { duration: $duration }';
}

class TimerLoad extends TimerState {
  const TimerLoad() : super(60);

  @override
  String toString() => 'TimerRunPause { duration: $duration }';
}

class TimerRunPause extends TimerState {
  const TimerRunPause(int duration) : super(duration);

  @override
  String toString() => 'TimerRunPause { duration: $duration }';
}

class TimerRunInProgress extends TimerState {
  const TimerRunInProgress(int duration) : super(duration);

  @override
  String toString() => 'TimerRunInProgress { duration: $duration }';
}

class TimerRunComplete extends TimerState {
  const TimerRunComplete() : super(0);
}
