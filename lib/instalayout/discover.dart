import 'package:awesome_icons/awesome_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ghanuflix/instalayout/videoview.dart';
import 'package:ghanuflix/movies/ui_dao.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../movies/ui_entity.dart';
import 'albumview.dart';

class FilterPage extends StatefulWidget {
  List<VideoItem> photos;
  List<VideoItem> videos;
  AppUser appUser;
  FilterPage(this.photos, this.videos, this.appUser);

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List<String> selectedTags = [];
  List<VideoItem> allContents = <VideoItem>[];
  List<VideoItem> filteredContents = <VideoItem>[];
  Set<String> allTags=<String>{};
  bool isExpanded=false;
  Map<String, Set<VideoItem>> myMap = Map<String, Set<VideoItem>>();

  @override
  void initState() {
    super.initState();
    allContents.addAll(widget.photos);
    allContents.addAll(widget.videos);
    allTags.add("last month");
    allTags.add("last 3 months");
    allTags.add("last year");
    for(var v in allContents){
      allTags.addAll(v.tags!);
    }
    allTags = allTags.map((item) => item.toLowerCase()).toSet();
    allTags.removeWhere((element) => element.startsWith("20"));
    allContents.shuffle();
    filteredContents = List.from(allContents);
  }

  void _filterContent() {
    if (selectedTags.isEmpty) {
      filteredContents = List.from(allContents);
    } else {
      DateTime now = DateTime.now();

      if(selectedTags.contains("last 3 months")){
        for (int i = 3; i > 0; i--) {
          DateTime month = DateTime(now.year, now.month - i + 1, now.day);
          String formatted = DateFormat('yyyy-MM').format(month);
          selectedTags.add(formatted);
        }
      }
      if(selectedTags.contains("last month")){
        for (int i = 2; i > 0; i--) {
          DateTime month = DateTime(now.year, now.month - i + 1, now.day);
          String formatted = DateFormat('yyyy-MM').format(month);
          selectedTags.add(formatted);
        }
      }
      if(selectedTags.contains("last year")){
        for (int i = 12; i > 0; i--) {
          DateTime month = DateTime(now.year, now.month - i + 1, now.day);
          String formatted = DateFormat('yyyy-MM').format(month);
          selectedTags.add(formatted);
        }
      }
      filteredContents = allContents
          .where((content) => content.tags!.any((tag) => selectedTags.contains(tag.toLowerCase())))
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (isExpanded)
            Container(
              height: 40, // Adjust the height as needed
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: allTags.map((tag) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: FilterChip(
                      label: Text(tag),
                      selected: selectedTags.contains(tag),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            selectedTags.add(tag);
                          } else {
                            var now = DateTime.now();
                            if(tag.contains("last month")){
                              for (int i = 2; i > 0; i--) {
                                DateTime month = DateTime(now.year, now.month - i + 1, now.day);
                                String formatted = DateFormat('yyyy-MM').format(month);
                                selectedTags.remove(formatted);
                              }
                            }else if(tag.contains("last 3 months")){
                              for (int i = 3; i > 0; i--) {
                                DateTime month = DateTime(now.year, now.month - i + 1, now.day);
                                String formatted = DateFormat('yyyy-MM').format(month);
                                selectedTags.remove(formatted);
                              }
                            }else if(tag.contains("last Year")){
                              for (int i = 12; i > 0; i--) {
                                DateTime month = DateTime(now.year, now.month - i + 1, now.day);
                                String formatted = DateFormat('yyyy-MM').format(month);
                                selectedTags.remove(formatted);
                              }
                            }
                            selectedTags.remove(tag);
                          }
                          _filterContent();
                          // Optionally, apply filter logic here
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          IconButton(
            icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () => setState(() => isExpanded = !isExpanded),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredContents.length,
              itemBuilder: (context, index) {
                return ContentWidget(content: filteredContents[index], appUser: widget.appUser,);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ContentWidget extends StatelessWidget {
  final VideoItem content;
  final AppUser appUser;
  ContentWidget({required this.content, required this.appUser});

  @override
  Widget build(BuildContext context) {
    // Assuming the content is an image for demonstration
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: (){
              int initialCount=appUser.favMovies!.length+appUser.favAlbums!.length;
              if(content.tags!.contains("Album")){
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AlbumViewPage(albumPhotos: content.album!, appUser: appUser,),
                )).then((value) {
                  int newCount=appUser.favMovies!.length+appUser.favAlbums!.length;
                  if(newCount-initialCount != 0){
                    VideoDao().saveAppUserDetails(appUser);
                  }
                });

              }else{
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => VideoViewPage(videoUrl: content.url, id: content.id, appUser: appUser,),
                )).then((value) {
                  if(value == 'openInChrome'){
                    _openInChrome(content.url);
                  }
                  int newCount=appUser.favMovies!.length+appUser.favAlbums!.length;
                  if(newCount-initialCount != 0){
                    VideoDao().saveAppUserDetails(appUser);
                  }
                });
              }
            },
            child: AspectRatio(
                aspectRatio: 2/1,
                child:
                Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl:
                      content.imageUrl,
                      errorWidget: (context, url, error) {
                        return Image.network(
                          'https://via.placeholder.com/150/000000/FFFFFF/?text=loading...',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                            margin: EdgeInsets.all(4.0),
                            child: Icon(content.type.contains("ALBUM")? FontAwesomeIcons.camera : FontAwesomeIcons.play,color: Colors.white60, size: 35,))),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                            margin: EdgeInsets.all(4.0),
                            child:
                            content.type.contains("ALBUM")?
                            Container(
                              width: 50,
                              alignment: Alignment.center,
                              color: Colors.white60,
                              margin: EdgeInsets.all(1.0),
                              padding: EdgeInsets.all(4.0),
                              child: Text('${content.album!.length}', style: GoogleFonts.openSans(fontSize: 20,color: Colors.black54, fontWeight: FontWeight.bold),),
                            ):
                            Container(
                              width: 70,
                              alignment: Alignment.center,
                              color: Colors.white60,
                              margin: EdgeInsets.all(1.0),
                              padding: EdgeInsets.all(4.0),
                              child: Text(formatDuration(content.duration), style: GoogleFonts.openSans(fontSize: 15,color: Colors.black54, fontWeight: FontWeight.bold),),
                            ),
                        ),
                    ),
                  ],
                ),),
          ),
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

  String formatDuration(int secCount) {
    Duration duration = Duration(seconds: secCount);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours == 0) {
      return "$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  String _formatTags(List<String>? tags) {
    if (tags == null) return '';
    return tags.map((tag) {
      // Check if the tag matches the date pattern yyyy-MM
      RegExp datePattern = RegExp(r'\d{4}-\d{2}');
      if (datePattern.hasMatch(tag)) {
        try {
          // Parse the date
          DateTime dateTime = DateFormat('yyyy-MM').parse(tag);
          // Format the date to MMM yy (e.g., May 23)
          return DateFormat('MMM yy').format(dateTime);
        } catch (e) {
          // If parsing or formatting fails, return the original tag
          return tag;
        }
      }
      // Return the original tag if it doesn't match the date pattern
      return tag;
    }).join(', ');
  }

}


