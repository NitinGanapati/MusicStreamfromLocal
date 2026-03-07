import 'dart:async';
import 'dart:io';
//kage:on_audio_query/on_audio_query.dart';

import 'package:musics/models/Playlists.dart';
import 'package:musics/models/Playmusic.dart';
import 'package:musics/pages/Favourites.dart';
import 'package:musics/pages/MiniPlayer.dart';
import 'package:musics/pages/PlayerScreen.dart' as Player;
import 'package:musics/db_handler.dart' as db;

import 'pages/Playlist.dart' as PlayList;
import 'models/Songs.dart';
// import 'services/audio_query_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';

import 'package:permission_handler/permission_handler.dart';
import 'services/storage_scan_services.dart' as Musics;

import 'package:flutter_media_delete/flutter_media_delete.dart';

enum SampleItem
{Favourites, Playlist}

void main()
{
    runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
    const MyApp({super.key});

    // This widget is the root of your application.
    @override
    Widget build(BuildContext context)
    {
        return MaterialApp(
          debugShowCheckedModeBanner:false,
            title: 'Flutter Demo',
            theme: ThemeData(
                colorScheme: .fromSeed(seedColor: Colors.deepPurple)
            ),
            home: MyHomePage(title: 'Flutter Demo Home Page')
        // home: const PlayList.Playlist(),
        );
    }
}

class MyHomePage extends StatefulWidget
{
    MyHomePage({super.key, required this.title, this.dbHelper});
    final db.DBHelper? dbHelper;

    final String title;

    @override
    State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{

    final TextEditingController _controller = TextEditingController();
    bool isshowMinipage = false;
    Map<String, dynamic>? miniPlayerSong;
    String _submittedText = "";
    List<Songs> favSongs = [];

    // late final _player = AudioPlayer();
    // final AudioQueryService _audioService = AudioQueryService();
    SampleItem? selectedItem;
    late Future<List<Songs>> songsList;
    final AudioPlayer _handlers = AudioPlayer();
    List<Map<String, dynamic>> songs = [];
    int currentIndex = 0;



    @override
    void initState()
    {
        super.initState();
        // WidgetsFlutterBinding.ensureInitialized();
        // _setupAudioPlayer();
        // _testSongsFromMap();
        init();
        loadData();
        loadFavourites();
    }
    Future<void> init() async
    {
        bool isPermitted = await requestPermission();
        if (isPermitted)
        {
            await loadMusic();
        }
    }
    Future<void> loadMusic() async
    {
        songs = await Musics.storageScanService().getSongDetails();
        setState(()
            {

            });
    }
    void loadData() async
    {
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
    Widget build(BuildContext context)
    {
        print("build called");
        return Scaffold(
            appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text('Nitin Music Player'),
                actions: [
                    IconButton(onPressed: ()
                        {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Favourites()));
                        }, icon: const Icon(Icons.favorite), tooltip: 'favourites'),
                    IconButton(onPressed: loadMusic, icon: const Icon(Icons.refresh)),
                    IconButton(onPressed: ()
                        {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PlayList.Playlist()));
                        }, icon: Icon(Icons.playlist_add))
                ]
            ),
            body: Stack(
              children: [
                songs.isEmpty ? RefreshIndicator(
                    onRefresh: loadMusic,
                    child: Center(child: Text("Scanning your Songs")))
                    : ListView.builder(itemCount: songs.length,
                    itemBuilder: (BuildContext context, int index)
                    {
                      final singlesong = songs[index];
                      // singlesong = songs[index];
                      // print(singlesong);
                      // print("HIIII");
                      // if(!(index>favSongs.length)){
                      //   print(favSongs[index].title!);
                      // }

                      return
                        // setState(() {
                        //
                        // });
                        ListTile(
                            leading: favSongs.any((fav) => fav.title == singlesong["title"])
                                ? const Icon(Icons.favorite, color: Colors.red)
                                : const Icon(Icons.music_note),
                            // leading: favSongs[index].title == singlesong[index].title ? Icon(Icons.monitor_heart) : Icon(Icons.music_note),
                            title: Text(singlesong["title"] ?? "Unknown"),
                            subtitle: Text(singlesong["artistName"] ?? "Unknown"),
                            trailing: PopupMenuButton<SampleItem>(
                                initialValue: selectedItem,
                                onSelected: (SampleItem item)
                                {
                                  // setState(() {
                                  //
                                  // });
                                  if (item == SampleItem.Favourites)
                                  {
                                    Songs song = Songs(
                                        title: singlesong["title"],
                                        path: singlesong["path"],
                                        artistName: singlesong["artistName"],
                                        albumName: singlesong["albumName"]
                                    );

                                    setState(() async{
                                      db.DBHelper().insert(song).then((value)
                                      {print("Songs inserted successfully");});
                                      await loadFavourites();
                                    });

                                    // key:UniqueKey();
                                    // Navigator.push(context, MaterialPageRoute(builder: (context)=> Player.Playerscreen(
                                    //         songs:songs,currentIndex:index,
                                    //       )));
                                    // }, child: Icon(Icons.add)),
                                    //   onTap: ()=>{
                                    //     Navigator.push(context, MaterialPageRoute(builder: (context)=> Player.Playerscreen(
                                    //       songs:songs,currentIndex:index,
                                    //     ))),
                                  }
                                  else if (item == SampleItem.Playlist)
                                  {
                                    //   print("hiiiiiiiiiiiiiiiiiiiiiiiiiii");
                                    //   Column(
                                    //     children: <Widget>[
                                    //       Expanded(child: FutureBuilder(future: db.DBHelper().getPlaylist(), builder:(context,AsyncSnapshot<List<Playlists>>snapshot){
                                    // // print(snapshot.data);
                                    //
                                    // if (snapshot.connectionState == ConnectionState.waiting) {
                                    // return Center(child: CircularProgressIndicator());
                                    // }
                                    // return ListView.builder(itemCount:snapshot.data?.length,itemBuilder: (context,index){
                                    //
                                    // });
                                    //
                                    //
                                    // }
                                    //       ),
                                    //       )
                                    //     ],
                                    //   );
                                    final scaffoldContent = context;
                                    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (BuildContext context)
                                    {
                                      return SizedBox(

                                          height: MediaQuery.of(context).size.height * 0.75,
                                          width: MediaQuery.of(context).size.width * 0.75,
                                          child: Column(
                                              children: [
                                                TextField(
                                                    controller: _controller,
                                                    decoration: InputDecoration(
                                                        hintText: "Enter playlist name"
                                                    )
                                                ),
                                                ElevatedButton(onPressed: ()
                                                {
                                                  String value = _controller.text.trim();
                                                  // if(value==" "){
                                                  //   return;
                                                  // }
                                                  // Text(value.isEmpty ? 'Please Enter the name' : 'Please wait for while');
                                                  // if(value.isEmpty){
                                                  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter the name please"),behavior: SnackBarBehavior.floating,));
                                                  //   return;
                                                  // }
                                                  Playlists p = new Playlists(
                                                      name: value
                                                  );
                                                  db.DBHelper().insertPlaylist(p).then((value)
                                                  {print("Playlist inserted successfully");});
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(scaffoldContent).showSnackBar(SnackBar(content: Text("Playlist has been added successfully"), behavior: SnackBarBehavior.floating));

                                                }, child: Text("Add a Playlist")),
                                                Expanded(
                                                    child: FutureBuilder(future: db.DBHelper().getPlaylist(), builder: (context, AsyncSnapshot<List<Playlists>> snapshot)
                                                    {
                                                      return ListView.builder(itemCount: snapshot.data!.length, itemBuilder: (context, index)
                                                      {
                                                        return ListTile(
                                                            title: Text(snapshot.data![index].name.toString()),
                                                            trailing: ElevatedButton(onPressed: ()
                                                            {
                                                              // Playmusic(playListID: null, songID: )
                                                              // print(snapshot.data?[index].name);
                                                              // print(snapshot.data![index].id);
                                                              // print("*************************");
                                                              // print(singlesong['path']);
                                                              // print(singlesong['artistName']);
                                                              // print(singlesong['title']);

                                                              print("**************************");
                                                              Playmusic m = new Playmusic(playListName: snapshot.data![index].name,
                                                                  path: singlesong['path'],
                                                                  title: singlesong['title'],
                                                                  artistName: singlesong['artistName']);

                                                              db.DBHelper().insertPlaySongs(m).then((value)
                                                              {
                                                                print("Your song has been added successfully");
                                                              });
                                                              Navigator.pop(context);
                                                              ScaffoldMessenger.of(scaffoldContent).showSnackBar(SnackBar(content: Text("Songs has been added successfully"), behavior: SnackBarBehavior.floating));
                                                            }, child: Icon(Icons.add))
                                                        );
                                                      });
                                                    })
                                                )
                                              ]
                                          )
                                      );
                                    }
                                    );

                                  }

                                  setState(()
                                  {
                                    selectedItem = item;
                                  });
                                },
                                itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<SampleItem>>[
                                  const PopupMenuItem<SampleItem>(
                                      value: SampleItem.Favourites,
                                      child: Text("Add to Favourites")),
                                  const PopupMenuItem<SampleItem>(
                                      value: SampleItem.Playlist,
                                      child: Text("Add to Playlist")
                                  )
                                ]
                            ),
                            onTap: () async
                            {
                              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => Player.Playerscreen(
                                  songs: songs, currentIndex: index, player: _handlers
                              )));
                              if(result!=null){
                                setState(() {
                                  isshowMinipage=true;
                                  currentIndex = result["currentIndex"];
                                  miniPlayerSong=result;
                                });
                              }
                            }
                        );
                      // trailing: ElevatedButton(onPressed: (){
                      //   Songs song = Songs(
                      //     title : singlesong["title"],
                      //     path: singlesong["path"],
                      //     artistName: singlesong["artistName"],
                      //     albumName: singlesong["albumName"]
                      //   );
                      //   db.DBHelper().insert(song).then( (value) {print("Songs inserted successfully");});
                      // }, child: Icon(Icons.add)),
                      //   onTap: ()=>{
                      //     Navigator.push(context, MaterialPageRoute(builder: (context)=> Player.Playerscreen(
                      //       songs:songs,currentIndex:index,
                      //     ))),
                      //     // playButton(singlesong["path"]!)
                      //
                      //   },onLongPress: () =>{
                      //       print('Hi i m from long press $singlesong["path"]'),
                      //       _deleteItem(singlesong["path"].toString()),
                      // },
                      // );
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
                //
                //
,
                // if(isshowMinipage)
                //   Align(
                //     alignment: Alignment.bottomCenter,
                //     child: Miniplayer(title: miniPlayerSong!["title"], songs: songs, currentIndex: miniPlayerSong!["currentIndex"],player:_handlers, onSongChanged: (index) {
                //       currentIndex= index;
                //     },),
                //   )

                if (isshowMinipage)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Miniplayer(
                      title: songs[currentIndex]["title"],
                      songs: songs,
                      currentIndex: currentIndex,
                      player: _handlers,
                      onSongChanged: (index) {
                        setState(() {
                          currentIndex = index;
                          miniPlayerSong = {
                            ...songs[index],
                            "currentIndex": index
                          };
                        });
                      },
                    ),
                  )

              ],
            )
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
    void playButton(String path)
    {
        _handlers.stop();

        _handlers.play(DeviceFileSource(path));

        print("playing the songs");

    }

    void liked()
    {

    }

    Future<bool> requestPermission() async
    {

        var status = await Permission.audio.request();

        if (status.isGranted)
        {
            print("Permission granted");
            return true;
        }

        if (status.isDenied)
        {
            print("Permission denied");
        }

        if (status.isPermanentlyDenied)
        {
            print("Permission permanently denied");

            await openAppSettings();
        }
        return false;
    }

    Future<bool> requestMusicStorage() async
    {
        late PermissionStatus status;

        if (Platform.isAndroid)
        {
            if (await Permission.audio.status.isPermanentlyDenied)
            {
                await openAppSettings();
                return false;
            }
            status = await Permission.mediaLibrary.request();
        }

        if (status.isGranted)
        {
            return true;
        }
        else if (status.isDenied || status.isPermanentlyDenied)
        {
            await openAppSettings();
            return false;
        }
        else
        {
            return false;
        }
    }

    Future<void> _deleteItem(String path) async
    {
        if (await requestMusicStorage())
        {
            try
            {
                // final file = File(path);
                // print("im from deleteitem {$file}");
                //
                // if(await file.exists()){
                //   await file.delete();
                //   print('File deleted successfully : $path');
                final result = await FlutterMediaDelete.deleteMediaFile(path);
                print('Deleted result : $result');
                if (mounted)
                {
                    setState(()
                        {
                            songs.removeWhere((song) => song["path"] == path);
                            // AlertDialog(
                            //   title: const Text("AlertDialog Title"),
                            //   content: const SingleChildScrollView(
                            //     child: ListBody(
                            //       children: <Widget>[
                            //         Text('The Song has been deleted'),
                            //         Text('Thank you')
                            //       ],
                            //     ),
                            //   ),
                            //   actions: <Widget>[
                            //     TextButton(onPressed: (){
                            //       Navigator.of(context).pop();
                            //     }, child: Text("Okay"))
                            //   ],
                            // );
                        });
                }
            }

            catch(e)
            {
                print('Error deleting file: $e');
            }

        }
        else
        {
            print("Permission not granted to delete file");
        }
    }

    Future<void> loadFavourites() async
    {
        favSongs = await db.DBHelper().getMusicsList();
        setState(() {

        });
        print(favSongs);
    }

}
