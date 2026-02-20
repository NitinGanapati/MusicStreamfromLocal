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
    String path = join(documentDirectory.path,'songs.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);

    return db;
  }

  _onCreate (Database db,int version)async{
    await db.execute(
      "CREATE TABLE music(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL UNIQUE,path TEXT NOT NULL,artistName TEXT NOT NULL,albumName TEXT NOT NULL)"
    );
  }

  Future<Songs> insert(Songs song) async{
    var dbClient = await db;
    await dbClient?.insert('music', song.toMap());
    return song;
  }

  Future<List<Songs>> getMusicsList () async{
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult = await dbClient!.query('music');
    print(queryResult);
    // print("FUNCTION CALLED");
    // print(queryResult);

    return queryResult.map((e) => Songs.fromMap(e)).toList();
  }

  Future<int?> deleteMusic(int id) async{
    var dbClient = await db;
    return await dbClient!.delete(
      'music',
      where: 'id = ?',
      whereArgs: [id]
    );
  }
}