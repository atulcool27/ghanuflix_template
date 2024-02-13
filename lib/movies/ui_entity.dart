

import 'package:flutter/foundation.dart';

class AppUser {
  String? id;
  List<String>? favMovies;
  List<String>? favAlbums;
  String? appUsername;
  String? appBio;
  String? appDescription;
  String? appProfileUrl;
  String? statusUrl;
  bool? isStatusPresent;
  List<YtMap>? ytTags;

  AppUser(
      {this.id,
        this.favMovies,
        this.favAlbums,
        this.appUsername,
        this.appBio,
        this.appDescription,
        this.appProfileUrl,
        this.statusUrl,
        this.isStatusPresent,
        this.ytTags});

  AppUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    favMovies = json['favMovies'].cast<String>();
    favAlbums = json['favAlbums'].cast<String>();
    appUsername = json['appUsername'];
    appBio = json['appBio'];
    appDescription = json['appDescription'];
    appProfileUrl = json['appProfileUrl'];
    statusUrl = json['statusUrl'];
    isStatusPresent = json['isStatusPresent'];
    if (json['ytTags'] != null) {
      ytTags = <YtMap>[];
      json['ytTags'].forEach((v) {
        ytTags!.add(new YtMap.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['favMovies'] = this.favMovies;
    data['favAlbums'] = this.favAlbums;
    data['appUsername'] = this.appUsername;
    data['appBio'] = this.appBio;
    data['appDescription'] = this.appDescription;
    data['appProfileUrl'] = this.appProfileUrl;
    data['statusUrl'] = this.statusUrl;
    data['isStatusPresent'] = this.isStatusPresent;
    // if (this.ytMap != null) {
    //   data['ytMap'] = this.ytMap!.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}


class YtMap {
  final int id;
  final String name;
  final List<VideoItem> videos;

  YtMap({
    required this.id,
    required this.name,
    required this.videos,
  });

  factory YtMap.fromJson(Map<String, dynamic> json) {
    final List<dynamic> videosJson = json['videos'] ?? [];
    final List<VideoItem> videos =
    videosJson.map((videoJson) => VideoItem.fromJson(videoJson)).toList();

    return YtMap(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      videos: videos,
    );
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is YtMap &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              listEquals(videos, other.videos);

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ videos.hashCode;

}

class VideoItem {
  final String id;
  final String title;
  final String description;
  final List<String>? tags;
  final List<String>? album;
  final String url;
  final int width;
  final int height;
  final String type;
  final String linkRefreshDate;
  final int duration;
  final bool urlValid;
  final String orientation;
  final String imageUrl;
  final String imageUrlBackup;
  final List<Format>? formats;

  VideoItem({
    required this.id,
    required this.title,
    required this.description,
    this.tags,
    this.album,
    required this.url,
    required this.width,
    required this.height,
    required this.type,
    required this.linkRefreshDate,
    required this.duration,
    required this.urlValid,
    required this.orientation,
    required this.imageUrl,
    required this.imageUrlBackup,
    this.formats,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    final List<dynamic> formatsJson = json['formats'] ?? [];
    final List<Format> formats =
    formatsJson.map((formatJson) => Format.fromJson(formatJson)).toList();

    return VideoItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      album: List<String>.from(json['album'] ?? []),
      url: json['url'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      type: json['type'] ?? '',
      linkRefreshDate: json['linkRefreshDate'] ?? '',
      duration: json['duration'] ?? 0,
      urlValid: json['urlValid'] ?? false,
      orientation: json['orientation'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      imageUrlBackup: json['imageUrlBackup'] ?? '',
      formats: formats,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is VideoItem &&
              url == other.url  &&
              album == other.album;



  @override
  int get hashCode =>
      url.hashCode ;
}


class Format {
  final String? label;
  final String? ext;
  final String? format;
  final int? filesize;
  final String? url;

  Format({
    this.label,
    this.ext,
    this.format,
    this.filesize,
    this.url,
  });

  factory Format.fromJson(Map<String, dynamic> json) {
    return Format(
      label: json['label'],
      ext: json['ext'],
      format: json['format'],
      filesize: json['filesize'],
      url: json['url'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Format &&
              label == other.label &&
              ext == other.ext &&
              format == other.format &&
              filesize == other.filesize &&
              url == other.url;

  @override
  int get hashCode =>
      label.hashCode ^ ext.hashCode ^ format.hashCode ^ filesize.hashCode ^ url.hashCode;
}
