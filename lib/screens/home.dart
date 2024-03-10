// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:youtube_downloder_final/constants/constants.dart';
import 'package:geocoding/geocoding.dart';

import '../widgets/__video_tile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ScrollController _scrollControllerTrending = ScrollController();
  TextEditingController searchTextController = TextEditingController();
  bool _isLoadingVideos = false;
  String _searchedVideo = '';
  bool _isLoadingMoreVideos = false;

  @override
  initState() {
    super.initState();
    _scrollControllerTrending.addListener(_scrollListener);
    _ToFetchTrending();
    _isLoadingVideos = true;
    myrequestForPermission();
    checkLocationPermission();
  }

  void _scrollListener() {
    // Check if the user has reached the end of the list
    if (_scrollControllerTrending.position.pixels ==
        _scrollControllerTrending.position.maxScrollExtent) {
      // Fetch more items when scrolled to the bottom
      fetchMoreVideos();
    }
  }

  Future<void> fetchMoreVideos() async {
    // Fetch more items and add them to the existing list
    setState(() {
      _isLoadingMoreVideos = true;
    });
    List<YouTubeVideo> moreVideos = await ytApi.nextPage();
    // for (var i = 0; i < videoResult.length; i++) {
    //   print(videoResult[i].title);
    // }
    setState(() {
      videoResult.addAll(moreVideos);
      _isLoadingMoreVideos = false;
    });
  }

  YoutubeAPI ytApi = YoutubeAPI(API_KEY, maxResults: 20, type: "video");

  List<YouTubeVideo> videoResult = [];

  Future<void> _ToFetchTrending() async {
    setState(() {
      _isLoadingVideos = true;
    });

    try {
      // Get the user's location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Reverse geocoding to get country details
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      // Extract country code from the placemark
      String country = placemarks.isNotEmpty
          ? placemarks[0].isoCountryCode ??
              'US' // Default to 'US' if not available
          : 'US';

      videoResult = await ytApi.getTrends(regionCode: country);
      setState(() {
        _isLoadingVideos = false;
        videoResult = videoResult;
      });
    } catch (e) {
      print('Error fetching location: $e');
      // Handle errors, e.g., default to a specific country code
      videoResult = await ytApi.getTrends(regionCode: 'US');
      setState(() {
        _isLoadingVideos = false;
        videoResult = videoResult;
      });
    }
  }

  Future _ToFetchSearch({required query}) async {
    //  var regionCode='YOUR_COUNTRY_REGION_CODE(apha-2)';
    setState(() {
      _isLoadingVideos = true;
    });
    videoResult = await ytApi.search(query, type: 'video');
    setState(() {
      _isLoadingVideos = false;
      videoResult = videoResult;
    });
    // for (var i = 0; i < videoResult.length; i++) {
    //   print(videoResult[i].duration);
    // }
    //make sure you assign alpha-2 region code
  }

  String formatDuration(String? duration) {
    if (duration == null) {
      return ''; // or any default value you want to use for null
    }

    // Check if the duration is already in "mm:ss" format
    if (duration.contains(':')) {
      return duration;
    }

    // Parse the duration string to an integer
    int seconds = int.tryParse(duration) ?? 0;

    // Calculate minutes and remaining seconds
    int minutes = (seconds / 60).floor();
    seconds %= 60;

    // Format the result as "mm:ss"
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> checkLocationPermission() async {
    // Check if the location permission is granted
    PermissionStatus status = await Permission.location.status;

    if (status.isGranted) {
      // Location permission is already granted, continue with the app
      print('Location permission granted. Continue with the app.');
      // Add your logic here to continue with the app
    } else if (status.isDenied) {
      // Location permission is denied, stop the app
      print('Location permission denied. Stopping the app.');
      // Add your logic here to stop the app or show a message to the user
    } else if (status.isPermanentlyDenied) {
      // Location permission is permanently denied, show a dialog to open app settings
      print('Location permission permanently denied. Opening app settings.');
      openAppSettings();
    } else {
      // Location permission is not determined, request it
      print('Location permission not determined. Requesting permission.');
      requestLocationPermission();
    }
  }

  Future<void> requestLocationPermission() async {
    // Request location permission
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      // Location permission granted after request, continue with the app
      print(
          'Location permission granted after request. Continue with the app.');
      // Add your logic here to continue with the app
    } else if (status.isDenied) {
      // Location permission denied after request, stop the app
      print('Location permission denied after request. Stopping the app.');
      Permission.locationAlways.request();
      Permission.location.request();
      // Add your logic here to stop the app or show a message to the user
    } else if (status.isPermanentlyDenied) {
      // Location permission permanently denied after request, show a dialog to open app settings
      print(
          'Location permission permanently denied after request. Opening app settings.');
      openAppSettings();
    }
  }

  bool isLoadingPested = true;

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      overlayColor: Colors.grey.withOpacity(0.8),
      useDefaultLoading: false,
      overlayWidgetBuilder: (_) {
        //ignored progress for the moment
        return const Center(
          child: SpinKitCubeGrid(
            color: secondaryBackGround,
            size: 50.0,
          ),
        );
      },
      child: Scaffold(
        //--- app bar
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/download');
              },
              icon: const Icon(
                Icons.file_download,
              ),
            )
          ],
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            'Swift Tube',
            style: GoogleFonts.aBeeZee(
              color: textColor1,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
          toolbarHeight: 80,
          // backgroundColor: Colors.red,
        ),

        //--- body
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                // padding: EdgeInsets.only(left: 10),
                child: TextField(
                  controller: searchTextController,
                  onSubmitted: (String value) async {
                    if (isYouTubeLink(value)) {
                      context.loaderOverlay.show();
                      searchTextController.clear();

                      setState(() {
                        isLoadingPaste = true;
                      });

                      Future<void> handlePastedLinkDownLoad({
                        required context,
                        required title,
                        required auther,
                        required url,
                        required thambnail,
                        required durationtime,
                      }) async {
                        // context.loaderOverlay.show();

                        void categorizeAndPrintResponses(dynamic responseData) {
                          audiosToDownload.clear();
                          videosToDownload.clear();
                          // Assuming responseData is a List of Maps
                          List<Map<String, dynamic>> items =
                              List<Map<String, dynamic>>.from(
                                  responseData['streams']);

                          for (Map<String, dynamic> item in items) {
                            if (item['resolution'] == null) {
                              audiosToDownload.add(item);
                            }

                            if (item['audio_res'] != null && item['mime_type'] == "video/mp4") {
                              videosToDownload.add(item);
                            }
                          }

                          // Now you have the categorized lists
                          // print('Videos to Download: ${videosToDownload}');
                        }

                        isLiadingDids = true;

                        // print(widget.url);

                        try {
                          Response response = await dio.post(
                            'https://youtube-downloder-dc5f27c2db41.herokuapp.com/api/download/',
                            options: Options(
                              headers: {
                                'Authorization': 'Bearer YourAccessToken',
                                // Add other headers if required
                              },
                            ),
                            data: {'url': url.toString()},
                          );

                          if (response.statusCode == 200) {
                            // context.loaderOverlay.hide();
                            // isLiadingDids = false;
                            Future.microtask(() {
                              showModalBottomSheet(
                                // isScrollControlled: true,
                                scrollControlDisabledMaxHeightRatio: .95,
                                isDismissible: false,
                                // anchorPoint: Offset(5, 5),
                                // useSafeArea: true,
                                context: context,
                                builder: (BuildContext context) {
                                  return BottomSheetCusom(
                                    context: context,
                                    title: title,
                                    thambnail: thambnail,
                                    auther: auther,
                                    url: url,
                                    durationtime: durationtime,
                                    isPasted: true,
                                  );
                                },
                              );
                            });

                            categorizeAndPrintResponses(response.data);
                            isGettingString = false;

                            setState(() {
                              // isUsingUrl = 0;
                              isLoadingPaste = false;
                            });
                            // setState(() {});
                            // context.loaderOverlay.hide();
                          } else {
                            // context.loaderOverlay.hide();
                            isLiadingDids = false;
                            setState(() {
                              // isUsingUrl = 0;
                              isLoadingPested = false;
                            });

                            // context.loaderOverlay.hide();

                            CustomSnackbar.showSnackbar(
                              context: context,
                              content: const Text(
                                "An Error Ocurred",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor:
                                  tatiaryBackGround, // Set your desired background color
                              duration: const Duration(
                                  seconds: 3), // Set your desired duration
                            );
                          }
                        } catch (e) {
                          CustomSnackbar.showSnackbar(
                            context: context,
                            content: const Text(
                              "An Error Ocurred",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor:
                                tatiaryBackGround, // Set your desired background color
                            duration: const Duration(
                                seconds: 3), // Set your desired duration
                          );
                          // context.loaderOverlay.hide();
                          isLiadingDids = false;
                        }
                      }

                      // operartion here
                      // isGettingString = true;

                      try {
                        Response response = await dio.post(
                            'https://youtube-downloder-dc5f27c2db41.herokuapp.com/api/download/',
                            data: {'url': _searchedVideo});
                        if (response.statusCode == 200) {
                          final requestData = response.data;
                          Future.microtask(() {
                            handlePastedLinkDownLoad(
                              context: context,
                              title: requestData['title'],
                              auther: requestData['channel_name'],
                              url: _searchedVideo,
                              thambnail: requestData['thumbnail_url'],
                              durationtime: formatDuration(
                                  requestData['duration'].toString()),
                              // to be changed
                            );
                          });
                        }
                      } catch (e) {
                        Future.microtask(() {
                          CustomSnackbar.showSnackbar(
                            context: context,
                            content: const Text(
                              "An Error Ocurred",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor:
                                tatiaryBackGround, // Set your desired background color
                            duration: const Duration(
                                seconds: 3), // Set your desired duration
                          );
                        });
                      }
                    } else {
                      _ToFetchSearch(query: value);
                      // closeKeyboard(context);
                    }

                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  },
                  onChanged: (value) {
                    setState(() {
                      _searchedVideo = value;
                    });
                  },
                  cursorColor: textColor1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 54, 54, 54),
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      padding: const EdgeInsets.all(10),
                      onPressed: () async {
                        if (isYouTubeLink(_searchedVideo)) {
                          context.loaderOverlay.show();
                          searchTextController.clear();

                          setState(() {
                            isLoadingPaste = true;
                          });

                          Future<void> handlePastedLinkDownLoad({
                            required context,
                            required title,
                            required auther,
                            required url,
                            required thambnail,
                            required durationtime,
                          }) async {
                            // context.loaderOverlay.show();

                            void categorizeAndPrintResponses(
                                dynamic responseData) {
                              audiosToDownload.clear();
                              videosToDownload.clear();
                              // Assuming responseData is a List of Maps
                              List<Map<String, dynamic>> items =
                                  List<Map<String, dynamic>>.from(
                                      responseData['streams']);

                              for (Map<String, dynamic> item in items) {
                                if (item['resolution'] == null) {
                                  audiosToDownload.add(item);
                                }

                                if (item['audio_res'] != null &&
                                    item['mime_type'] == "video/mp4") {
                                  videosToDownload.add(item);
                                }
                              }

                              // Now you have the categorized lists
                              // print('Videos to Download: ${videosToDownload}');
                            }

                            isLiadingDids = true;

                            // print(widget.url);

                            try {
                              Response response = await dio.post(
                                'https://youtube-downloder-dc5f27c2db41.herokuapp.com/api/download/',
                                options: Options(
                                  headers: {
                                    'Authorization': 'Bearer YourAccessToken',
                                    // Add other headers if required
                                  },
                                ),
                                data: {'url': url.toString()},
                              );

                              if (response.statusCode == 200) {
                                // context.loaderOverlay.hide();
                                // isLiadingDids = false;
                                Future.microtask(() {
                                  showModalBottomSheet(
                                    // isDismissible: false,
                                    // isScrollControlled: false,
                                    isDismissible: false,
                                    // isScrollControlled: true,
                                    scrollControlDisabledMaxHeightRatio: .95,
                                    // anchorPoint: Offset(5, 5),
                                    // useSafeArea: true,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return BottomSheetCusom(
                                        context: context,
                                        title: title,
                                        thambnail: thambnail,
                                        auther: auther,
                                        url: url,
                                        durationtime: durationtime,
                                        isPasted: true,
                                      );
                                    },
                                  );
                                });

                                categorizeAndPrintResponses(response.data);
                                isGettingString = false;

                                setState(() {
                                  // isUsingUrl = 0;
                                  isLoadingPaste = false;
                                });
                                // setState(() {});
                                // context.loaderOverlay.hide();
                              } else {
                                // context.loaderOverlay.hide();
                                isLiadingDids = false;
                                setState(() {
                                  // isUsingUrl = 0;
                                  isLoadingPested = false;
                                });
                                // context.loaderOverlay.hide();
                              }
                            } catch (e) {
                              // context.loaderOverlay.hide();
                              isLiadingDids = false;
                            }
                          }

                          // operartion here
                          // isGettingString = true;

                          try {
                            Response response = await dio.post(
                                'https://youtube-downloder-dc5f27c2db41.herokuapp.com/api/download/',
                                data: {'url': _searchedVideo});
                            if (response.statusCode == 200) {
                              final requestData = response.data;
                              Future.microtask(() {
                                handlePastedLinkDownLoad(
                                  context: context,
                                  title: requestData['title'],
                                  auther: requestData['channel_name'],
                                  url: _searchedVideo,
                                  thambnail: requestData['thumbnail_url'],
                                  durationtime: formatDuration(
                                      requestData['duration'].toString()),
                                  // to be changed
                                );
                              });
                            }
                          } catch (e) {
                            CustomSnackbar.showSnackbar(
                              context: context,
                              content: const Text(
                                "An Error Ocurred",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor:
                                  tatiaryBackGround, // Set your desired background color
                              duration: const Duration(
                                  seconds: 3), // Set your desired duration
                            );
                          }
                        } else {
                          _ToFetchSearch(query: _searchedVideo);
                          // closeKeyboard(context);
                        }
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                      },
                      icon: const Icon(
                        color: Color.fromARGB(255, 87, 87, 87),
                        Icons.search,
                        size: 28,
                      ),
                    ),
                    hintText: 'Search video...',
                    hintStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(255, 124, 124, 124),
                      fontSize: 16,
                    ),
                    contentPadding: const EdgeInsets.all(10),
                    filled: true,
                    fillColor: secondaryBackGround,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(100),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(100),
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // the vidosLoad
              _isLoadingVideos
                  // preloader
                  ? Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: 10,
                        itemBuilder: (BuildContext context, int i) {
                          return const _PreLoaderVideoTile();
                        },
                      ),
                    )
                  // content
                  : Expanded(
                      child: ListView.builder(
                        controller: _scrollControllerTrending,
                        shrinkWrap: true,
                        itemCount: videoResult.length,
                        itemBuilder: (BuildContext context, int i) {
                          return VideoTile(
                            context: context,
                            title: videoResult[i].title,
                            thambnail:
                                videoResult[i].thumbnail.high.url.toString(),
                            auther: videoResult[i].channelTitle.toString(),
                            url: videoResult[i].url,
                            durationtime:
                                formatDuration(videoResult[i].duration),
                          );
                        },
                      ),
                    ),
              _isLoadingMoreVideos
                  ? const Text('Loading...')
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

// class _VideoTile extends StatefulWidget {
//   @override
//   State<_VideoTile> createState() => _VideoTileState();
// }

// class _VideoTileState extends State<_VideoTile> {
//   @override
//   Widget build(BuildContext context) {

//   }
// }

class _PreLoaderVideoTile extends StatelessWidget {
  const _PreLoaderVideoTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryBackGround,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: <Widget>[
          // thambnail of the video
          Container(
            height: 130,
            decoration: const BoxDecoration(
              color: primaryBackGround,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(),
              )
              .shimmer(
                delay: const Duration(microseconds: 800),
                duration: const Duration(milliseconds: 1500),
                color: secondaryBackGround,
              ),
          const SizedBox(height: 10),
          // info and the download part
          Container(
            padding: const EdgeInsets.only(
              top: 15,
              bottom: 10,
              left: 20,
              right: 20,
            ),
            // height: 130,
            decoration: const BoxDecoration(
              color: primaryBackGround,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(7),
                bottomRight: Radius.circular(7),
                topLeft: Radius.circular(2),
                topRight: Radius.circular(2),
              ),
            ),
            child: Column(
              children: <Widget>[
                // info title, by, time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: secondaryBackGround,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: 200,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // video title
                          Text(
                            'Video Long Title here',
                            style: TextStyle(
                              color: secondaryBackGround,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // auther name
                          Text(
                            'by name of',
                            style: TextStyle(
                              color: secondaryBackGround,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate(
                          onPlay: (controller) => controller.repeat(),
                        )
                        .shimmer(
                          delay: const Duration(microseconds: 850),
                          duration: const Duration(milliseconds: 1500),
                          // color: secondaryBackGround,
                        ),
                    // time
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: secondaryBackGround,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        '4.5min',
                        style: TextStyle(
                          color: secondaryBackGround,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 10),
                // download button
                Container(
                  decoration: BoxDecoration(
                    color: secondaryBackGround,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 120),
                        alignment: const Alignment(1, 0),
                        child: const Text(
                          '',
                          style: TextStyle(
                            color: secondaryBackGround,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      // btn its selef
                      Container(
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: primaryBackGround,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.arrow_downward_rounded,
                            color: primaryBackGround,
                          ),
                        ),
                      )
                    ],
                  )
                      .animate(
                        onPlay: (controller) => controller.repeat(),
                      )
                      .shimmer(
                        delay: const Duration(microseconds: 900),
                        duration: const Duration(milliseconds: 1500),
                        // color: secondaryBackGround,
                      ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
