import 'dart:async';

import 'package:flutter/material.dart';
import 'music.dart';
//import 'package:audioplayer/audioplayer.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "Flow2Dot0 Music Player",
      theme: ThemeData(
        primarySwatch: Colors.blueGrey
      ),
      debugShowCheckedModeBanner: false,
      home: Player(),
    );
  }

}

class Player extends StatefulWidget {

  Player({Key key, this.title}) : super(key : key);

  final String title;

  @override
  _Player createState() => _Player();

}

class _Player extends State<Player> {

  List<Music> musicList = [
    Music('Hell and back', 'Kid Ink', 'images/hb.jpg', 'https://codabee.com/wp-content/uploads/2018/06/un.mp3'),
    Music('Time of your life', 'Kid Ink', 'images/tl.jpg', 'https://codabee.com/wp-content/uploads/2018/06/deux.mp3')
  ];

  AudioPlayer audioPlayer;
  StreamSubscription positionSub;
  StreamSubscription stateSubscription;
  StreamSubscription durationSub;
  Music actualMusic;
  Duration position = Duration(seconds: 0);
  Duration durationTmp = Duration(seconds: 10);
  PlayerState status = PlayerState.stopped;
  int index = 0;
  String localFilePath = "musics/un.mp3";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    actualMusic = musicList[index];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double widthDevice = MediaQuery.of(context).size.width;
    double heightDevice = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player Demo Flow2dot0',
          style: TextStyle(
            fontSize: 18.00,
            letterSpacing: 5,
          ),
        ),
        elevation: 10.0,
        centerTitle: true,
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Container(
          height: heightDevice,
          width: widthDevice,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Card(
                elevation: 9.0,
                child: Container(
                  child: Image.asset(actualMusic.imagePath,
                    height: heightDevice / 2.5,
                  ),
                ),
              ),
              textStyle(actualMusic.title, 1.5),
              textStyle(actualMusic.artist, 1.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  button(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                  button((status == PlayerState.playing) ? Icons.pause : Icons.play_arrow, 45.0, (status == PlayerState.playing) ? ActionMusic.pause : ActionMusic.play),
                  button(Icons.fast_forward, 30.0, ActionMusic.forward)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  textStyle(fromDuration(position), 0.8),
                  textStyle(fromDuration(durationTmp), 0.8),
                ],
              ),
              Slider(
                  value: position.inSeconds.toDouble(),
                  min: 0.0,
                  max: 30.0,
                  inactiveColor: Colors.white,
                  activeColor: Colors.red,
                  onChanged: (double d) {
                    setState(() {
                      Duration newDuration = Duration(seconds: d.toInt());
                      position = newDuration;
                    });
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Text textStyle(String data, double scale) {
    return Text(
        data,
        textScaleFactor: scale,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontStyle: FontStyle.italic,
        ),
    );
  }

  IconButton button(IconData icon, double size, ActionMusic action) {
    return
      IconButton(
        iconSize: size,
        color: Colors.white,
        icon: Icon(icon),
        onPressed: () {
          switch(action) {
            case ActionMusic.play:
              play();
              break;
            case ActionMusic.pause:
              pause();
              break;
            case ActionMusic.forward:
              forward();
              break;
            case ActionMusic.rewind:
              rewind();
              break;
          }
        }
    );
  }

  void configurationAudioPlayer() {
    audioPlayer = AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen(
        (pos) => setState(() => position = pos)
    );
    durationSub = audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        durationTmp = d;
      });
    });
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {
          status = PlayerState.playing;
        });
      }
      else if (state == AudioPlayerState.STOPPED) {
        setState(() {
          status = PlayerState.stopped;
        });
      }
      else if (state == AudioPlayerState.PAUSED) {
        setState(() {
          status = PlayerState.paused;
        });
      }
    }, onError: (message) {
      print('Erreur: $message');
      setState(() {
        status = PlayerState.stopped;
        durationTmp = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    }
    );
  }

  playBis() async {

  }

  Future play() async {
    await audioPlayer.play(actualMusic.urlSong);
    setState(() => status = PlayerState.playing);
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => status = PlayerState.paused);
  }

  void forward() async {
    if (index == musicList.length - 1) {
      index = 0;
    } else {
      index++;
    }
    actualMusic = musicList[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }

  void rewind() {
    if (position > Duration(seconds: 3)) {
      audioPlayer.seek(Duration(seconds: 0));
    } else {
      if (index == 0) {
        index = musicList.length - 1;
      }
      else {
        index--;
      }
      actualMusic = musicList[index];
      audioPlayer.stop();
      configurationAudioPlayer();
      play();
    }
  }

  String fromDuration(Duration duree) {
    print(duree);
    return duree.toString().split('.').first;
  }
}


enum ActionMusic {
  play,
  pause,
  rewind,
  forward,
}

enum PlayerState {
  playing,
  stopped,
  paused
}


//# Setting PATH for Python 3.7
//# The original version is saved in .bash_profile.pysave
//PATH="/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"
//export PATH
//export PATH="$PATH:`pwd`/flutter/bin"
//export PATH=/Users/flow2dot0-osx/flutter:$PATH
//export PATH=/Users/flow2dot0-osx/flutter/.pub-cache/bin:$PATH