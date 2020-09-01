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

  calculateCurrentDuration(int lastTime, int lastDuration) {
    print('calculateCurrentDuration==START=====================');
    print('lastTime = $lastTime : lastDuration = $lastDuration');
    final lastTimeDateTime = DateTime.fromMillisecondsSinceEpoch(lastTime);
    final currentTimeDateTime = DateTime.now();
    print(
        'lastTimeDateTime = $lastTimeDateTime : currentTimeDateTime = $currentTimeDateTime');
    final timeDifference = lastTimeDateTime.difference(currentTimeDateTime);
    print('timeDifference = $timeDifference');
    final timeDifferenceSecs = timeDifference.inSeconds;
    print('timeDifferenceSecs = $timeDifferenceSecs');
    final lastDurationSecs = Duration(seconds: lastDuration).inSeconds;
    print('lastDurationSecs = $lastDurationSecs');
    final currentDuration = lastDurationSecs + timeDifferenceSecs;
    print('currentDuration = $currentDuration');
    print('calculateCurrentDuration==END=====================');
    return currentDuration;
  }

  Future loadTimerFromBackUp() async {
    final manager = await PersistTimerStateManager.getInstance();
    String timerState = await manager.getTimerState();
    if (timerState == null) {
      emit(TimerInitial(_duration));
    } else {
      int backUpDuration = await manager.getRemainingDuration();
      int lastTime = await manager.getLastTime();
      if (timerState != null && lastTime != null) {
        int newBackUpDuration = timerState != TimerState.PAUSED
            ? calculateCurrentDuration(lastTime, backUpDuration)
            : backUpDuration;
        if (newBackUpDuration < 0) {
          emit(TimerRunComplete());
        } else {
          switch (timerState) {
            case TimerState.INITIAL:
              emit(TimerInitial(_duration));
              break;
            case TimerState.PAUSED:
              emit(TimerRunPause(newBackUpDuration));
              break;
            case TimerState.RUNNING:
              start(newBackUpDuration);
              break;
            case TimerState.COMPLETE:
              emit(TimerRunComplete());
              break;
          }
        }
      } else {
        print('Error: timerState & lastTime were null, '
            'but backUpDuration was not null. ');
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
