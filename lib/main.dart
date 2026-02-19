import 'dart:async';
// import 'package:on_audio_query/on_audio_query.dart';

import 'package:musics/pages/Favourites.dart';

import 'pages/Playlist.dart' as PlayList;
import 'models/Songs.dart';
// import 'services/audio_query_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'db_handler.dart' as db;

import 'package:audioplayers/audioplayers.dart';

import 'package:permission_handler/permission_handler.dart';
import 'services/storage_scan_services.dart' as Musics;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      // home: const PlayList.Playlist(),
    );
  }
}

class MyHomePage extends StatefulWidget {
   MyHomePage({super.key, required this.title, this.dbHelper});
  final db.DBHelper? dbHelper;

  final String title;




  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // late final _player = AudioPlayer();
  // final AudioQueryService _audioService = AudioQueryService();
  late Future<List<Songs>> songsList;
  final AudioPlayer _handlers = AudioPlayer();
  List<Map<String,dynamic>> songs = [];
  @override
  void initState() {
    super.initState();
    // WidgetsFlutterBinding.ensureInitialized();
    // _setupAudioPlayer();
    // _testSongsFromMap();
    init();
    loadData();
    // fetchSongs();
    print("initState called");
  }

 Future<void> init() async{
    bool isPermitted = await requestPermission();
    if(isPermitted){
      await loadMusic();
    }
 }
  Future<void> loadMusic() async{
     songs = await Musics.storageScanService().getSongDetails();
    setState(() {

    });
  }
  void loadData()async{
      songsList = db.DBHelper().getMusicsList();
  }
  // void _testSongsFromMap() {
  //   final testMap = {
  //     'id': 1,
  //     'title': 'Believer',
  //     'filePath': '/storage/music/believer.mp3',
  //     'artistName': 'Imagine Dragons',
  //     'albumTitle': 'Evolve',
  //     'genre': 'Rock',
  //   };
  //
  //   final song = Songs.fromMap(testMap);
  //
  //   print("----- Songs.fromMap Test -----");
  //   print("Title: ${song.title}");
  //   print("Path: ${song.data}");
  //   print("Artist: ${song.artist}");
  //   print("Album: ${song.album}");
  //   print("Genre: ${song.genre}");
  // }



  @override
  Widget build(BuildContext context) {
    print("build called");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Nitin Music Player'),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => Favourites()));

          }, icon: const Icon(Icons.favorite),tooltip: 'favourites',)
        ],
      ),
      body:
        songs.isEmpty ? Center(child: Text("Scanning your Songs"),)
            : ListView.builder(itemCount: songs.length,
        itemBuilder: (BuildContext context,int index){
              var singlesong = songs[index];
              print(singlesong);
              return
                  ListTile(
                    leading: Icon(Icons.music_note),
                    title: Text(singlesong["title"] ?? "Unknown"),
                    subtitle: Text(singlesong["artistName"] ?? "Unknown"),
                    trailing: ElevatedButton(onPressed: (){

                      Songs song = Songs(
                        title : singlesong["title"],
                        path: singlesong["path"],
                        artistName: singlesong["artistName"],
                        albumName: singlesong["albumName"]
                      );
                      db.DBHelper().insert(song).then( (value) {print("Songs inserted successfully");});
                    }, child: Icon(Icons.add)),
                    onTap: ()=>{
                      playButton(singlesong["path"]!)
                    },
                  );
        })
      // SafeArea(
      //     child: Center(
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         mainAxisSize: MainAxisSize.max,
      //         children: [
      //           Row(
      //             children: [
      //               Expanded(flex:5,child: IconButton(onPressed: _player.hasNext?_player.seekToNext:null, icon: Icon(Icons.skip_previous))),
      //               Expanded(flex:5,child: _playbackControllerButton()),
      //               Expanded(flex:5,child: IconButton(onPressed: _player.hasNext?_player.seekToNext:null, icon: Icon(Icons.skip_next))),
      //             ],
      //           ),
      //           _progressBar(),
      //           Row(
      //             children: [
      //               Expanded(child: _controlButtons()),
      //               Expanded(child: _volumeButtons())
      //             ],
      //           )
      //         ],
      //       ),
      //     )
      //
      //
      //
      // )
    );
  }
  //
  // Future<void> _setupAudioPlayer() async {
  //   _player.playbackEventStream.listen((event) {},
  //       onError: (Object e, StackTrace stacktrace) {
  //         print("A stream error occured:$e");
  //       });
  //   try {
  //     await _player.setAudioSource(AudioSource.uri(Uri.parse(
  //         "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3")));
  //     // await AudioPlayer.clearAssetCache();
  //     // await _player.setAsset('assets/song4.mp3');
  //   } catch (e) {
  //     print("Error");
  //   }
  // }
  //
  //   Widget _playbackControllerButton(){
  //     return StreamBuilder<PlayerState>(stream: _player.playerStateStream, builder: (context,snapshot){
  //       final playerState = snapshot.data;
  //       final processingState = snapshot.data?.processingState;
  //       final playing = snapshot.data?.playing;
  //       if(processingState == ProcessingState.loading || processingState == ProcessingState.buffering){
  //         return Container(
  //           margin: const EdgeInsets.all(8.0),
  //           width: 64,
  //           height: 64,
  //           child: const CircularProgressIndicator(),
  //         );
  //       }
  //       else if(playing!=true){
  //         return IconButton(onPressed: _player.play,
  //         icon: const Icon(Icons.play_arrow),iconSize: 60,);
  //       }
  //       else if(processingState!=ProcessingState.completed){
  //            return IconButton(onPressed: _player.pause,
  //                icon: const Icon(Icons.pause),iconSize: 60,);
  //       }
  //       else {
  //           return IconButton(onPressed: ()=> _player.seek(Duration.zero), icon: const Icon(Icons.replay),iconSize: 62,);
  //       }
  //       return const SizedBox();
  //     });
  //   }
  //
  //   Widget _progressBar(){
  //       return StreamBuilder<Duration>(stream: _player.positionStream, builder: (context,snapshot){
  //         return ProgressBar(progress: snapshot.data ?? Duration.zero,
  //             total: _player.duration ?? Duration.zero,
  //             buffered:_player.bufferedPosition,
  //             onSeek: (duration){
  //               _player.seek(duration);
  //             });
  //       });
  //   }
  //
  //   Widget _controlButtons(){
  //       return StreamBuilder(stream: _player.speedStream, builder: (context,snapshot){
  //           return Column(
  //             children: [
  //               Icon(
  //                 Icons.speed,
  //               ),
  //               Slider(
  //                 divisions: 3,
  //                 value: snapshot.data ?? 1,
  //                 onChanged: (value) async {
  //                   await _player.setSpeed(value);
  //                 },
  //               )
  //             ],
  //           );
  //       });
  //   }
  //
  //   Widget _volumeButtons(){
  //       return StreamBuilder(stream: _player.volumeStream, builder: (context,snapshot){
  //         return Column(
  //             mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(
  //               Icons.volume_up
  //             ),
  //             Slider(value: snapshot.data ?? 1, onChanged: (value) async {
  //                 await _player.setVolume(value);
  //             })
  //
  //           ],
  //         );
  //       });
  //   }
    void playButton(String path){
        _handlers.stop();

        _handlers.play(DeviceFileSource(path));

        print("playing the songs");

    }

  Future<bool> requestPermission() async {

    var status = await Permission.audio.request();

    if (status.isGranted) {
      print("Permission granted");
      return true;
    }

    if (status.isDenied) {
      print("Permission denied");
    }

    if (status.isPermanentlyDenied) {
      print("Permission permanently denied");
      await openAppSettings();
    }

    return false;
  }

}
