import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:musics/components/player_widget.dart';

class Playerscreen extends StatefulWidget {
  List<Map<String,dynamic>> songs = [];
  late int currentIndex;

  Playerscreen({super.key, required this.songs, required this.currentIndex});

  @override
  State<Playerscreen> createState() => _PlayerScreenState();
}


class _PlayerScreenState extends State<Playerscreen> {
  // late int currentIndex;
  late AudioPlayer player = AudioPlayer();
  //
  // List<Songs> songs = [];

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();

    player.setReleaseMode(ReleaseMode.stop);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await player.setSource(DeviceFileSource(widget.songs[widget.currentIndex]["path"]));
      await player.resume();
    });
    // WidgetsFlutterBinding.ensureInitialized();
    // _setupAudioPlayer();
    // _testSongsFromMap();
    print("Hi Widget path is ${DeviceFileSource(widget.songs[widget.currentIndex]["path"])}");
  }

  @override
  void dispose(){
    player.dispose();

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
            title: Text('Nitin Player Window')
        ),
        body: playerWidget(player: player,songs:widget.songs,currentIndex: widget.currentIndex,)

    );
  }
}