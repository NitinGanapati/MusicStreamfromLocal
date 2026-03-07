import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:musics/db_handler.dart' as db;
import 'package:musics/models/Playlists.dart';
import 'package:musics/models/Playmusic.dart';
import 'package:musics/models/Songs.dart';
import 'package:musics/pages/PlaySongs.dart';
import 'package:musics/pages/PlaylistSongScreen.dart';
import 'package:musics/pages/Playlistonclick.dart';

import 'PlayerScreen.dart';
class Playlist extends StatefulWidget {
  // var playListName;

  // List<Map<String,dynamic>> songs = [];
  // late int currentIndex;

  Playlist({super.key});


  @override
  State<Playlist> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<Playlist> {

  final AudioPlayer _handlers = AudioPlayer();
  // late List<Map<String,dynamic?>>? playListMusics;
  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Playlist'),
      ),
     body: Container(
       child: FutureBuilder(future: db.DBHelper().getPlaylist() , builder: (context,AsyncSnapshot<List<Playlists>>snapshot){
         if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator());
         }
         if (snapshot.hasError) {
           return Center(child: Text("Error: ${snapshot.error}"));
         }
         if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
           return const Center(child: Text("No Playlists Found"));
         }
          return ListView.builder(itemCount:snapshot.data!.length,itemBuilder: (context,index){
              return Dismissible(
                direction: DismissDirection.horizontal,
                background: Container(
                  child: Icon(Icons.delete_forever),
                  color: Colors.red,
                ),
                onDismissed: (DismissDirection direction){
                  db.DBHelper().deletePlaylist(snapshot.data![index].id!);
                  print("Deleted Playlsit");

                  setState(() {
                    db.DBHelper().getPlaylist();
                  });

                }, key:  ValueKey<int?>(index),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(snapshot.data![index].name.toString()),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.blue,width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    //

                      // String k = snapshot.data![index].name;
                      // var songs = db.DBHelper().getMusicByPlaylist(snapshot.data![index].name);
                      //
                      // Navigator.push(context, MaterialPageRoute(builder: (_)=> Scaffold(
                      //   appBar: AppBar(title: Text("Songs")),
                      //   body: Container(
                      //     child: FutureBuilder(future: songs, builder: (context,AsyncSnapshot<List<Map<String,dynamic>>>snapshot)
                      //   {
                      //     return ListView.builder(itemCount:snapshot.data!.length,itemBuilder:(context,index){
                      //       // final id = index;
                      //       return Dismissible(
                      //         direction: DismissDirection.horizontal,
                      //         background: Container(
                      //           child: Icon(Icons.delete_forever),
                      //           color: Colors.red,
                      //         ),
                      //         onDismissed: (DismissDirection direction) async{
                      //
                      //         final song = snapshot.data![index];
                      //         db.DBHelper().deleteMusicfromPlay(song["id"]);
                      //         print("Deleted");
                      //
                      //           setState(() {
                      //
                      //
                      //             songs = db.DBHelper().getMusicByPlaylist(k);
                      //           });
                      //         },
                      //         key:  ValueKey<int?>(index),
                      //         child: ListTile(
                      //           title: Text(snapshot.data![index]["title"]),
                      //           subtitle: Text(snapshot.data![index]["artistName"]),
                      //           leading: Icon(Icons.music_note),
                      //         ),
                      //       );
                      //     });
                      //   })
                      //   ),
                      // )) );

                    //   Container(
                    //       child:  FutureBuilder(builder: (context,AsyncSnapshot<List<Map<String,dynamic>>>snapshot){
                    //         return ListView.builder(itemCount:snapshot.data!.length,itemBuilder: (context,index){
                    //           return ListTile(
                    //             title: Text(snapshot.data![index]["title"]),
                    //           );
                    //         });
                    //       }, future: db.DBHelper().getMusicByPlaylist(snapshot.data![index].name))
                    //   );
                    // } , child: Icon(Icons.ads_click_outlined)),


                    // trailing: ElevatedButton(onPressed: (){
                    //   print("The Button has been pressed");
                    //   // Navigator.push(context,MaterialPageRoute(builder: (context)=> Playsongs(playListName: snapshot.data![index].name.toString())));
                    //   Container(
                    //     child:  FutureBuilder(builder: (context,AsyncSnapshot<List<Map<String,dynamic>>>snapshot){
                    //       return ListView.builder(itemCount:snapshot.data!.length,itemBuilder: (context,index){
                    //         return ListTile(
                    //           title: Text(snapshot.data![index]["title"]),
                    //         );
                    //       });
                    //     }, future: db.DBHelper().getMusicByPlaylist(snapshot.data![index].name))
                    //   );
                    //
                    // }, child: Icon(Icons.favorite)),
                    onTap: ()  {
                      String k = snapshot.data![index].name;
                      var songs = db.DBHelper().getMusicByPlaylist(snapshot.data![index].name);

                      // Navigator.push(context, MaterialPageRoute(builder: (_)=>  );


                      Navigator.push(context, MaterialPageRoute(builder: (context) => Playlistonclick(songs: songs, k: k,player:_handlers)));

                      // Navigator.push(context,MaterialPageRoute(builder: (context)=> Playsongs(playListName: snapshot.data![index].name.toString())));
                      // // List<Playmusic> songs = db.DBHelper().getMusicListPlaylist();
                      // print(snapshot.data![index].name);
                      // final playListMusics = await db.DBHelper().getMusicByPlaylist(snapshot.data![index].name);
                      // print(playListMusics?.isEmpty);
                      // if(playListMusics.isEmpty){
                      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No Songs found")));
                      // }
                      //
                      // // if(playListMusics.isNotEmpty){
                      // //   Navigator.push(context,MaterialPageRoute(builder: (context)=> Playerscreen(songs: playListMusics, currentIndex: 0)));
                      // // }
                      // if(playListMusics.isNotEmpty){
                      //   print(playListMusics);
                      //     Navigator.push(context,MaterialPageRoute(builder: (context)=> Playlistsongscreen(songs: playListMusics, currentIndex: 0, playListName: snapshot.data![index].name.toString(),)));
                      // }

                    },
                  ),
                ),
              );
          });
       }),
     ),
    );
  }
  
  
}
