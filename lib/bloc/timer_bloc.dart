import 'dart:async';
import 'package:blocpattern_timer_app/bloc/timer_event.dart';
import 'package:blocpattern_timer_app/bloc/timer_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../ticker.dart';
import 'timer_event.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final int _duration = 60;
  final Ticker _ticker;
  StreamSubscription<int> _tickSubscription;
  TimerBloc({@required Ticker ticker})
      : _ticker = ticker,
        super(null);

  TimerState get initialState => Ready(_duration);

  @override
  Stream<TimerState> mapEventToState(TimerEvent event) async* {
    if (event is Start) {
      Start start = event;
      yield Running(start.duration);
      _tickSubscription?.cancel();
      _tickSubscription =
          _ticker.tick(ticks: start.duration).listen((duration) {
        add(Tick(duration: duration));
      });
    } else if (event is Pause) {
      if (state is Running) {
        _tickSubscription.pause();
        yield Paused(state.duration);
      }
    } else if (event is Resume) {
      if (state is Paused) {
        _tickSubscription?.resume();
        yield Running(state.duration);
      }
    } else if (event is Reset) {
      _tickSubscription?.cancel();
      yield Ready(_duration);
    } else if (event is Tick) {
      Tick tick = event;
      yield tick.duration > 0 ? Running(_duration) : Finished();
    }
  }

  @override
  Future<void> close() {
    _tickSubscription?.cancel();
    return super.close();
  }
}
