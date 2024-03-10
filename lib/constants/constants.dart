// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:youtube_downloder_final/widgets/__video_tile.dart';

const textColor1 = Color.fromRGBO(26, 26, 26, 1);
const primaryBackGround = Color.fromRGBO(255, 255, 255, 1);
const secondaryBackGround = Color.fromRGBO(231, 231, 231, 1);
const tatiaryBackGround = Color.fromRGBO(255, 0, 0, 1);
const iconsColor = Color.fromRGBO(134, 134, 134, 1);

organizeListDescending(List<int> numbers) {
  numbers.sort((a, b) => b.compareTo(a));
}

//  double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

// initaliseDio
Dio dio = Dio();
//
// ignore: non_constant_identifier_names
String API_KEY = 'AIzaSyAhh-JrFi-G3Mv3269JD10Ai1GEt4LW4WA';

void closeKeyboard(BuildContext context) {
  // Use FocusScope to find the current FocusNode and unfocus it
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
}

// format seconds
String formatDuration(int seconds) {
  int minutes = (seconds / 60).floor();
  int remainingSeconds = seconds % 60;
  String minutesStr = minutes.toString().padLeft(2, '0');
  String secondsStr = remainingSeconds.toString().padLeft(2, '0');
  return '$minutesStr:$secondsStr';
}

bool isLoadingPaste = false;

class NavigationService {
  static bool _isNavigationEnabled = true;

  static bool get isNavigationEnabled => _isNavigationEnabled;

  static void disableNavigation() {
    _isNavigationEnabled = false;
  }

  static void enableNavigation() {
    _isNavigationEnabled = true;
  }
}

// to check if text is youtube link
bool isYouTubeLink(String url) {
  // Regular expression to match various video URLs including YouTube Shorts
  RegExp regExp = RegExp(
    r'^https?:\/\/(?:www\.)?youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=|shorts\/)|youtu\.be\/([\w\-]{11})|(?:www\.)?twitch\.tv\/videos\/(\d+)|(?:www\.)?facebook\.com\/.*\/videos\/(\d+)|www\.tiktok\.com\/.*\/video\/(\d+)|www\.tiktok\.com\/.*\/v\/(\d+)$',
    caseSensitive: false,
  );

  return regExp.hasMatch(url);
}

bool isGettingString = true;
Future<void> handlePastedLink(context, {required String url}) async {
  // operartion here
  isGettingString = true;
  try {
    Response response = await dio.post(
        'https://youtube-downloder-dc5f27c2db41.herokuapp.com/api/download/',
        data: {'url': url});
    if (response.statusCode == 200) {
      final requestData = response.data;
      handlePastedLinkDownLoad(
        context: context,
        title: requestData['title'],
        auther: requestData['channel_name'],
        url: url,
        thambnail: requestData['thumbnail_url'],
        durationtime: formatDuration(requestData['duration']).toString(),
      );
    }
  } catch (e) {
    CustomSnackbar.showSnackbar(
      context: context,
      content: const Text(
        "An Error Ocurred",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: tatiaryBackGround, // Set your desired background color
      duration: const Duration(seconds: 3), // Set your desired duration
    );
  }
}

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
        List<Map<String, dynamic>>.from(responseData['streams']);

    for (Map<String, dynamic> item in items) {
      if (item['resolution'] == null) {
        audiosToDownload.add(item);
        // organizeListDescending(audiosToDownload);
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
      isLiadingDids = false;
      Future.microtask(() {
        showModalBottomSheet(
          // isScrollControlled: true,
          isDismissible: false,
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
              durationtime: durationtime.toString(),
              isPasted: false,
            );
          },
        );
      });
      categorizeAndPrintResponses(response.data);
      isGettingString = false;
    } else {
      // context.loaderOverlay.hide();
      isLiadingDids = false;
    }
  } catch (e) {
    // context.loaderOverlay.hide();
    isLiadingDids = false;
  }
}

// replace in string _ and |
String removeSpacesAndReplaceWithUnderscores(String inputString) {
  return inputString
      .replaceAll(' ', '_')
      .replaceAll('|', '')
      .replaceAll('?', '')
      .replaceAll('#', '')
      .replaceAll('{', '-')
      .replaceAll('}', '-')
      .replaceAll('[', '-')
      .replaceAll(']', '-')
      .replaceAll('<', '-')
      .replaceAll('>', '-')
      .replaceAll('/', '');
}

// to trancate the string
String truncateString(String input, int maxLength) {
  if (input.length <= maxLength) {
    // If the string is already shorter than or equal to maxLength, no truncation needed
    return input;
  } else {
    // Truncate the string and append three dots
    return '${input.substring(0, maxLength - 3)}...';
  }
}

List<Map<String, dynamic>> videosToDownload = [];
List<Map<String, dynamic>> audiosToDownload = [];
bool isLiadingDids = false;

Future<void> myrequestForPermission() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo;
  try {
    androidInfo = await deviceInfo.androidInfo;
    if (int.parse(androidInfo.version.release) >= 11) {
      var status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        createFolders();
        // await createFolders(); // No need to pass context here
      } else if (status.isDenied) {
        // Permission still not granted, keep asking
        Permission.manageExternalStorage.request();
      }
    } else {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        createFolders();
        // await createFolders(); // No need to pass context here
      } else if (status.isDenied) {
        // Permission still not granted, keep asking
        Permission.storage.request();
      }
    }
  } catch (e) {
    // CustomSnackbar.showSnackbar(
    //   context: context,
    //   content: const Text(
    //     "An Error Ocurred",
    //     style: TextStyle(color: Colors.white),
    //   ),
    //   backgroundColor: tatiaryBackGround, // Set your desired background color
    //   duration: const Duration(seconds: 3), // Set your desired duration
    // );
  }
}

Future<void> createFolders() async {
  var root = Directory('/storage/emulated/0/Download/youtube_downloader');
  String directoryPathAudio = '${root.path}/Audio';
  String directoryPathVideo = '${root.path}/Video';

  // Check if the directory already exists
  if (!(await Directory(directoryPathAudio).exists())) {
    // If not, create the directory
    await Directory(directoryPathAudio).create(recursive: true);
  } else {}
  // Check if the directory already exists
  if (!(await Directory(directoryPathVideo).exists())) {
    // If not, create the directory
    await Directory(directoryPathVideo).create(recursive: true);
  } else {}

  // Continue with your application logic...
}

Future<List<String>> getDownloadedItems(String folderPath) async {
  Directory directory = Directory(folderPath);
  List<FileSystemEntity> files = directory.listSync();

  // Extract file names from the list of files
  List<String> fileNames =
      files.map((file) => file.uri.pathSegments.last).toList();

  return fileNames;
}

class DownloadedItemsWidget extends StatelessWidget {
  final String folderPath;

  const DownloadedItemsWidget({super.key, required this.folderPath});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: getDownloadedItems(folderPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No downloaded items found.');
        } else {
          List<String> downloadedItems = snapshot.data!;
          return ListView.builder(
            itemCount: downloadedItems.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(downloadedItems[index]),
                // Add other details or actions as needed
              );
            },
          );
        }
      },
    );
  }
}

class CustBackButton extends StatelessWidget {
  final double? size;
  const CustBackButton({
    Key? key,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(
        Icons.arrow_back_rounded,
        size: size,
      ),
    );
  }
}

class CustomSnackbar {
  static void showSnackbar({
    required BuildContext context,
    required Widget content,
    Color backgroundColor = Colors.black,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: content,
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }
}

// convert mbs/gbs/kbs
String formatBytes(int bytes) {
  const int kb = 1024;
  const int mb = kb * 1024;
  const int gb = mb * 1024;

  if (bytes >= gb) {
    return '${(bytes / gb).toStringAsFixed(2)} GB';
  } else if (bytes >= mb) {
    return '${(bytes / mb).toStringAsFixed(2)} MB';
  } else if (bytes >= kb) {
    return '${(bytes / kb).toStringAsFixed(2)} KB';
  } else {
    return '$bytes Bytes';
  }
}
