import 'package:awesome_icons/awesome_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghanuflix/movies/ui_entity.dart';
import 'package:ghanuflix/movies/ui_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AlbumViewPage extends StatefulWidget {
  final List<String> albumPhotos;
  final AppUser appUser;
  AlbumViewPage({required this.albumPhotos, required this.appUser});

  @override
  _AlbumViewPageState createState() => _AlbumViewPageState();
}

class _AlbumViewPageState extends State<AlbumViewPage> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  late AppUser appUser;

  @override
  void initState() {
    appUser = widget.appUser;
    if(appUser.favAlbums==null){
      appUser.favAlbums=<String>[];
    }
    if(appUser.favMovies==null){
      appUser.favMovies=<String>[];
    }
    super.initState();
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
      body: Column(
        children: [
          SizedBox(height: 10,),
          Expanded(
            child:

       SizedBox(
      width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.70,
        child: CarouselSlider.builder(
          options: CarouselOptions(
              disableCenter: true,
              viewportFraction: 0.98,
              enlargeCenterPage: true,
              pauseAutoPlayOnManualNavigate: true,
              pauseAutoPlayOnTouch: true,
              autoPlay: false,
              enableInfiniteScroll: true,
              initialPage: 0
          ),
          itemBuilder: (BuildContext context, int index, pageViewIndex) {
            return Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                Container(
                  decoration:BoxDecoration(
                    border: Border.all(
                      color: Colors.black12,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    gradient: LinearGradient(colors: <Color>[
                      Colors.black26,
                      Colors.black54,
                      Colors.black87,
                      Colors.black54,
                      Colors.black26
                    ]),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black, // Background color
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2), // Shadow color
                              blurRadius: 10, // Shadow blur radius
                              spreadRadius: 1, // Shadow spread radius
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white70, // Border color
                            width: 2, // Border width
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl:
                            widget.albumPhotos[index],
                            errorWidget: (context, url, error) {
                              return Image.network(
                                widget.albumPhotos[index],
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
                      //_netflixLikeShadowEffect(),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                      margin: EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: (){
                          _openInChrome(widget.albumPhotos[index]);
                        },
                          child: Icon(FontAwesomeIcons.chrome, color: Colors.white,size: 35,))),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right:0,
                  child: GestureDetector(
                    onTap: (){
                     setState(() {
                       if(appUser.favAlbums!.contains(widget.albumPhotos[index])){
                         appUser.favAlbums!.remove(widget.albumPhotos[index]);
                       }else{
                         appUser.favAlbums!.add(widget.albumPhotos[index]);
                       }
                     });
                    },
                    child: Container(
                        margin: EdgeInsets.all(8.0),
                        child: Icon(
                          appUser.favAlbums!.contains(widget.albumPhotos[index])?FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart
                          , color:
                        appUser.favAlbums!.contains(widget.albumPhotos[index])?Colors.red : Colors.white,size: 25,)),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                      color: Colors.white,
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(8.0),
                      child: Text("${index+1}/${widget.albumPhotos.length}", style: GoogleFonts.openSans(),)),
                )
              ],
            );
          },
          itemCount: widget.albumPhotos.length,
        ),
      )
            ,
          ),

          SizedBox(height: 5,),
        ],
      ),
    );
  }


void _openInChrome(String url) async {// Replace with the URL you want to open
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

}
