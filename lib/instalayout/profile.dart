import 'package:awesome_icons/awesome_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghanuflix/instalayout/discover.dart';
import 'package:ghanuflix/instalayout/loading.dart';
import 'package:ghanuflix/instalayout/status.dart';
import 'package:ghanuflix/instalayout/videoview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../movies/ui_entity.dart';
import '../movies/ui_service.dart';
import '../movies/ui_service_request.dart';
import '../movies/ui_service_response.dart';
import 'albumview.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'favorites.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final MoviesService _videoService = MoviesService();
  late TabController _tabController;
  int _selectedIndex = 0;

  void _onItemTapped(int index, AppUser appUser, List<VideoItem> videos,
      List<VideoItem> photos) {
    setState(() {
      _selectedIndex = index;
      _videoService.add(RefreshVideoServiceRequest(
          appUser, videos, DateTime.now().millisecondsSinceEpoch));
    });
  }

  @override
  void initState() {
    super.initState();
    generateDeviceIdentifier().then((value) {
      //fetch profile specific details ...
      _videoService.add(GetPlaylistVideoServiceRequest('', value));
      _tabController = TabController(length: 2, vsync: this);
    });
  }

  Future<String> generateDeviceIdentifier() {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    // For Android
    Future<String> getAndroidDeviceInfo() async {
      if(Platform.isAndroid){
        var build = await deviceInfoPlugin.androidInfo;
        return 'android_${build.model}_${build.id}';
      } else if(Platform.isIOS){
        var data = await deviceInfoPlugin.iosInfo;
        return 'ios_${data.model}_${data.identifierForVendor}';
      }else {
        return 'unknown';
      }
    }

    return getAndroidDeviceInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _videoService,
      child: BlocListener<MoviesService, VideoServiceResponse>(
        listener: (context, state) async {
          if (state is InternetErrorVideoServiceResponse) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          } else if (state is GetPlaylistVideoServiceResponse) {}
        },
        child: BlocBuilder<MoviesService, VideoServiceResponse>(
          builder: (context, state) {
            if (state is DefaultVideoServiceResponse) {
              return LoadingScreen();
            } else if (state is GetPlaylistVideoServiceResponse) {
              List<VideoItem> photos = <VideoItem>[];
              List<VideoItem> videos = <VideoItem>[];
              for (YtMap obj in state.appUser.ytTags!) {
                if (obj.name.contains("album")) {
                  photos.addAll(obj.videos);
                }
                if (obj.name.startsWith("20")) {
                  videos.addAll(obj.videos);
                }
              }
              return getProfileBody(state.appUser, photos, videos);
            } else if (state is RefreshVideoServiceResponse) {
              List<VideoItem> photos = <VideoItem>[];
              List<VideoItem> videos = <VideoItem>[];
              for (YtMap obj in state.appUser.ytTags!) {
                if (obj.name.contains("album")) {
                  photos.addAll(obj.videos);
                }
                if (obj.name.startsWith("20")) {
                  videos.addAll(obj.videos);
                }
              }
              return getProfileBody(state.appUser, photos, videos);
            } else {
              return LoadingScreen();
            }
          },
        ),
      ),
    );
  }

  Widget getProfileBody(
      AppUser appUser, List<VideoItem> photos, List<VideoItem> videos) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ghanuflix',
          style: GoogleFonts.pacifico(fontSize: 25.0),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.black),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.black26,
        onTap: (value) {
          _onItemTapped(value, appUser, photos, videos);
        },
      ),
      body: getCurrentPage(appUser, photos, videos),
    );
  }

  Widget getCurrentPage(
      AppUser appUser, List<VideoItem> photos, List<VideoItem> videos) {
    if (_selectedIndex == 0) {
      return getProfilePageBody(appUser, photos, videos);
    } else if (_selectedIndex == 1) {
      return FilterPage(photos, videos, _videoService.appUser!);
    }
    return FavoritesPage(_videoService.appUser!);
  }


  Widget getProfilePageBody(
      AppUser appUser, List<VideoItem> photos, List<VideoItem> videos) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverToBoxAdapter(
            child: ProfileDetails(appUser),
          ),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor:
                    Colors.black, // Color of the text for the selected tab
                unselectedLabelColor:
                    Colors.black54,
                indicator: BoxDecoration(
                  color: Colors.black12, // Background color of the selected tab
                ),
                tabs: [
                  Tab(text: "Photos"),
                  Tab(text: "Videos"),
                ],
              ),
            ),
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          PhotosTab(photos, _videoService),
          VideosTab(videos, _videoService),
        ],
      ),
    );
  }
}

class ProfileDetails extends StatelessWidget {
  AppUser appUser;
  ProfileDetails(this.appUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (appUser.isStatusPresent!)
              ? GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ContentDisplay(
                  url: appUser.statusUrl!)));
            },
                child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.deepOrange,
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(appUser.appProfileUrl!),
                      ),
                    ),
                  ),
              )
              : CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(appUser.appProfileUrl!),
                ),
          SizedBox(
              width:
                  16), // Spacing between the profile pic and text information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appUser.appUsername!,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.openSans().fontFamily),
                ),
                Text(
                  DateFormat('d MMM yy')
                      .format(DateFormat('dd-MM-yy').parse(appUser.appBio!)),
                  style: GoogleFonts.openSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
                Text(
                  appUser.appDescription!,
                  style: GoogleFonts.openSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Theme.of(context)
          .scaffoldBackgroundColor, // You can set your own color
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class PhotosTab extends StatelessWidget {
  final List<VideoItem> albums;
  final MoviesService videoService;
  PhotosTab(this.albums, this.videoService);

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get the device width and height for a responsive grid
    var width = MediaQuery.of(context).size.width;
    var crossAxisCount = width > 600 ? 4 : 3;

    return GridView.builder(
      itemCount: albums.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (BuildContext context, int index) {
        // Placeholder image with incremental numbers
        return GestureDetector(
          onTap: () {
            int initialCount = videoService.getAppUser().favMovies!.length +
                videoService.getAppUser().favAlbums!.length;
            Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) => AlbumViewPage(
                  albumPhotos: albums[albums.length - 1 - index].album!,
                  appUser: videoService.getAppUser()),
            ))
                .then((value) {
              int newCount = videoService.getAppUser().favMovies!.length +
                  videoService.getAppUser().favAlbums!.length;
              if (newCount - initialCount != 0) {
                videoService.dao.saveAppUserDetails(videoService.getAppUser());
              }
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: albums[albums.length - 1 - index].imageUrl,
                errorWidget: (context, url, error) {
                  return Image.network(
                    'https://via.placeholder.com/150/000000/FFFFFF/?text=loading...',
                    fit: BoxFit.cover,
                  );
                },
              ),
              Positioned(
                  bottom: 5,
                  left: 0,
                  right: 0,
                  child: Icon(
                    FontAwesomeIcons.camera,
                    color: Colors.white60,
                    size: 15,
                  )),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  alignment: Alignment.center,
                  color: Colors.white60,
                  margin: EdgeInsets.all(4.0),
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    '${albums[albums.length - 1 - index].album!.length}',
                    style: GoogleFonts.openSans(
                        fontSize: 10,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class VideosTab extends StatelessWidget {
  final List<VideoItem> videos;
  final MoviesService moviesService;
  VideosTab(this.videos, this.moviesService);

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get the device width and height for a responsive grid
    var width = MediaQuery.of(context).size.width;
    var crossAxisCount = width > 600 ? 4 : 3;

    return GridView.builder(
      itemCount: videos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 9 / 16,
      ),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            int initialCount = moviesService.getAppUser().favMovies!.length +
                moviesService.getAppUser().favAlbums!.length;
            Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) => VideoViewPage(
                  videoUrl: videos[index].url,
                  id: videos[index].id,
                  appUser: moviesService.getAppUser()),
            ))
                .then((value) {
              if (value == 'openInChrome') {
                _openInChrome(videos[index].url);
              }
              int newCount = moviesService.getAppUser().favMovies!.length +
                  moviesService.getAppUser().favAlbums!.length;
              if (newCount - initialCount != 0) {
                moviesService.dao
                    .saveAppUserDetails(moviesService.getAppUser());
              }
            });
          },
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: videos[index].imageUrl,
                      errorWidget: (context, url, error) {
                        return Image.network(
                          'https://via.placeholder.com/150/000000/FFFFFF/?text=loading...',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Icon(
                          FontAwesomeIcons.play,
                          color: Colors.white60,
                          size: 15,
                        )),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                          color: Colors.white60,
                          margin: EdgeInsets.all(4.0),
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            '${formatDuration(videos[index].duration)}',
                            style: GoogleFonts.openSans(
                                fontSize: 10,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold),
                          )),
                    )
                  ],
                ),
              ),
              Container(
                width: width / crossAxisCount,
                padding: EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.white60,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  '${videos[index].title.substring(7).replaceAll("Ghanu", "").replaceAll("SHORTS", "")}',
                  style: GoogleFonts.openSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _openInChrome(String url) async {
    // Replace with the URL you want to open
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
}
