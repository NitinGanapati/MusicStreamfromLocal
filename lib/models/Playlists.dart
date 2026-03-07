
class Playlists {
  final int? id;
  final String name;


  Playlists({
    this.id,
    required this.name
});

  factory Playlists.fromMap(Map<String,dynamic>map){
    return Playlists(
      id: map['id'] as int?,
      name: map['name'] as String
    );
  }

  Map<String,Object?> toMap(){
    return({
      'id':id,
      'name':name
    });
  }
}