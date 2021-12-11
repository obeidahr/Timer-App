import 'package:blocpattern_timer_app/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'ticker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(109, 234, 255,1),
        accentColor: Color.fromRGBO(72, 74, 126, 1),
        brightness: Brightness.dark,
      ),
      home: BlocProvider(
        create:(context) => TimerBloc(ticker: Ticker()),
        child: Home(),
      ),
    );
  }
}

class Home extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('flutter Timer App'),
      ),
      body: Stack(
        children: [
            Background(), 
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:EdgeInsets.symmetric(vertical: 100),
                  child: Center(
                    child: BlocBuilder<TimerBloc,TimerState>(
                      builder: (context,state){
                        final String minutesSection = ((state.duration / 60) % 60).floor().toString().padLeft(2,'0');
                        final String secondsSection = (state.duration % 60).floor().toString().padLeft(2,'0');
                        return Text('$minutesSection:$secondsSection',style: TextStyle(fontSize: 60,fontWeight: FontWeight.bold),);
                      },
                    ),
                  ), 
                ),
                BlocBuilder<TimerBloc,TimerState>(
                  buildWhen: (previousState,currentState) => currentState.runtimeType != previousState.runtimeType,
                  builder: (context,state) => Actions(),
                ),
              ],
            )
        ],
      ),
    );
  }
}
class Background extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return WaveWidget(
            config: CustomConfig(
              gradients:[
                [
                  Color.fromRGBO(72, 74, 12, 1),
                  Color.fromRGBO(125, 170, 206, 1),
                  Color.fromRGBO(184, 189, 245, 0.7)
                ],
                [
                  Color.fromRGBO(72, 74, 12, 1),
                  Color.fromRGBO(125, 170, 206, 1),
                  Color.fromRGBO(172, 185, 215, 0.7)
                ],
                [
                  Color.fromRGBO(72, 74, 126, 1),
                  Color.fromRGBO(129, 200, 306, 1),
                  Color.fromRGBO(120, 89, 145, 0.7)
                ]
              ],
              durations: [19440,10000,6000],
              heightPercentages: [0.3,0.01,0.02],
              gradientBegin: Alignment.bottomCenter,
              gradientEnd: Alignment.topCenter
            ),
            size: Size(double.infinity, double.infinity),
            backgroundColor: Colors.blue[50],
            );
  }
}
class Actions extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _mapStateToActionButtons(
        timerBloc:BlocProvider.of<TimerBloc>(context) 
      ),
    );
  }
  List<Widget> _mapStateToActionButtons({TimerBloc timerBloc}){
    final TimerState currentState = timerBloc.state;
    if(currentState is Ready){
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed:(){
            timerBloc.add(Start(duration: currentState.duration));
           },
          )
      ];
    }
    if(currentState is Running){
      return [
        FloatingActionButton(
          child: Icon(Icons.pause),
          onPressed:() => timerBloc.add(Pause()),
        ),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(Reset()),
        )
      ];
    }
    if(currentState is Paused){
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed:() => timerBloc.add(Resume())
        ),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed:() =>timerBloc.add(Reset()) 
        ),
      ];
    }
    if(currentState is Finished){
      return [
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed:()=>timerBloc.add(Reset()) 
        ),
      ];
    }

    return [];

  }
}