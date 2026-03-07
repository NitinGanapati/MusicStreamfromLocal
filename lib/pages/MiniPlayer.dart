import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'PlayerScreen.dart';
import 'PlayerScreen.dart' as Player;

class Miniplayer extends StatefulWidget{

  final String title;

  final Function(int) onSongChanged;

  // final AudioPlayer player;

   final int currentIndex;
  final AudioPlayer player;
  final List<Map<String, dynamic>> songs;
  const Miniplayer({super.key,required this.title,required this.songs,required this.currentIndex,required this.player,required this.onSongChanged});

  // AudioPlayer get player => null;

  @override
  State<Miniplayer> createState() => _MiniPlayerState();

}
class _MiniPlayerState extends State<Miniplayer> {
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;
  AudioPlayer get player => widget.player;
  late int currentIndex;

  @override
  void didUpdateWidget(covariant Miniplayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() {
        currentIndex = widget.currentIndex;
      });
    }
  }


  double _volume = 1;
  double _rate = 1.0;

  Uint8List? _artwork;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;




  // late int currentIndex;

  bool changeable = false;

  bool get _isPlaying => _playerState == PlayerState.playing;

  bool get _isPaused => _playerState ==  PlayerState.paused;

  String get _durationText => _duration?.toString().split('.').first ?? '';

  String get _positionText => _position.toString().split('.').first ?? '';

@override
  void initState() {
    // TODO: implement initState
  _playerState = player.state;
  currentIndex = widget.currentIndex;

  player.getDuration().then((value)=>{
    setState(() {
      _duration = value;
    })
  });
  player.getCurrentPosition().then((value)=>{
    _position = value
  });

  player.onPlayerComplete.listen((event){
    _onNextSong();
  });
  _initStreams();


  super.initState();
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // // TODO: implement
    return Container(
      color: Colors.pinkAccent,
      child:ListTile(

              // title: changeable ?  Text(widget.songs[currentIndex]["title"],style: TextStyle(color: Colors.black45),) :Text(
              // widget.title,style: TextStyle(color: Colors.black45), ),
        // title: Text(
        //   widget.songs[currentIndex]["title"] ?? "Unknown",
        //   style: TextStyle(color: Colors.black45),
        // ),
        title: Text(
            widget.songs[currentIndex]["title"] ?? "Unknown",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black45),
        ),
        trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(onPressed: _isPlaying || _isPaused ? _stop : null, icon: Icon(Icons.stop)),
                  IconButton(onPressed: _onPreviousSong, icon: Icon(Icons.skip_previous)),
                  IconButton(onPressed: _isPlaying ? _pause: _play, icon: _isPaused ? Icon(Icons.play_arrow) : Icon(Icons.pause)),
                  // IconButton(onPressed: _isPlaying ? _pause : null, icon: Icon(Icons.pause)),
                  //
                  IconButton(onPressed: _onNextSong, icon: Icon(Icons.next_plan))

                ],
              ),
         onTap: (){
           Navigator.push(context, MaterialPageRoute(builder: (context) => Player.Playerscreen(
               songs: widget.songs, currentIndex: currentIndex, player: widget.player
           )));
         },

              // Icon(Icons.music_note, color: Colors.black45),
              //
              // SizedBox(width: 10),

              // Expanded(
              //   child: Text(
              //     widget.title,
              //     style: TextStyle(color: Colors.black45),
              //     overflow: TextOverflow.ellipsis,
              //   ),
              // ),

              // IconButton(
              //   icon: Icon(Icons.pause, color: Colors.black45),
              //   onPressed: () async{
              //     // Navigator.push(context,MaterialPageRoute(builder: (context)=> Playerscreen(songs: widget.songs, currentIndex: widget.currentIndex,player: widget.player,)));
              //     await player.pause();
              //   },
              // ),
              // IconButton(onPressed: _isPlaying || _isPaused ? _stop : null, icon: Icon(Icons.stop)),
              // IconButton(onPressed: _onPreviousSong, icon: Icon(Icons.skip_previous)),
              // IconButton(onPressed: _isPlaying ? _pause: _play, icon: _isPaused ? Icon(Icons.play_arrow) : Icon(Icons.pause)),
              // // IconButton(onPressed: _isPlaying ? _pause : null, icon: Icon(Icons.pause)),
              // //
              // IconButton(onPressed: _onNextSong, icon: Icon(Icons.next_plan))
              //

      )

    );
    return Row(

    );
    // throw UnimplementedError();

  }
  void _initStreams() {
    _durationSubscription = player.onDurationChanged.listen((duration){
      setState(() {
        _duration = duration;
      });
    });

    _positionSubscription = player.onPositionChanged.listen((p){
      setState(() {
        _position = p;
      });
    });

    _playerStateChangeSubscription = player.onPlayerStateChanged.listen((event){
      setState(() {
        _playerState= event;
      });
    });

    _playerCompleteSubscription = player.onPlayerComplete.listen((event){
      _onNextSong();
    });


  }

  Future<void> _loadMetadata(String path) async {
    try{

      final metadata = readMetadata(File(widget.songs[currentIndex]["path"]),getImage:true);
      print("File path: ${File(path)}");
      print("Pictures count: ${metadata.pictures.length}");
      setState((){
        _artwork = metadata.pictures.isNotEmpty ? metadata.pictures.first.bytes : null;
      });

    }
    catch(e){
      print('Metadata Error : ${e}');
    }
  }

  Future<void> _play() async{

    await player.resume();
    setState(() {
      _playerState = PlayerState.playing;
    });

    // if(_isPlaying){
    //   await player.stop();
    //   setState((){
    //     _playerState = PlayerState.stopped;
    //   });
    // }
  }
  Future<void> _pause() async{
    await player.pause();
    setState(() {
      _playerState = PlayerState.paused;
    });
  }
  Future<void> _stop() async{
    await player.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }

  Future<void> playCurrentSong() async{
    final song = widget.songs[currentIndex];
    await player.stop();

    await player.setSource(DeviceFileSource(song["path"]));

    await player.resume();


    await _loadMetadata(song["path"]);

    setState((){

    });
  }
  Future<void> _onNextSong()async {
    changeable = true;

    if(currentIndex < widget.songs.length -1){
      setState((){
        widget.onSongChanged(currentIndex++);
      });
      await playCurrentSong();
    }
    else{
      return;
    }
  }

  Future<void> _onPreviousSong() async{
    changeable = true;
    if(currentIndex > 0){
      setState((){
        widget.onSongChanged(currentIndex--);
      });
      await playCurrentSong();
    }
    else{
      return;
    }
  }


}