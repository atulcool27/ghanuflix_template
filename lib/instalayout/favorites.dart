import 'package:awesome_icons/awesome_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../movies/ui_entity.dart';

class FavoritesPage extends StatelessWidget {
  late List<Map<String,dynamic>> favorites;
  final AppUser appUser;
  FavoritesPage(this.appUser){
    favorites = [];
    for(String url in appUser.favAlbums!){
      favorites.add({"url": url, "type": CardType.photo});
    }

    Set<VideoItem> videos = <VideoItem>{};
    for (YtMap obj in appUser.ytTags!) {
        videos.addAll(obj.videos);
    }
    Map<String, VideoItem> userMap = {for (var vid in videos) vid.id: vid};

    for(String id in appUser.favMovies!){
      favorites.add({"url": userMap[id]?.url, "type": CardType.video, "height": (userMap[id]!.height>userMap[id]!.width)?'700':'350'});
    }
    favorites.shuffle();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          var item = favorites[index];
          return FavoriteCard(url: item['url'], type: item['type'], height: item['type']==CardType.video?double.parse(item['height']):600, appUser: appUser, comments: [],isFavorited: true);
        },
      ),
    );
  }
}


enum CardType { photo, video }



class FavoriteCard extends StatefulWidget {
  final String url;
  final CardType type;
  final double height;
  final AppUser appUser;
  final List<String> comments;
  final bool isFavorited;

  FavoriteCard({
    required this.url,
    required this.type,
    required this.height,
    required this.appUser,
    required this.comments,
    this.isFavorited = false,
  });

  @override
  _FavoriteCardState createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard> {
  VideoPlayerController? _videoController;
  late bool _isVideo;
  late bool _isFavorited;

  @override
  void initState() {
    super.initState();
    _isVideo = widget.type == CardType.video;
    _isFavorited = widget.isFavorited;
    if (_isVideo) {
      _videoController = VideoPlayerController.network(widget.url)
        ..initialize().then((_) => setState(() {}));
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  bool _isHorizontalVideo() {
    // Ensure the controller is initialized and has a valid video
    if (_videoController != null && _videoController!.value.isInitialized) {
      final videoAspect = _videoController!.value.aspectRatio;
      // Aspect ratio > 1 indicates a horizontal video
      return videoAspect > 1;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.url),
      onVisibilityChanged: (visibilityInfo) {
        if (_isVideo) {
          if (visibilityInfo.visibleFraction > 0.5) {
            _videoController?.play();
          } else {
            _videoController?.pause();
          }
        }
      },
      child: Container(
        color: Colors.white,
        height: widget.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 4,bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 5,),
                  CircleAvatar(
                    // Placeholder for user profile picture
                    radius: 14,
                    backgroundImage: NetworkImage(widget.appUser.appProfileUrl!),
                  ),
                  SizedBox(width: 5,),
                  Text('${widget.appUser.appUsername!} liked this.', style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.black54)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                height:  widget.height , // Use dynamically adjusted height
                width: MediaQuery.of(context).size.width,
                child: _isVideo
                    ? _videoController?.value.isInitialized ?? false
                    ? AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                )
                    : Center(child: SpinKitFadingCube(color: Colors.red, size: 50.0))
                    : Image.network(widget.url, fit: BoxFit.cover),
              ),
            ),

            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Row(
            //         children: [
            //           // IconButton(
            //           //   icon: Icon(_isFavorited ? Icons.favorite : Icons.favorite_border, color: Colors.red),
            //           //   onPressed: () => setState(() => _isFavorited = !_isFavorited),
            //           // ),
            //           IconButton(
            //             icon: Icon(FontAwesomeIcons.chrome, color: Colors.orange,size: 35,),
            //             onPressed: () {
            //               // Handle emoji action
            //             },
            //           ),
            //           // IconButton(
            //           //   icon: Icon(FontAwesomeIcons.comment),
            //           //   onPressed: () {
            //           //     // Handle comments action
            //           //   },
            //           // ),
            //         ],
            //       ),
            //       //Icon(Icons.bookmark_border), // Placeholder for saving/favoriting the post
            //     ],
            //   ),
            // ),
            if (widget.comments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.comments.last, // Displaying the latest comment
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            SizedBox(height: 25,),
          ],
        ),
      ),
    );
  }
}


