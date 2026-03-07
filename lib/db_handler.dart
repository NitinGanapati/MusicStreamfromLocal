import 'package:musics/models/Playlists.dart';
import 'package:musics/models/Playmusic.dart';
import 'package:musics/models/Songs.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
class DBHelper{
  static Database? _db ;

  Future<Database?> get db async{
    if(_db != null){
      return _db;
    }
    _db = await initDatabase();
    return _db;
  }

  initDatabase() async{

    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path,'musicals.db');
    var db = await openDatabase(path, version: 9, onCreate: _onCreate);
    onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    };


    return db;
  }

  _onCreate (Database db,int version)async{
    await db.execute(
      "CREATE TABLE Mayana(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL,path TEXT NOT NULL,artistName TEXT NOT NULL,albumName TEXT NOT NULL,Unique(title,path))"
    );

      await db.execute(
          "CREATE TABLE Playlist(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE)"
    );

      await db.execute(
        "CREATE TABLE Musical(id INTEGER PRIMARY KEY AUTOINCREMENT, playListName TEXT, path TEXT , title TEXT , artistName TEXT,FOREIGN KEY(playListName) REFERENCES Playlist(name) ON DELETE CASCADE, UNIQUE(playListName,path))"
      );
      //
      // await db.execute(
      //   "CREATE TABLE PlayListMusic(playListID INTEGER, songID INTEGER, FOREIGN KEY(playListID) REFERENCES Playlist(id) ON DELETE CASCADE, FOREIGN KEY(songID) REFERENCES Mayana(id) ON DELETE CASCADE, PRIMARY KEY(playlistID,songID))"
      // );
  }

  Future<Songs> insert(Songs song) async{
    var dbClient = await db;
    await dbClient?.insert('Mayana', song.toMap(),conflictAlgorithm: ConflictAlgorithm.ignore);
    return song;
  }

  // Future<Playmusic>insertPlaySongs(Playmusic play) async{
  //   var dbClient = await db;
  //   await dbClient?.insert('Musical', play.toMap(),conflictAlgorithm: ConflictAlgorithm.ignore);
  //   print("INSERTING INTO PLAYLIST: '${Musical.playListName}'");
  //   print("SONG PATH: '${db.M.path}'");
  //   return play;
  //
  // }


  Future<Playmusic> insertPlaySongs(Playmusic play) async {
    final dbClient = await db;

    if (dbClient == null) return play;

    print("INSERTING INTO PLAYLIST: '${play.playListName}'");
    print("SONG PATH: '${play.path}'");

    print(play.toMap());

    await dbClient.insert(
      'Musical',
      play.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    final check = await dbClient.rawQuery(
        "SELECT playListName FROM Musical");

    print("All playlist names in Musical: $check");

    final structure = await dbClient.rawQuery("PRAGMA table_info(Musical)");
    print(structure);

    return play;
  }
  Future<int?>createPlaylist(String name) async{
    var dbClient = await db;
    return await dbClient?.insert('Playlist',{'name':name});
  }

  Future<Playlists> insertPlaylist(Playlists song) async{
    var dbClient = await db;
    Playlists p = new Playlists(name: song.name);
    await dbClient?.insert('Playlist', p.toMap(),conflictAlgorithm: ConflictAlgorithm.ignore);
    return song;
  }

  Future<List<Songs>> getMusicsList () async{
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult = await dbClient!.query('Mayana');
    print(queryResult);
    // print("FUNCTION CALLED");
    // print(queryResult);

    return queryResult.map((e) => Songs.fromMap(e)).toList();
  }


  Future<List<Playlists>> getPlaylist () async{
    var dbClient = await db;
    final List<Map<String,Object?>> queryResult = await dbClient!.query('Playlist');
    print(queryResult);
    return queryResult.map((e) => Playlists.fromMap(e)).toList();
  }


  //to retrieve the song from particular playlist
  Future<List<Map<String,dynamic>>> getMusicByPlaylist(String playlistName) async {
    final dbClient = await db;

    if (dbClient == null) return [];

    final result = await dbClient.rawQuery(
      '''
    SELECT *
    FROM Musical
    WHERE playListName = ?
    ''',
      [playlistName.trim()],
    );

    print("Raw maps: $result");

    return result;
  }

  // Future<List<Map<String,dynamic>>> getMusicByPlaylistMapOp(String playlistName) async {
  //   final dbClient = await db;
  //
  //   if (dbClient == null) return [];
  //
  //   final result = await dbClient.rawQuery(
  //     '''
  //   SELECT *
  //   FROM Musical
  //   WHERE playListName = ?
  //   ''',
  //     [playlistName.trim()],
  //   );
  //
  //   print("Raw maps: $result");
  //
  //   return result?.map((item)=> Playmusic.fromMap(item)).toList();
  // }

  // Future<List<Playmusic>?> getMusicByPlaylist(String path) async{
  //   var dbClient = await db;
  //   final List<Map<String, Object?>>? songs = await dbClient?.rawQuery(
  //       '''
  //     SELECT Mayana.* FROM Mayana
  //     INNER JOIN Musical ON Musical.songPath = Mayana.path
  //     WHERE Mayana.path = ?
  //     ''',[path]
  //   );
  //
  //   return songs?.map((item)=>Playmusic.fromMap(item)).toList();
  // }

  Future<int?> deleteMusic(int id) async{
    var dbClient = await db;
    return await dbClient!.delete(
        'Mayana',
        where: 'id = ?',
        whereArgs: [id]
    );
  }

  Future<int?> deleteMusicfromPlay(int id) async{
    var dbClient = await db;
    return await dbClient!.delete(
        'Musical',
        where: 'id = ?',
        whereArgs: [id]
    );
  }

  Future<int?> deletePlaylist(int id) async{
    var dbClient = await db;
    return await dbClient!.delete(
        'Playlist',
        where: 'id = ?',
        whereArgs: [id]
    );
  }


  }



