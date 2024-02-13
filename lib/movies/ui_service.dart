
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghanuflix/movies/ui_entity.dart';
import 'ui_dao.dart';
import 'ui_service_request.dart';
import 'ui_service_response.dart';

class MoviesService extends Bloc<VideoServiceRequest, VideoServiceResponse>{
  AppUser? appUser;
  VideoDao dao = VideoDao();

  MoviesService() : super(DefaultVideoServiceResponse()){


    on<GetPlaylistVideoServiceRequest>((event, emit)  async{
        await dao.getVideoPlaylistDataByUser(event.user).then((appUser) async {
          this.appUser=appUser;
          emit(GetPlaylistVideoServiceResponse(appUser));
        });
    },);

    on<PopUpServiceRequest>((event, emit) async {
      await dao.getVideoPlaylistData().then((ytMap) async {
        emit(PopUpServiceResponse(ytMap));
      });
    },);

    on<RefreshVideoServiceRequest>((event, emit) {
      try{
        emit(RefreshVideoServiceResponse(appUser!, event.videoItemList, event.playThisIndex));
      }on Exception catch(e){
        emit(InternetErrorVideoServiceResponse("Failed to Play This Video. Please check your internet connection."));
      }
    },);
  }

  AppUser getAppUser(){
    return appUser!;
  }

}