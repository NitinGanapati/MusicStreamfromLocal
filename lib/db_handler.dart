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
    var db = await openDatabase(path, version: 2, onCreate: _onCreate);
    return db;
  }

  _onCreate (Database db,int version)async{
    await db.execute(
      "CREATE TABLE Mayana(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL,path TEXT NOT NULL,artistName TEXT NOT NULL,albumName TEXT NOT NULL,Unique(title,path))"
    );
  }

  Future<Songs> insert(Songs song) async{
    var dbClient = await db;
    await dbClient?.insert('Mayana', song.toMap(),conflictAlgorithm: ConflictAlgorithm.ignore);
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

  Future<int?> deleteMusic(int id) async{
    var dbClient = await db;
    return await dbClient!.delete(
      'Mayana',
      where: 'id = ?',
      whereArgs: [id]
    );
  }
}