import 'package:equatable/equatable.dart';
import 'package:ghanuflix/movies/ui_entity.dart';
import 'ui_entity.dart';

abstract class VideoServiceRequest extends Equatable {
  const VideoServiceRequest();

  @override
  List<Object> get props => [];
}


class GetPlaylistVideoServiceRequest extends VideoServiceRequest{
  final String playlistid;
  final String user;
  GetPlaylistVideoServiceRequest(this.playlistid, this.user);

  @override
  List<Object> get props => [playlistid,user];
}


class PlayThisVideoServiceRequest extends VideoServiceRequest{
  final List<VideoItem> videoItemList;
  final List<YtMap> ytMapList;
  final int playThisIndex;
  PlayThisVideoServiceRequest(this.ytMapList, this.videoItemList, this.playThisIndex);

  @override
  List<Object> get props => [videoItemList,ytMapList,playThisIndex];
}


class RefreshVideoServiceRequest extends VideoServiceRequest{
  final List<VideoItem> videoItemList;
  final AppUser appUser;
  final int playThisIndex;
  RefreshVideoServiceRequest(this.appUser, this.videoItemList, this.playThisIndex);

  @override
  List<Object> get props => [videoItemList,appUser,playThisIndex];
}

class PopUpServiceRequest extends VideoServiceRequest{
  final List<VideoItem> videoItemList;
  final List<YtMap> ytMapList;
  final int playThisIndex;
  PopUpServiceRequest(this.ytMapList, this.videoItemList, this.playThisIndex);

  @override
  List<Object> get props => [videoItemList,ytMapList,playThisIndex];
}