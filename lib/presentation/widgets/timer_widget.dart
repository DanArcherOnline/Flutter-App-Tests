import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer/presentation/widgets/actions_widget.dart';
import '../../application/timer/timer_bloc_import.dart';

class Timer extends StatelessWidget {
  static const TextStyle timerTextStyle = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Timer App')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 100.0),
            child: Center(
              child: BlocBuilder<TimerCubit, TimerState>(
                builder: (context, state) {
                  if (state is TimerLoad) {
                    context.bloc<TimerCubit>().loadTimerFromBackUp();
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    final String minutesStr = ((state.duration / 60) % 60)
                        .floor()
                        .toString()
                        .padLeft(2, '0');
                    final String secondsStr = (state.duration % 60)
                        .floor()
                        .toString()
                        .padLeft(2, '0');
                    return Text(
                      '$minutesStr:$secondsStr',
                      style: Timer.timerTextStyle,
                    );
                  }
                },
              ),
            ),
          ),
          BlocBuilder<TimerCubit, TimerState>(
            buildWhen: (previousState, state) =>
                state.runtimeType != previousState.runtimeType,
            builder: (context, state) => ButtonActions(),
          ),
        ],
      ),
    );
  }
}
