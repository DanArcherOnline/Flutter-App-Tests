import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/timer/timer_bloc_import.dart';

class ButtonActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _mapStateToActionButtons(
        timerCubit: BlocProvider.of<TimerCubit>(context),
      ),
    );
  }

  List<Widget> _mapStateToActionButtons({
    TimerCubit timerCubit,
  }) {
    final TimerState currentState = timerCubit.state;
    if (currentState is TimerInitial) {
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () => timerCubit.start(currentState.duration),
        ),
      ];
    }
    if (currentState is TimerRunInProgress) {
      return [
        FloatingActionButton(
          child: Icon(Icons.pause),
          onPressed: () => timerCubit.pause(),
        ),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerCubit.reset(),
        ),
      ];
    }
    if (currentState is TimerRunPause) {
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () => timerCubit.resume(),
        ),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerCubit.reset(),
        ),
      ];
    }
    if (currentState is TimerRunComplete) {
      return [
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerCubit.reset(),
        ),
      ];
    }
    return [];
  }
}
