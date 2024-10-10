import 'package:flutter/material.dart';
import 'package:meet/sdk/connection.dart';
import 'package:meet/widget/remote_connection.dart';
// import 'package:flutter_webrtc/rtc_video_view.dart';
// import 'package:video_conferening_mobile/sdk/connection.dart';
// import 'package:video_conferening_mobile/widget/remote_connection.dart';

class RemoteVideoPageView extends StatefulWidget {
  final List<Connection> connections;

  RemoteVideoPageView({required this.connections});

  @override
  State createState() => _RemoteVideoPageViewState();
}

class _RemoteVideoPageViewState extends State<RemoteVideoPageView> {
  Widget _buildRemoteViewPage(int start) {
    var widgets = <Widget>[];
    var end = start + 2;
    var length = widget.connections.length;
    // widget.connections
    //     .sublist(start, end <= length ? end : length)
    //     .forEach((connection) {
    //   widgets.add(RemoteConnection(
    //     renderer: connection.renderer,
    //     connection: connection,
    //   ));
    // });
    print('connection count widget');
    print('connection count widget');
    print('connection count widget');
    print('connection count widget');
    print('connection count widget');
    print('connection count widget');
    print('connection count widget');
    print('connection count widget');

    print(widget.connections.length);

    // Safely sublist the connections
    widget.connections
        .sublist(start, end <= length ? end : length)
        .forEach((connection) {
      print('Connection: ${connection.name}');
      print('Connection: ${connection.renderer}');

      if (connection.renderer != null) {
        print(" video available");
        print("no video available");
        print("no video available");
        print("no video available");
        print("no video available");

        widgets.add(RemoteConnection(
          renderer: connection.renderer!,
          connection: connection,
        ));
      } else {
        print("no video available");
        print("no video available");
        print("no video available");
        print("no video available");
        print("no video available");

        print('Renderer is null');
        widgets.add(Center(child: Text('No video available')));
      }
    });

    print('Connection count: ${widget.connections.length}');

    return Container(
      child: Center(
        child: OrientationBuilder(builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: widgets,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: widgets,
                );
        }),
      ),
    );
  }

  List<Widget> _buildRemoteViewPages() {
    var widgets = <Widget>[];
    for (int start = 0; start < widget.connections.length; start = start + 2) {
      widgets.add(_buildRemoteViewPage(start));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: _buildRemoteViewPages(),
    );
  }
}
