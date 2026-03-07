class Playmusic {
  final String playListName;
  final String path;
  final String title;
  final String artistName;


  Playmusic({
    required this.playListName,
    required this.path,
    required this.title,
    required this.artistName,



});

  factory Playmusic.fromMap(Map<String,dynamic>map){
    return Playmusic(
      playListName: map['playListName'],
        path: map['path'],
        title: map['title'],
        artistName: map['artistName']
      // id: map['id'] as int?,
      // title: map['title'] as String?,
      // path: map['path'] as String?,
      // artistName: map['artistName'] as String?,
      // albumName: map['albumName'] as String?,
    );
  }
  Map<String,Object?> toMap(){
    return({
      // 'playListID':playListID,
      // 'songID':

      'playListName':playListName,
      'path':path,
      'title':title,
      'artistName':artistName
    });
  }
}