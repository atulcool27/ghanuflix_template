
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ghanuflix/movies/ui_entity.dart';

class VideoDao{

  var SERVER_URL= "";


  Future<List<YtMap>> getVideoPlaylistData() {
    return fetchDataWithBearerToken();
  }

  Future<AppUser> getVideoPlaylistDataByUser(String username) {
    return fetchDataWithBearerTokenByUsername(username);
  }




  Future<AppUser> fetchDataWithBearerTokenByUsername(String username) async {
    
    return appuser;
  }

  Future<List<YtMap>> fetchDataWithBearerToken() async {
    
    return videos;
  }


  Future<String> getUrlByVideoId(String videoid) async{
    
    return await response.data;
  }

  Future<void> saveAppUserDetails(AppUser appUser) async {
   

  }




}