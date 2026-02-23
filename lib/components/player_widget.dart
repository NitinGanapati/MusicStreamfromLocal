import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';


class playerWidget extends StatefulWidget{


  final AudioPlayer player;

  final dynamic path;

  const playerWidget({
    required this.player,
    required this.path,
    super.key
});

  @override
  State<StatefulWidget> createState() => _playerWidgetState();


}

class _playerWidgetState extends State<playerWidget>{
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;

  bool get _isPaused => _playerState ==  PlayerState.paused;

  String get _durationText => _duration?.toString().split('.').first ?? '';

  String get _positionText => _position.toString().split('.').first ?? '';

  AudioPlayer get player => widget.player;

  late Uint8List? _artwork;
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //currently using the initial values
    _playerState = player.state;
    player.getDuration().then((value)=>{
      setState(() {
        _duration = value;
      })
    });
    player.getCurrentPosition().then((value)=>{
      _position = value
    });

    _initStreams();
    _loadMetadata();
  }

  @override void setState(VoidCallback fn) {
    // TODO: implement setState
    if(mounted){
      super.setState(fn);
    }

  }

  @override void dispose() {
    // TODO: implement dispose
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final color = Theme.of(context).primaryColor;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Card(
            // child: RoundedRectangleBorder(),
            // elevation: 6,
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(10),
            // ),
            child: ClipRect(
              child: Align(
                child: _artwork!=null ? Image.memory(_artwork!,width: 200,height: 200,) :
                Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.music_note, size: 70),
                ),
              ),
            ),
            

          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: _isPlaying ? _pause : null, icon: Icon(Icons.pause)),
              IconButton(onPressed: _isPlaying ? null: _play, icon: Icon(Icons.play_arrow)),
              IconButton(onPressed: _isPlaying || _isPaused ? _stop : null, icon: Icon(Icons.stop)),
            ]
          ),

          Slider(onChanged: (value){
            final duration = _duration;
            if(duration == null){
              return;
            }
            final position = value * duration.inMilliseconds;
            player.seek(Duration(milliseconds: position.round()));
          }, value: (_position != null &&
              _duration != null &&
              _position!.inMilliseconds > 0 &&
              _position!.inMilliseconds < _duration!.inMilliseconds)
              ? _position!.inMilliseconds / _duration!.inMilliseconds
              : 0.0,
          ),
          Text(
            _position != null ? '$_positionText/$_durationText'
                : _duration != null
                ? _durationText : '',
            style: const TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
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


  }

  Future<void> _play() async{
    await player.resume();
    setState(() {
      _playerState = PlayerState.playing;
    });
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

  Future<void> _loadMetadata() async {
    try{
      final metadata = readMetadata(File(widget.path));
      print("File path: ${widget.path}");
      print("Pictures count: ${metadata.pictures.length}");
      setState((){
        _artwork = metadata.pictures.isNotEmpty ? metadata.pictures.first.bytes : null;
      });
      
    }
    catch(e){
      print('Metadata Error : ${e}');

      
    }
  

  }

}