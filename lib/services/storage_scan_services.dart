import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';

class storageScanService{

    Future<List<Map<String,dynamic>>> getSongDetails() async {
      List<Map<String,dynamic>> songs = [];
      // Directory("/storage/emulated/0/Music"),
      // Directory("/storage/emulated/0/Download"),
      final directories = [

        Directory("/storage/emulated/0/Songs")
      ];

      for(var v in directories){
        if(!v.existsSync()){
          continue;
        }
        try{
          final files = v.listSync(followLinks: true,recursive: false);
          print(files);

          for(var file in files){
            if(file is File && file.path.endsWith(".mp3")){
              final metadata = readMetadata(file);
              songs.add({
                "title" : metadata.title ?? file.path.split("/").last,
                "path" : file.path ,
                "artistName": metadata.artist ?? "Unknown",
                "albumName" : metadata.album ?? "Unknown"
              }
              );
            }
          }
        }
        catch(_){
          print("Error");
        }
      }

    return songs;
    }



}