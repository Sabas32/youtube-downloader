// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';

class FullScreenLoader extends StatefulWidget {
  // const FullScreenLoader({super.key});
  final dynamic overlayColor;
  final dynamic loaderColor;
  const FullScreenLoader({
    Key? key,
    required this.overlayColor,
    required this.loaderColor,
  }) : super(key: key);

  @override
  State<FullScreenLoader> createState() => _FullScreenLoaderState();
}

class _FullScreenLoaderState extends State<FullScreenLoader> {
  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      overlayColor: widget.overlayColor,
      useDefaultLoading: false,
      overlayWidgetBuilder: (_) {
        //ignored progress for the moment
        return Center(
          child: SpinKitCubeGrid(
            // color: Colors.grey.withOpacity(0.8),
            color: widget.loaderColor,
            size: 50.0,
          ),
        );
      },
      child: const Test(),
    );
  }
}

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    context.loaderOverlay.show();

    return const Scaffold();
  }
}
