import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class PersistTimerStateManager {
  static Completer<PersistTimerStateManager> _completer;
  static SharedPreferences _sharedPreferences;

  static const REMAING_DURATION_KEY = 'remainingDuration';
  static const TIMER_STATE_KEY = 'timerState';
  static const LAST_TIME_KEY = 'lastTime';

  PersistTimerStateManager._();

  static Future<PersistTimerStateManager> getInstance() async {
    if (_completer == null) {
      _completer = Completer<PersistTimerStateManager>();
      try {
        _sharedPreferences = await SharedPreferences.getInstance();
        _completer.complete(PersistTimerStateManager._());
      } on Exception catch (e) {
        _completer.completeError(e);
        final Future<PersistTimerStateManager> persistStateManagerFuture =
            _completer.future;
        _completer = null;
        return persistStateManagerFuture;
      }
    }
    return _completer.future;
  }

  Future setTimerStateAndDuration(
      int remainingDuration, String timerState) async {
    await _sharedPreferences.setInt(REMAING_DURATION_KEY, remainingDuration);
    await _sharedPreferences.setString(TIMER_STATE_KEY, timerState);
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    await _sharedPreferences.setInt(LAST_TIME_KEY, currentTime);
    print('State Saved: ');
    print(
        'State Saved: Current Time($currentTime) - Duration($remainingDuration) - State($timerState)');
  }

  Future<int> getRemainingDuration() async {
    return _sharedPreferences.getInt(REMAING_DURATION_KEY);
  }

  Future<String> getTimerState() async {
    return _sharedPreferences.getString(TIMER_STATE_KEY);
  }

  Future<int> getLastTime() async {
    return _sharedPreferences.getInt(LAST_TIME_KEY);
  }
}
