import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:musics/models/Songs.dart';
// import 'package:on_audio_query/on_audio_query.dart';


class playerWidget extends StatefulWidget{


  final AudioPlayer player;

  // final dynamic path;

  late int currentIndex;
  List<Map<String,dynamic>> songs;

  playerWidget({
    required this.currentIndex,
    required this.player,
    // required this.path,
    required this.songs,
    super.key
});

  @override
  State<StatefulWidget> createState() => _playerWidgetState();


}

class _playerWidgetState extends State<playerWidget>{
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  double _volume = 1;
  double _rate = 1.0;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;


  // late int currentIndex;

  bool get _isPlaying => _playerState == PlayerState.playing;

  bool get _isPaused => _playerState ==  PlayerState.paused;

  String get _durationText => _duration?.toString().split('.').first ?? '';

  String get _positionText => _position.toString().split('.').first ?? '';



  // final _audioQuery = OnAudioQuery();

  // late SongModel _songsModel;
  //
  AudioPlayer get player => widget.player;

Uint8List? _artwork;
  //
  // get currentIndex => currentIndex;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //currently using the initial values
    //
    var currentIndex = widget.currentIndex;

    _playerState = player.state;

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
    _loadMetadata(widget.songs[currentIndex]["path"]);
    // _loadArtworkFromQuery();
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
    int currentIndex = widget.currentIndex;
    final color = Theme.of(context).primaryColor;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 10),
              Text(
                widget.songs[currentIndex]["title"] ?? "Unknown",
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            // child: Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            //     child: Text(widget.songs[currentIndex]["title"] ?? "Unknown",textAlign: TextAlign.center,),
            // ),
          const SizedBox(height: 50),
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
              IconButton(onPressed: _onPreviousSong, icon: Icon(Icons.skip_previous)),
              IconButton(onPressed: _isPlaying ? null: _play, icon: Icon(Icons.play_arrow)),
              IconButton(onPressed: _isPlaying ? _pause : null, icon: Icon(Icons.pause)),
              IconButton(onPressed: _isPlaying || _isPaused ? _stop : null, icon: Icon(Icons.stop)),
              IconButton(onPressed: _onNextSong, icon: Icon(Icons.next_plan))
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

          const Text(
            "Volume",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Slider(value: _volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label : (_volume*100).round().toString(),
              onChanged: (value)async{
            setState((){
              _volume = value;
            });
            await player.setVolume(_volume);
          }),
          const Text(
            "Speed",
            style:TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Slider(
            value: _rate,
            min: 0.0,
            max: 2.0,
            divisions: 4,
            label: "${_rate.toStringAsFixed(1)}",
            onChanged: (value) async{

              setState((){
                _rate = value;
              });

            await player.setPlaybackRate(_rate);
          },
          )
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

    _playerCompleteSubscription = player.onPlayerComplete.listen((event){
        _onNextSong();
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
  Future<void> _loadMetadata(String path) async {
    try{
      final metadata = readMetadata(File(widget.songs[widget.currentIndex]["path"]),getImage:true);
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


   Future<void> playCurrentSong() async{
    final song = widget.songs[widget.currentIndex];
    await player.stop();

    await player.setSource(DeviceFileSource(song["path"]));

    await player.resume();


    await _loadMetadata(song["path"]);

    setState((){

    });
 }
 Future<void> _onNextSong()async {
    if(widget.currentIndex < widget.songs.length -1){
      setState((){
        widget.currentIndex++;
      });
      await playCurrentSong();
    }
    else{
      return;
    }
 }

 Future<void> _onPreviousSong() async{
   if(widget.currentIndex > 0){
     setState((){
       widget.currentIndex--;
     });
     await playCurrentSong();
   }
   else{
     return;
   }
 }

 Future<void> deleteMusicFile(String filePath) async{
    // if(await request)
    //

 }
 //
 //
 //  // Future<void> _loadArtworkFromQuery() async{
 //  //   try{
 //  //     bool permission = await _audioQuery.permissionsRequest();
 //  //     if(!permission){
 //  //       print("Audio permission denied!");
 //  //       return;
 //  //     }
 //  //
 //  //     List<SongModel> songs = await _audioQuery.querySongs();
 //  //
 //  //     _songsModel = songs.firstWhere(
 //  //         (s) => s.data == widget.path,
 //  //       orElse: () => songs.first
 //  //     );
 //  //     setState((){});
 //  //   }
 //  //   catch(e){
 //  //       print("on_audio_query error : $e");
 //  //   }
 //  // }

}