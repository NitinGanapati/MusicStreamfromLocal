import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Playerscreen extends StatefulWidget {
  final dynamic path;

  const Playerscreen({super.key, required this.path});

  @override
  State<Playerscreen> createState() => _PlayerScreenState();
}


class _PlayerScreenState extends State<Playerscreen> {
  late AudioPlayer player = AudioPlayer();
  //
  // List<Songs> songs = [];

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();

    player.setReleaseMode(ReleaseMode.stop);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await player.setSource(DeviceFileSource(widget.path));
      await player.resume();
    });
    // WidgetsFlutterBinding.ensureInitialized();
    // _setupAudioPlayer();
    // _testSongsFromMap();
    print("Hi Widget path is ${DeviceFileSource(widget.path)}");
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
            title: Text('Player')
        ),
        body: Column(
          children: [
            Text("Hi Namaste")
          ],
        )
    );
  }
}