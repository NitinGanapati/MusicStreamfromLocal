import 'package:flutter/material.dart';
import 'package:musics/db_handler.dart' as db;
import 'package:musics/models/Playmusic.dart';
import 'package:musics/models/Songs.dart';
import 'package:musics/pages/PlayerScreen.dart';

class Playsongs extends StatelessWidget {
  final String playListName;


  const Playsongs({super.key , required this.playListName});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page',playListName: playListName,),
      // home: const PlayList.Playlist(),
    );
  }
}
class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title, required this.playListName});
  final String playListName;

  final String title;

  late int currentIndex;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late List<Map<String,dynamic>> playListMusics;

  @override
  void initState() {
    // TODO: implement initState
    // _loadData(widget.playListName);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .inversePrimary,
          title: Text('Playlist'),
          // title: Text('Playlist'),
        ),
      //   body: if(playListMusics.isNotEmpty) {
      // Navigator.push(context,MaterialPageRoute(builder: (context)=> Playerscreen(songs: playListMusics, currentIndex: 0)))
    );
  }

  // void _loadData(String playListName) async{
  //   playListMusics = (await db.DBHelper().getMusicListPlaylist(widget.playListName))!;
  //   if(playListMusics.isNotEmpty){
  //     Navigator.push(context,MaterialPageRoute(builder: (context)=> Playerscreen(songs: playListMusics, currentIndex: 0)));
  //   }
  // }


}


