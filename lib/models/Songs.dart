
class Songs {
    final int? id;
    final String title;
    final String path;
    final String artistName;
    final String albumName;

    Songs({
      this.id,
      required this.title,
      required this.path,
      required this.artistName,
      required this.albumName,
});

    factory Songs.fromMap(Map<String,dynamic>map){
      return Songs(
        id: map['id'],
        title: map['title'] ?? '',
        path: map['path'] ?? '',
        artistName: map['artistName'] ?? 'Unknown',
        albumName: map['albumName'] ?? 'Unknown',
      );
    }
    void main(){
      final testMap = {
        'id': 1,
        'title': 'Believer',
        'filePath': '/storage/music/believer.mp3',
        'artistName': 'Imagine Dragons',
        'albumTitle': 'Evolve',
        'genre': 'Rock',
      };

      final song = Songs.fromMap(testMap);

      print(song.title);
      print(song.path);
      print(song.artistName);
      print(song.albumName);
    }
}