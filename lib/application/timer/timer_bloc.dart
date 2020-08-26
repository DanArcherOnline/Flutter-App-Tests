import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_timer/domain/ticker.dart';
import 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  final Ticker _ticker;
  static const int _duration = 60;
  StreamSubscription<int> _tickerSubscription;

  TimerCubit({
    @required Ticker ticker,
  })  : assert(ticker != null),
        _ticker = ticker,
        super(TimerInitial(_duration));

  start(int duration) {
    emit(TimerRunInProgress(duration));
    _tickerSubscription?.cancel();
    _tickerSubscription =
        _ticker.tick(ticks: duration).listen((duration) => tick(duration));
  }

  pause() {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      emit(TimerRunPause(state.duration));
    }
  }

  resume() {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgress(state.duration));
    }
  }

  reset() {
    _tickerSubscription?.cancel();
    emit(TimerInitial(_duration));
  }

  tick(int duration) {
    TimerState newState =
        duration > 0 ? TimerRunInProgress(duration) : TimerRunComplete();
    emit(newState);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}
