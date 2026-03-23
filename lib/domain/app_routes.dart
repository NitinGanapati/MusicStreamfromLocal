import 'package:flutter/material.dart';
import 'package:uipart/ui/IntroPage.dart';
import 'package:uipart/ui/playlistSongs.dart';
import '../ui/AllSongs.dart';
import '../ui/PlaylistPage.dart';
import '../ui/QuicksPage.dart';
import '../ui/SplashPage.dart';

class AppRoutes {

  static const String splash_page = '/splash';
  static const String intro_page = '/intro';
  static const String quick_page = '/quick';
  static const String all_songs = '/allsongs';
  static const String playlist_page = '/playlistPage';
  static const String playlist_songs = '/playlistsongs';

  static Map<String , Widget Function(BuildContext)> getRoutes()=>{
    splash_page : (context) => SplashPage(),
    intro_page : (context) => Intropage(),
    quick_page : (context) => QuickPicksPage(),
    all_songs : (context) => Allsongs(),
    playlist_page : (context)=> Playlistpage(),
    playlist_songs : (context) => Playlistsongs()
  };


}