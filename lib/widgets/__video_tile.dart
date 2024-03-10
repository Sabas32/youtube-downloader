// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:youtube_downloder_final/constants/constants.dart';

// Widget VideoTile({
//   required BuildContext context,
//   required String? title,
//   required String? thambnail,
//   required String? auther,
//   required String url,
//   required String? durationtime,
// }) {
//   return VideoTile();
// }

class VideoTile extends StatefulWidget {
  final BuildContext context;

  final String title;
  final String thambnail;
  final String auther;
  final String url;
  final String durationtime;
  const VideoTile({
    Key? key,
    required this.context,
    required this.title,
    required this.thambnail,
    required this.auther,
    required this.url,
    required this.durationtime,
  }) : super(key: key);

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  @override
  Widget build(BuildContext context) {
    if (isLoadingPaste == true) {
      context.loaderOverlay.show();
    } else {
      context.loaderOverlay.hide();
    }

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
            decoration: BoxDecoration(
              color: primaryBackGround,
              image: DecorationImage(
                image: NetworkImage(widget.thambnail),
                fit: BoxFit.cover,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // video title
                        SizedBox(
                          width: 220,
                          child: Text(
                            truncateString(widget.title, 40),
                            style: const TextStyle(
                              color: textColor1,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // auther name
                        Text(
                          widget.auther,
                          style: const TextStyle(
                            color: textColor1,
                            fontWeight: FontWeight.w300,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    // time
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: secondaryBackGround,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.durationtime,
                        style: const TextStyle(
                          color: textColor1,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                // download button
                Container(
                  // height: 40,
                  decoration: BoxDecoration(
                    color: secondaryBackGround,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Download',
                          style: TextStyle(
                            color: textColor1,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // btn its selef
                      Container(
                        padding: const EdgeInsets.all(0),
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: primaryBackGround,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            context.loaderOverlay.show();

                            void categorizeAndPrintResponses(
                                dynamic responseData) {
                              audiosToDownload.clear();
                              videosToDownload.clear();
                              // Assuming responseData is a List of Maps
                              List<Map<String, dynamic>> items =
                                  List<Map<String, dynamic>>.from(
                                responseData['streams'],
                              );

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

                            Dio dio = Dio();

                            isLiadingDids = true;

                            try {
                              Response response = await dio.post(
                                'https://youtube-downloder-dc5f27c2db41.herokuapp.com/api/download/',
                                options: Options(
                                  headers: {
                                    'Authorization': 'Bearer YourAccessToken',
                                    // Add other headers if required
                                  },
                                ),
                                data: {'url': widget.url.toString()},
                              );

                              if (response.statusCode == 200) {
                                Future.microtask(() {
                                  context.loaderOverlay.hide();
                                });
                                isLiadingDids = false;
                                Future.microtask(() {
                                  showModalBottomSheet(
                                    // isScrollControlled: true,
                                    isDismissible: false,
                                    scrollControlDisabledMaxHeightRatio: .95,
                                    // anchorPoint: Offset(5, 5),
                                    // useSafeArea: true,
                                    context: widget.context,
                                    builder: (BuildContext context) {
                                      return BottomSheetCusom(
                                        context: context,
                                        title: widget.title,
                                        thambnail: widget.thambnail,
                                        auther: widget.auther,
                                        url: widget.url,
                                        durationtime: widget.durationtime,
                                        isPasted: false,
                                      );
                                    },
                                  );
                                });
                                categorizeAndPrintResponses(response.data);
                              } else {
                                Future.microtask(() {
                                  context.loaderOverlay.hide();
                                });
                                isLiadingDids = false;
                              }
                            } catch (e) {
                              isLiadingDids = false;
                              Future.microtask(() {
                                context.loaderOverlay.hide();
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
                          },
                          icon: const Icon(
                            Icons.arrow_downward_rounded,
                          ),
                        ),
                      ),
                    ],
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

// Widget _ButtonChoose({
//   required grapic,
//   required chosenInfo,
//   required videoName,
//   required autherName,
//   required mediaType,
// }) {
//   return _ButtonChoose();
// }

// class _ButtonChoose extends StatefulWidget {
//   final String? grapic;
//   final dynamic chosenInfo;
//   final String? videoName;
//   final String? autherName;
//   final String? mediaType;
//   const _ButtonChoose({
//     Key? key,
//     this.grapic,
//     this.chosenInfo,
//     this.videoName,
//     this.autherName,
//     this.mediaType,
//   }) : super(key: key);

//   @override
//   State<_ButtonChoose> createState() => _ButtonChooseState();
// }

void showDownloadCompleteSnackbar(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Download completed!'),
      duration: Duration(seconds: 5),
    ),
  );
}

// class _ButtonChooseState extends State<_ButtonChoose> {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         // var root = Directory('/storage/emulated/0/Download/youtube_downloader');
//         // String directoryPathAudio = '${root.path}/Audio';
//         var savePath =
//             '/storage/emulated/0/Download/youtube_downloader/${widget.mediaType}';
//         print(
//           "$savePath/${widget.autherName}-${widget.grapic}.${widget.mediaType == 'Audio' ? 'mp3' : 'mp4'}",
//         );
//         print(
//           widget.chosenInfo['url'].toString(),
//         );
//         Dio().download(
//           widget.chosenInfo['url'].toString(),
//           "$savePath/${widget.autherName}-${widget.grapic}.${widget.mediaType == 'Audio' ? 'mp3' : 'mp4'}",
//           onReceiveProgress: (count, total) {
//             if (count != total) {
//               setState(() {
//                 downloadParcent = (count / total * 100).toInt();
//                 print(downloadParcent);
//                 // isDownloading = true;
//               });
//             } else if (count == total) {
//               setState(() {
//                 // isDownloading = false;
//                 downloadParcent = 100;
//                 showDownloadCompleteSnackbar();
//               });
//             }
//           },
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.only(
//           bottom: 5,
//         ),
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: secondaryBackGround,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           children: [
//             const Icon(Icons.file_download_outlined),
//             Text(
//               widget.grapic!,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w400,
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// Widget BottomSheetCusom({
//   required BuildContext context,
//   required String title,
//   required String thambnail,
//   required String auther,
//   required String url,
//   required String durationtime,
// }) {
//   return BottomSheetCusom();
// }

// ignore: must_be_immutable
class BottomSheetCusom extends StatefulWidget {
  final BuildContext context;
  final String title;
  final String thambnail;
  final String auther;
  final String url;
  final String durationtime;
  bool isPasted = false;
  BottomSheetCusom({
    Key? key,
    required this.context,
    required this.title,
    required this.thambnail,
    required this.auther,
    required this.url,
    required this.durationtime,
    required this.isPasted,
  }) : super(key: key);

  @override
  State<BottomSheetCusom> createState() => BottomSheetCusomState();
}

void showDownloadInProgressPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Download in Progress',
          style: TextStyle(fontSize: 18),
        ),
        content: const Text('A download is already in progress.',
            style: TextStyle(fontSize: 14)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK', style: TextStyle(color: textColor1)),
          ),
        ],
      );
    },
  );
}

class BottomSheetCusomState extends State<BottomSheetCusom> {
  int downloadParcent = 0;
  bool isDownloading = false;
  @override
  Widget build(BuildContext context) {
    // print(formatDuration(int.parse(widget.durationtime)));
    context.loaderOverlay.hide();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        // color: Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      width: double.infinity,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          // video thumbnail

          Container(
            height: 200,
            // margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: secondaryBackGround,
              image: DecorationImage(
                image: NetworkImage(widget.thambnail),
                fit: BoxFit.cover,
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
          ),

          // this is the title
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: textColor1,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        // color: secondaryBackGround,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        widget.auther,
                        style: const TextStyle(
                          color: textColor1,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: secondaryBackGround,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        // ignore: unnecessary_null_comparison
                        widget.isPasted != null
                            ? '${widget.isPasted ? widget.durationtime : widget.durationtime} min'
                            : 'N/A',
                        style: const TextStyle(
                          color: textColor1,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // choose title
          Container(
            padding: const EdgeInsets.all(10),
            child: const Column(
              children: [
                Text(
                  'Choose audio or video',
                  style: TextStyle(
                    color: textColor1,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '(Choose the resolution or quality you need)',
                  style: TextStyle(
                    color: textColor1,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // download options
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 7,

                // color: Colors.red,
                child: Container(
                  margin: const EdgeInsets.only(left: 0),
                  child: Column(
                    children: <Widget>[
                      const Text(
                        'Audio',
                        style: TextStyle(
                          color: textColor1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: audiosToDownload.length,
                        itemBuilder: (BuildContext context, int i) {
                          return GestureDetector(
                            onTap: () {
                              createFolders();
                              // var root = Directory('/storage/emulated/0/Download/youtube_downloader');
                              // String directoryPathAudio = '${root.path}/Audio';
                              var savePath =
                                  '/storage/emulated/0/Download/youtube_downloader';

                              Dio().download(
                                audiosToDownload[i]['url'].toString(),
                                "$savePath/Audio/${removeSpacesAndReplaceWithUnderscores(widget.title)}-${removeSpacesAndReplaceWithUnderscores(widget.auther)}-${removeSpacesAndReplaceWithUnderscores(audiosToDownload[i]['audio_res'])}.${'mp3'}",

                                // '$savePath/Audio/NSG_-_Daily_Duppy__GRM_Daily
                                // -GRM_Daily-70kbps.mp3',

                                onReceiveProgress: (count, total) {
                                  if (count != total) {
                                    setState(() {
                                      downloadParcent =
                                          (count / total * 100).toInt();
                                      isDownloading = true;
                                    });
                                  } else if (count == total) {
                                    setState(() {
                                      isDownloading = false;
                                      downloadParcent = 100;
                                      Navigator.pop(context);
                                      showDownloadCompleteSnackbar(context);
                                      context.loaderOverlay.hide();
                                    });
                                  }
                                },
                                // ignore: body_might_complete_normally_catch_error
                              ).catchError((error) {
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
                                // Handle error appropriately
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                bottom: 5,
                              ),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: secondaryBackGround,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.file_download_outlined,
                                        size: 16,
                                      ),
                                      Text(
                                        audiosToDownload[i]['audio_res'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        formatBytes(audiosToDownload[i]['size'])
                                            .toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // ListView.builder(
                      //   shrinkWrap: true,
                      //   itemCount: audiosToDownload.length,
                      //   itemBuilder: (BuildContext context, int i) {
                      //     return _ButtonChoose(
                      //       mediaType: "Audio",
                      //       autherName: widget.auther,
                      //       videoName: widget.title,
                      //       grapic: audiosToDownload[i]['audio_res'],
                      //       chosenInfo: audiosToDownload[i],
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 2.5,
                  // height: double.infinity,
                  color: secondaryBackGround,
                ),
              ),
              Expanded(
                flex: 7,
                // color: Colors.red,
                child: Column(
                  children: <Widget>[
                    const Text(
                      'Video',
                      style: TextStyle(
                        color: textColor1,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: videosToDownload.length,
                      itemBuilder: (BuildContext context, int i) {
                        return GestureDetector(
                          onTap: () {
                            // ScaffoldMessenger.of(context)
                            //     .showSnackBar(SnackBar(
                            //   content: Text('SnackBar Message'),
                            // ));

                            if (isDownloading == false) {
                              var savePath =
                                  '/storage/emulated/0/Download/youtube_downloader';

                              Dio().download(
                                videosToDownload[i]['url'].toString(),
                                "$savePath/Video/${removeSpacesAndReplaceWithUnderscores(widget.title)}-${removeSpacesAndReplaceWithUnderscores(widget.auther)}-${removeSpacesAndReplaceWithUnderscores(videosToDownload[i]['resolution'])}.${'mp4'}",
                                onReceiveProgress: (count, total) {
                                  if (count != total) {
                                    setState(() {
                                      downloadParcent =
                                          (count / total * 100).toInt();
                                      context.loaderOverlay.hide();
                                      isDownloading = true;
                                    });
                                  } else if (count == total) {
                                    setState(() {
                                      isDownloading = false;
                                      downloadParcent = 100;
                                      Navigator.pop(context);
                                      showDownloadCompleteSnackbar(context);
                                      context.loaderOverlay.hide();
                                    });
                                  }
                                },
                              );
                            } else {
                              Navigator.pop(context);
                              showDownloadInProgressPopup(context);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 5,
                            ),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: secondaryBackGround,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.file_download_outlined,
                                      size: 16,
                                    ),
                                    Text(
                                      videosToDownload[i]['resolution'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      formatBytes(videosToDownload[i]['size'])
                                          .toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // ListView.builder(
                    //   shrinkWrap: true,
                    //   itemCount: videosToDownload.length,
                    //   itemBuilder: (BuildContext context, int i) {
                    //     return _ButtonChoose(
                    //       mediaType: 'Video',
                    //       autherName: widget.auther,
                    //       videoName: widget.title,
                    //       grapic: videosToDownload[i]['resolution'],
                    //       chosenInfo: videosToDownload[i],
                    //     );
                    //   },
                    // ),
                    // Column(
                    //   children: <Widget>[
                    //     _ButtonChoose(),
                    //     _ButtonChoose(),
                    //     _ButtonChoose(),
                    //   ],
                    // )
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          // Text(justTets.toString()),

          isDownloading
              ? Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Downloading...'),
                          Text('${downloadParcent.toString()}%')
                        ],
                      ),
                    ),
                    LinearProgressIndicator(
                      value: downloadParcent.toDouble() / 100,
                      color: tatiaryBackGround,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        tatiaryBackGround,
                      ),
                    ),
                  ],
                )
              : const SizedBox(),

          GestureDetector(
            onTap: () {
              if (isDownloading == false) {
                Navigator.pop(context);
                // showDownloadCompleteSnackbar(context);

                context.loaderOverlay.hide();
              } else {
                showDownloadInProgressPopup(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: secondaryBackGround,
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontSize: 18,
                  color: textColor1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
