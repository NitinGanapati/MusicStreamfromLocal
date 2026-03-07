import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:musics/components/player_widget.dart';

class Playerscreen extends StatefulWidget {
  List<Map<String,dynamic>> songs = [];
  late int currentIndex;
  final AudioPlayer player;

  Playerscreen({super.key, required this.songs, required this.currentIndex, required this.player});

  @override
  State<Playerscreen> createState() => _PlayerScreenState();
}


class _PlayerScreenState extends State<Playerscreen> {
  // late int currentIndex;
  late AudioPlayer player;
  //
  // List<Songs> songs = [];
  late int currentIndex;


  @override
  void didUpdateWidget(covariant Playerscreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() {
        currentIndex = widget.currentIndex;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    player = widget.player;

    player.setReleaseMode(ReleaseMode.stop);

    currentIndex = widget.currentIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await player.setSource(DeviceFileSource(widget.songs[currentIndex]["path"]));
      await player.resume();
    });
    // WidgetsFlutterBinding.ensureInitialized();
    // _setupAudioPlayer();
    // _testSongsFromMap();
    print("Hi Widget path is ${DeviceFileSource(widget.songs[currentIndex]["path"])}");
  }

  @override
  void dispose(){
    // player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme
                .of(context)
                .colorScheme
                .inversePrimary,
            title: Text('Nitin Player Window'),
            automaticallyImplyLeading:false,
            leading: IconButton(onPressed: (){
              if(Navigator.canPop(context)){
                // Navigator.pop(context, widget.songs[widget.currentIndex]);
                Navigator.pop(context, {
                  "title": widget.songs[currentIndex]["title"],
                  "currentIndex": currentIndex,
                  "player":widget.player
                });
              }
            }, icon: Icon(Icons.keyboard_arrow_down),

        )),
        body: playerWidget(player: player,songs:widget.songs,currentIndex: currentIndex, onSongChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },)

    );
  }
}