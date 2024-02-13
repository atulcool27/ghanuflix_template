import 'package:equatable/equatable.dart';
import 'package:ghanuflix/movies/ui_entity.dart';

abstract class VideoServiceResponse extends Equatable {
  const VideoServiceResponse();

  @override
  List<Object> get props => [];
}


class DefaultVideoServiceResponse extends VideoServiceResponse{}

class InternetErrorVideoServiceResponse extends VideoServiceResponse{
  final String message;
  InternetErrorVideoServiceResponse(this.message);

  @override
  List<Object> get props => [message];
}

class GetPlaylistVideoServiceResponse extends VideoServiceResponse{
  final AppUser appUser;
  GetPlaylistVideoServiceResponse(this.appUser);

  @override
  List<Object> get props => [appUser];
}


class PopUpServiceResponse extends VideoServiceResponse{
  final List<YtMap> playMap;
  PopUpServiceResponse(this.playMap);

  @override
  List<Object> get props => [playMap];
}

class PlayThisVideoServiceResponse extends VideoServiceResponse{
  final List<VideoItem> videoItemList;
  final AppUser appUser;
  final int playThisIndex;
  PlayThisVideoServiceResponse(this.appUser, this.videoItemList, this.playThisIndex);

  @override
  List<Object> get props => [videoItemList,appUser,playThisIndex];
}

class RefreshVideoServiceResponse extends VideoServiceResponse{
  final List<VideoItem> videoItemList;
  final AppUser appUser;
  final int playThisIndex;
  RefreshVideoServiceResponse(this.appUser, this.videoItemList, this.playThisIndex);

  @override
  List<Object> get props => [videoItemList,appUser,playThisIndex];
}


