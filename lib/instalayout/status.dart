import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ContentDisplay extends StatefulWidget {
  final String url;

  ContentDisplay({required this.url});

  @override
  _ContentDisplayState createState() => _ContentDisplayState();
}

class _ContentDisplayState extends State<ContentDisplay> {
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubePlayerController;
  late ContentType _contentType;

  @override
  void initState() {
    super.initState();
    _contentType = getContentType(widget.url);

    if (_contentType == ContentType.video) {
      _videoController = VideoPlayerController.network(widget.url)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play(); // Autoplay the video
          _videoController!.setVolume(0.0); // Mute video
        });
    } else if (_contentType == ContentType.youtube) {
      String videoId = YoutubePlayer.convertUrlToId(widget.url)!;
      _youtubePlayerController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: true,
          mute: true,
          hideControls: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _youtubePlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ghanuflix',
          style: GoogleFonts.pacifico(fontSize: 25.0, color: Colors.white),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back,color: Colors.white,size: 35,),
        ),
        elevation: 0,
        backgroundColor: Colors.black,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.black),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: _getContentWidget(),
        ),
      ),
    );
  }

  Widget _getContentWidget() {
    switch (_contentType) {
      case ContentType.photo:
        return Image.network(widget.url, fit: BoxFit.cover);
      case ContentType.video:
        return _videoController != null && _videoController!.value.isInitialized
            ? AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        )
            : CircularProgressIndicator();
      case ContentType.youtube:
        return YoutubePlayer(
          controller: _youtubePlayerController!,
          showVideoProgressIndicator: false,
        );
      default:
        return CircularProgressIndicator();
    }
  }
}



enum ContentType { photo, video, youtube, unknown }

ContentType getContentType(String url) {
  Uri uri = Uri.parse(url);
  if (url.contains("youtube.com") || url.contains("youtu.be")) {
    return ContentType.youtube;
  } else if (url.contains(".mp4")) {
    return ContentType.video;
  } else if (url.contains(".jpg") || url.contains(".png") || url.contains(".jpeg") || url.contains(".gif")) {
    return ContentType.photo;
  }
  return ContentType.unknown;
}

