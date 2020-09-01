import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer/application/timer/timer_bloc_import.dart';
import 'package:flutter_timer/application/utils/persist_state_manager.dart';
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
        super(TimerLoad());

  Future loadTimerFromBackUp() async {
    final manager = await PersistTimerStateManager.getInstance();
    int backUpDuration = await manager.getRemainingDuration();
    if (backUpDuration == null) {
      emit(TimerInitial(_duration));
    } else {
      String timerState = await manager.getTimerState();
      switch (timerState) {
        case TimerState.INITIAL:
          emit(TimerInitial(_duration));
          break;
        case TimerState.PAUSED:
          emit(TimerRunPause(backUpDuration));
          break;
        case TimerState.RUNNING:
          start(backUpDuration);
          break;
        case TimerState.COMPLETE:
          emit(TimerRunComplete());
          break;
      }
    }
  }

  backUpRemainingDuration(int duration, String timerState) {
    PersistTimerStateManager.getInstance().then(
        (manager) => manager.setTimerStateAndDuration(duration, timerState));
  }

  start(int duration) {
    emit(TimerRunInProgress(duration));
    _tickerSubscription?.cancel();
    _tickerSubscription =
        _ticker.tick(ticks: duration).listen((duration) => tick(duration));
  }

  pause() {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      backUpRemainingDuration(state.duration, TimerState.PAUSED);
      emit(TimerRunPause(state.duration));
    }
  }

  resume() {
    if (state is TimerRunPause) {
      if (_tickerSubscription != null) {
        print('_tickerSubscription is NOT null');
        _tickerSubscription.resume();
        emit(TimerRunInProgress(state.duration));
      } else {
        print('_tickerSubscription is NULL');
        start(state.duration);
      }
    }
  }

  reset() {
    _tickerSubscription?.cancel();
    backUpRemainingDuration(_duration, TimerState.INITIAL);
    emit(TimerInitial(_duration));
  }

  tick(int duration) {
    TimerState newState;
    if (duration > 0) {
      newState = TimerRunInProgress(duration);
      backUpRemainingDuration(state.duration, TimerState.RUNNING);
    } else {
      newState = TimerRunComplete();
      backUpRemainingDuration(state.duration, TimerState.COMPLETE);
    }
    emit(newState);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}
