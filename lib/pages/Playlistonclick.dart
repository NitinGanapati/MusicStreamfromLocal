import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../db_handler.dart' as db;
import 'MiniPlayer.dart';
import 'PlaylistSongScreen.dart';

class Playlistonclick extends StatefulWidget{

// final AudioPlayer player;
  final AudioPlayer player;
  final String k ;
  final Future<List<Map<String, dynamic>>> songs;
  Playlistonclick({
    required this.songs,
    required this.k,
    required this.player,
    super.key
});

  @override
  State<StatefulWidget> createState() => _PlaylistonClick();

}

class _PlaylistonClick extends State<Playlistonclick>{

  bool isshowMinipage = false;
  Map<String, dynamic>? miniPlayerSong;
  List<Map<String,dynamic>> currentSongs = [];
  int miniPlayerIndex = 0;
  int currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    player = widget.player;
    songs = widget.songs;
    super.initState();
  }

  // late var songs = widget.songs;
  late Future<List<Map<String, dynamic>>> songs;
  late String k = widget.k;
  late AudioPlayer player;
  @override
  Widget build(BuildContext context) {
    // // TODO: implement build
    // throw UnimplementedError()
    return  Scaffold(
      appBar: AppBar(title: Text("Songs")),
      body: Stack(
        children: [
          Container(
              child: FutureBuilder(future: songs, builder: (context,AsyncSnapshot<List<Map<String,dynamic>>>snapshot)

              {


                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }

                if(!snapshot.hasData || snapshot.data!.isEmpty){
                  return const Center(child: Text("No Songs"));
                }
                if(snapshot.hasData){
                  currentSongs = snapshot.data!;
                }
                final songList = snapshot.data!;
                return ListView.builder(itemCount:songList.length,itemBuilder:(context,index){
                  // final id = index;
                  return Dismissible(
                    direction: DismissDirection.horizontal,
                    background: Container(
                      child: Icon(Icons.delete_forever),
                      color: Colors.red,
                    ),
                    onDismissed: (DismissDirection direction) async{

                      final song = songList[index];
                      await db.DBHelper().deleteMusicfromPlay(song["id"]);
                      print("Deleted");

                      setState(() {


                        songs = db.DBHelper().getMusicByPlaylist(k);
                      });
                    },
                    key: ValueKey(songList[index]["id"]),
                    child: ListTile(
                        title: Text(songList[index]["title"]),
                        subtitle: Text(songList[index]["artistName"]),
                        leading: Icon(Icons.music_note),
                        onTap:() async{
                          // Navigator.push(context,MaterialPageRoute(builder: (context)=> Playsongs(playListName: k)));
                          // List<Playmusic> songs = db.DBHelper().getMusicListPlaylist();
                          print(k);
                          // final playListMusics = await db.DBHelper().getMusicByPlaylist(k);
                          final playListMusics = songList;
                          print(playListMusics?.isEmpty);
                          if(playListMusics.isEmpty){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No Songs found")));
                          }

                          // if(playListMusics.isNotEmpty){
                          //   Navigator.push(context,MaterialPageRoute(builder: (context)=> Playerscreen(songs: playListMusics, currentIndex: 0)));
                          // }
                          if(playListMusics.isNotEmpty){
                            print(playListMusics);

                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Playlistsongscreen(
                                  songs: playListMusics,
                                  currentIndex: index,
                                  playListName: k,
                                    onSongChanged:(index){
                                    setState(() {
                                      currentIndex = index;
                                    });
                                  }
                                ),
                              ),
                            );

                            if (result!= null) {
                              setState(() {
                                isshowMinipage = true;
                                miniPlayerSong = currentSongs[result["currentIndex"]];
                                // miniPlayerIndex = result["currentIndex"];
                                currentIndex = result["currentIndex"];
                              });
                            }
                            // setState(() {
                            //   isshowMinipage=true;
                            //   miniPlayerSong = currentSongs[result["currentIndex"]];
                            // });
                            // Navigator.push(context,MaterialPageRoute(builder: (context)=> Playlistsongscreen(songs: playListMusics, currentIndex: index, playListName: k,)));
                          }

                        }
                    ),
                  );
                });
              })
          ),
          if(isshowMinipage)
            Align(
              alignment: Alignment.bottomCenter,
              child: Miniplayer(
                title: miniPlayerSong?["title"],
                songs: currentSongs,
                currentIndex: currentIndex,
                player: widget.player, onSongChanged: (index){
                  setState(() {
                    currentIndex = index;
                    // miniPlayerSong = currentSongs[index];
                  });

              },
              ),
            )


        ],

      ),
    );


    }
}






