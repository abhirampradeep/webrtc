// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:meet/pojo/meeting_detail.dart';
// import 'package:meet/screen/chat_screen.dart';
// import 'package:meet/screen/home_screen.dart';
// import 'package:meet/sdk/meeting.dart';
// import 'package:meet/sdk/message_format.dart';
// import 'package:meet/util/user.util.dart';
// import 'package:meet/widget/actions_button.dart';
// import 'package:meet/widget/control_panel.dart';
// import 'package:meet/widget/remote_video_pageview.dart';
// import 'package:permission_handler/permission_handler.dart';
// // import 'package:flutter_webrtc/get_user_media.dart';
// // import 'package:flutter_webrtc/media_stream.dart';
// // import 'package:flutter_webrtc/rtc_video_view.dart';
// // import 'package:flutter_webrtc/webrtc.dart';
// // import 'package:video_conferening_mobile/pojo/meeting_detail.dart';
// // import 'package:video_conferening_mobile/screen/chat_screen.dart';
// // import 'package:video_conferening_mobile/screen/home_screen.dart';
// // import 'package:video_conferening_mobile/sdk/meeting.dart';
// // import 'package:video_conferening_mobile/sdk/message_format.dart';
// // import 'package:video_conferening_mobile/util/user.util.dart';
// // import 'package:video_conferening_mobile/widget/actions_button.dart';
// // import 'package:video_conferening_mobile/widget/control_panel.dart';
// // import 'package:video_conferening_mobile/widget/remote_video_page_view.dart';

// enum PopUpChoiceEnum { CopyLink, CopyId }

// class PopUpChoice {
//   PopUpChoiceEnum id;
//   String title;

//   PopUpChoice(this.id, this.title);
// }

// class MeetingScreen extends StatefulWidget {
//   final String meetingId;
//   final String name;
//   final MeetingDetail meetingDetail;

//   MeetingScreen(
//       {Key? key,
//       required this.meetingId,
//       required this.name,
//       required this.meetingDetail})
//       : assert(meetingDetail != null,
//             'meetingDetail cannot be null'), // Add this line
//         super(key: key);

//   @override
//   _MeetingScreenState createState() => _MeetingScreenState();
// }

// class _MeetingScreenState extends State<MeetingScreen> {
//   bool isValidMeeting = false;
//   TextEditingController textEditingController = new TextEditingController();
//   Meeting? meeting;
//   bool isConnectionFailed = false;
//   final _localRenderer = new RTCVideoRenderer();
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//   final Map<String, dynamic> mediaConstraints = {
//     "audio": true,
//     "video": true,
// //    {
// //      "mandatory": {
// //        "minWidth":
// //            '1280', // Provide your own width, height and frame rate here
// //        "minHeight": '720',
// //        "minFrameRate": '30',
// //      },
// //      "facingMode": "user",
// //      "optional": [],
// //    }
//   };
//   final List<PopUpChoice> choices = [
//     PopUpChoice(PopUpChoiceEnum.CopyId, 'Copy Meeting ID'),
//     PopUpChoice(PopUpChoiceEnum.CopyLink, 'Copy Meeting Link'),
//   ];
//   bool isChatOpen = false;
//   List<MessageFormat> messages = [];
//   final PageController pageController = new PageController();

//   @override
//   void initState() {
//     super.initState();
//     initRenderers();
//     start();
//   }

//   @override
//   deactivate() {
//     super.deactivate();
//     _localRenderer.dispose();
//     if (meeting != null) {
//       meeting?.destroy();
//       // meeting = null;
//     }
//   }

//   initRenderers() async {
//     await _localRenderer.initialize();
//   }

//   void goToHome() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => HomeScreen(
//           title: 'Home',
//         ),
//       ),
//     );
//   }

//   void start() async {
//     var cameraStatus = await Permission.camera.request();
//     var microphoneStatus = await Permission.microphone.request();

//     if (cameraStatus.isGranted && microphoneStatus.isGranted) {
//       final String userId = await loadUserId();
//       MediaStream _localstream = await navigator.getUserMedia(mediaConstraints);
//       _localRenderer.srcObject = _localstream;
//       // _localRenderer.objectFit =
//       //     RTCVideoViewObjectFit.RTCVideoViewObjectFitContain;
//       meeting = new Meeting(
//         meetingId: widget.meetingDetail.id!,
//         stream: _localstream,
//         userId: userId,
//         name: widget.name,
//       );
//       meeting?.on('open', null, (ev, context) {
//         setState(() {
//           isConnectionFailed = false;
//         });
//       });
//       meeting?.on('connection', null, (ev, context) {
//         setState(() {
//           isConnectionFailed = false;
//         });
//       });
//       meeting?.on('user-left', null, (ev, ctx) {
//         setState(() {
//           isConnectionFailed = false;
//         });
//       });
//       meeting?.on('ended', null, (ev, ctx) {
//         meetingEndedEvent();
//       });
//       meeting?.on('connection-setting-changed', null, (ev, ctx) {
//         setState(() {
//           isConnectionFailed = false;
//         });
//       });
//       // meeting.on('message', null, (ev, ctx) {
//       //   setState(() {
//       //     isConnectionFailed = false;
//       //     messages.add(ev.eventData);
//       //   });
//       // });
//       meeting?.on('message', null, (ev, ctx) {
//         setState(() {
//           isConnectionFailed = false;

//           // Check if ev.eventData is of type MessageFormat
//           if (ev.eventData is MessageFormat) {
//             messages.add(ev.eventData as MessageFormat);
//           } else {
//             // Handle the case where the type is not MessageFormat
//             print(
//                 'Received data is not of type MessageFormat: ${ev.eventData}');
//           }
//         });
//       });

//       meeting?.on('stream-changed', null, (ev, ctx) {
//         setState(() {
//           isConnectionFailed = false;
//         });
//       });
//       meeting?.on('failed', null, (ev, ctx) {
//         final snackBar = SnackBar(content: Text('Connection Failed'));
//         // scaffoldKey.currentState.showSnackBar(snackBar);
//         print("connection failed");

//         setState(() {
//           isConnectionFailed = true;
//         });
//       });
//       meeting?.on('not-found', null, (ev, ctx) {
//         meetingEndedEvent();
//       });
//       setState(() {
//         isValidMeeting = false;
//       });
//     } else {
//       print('Camera and/or Microphone permissions denied');
//     }
//   }

//   void meetingEndedEvent() {
//     final snackBar = SnackBar(content: Text('Meeing Ended'));
//     // scaffoldKey.currentState.showSnackBar(snackBar);
//     print("meeting ended");
//     goToHome();
//   }

//   void exitClick() {
//     Navigator.of(context).pushReplacementNamed('/');
//   }

//   void onEnd() {
//     print('Meeting before ending: $meeting'); // Debugging line
//     if (meeting != null) {
//       meeting?.end();
//       goToHome();
//     }
//   }

//   void onLeave() {
//     if (meeting != null) {
//       meeting?.leave();
//       // meeting = null;
//       goToHome();
//     }
//   }

//   void onVideoToggle() {
//     if (meeting != null) {
//       setState(() {
//         meeting?.toggleVideo();
//       });
//     }
//   }

//   void onAudioToggle() {
//     if (meeting != null) {
//       setState(() {
//         meeting?.toggleAudio();
//       });
//     }
//   }

//   bool isHost() {
//     return meeting != null && widget.meetingDetail != null
//         ? meeting?.userId == widget.meetingDetail.hostId
//         : false;
//   }

//   bool isVideoEnabled() {
//     return meeting != null ? meeting!.videoEnabled : false;
//   }

//   bool isAudioEnabled() {
//     return meeting != null ? meeting!.audioEnabled : false;
//   }

//   void _select(PopUpChoice choice) async {
//     final meetingId = widget.meetingId;
//     final snackBar = SnackBar(content: Text('Copied'));
//     String text = '';
//     if (choice.id == PopUpChoiceEnum.CopyId) {
//       text = meetingId;
//     } else if (choice.id == PopUpChoiceEnum.CopyLink) {
//       text = 'https://meetx.madankumar.me/meeting/$meetingId';
//     }
//     await Clipboard.setData(ClipboardData(text: text));
//     // scaffoldKey.currentState.showSnackBar(snackBar);
//   }

//   void handleReconnect() {
//     if (meeting != null) {
//       meeting?.reconnect();
//     }
//   }

//   void handleChatToggle() {
//     setState(() {
//       isChatOpen = !isChatOpen;
//       pageController.jumpToPage(isChatOpen ? 1 : 0);
//     });
//   }

//   void handleSendMessage(String text) {
//     if (meeting != null) {
//       meeting?.sendUserMessage(text);
//       final message = MessageFormat(
//         userId: meeting?.userId,
//         text: text,
//       );
//       setState(() {
//         messages.add(message);
//       });
//     }
//   }

//   List<Widget> _buildActions() {
//     var widgets = <Widget>[
//       ActionButton(
//         text: 'Leave',
//         onPressed: onLeave,
//         // color: Colors.blue,
//       ),
//     ];
//     if (isHost()) {
//       widgets.add(
//         ElevatedButton(
//           child: Text('End'),
//           onPressed: onEnd,
//           // color: Colors.red,
//         ),
//       );
//     }
//     widgets.add(PopupMenuButton<PopUpChoice>(
//       onSelected: _select,
//       itemBuilder: (BuildContext context) {
//         return choices.map((PopUpChoice choice) {
//           return PopupMenuItem<PopUpChoice>(
//             value: choice,
//             child: Text(choice.title),
//           );
//         }).toList();
//       },
//     ));
//     return widgets;
//   }

// //   Widget _buildMeetingRoom() {
// //     print('meetingDetail: ${widget.meetingDetail}');
// // print('meetingId: ${widget.meetingId}');
// // print('name: ${widget.name}');
// // print('meeting: $meeting');

// //     print("the lenght is ");
// //     print(meeting!.connections!.length);
// //     return Stack(
// //       children: <Widget>[
// //         meeting != null && meeting?.connections != null
// //             //  &&
// //             // meeting?.connections!.isNotEmpty
// //             ? RemoteVideoPageView(
// //                 connections: meeting!.connections!,
// //               )
// //             : Center(
// //                 child: Text(
// //                   'Waiting for participants to join the meeting',
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     color: Colors.grey,
// //                     fontSize: 24.0,
// //                   ),
// //                 ),
// //               ),
// //         Positioned(
// //           bottom: 10.0,
// //           right: 0.0,
// //           child: Container(
// //             width: 150.0,
// //             height: 200.0,
// //             child: RTCVideoView(_localRenderer),
// //           ),
// //         )
// //       ],
// //     );
// //   }

//   Widget _buildMeetingRoom() {
//     print("the length is ");
//     print('meetingDetail: ${widget.meetingDetail}');
//     print('meetingId: ${widget.meetingId}');
//     print('name: ${widget.name}');
//     print('meeting: $meeting');
//     print(meeting?.connections?.length); // Use null-aware operator
//     print('meeting: $meeting');

//     print(meeting?.connections?.length ?? 0); // Use null-aware operator

//     return Stack(
//       children: <Widget>[
//         meeting != null &&
//                 meeting?.connections != null &&
//                 meeting!.connections!.isNotEmpty
//             ? RemoteVideoPageView(
//                 connections: meeting!.connections!,
//               )
//             : Center(
//                 child: Text(
//                   'Waiting for participants to join the meeting',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: 24.0,
//                   ),
//                 ),
//               ),
//         Positioned(
//           bottom: 10.0,
//           right: 0.0,
//           child: Container(
//             width: 150.0,
//             height: 200.0,
//             child: RTCVideoView(_localRenderer),
//           ),
//         )
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('hi');
//     print('hi');

//     print('hi');

//     print('hi');

//     print('hi');
//     print('hi');

//     print(widget.meetingDetail);
//     print(widget.meetingId);
//     print(widget.name);
//     return Scaffold(
//       key: scaffoldKey,
//       appBar: AppBar(
//         title: Text("MeetX"),
//         actions: _buildActions(),
//         backgroundColor: Colors.green,
//       ),
//       body: PageView(
//         physics: NeverScrollableScrollPhysics(),
//         controller: pageController,
//         children: <Widget>[
//           _buildMeetingRoom(),
//           ChatScreen(
//             messages: messages,
//             onSendMessage: handleSendMessage,
//             connections: meeting?.connections,
//             userId: meeting?.userId!,
//             userName: meeting?.name!,
//           )
//         ],
//       ),
//       bottomNavigationBar: ControlPanel(
//         onAudioToggle: onAudioToggle,
//         onVideoToggle: onVideoToggle,
//         videoEnabled: isVideoEnabled(),
//         audioEnabled: isAudioEnabled(),
//         isConnectionFailed: isConnectionFailed,
//         onReconnect: handleReconnect,
//         onChatToggle: handleChatToggle,
//         isChatOpen: isChatOpen,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:meet/pojo/meeting_detail.dart';
import 'package:meet/screen/chat_screen.dart';
import 'package:meet/screen/home_screen.dart';
import 'package:meet/sdk/meeting.dart';
import 'package:meet/sdk/message_format.dart';
import 'package:meet/util/user.util.dart';
import 'package:meet/widget/actions_button.dart';
import 'package:meet/widget/control_panel.dart';
import 'package:meet/widget/remote_video_pageview.dart';
import 'package:permission_handler/permission_handler.dart';

enum PopUpChoiceEnum { CopyLink, CopyId }

class PopUpChoice {
  final PopUpChoiceEnum id;
  final String title;

  PopUpChoice(this.id, this.title);
}

class MeetingScreen extends StatefulWidget {
  final String meetingId;
  final String name;
  final MeetingDetail meetingDetail;

  MeetingScreen({
    Key? key,
    required this.meetingId,
    required this.name,
    required this.meetingDetail,
  })  : assert(meetingDetail != null, 'meetingDetail cannot be null'),
        super(key: key);

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  bool isValidMeeting = false;
  TextEditingController textEditingController = TextEditingController();
  Meeting? meeting;
  bool isConnectionFailed = false;
  final _localRenderer = RTCVideoRenderer();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, dynamic> mediaConstraints = {
    "audio": true,
    "video": true,
  };
  final List<PopUpChoice> choices = [
    PopUpChoice(PopUpChoiceEnum.CopyId, 'Copy Meeting ID'),
    PopUpChoice(PopUpChoiceEnum.CopyLink, 'Copy Meeting Link'),
  ];
  bool isChatOpen = false;
  List<MessageFormat> messages = [];
  final PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    initRenderers();
    start();
  }

  @override
  void deactivate() {
    super.deactivate();
    _localRenderer.dispose();
    meeting?.destroy();
  }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
  }

  void goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(title: 'Home'),
      ),
    );
  }

  Future<void> start() async {
    if (await _requestPermissions()) {
      final String userId = await loadUserId();
      MediaStream localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = localStream;

      meeting = Meeting(
        meetingId: widget.meetingDetail.id!,
        stream: localStream,
        userId: userId,
        name: widget.name,
      );

      _initializeMeetingListeners();
      setState(() {
        isValidMeeting = false;
      });
    } else {
      print('Camera and/or Microphone permissions denied');
    }
  }

  Future<bool> _requestPermissions() async {
    var cameraStatus = await Permission.camera.request();
    var microphoneStatus = await Permission.microphone.request();
    return cameraStatus.isGranted && microphoneStatus.isGranted;
  }

  void _initializeMeetingListeners() {
    meeting?.on('open', null,
        (ev, context) => setState(() => isConnectionFailed = false));
    meeting?.on('connection', null,
        (ev, context) => setState(() => isConnectionFailed = false));
    meeting?.on('user-left', null,
        (ev, ctx) => setState(() => isConnectionFailed = false));
    meeting?.on('ended', null, (ev, ctx) => meetingEndedEvent());
    meeting?.on('connection-setting-changed', null,
        (ev, ctx) => setState(() => isConnectionFailed = false));
    meeting?.on('message', null, (ev, ctx) {
      if (ev.eventData is MessageFormat) {
        setState(() {
          messages.add(ev.eventData as MessageFormat);
          isConnectionFailed = false;
        });
      } else {
        print('Received data is not of type MessageFormat: ${ev.eventData}');
      }
    });
    meeting?.on('stream-changed', null,
        (ev, ctx) => setState(() => isConnectionFailed = false));
    meeting?.on('failed', null, (ev, ctx) {
      print("Connection failed");
      setState(() => isConnectionFailed = true);
    });
    meeting?.on('not-found', null, (ev, ctx) => meetingEndedEvent());
  }

  void meetingEndedEvent() {
    print("Meeting ended");
    goToHome();
  }

  void onLeave() {
    meeting?.leave();
    goToHome();
  }

  void onEnd() {
    meeting?.end();
    goToHome();
  }

  void onVideoToggle() => meeting?.toggleVideo();

  void onAudioToggle() => meeting?.toggleAudio();

  bool isHost() => meeting?.userId == widget.meetingDetail.hostId;

  bool isVideoEnabled() => meeting?.videoEnabled ?? false;

  bool isAudioEnabled() => meeting?.audioEnabled ?? false;

  Future<void> _select(PopUpChoice choice) async {
    String text = choice.id == PopUpChoiceEnum.CopyId
        ? widget.meetingId
        : 'https://192.168.10.74:8081/meeting/${widget.meetingId}';
    await Clipboard.setData(ClipboardData(text: text));
    // scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text('Copied')));
  }

  void handleReconnect() => meeting?.reconnect();

  void handleChatToggle() {
    setState(() {
      isChatOpen = !isChatOpen;
      pageController.jumpToPage(isChatOpen ? 1 : 0);
    });
  }

  void handleSendMessage(String text) {
    if (meeting != null) {
      meeting?.sendUserMessage(text);
      final message = MessageFormat(userId: meeting?.userId, text: text);
      setState(() => messages.add(message));
    }
  }

  List<Widget> _buildActions() {
    var widgets = <Widget>[
      ActionButton(
        text: 'Leave',
        onPressed: onLeave,
      ),
    ];
    if (isHost()) {
      widgets.add(
        ElevatedButton(
          child: Text('End'),
          onPressed: onEnd,
        ),
      );
    }
    widgets.add(PopupMenuButton<PopUpChoice>(
      onSelected: _select,
      itemBuilder: (BuildContext context) {
        return choices.map((PopUpChoice choice) {
          return PopupMenuItem<PopUpChoice>(
            value: choice,
            child: Text(choice.title),
          );
        }).toList();
      },
    ));
    return widgets;
  }

  // Widget _buildMeetingRoom() {
  //   print("the meeting connection length:");
  //   print(meeting?.connections?.length);
  //   return Stack(

  //     children: <Widget>[
  //       meeting != null && meeting!.connections != null && meeting!.connections!.isNotEmpty
  //           ? RemoteVideoPageView(connections: meeting!.connections!)
  //           : Center(
  //               child: Text(
  //                 'Waiting for participants to join the meeting',
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(color: Colors.grey, fontSize: 24.0),
  //               ),
  //             ),
  //       Positioned(
  //         bottom: 10.0,
  //         right: 0.0,
  //         child: Container(
  //           width: 150.0,
  //           height: 200.0,
  //           child: RTCVideoView(_localRenderer),
  //         ),
  //       )
  //     ],
  //   );
  // }

  Widget _buildMeetingRoom() {
    print('Meeting detail: ${widget.meetingDetail}');
    print('Meeting ID: ${widget.meetingId}');
    print('Name: ${widget.name}');
    print('Meeting: $meeting');

    if (meeting == null || meeting?.connections == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    print('Connection count: ${meeting!.connections!.length}');
    print('count ');
    print('count ');
    print('count ');
    print('count ');
    print('count ');
    print('count ');
    print('count ');

    print(meeting?.connections);
    return Stack(
      children: <Widget>[
        meeting!.connections!.isNotEmpty
            ? RemoteVideoPageView(
                connections: meeting!.connections!,
              )
            : Center(
                child: Text(
                  'Waiting for participants to join the meeting',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 24.0,
                  ),
                ),
              ),
        Positioned(
          bottom: 1.0,
          right: 0.0,
          child: Container(
            width: 150.0,
            height: 150.0,
            child: RTCVideoView(_localRenderer),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("MeetX"),
        actions: _buildActions(),
        backgroundColor: Colors.green,
      ),
      // body: PageView(
      //   physics: NeverScrollableScrollPhysics(),
      //   controller: pageController,
      //   children: <Widget>[
      //     _buildMeetingRoom(),
      //     ChatScreen(
      //       messages: messages,
      //       onSendMessage: handleSendMessage,
      //       connections: meeting?.connections,
      //       userId: meeting?.userId ?? '',
      //       userName: meeting?.name ?? '',
      //     )
      //   ],
      // ),
      body: Row(children: [
        Expanded(child: _buildMeetingRoom()),
        Expanded(
          child: ChatScreen(
            messages: messages,
            onSendMessage: handleSendMessage,
            connections: meeting?.connections,
            userId: meeting?.userId ?? '',
            userName: meeting?.name ?? '',
          ),
        )
      ]),
      bottomNavigationBar: ControlPanel(
        onAudioToggle: onAudioToggle,
        onVideoToggle: onVideoToggle,
        videoEnabled: isVideoEnabled(),
        audioEnabled: isAudioEnabled(),
        isConnectionFailed: isConnectionFailed,
        onReconnect: handleReconnect,
        onChatToggle: handleChatToggle,
        isChatOpen: isChatOpen,
      ),
    );
  }
}
