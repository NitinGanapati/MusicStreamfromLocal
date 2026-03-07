import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:musics/components/playlistsong_widget.dart';

class Playlistsongscreen extends StatefulWidget{

  final Function(int) onSongChanged;

  String playListName;
  late int currentIndex;

  List<Map<String,dynamic>> songs = [];

  Playlistsongscreen({super.key, required this.songs, required this.currentIndex, required this.playListName, required this.onSongChanged});

  @override
  State<Playlistsongscreen> createState() => _PlaylistSongscreen();

}

class _PlaylistSongscreen extends State<Playlistsongscreen> {

  late AudioPlayer player = AudioPlayer();

  late int currentIndex;


  @override
  void didUpdateWidget(covariant Playlistsongscreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() {
        currentIndex = widget.currentIndex;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    player = AudioPlayer();

    currentIndex = widget.currentIndex;

    player.setReleaseMode(ReleaseMode.stop);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await player.setSource(DeviceFileSource(widget.songs[widget.currentIndex]["path"]));
      await player.resume();
    });
    // WidgetsFlutterBinding.ensureInitialized();
    // _setupAudioPlayer();
    // _testSongsFromMap();
    print("Hi Widget path nitin is ${DeviceFileSource(widget.songs[widget.currentIndex]["path"])}");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text("Nitin"),
          automaticallyImplyLeading:false,
          leading: IconButton(onPressed: (){
            if(Navigator.canPop(context)){
              // Navigator.pop(context, widget.songs[widget.currentIndex]);
              Navigator.pop(context, {
                "title": widget.songs[currentIndex]["title"],
                "currentIndex": currentIndex,
                "player":player
              });
            }
          }, icon: Icon(Icons.keyboard_arrow_down))),
        body: PlaylistsongWidget(currentIndex: widget.currentIndex, player: player, playListName: widget.playListName, songs: widget.songs,onSongChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        }),
      );
  }

}