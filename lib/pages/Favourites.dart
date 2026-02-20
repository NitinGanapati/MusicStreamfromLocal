import 'package:flutter/material.dart';
import 'package:musics/db_handler.dart' as db;
import 'package:musics/models/Songs.dart';
import 'package:musics/pages/PlayerScreen.dart';
class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {

  List<Songs> songs = [];
  @override
  void initState() {
    super.initState();
    // WidgetsFlutterBinding.ensureInitialized();
    // _setupAudioPlayer();
    // _testSongsFromMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text('Favourites')
        ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(future: db.DBHelper().getMusicsList(), builder: (context,AsyncSnapshot<List<Songs>>snapshot){
              print(snapshot.data);
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No favourites"));
              }
              return ListView.builder(itemCount:snapshot.data?.length,itemBuilder: (context,index){
                return Dismissible(
                  direction: DismissDirection.horizontal,
                  background: Container(
                    child: Icon(Icons.delete_forever),
                  ),
                  onDismissed: (DismissDirection direction) async {
                      db.DBHelper().deleteMusic(snapshot.data![index].id!);
                      songs = await db.DBHelper().getMusicsList();
                      snapshot.data!.remove(snapshot.data!.removeAt(index));
                  },
                  key: ValueKey<int?>(snapshot.data![index].id),
                  child: Card(
                    child: ListTile(

                      contentPadding: EdgeInsets.all(0),
                      title: Text(snapshot.data![index].title.toString()),
                      subtitle: Text(snapshot.data![index].artistName.toString()),
                      trailing: Text(snapshot.data![index].albumName.toString()),
                      onTap: (){
                        print("Tap is called");

                      },
                    ),
                  ),
                );
              });

            }),
          )
        ],
      )
    );
  }
}