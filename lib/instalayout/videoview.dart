import 'package:awesome_icons/awesome_icons.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ghanuflix/movies/ui_dao.dart';
import 'package:ghanuflix/movies/ui_entity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class VideoViewPage extends StatefulWidget {
  final String videoUrl;
  final String id;
  final AppUser appUser;
  VideoViewPage({required this.videoUrl,required this.id, required this.appUser});

  @override
  _VideoViewPageState createState() => _VideoViewPageState();
}

class _VideoViewPageState extends State<VideoViewPage> {
  ChewieController? _chewieController;
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    Wakelock.enable();
  }

  @override
  void dispose() {
    Wakelock.disable();
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer() {
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            autoPlay: true,
            looping: true,
            aspectRatio: _videoPlayerController.value.aspectRatio,
            showControls: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: Colors.blue,
              handleColor: Colors.blueAccent,
              backgroundColor: Colors.grey,
              bufferedColor: Colors.lightBlue,
            ),
            placeholder: Container(
              color: Colors.black,
            ),
            autoInitialize: true,
          );
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Text(
          'Ghanuflix',
          style: GoogleFonts.pacifico(fontSize: 25.0),
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back,color: Colors.black, size: 30,)),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.black),
      ),
      body: _chewieController != null
          ? Center(
        child: Stack(
          children: [
            Chewie(
              controller: _chewieController!,
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                  margin: EdgeInsets.all(8.0),
                  child: GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop("openInChrome");
                      },
                      child: Icon(FontAwesomeIcons.chrome, color: Colors.white,size: 35,))),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: (){
                  setState(() {
                    if(widget.appUser.favMovies!.contains(widget.id)){
                      widget.appUser.favMovies!.remove(widget.id);
                    }else{
                      widget.appUser.favMovies!.add(widget.id);
                    }
                  });
                },
                child: Container(
                    margin: EdgeInsets.all(8.0),
                    child: Icon(
                      widget.appUser.favMovies!.contains(widget.id)?FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart
                      , color:
                    widget.appUser.favMovies!.contains(widget.id)?Colors.red : Colors.white,size: 25,)),
              ),
            ),
          ],
        ),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.of(context).pop("openInChrome");
                },
                child: Icon(FontAwesomeIcons.chrome, color: Colors.orange,size: 65,)),
            SizedBox(height: 10,),
            Text("click to open in browser.", style: GoogleFonts.openSans(fontWeight: FontWeight.bold,color: Colors.black54,),),
            SizedBox(height: 40,),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: SpinKitFadingCube(
                color: Colors.black,
                size: 25.0,
              ),
            ),
            SizedBox(height: 40,),
            Text("loading...", style: GoogleFonts.openSans(fontWeight: FontWeight.bold,color: Colors.black54,),),
          ],
        ),
      ),
    );
  }
}
