import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:meet/sdk/peer_connection.dart';
// import 'package:flutter_webrtc/media_stream.dart';
// import 'package:video_conferening_mobile/sdk/peer_connection.dart';

// class Connection extends PeerConnection {
//   String userId;
//   String? connectionType;
//   String name;
//   bool videoEnabled;
//   bool audioEnabled;
//   RTCVideoRenderer? renderer;

//   Connection(
//       {required this.userId,
//       this.connectionType,
//       required this.name,
//       this.audioEnabled = true,
//       this.videoEnabled = true,
//       MediaStream? stream})
//       : super(localStream: stream);

//   void toggleVideo(bool val) {
//     videoEnabled = val;
//   }

//   void toggleAudio(bool val) {
//     audioEnabled = val;
//   }
// }

class Connection extends PeerConnection {
  String userId;
  String? connectionType;
  String name;
  bool videoEnabled;
  bool audioEnabled;
  RTCVideoRenderer? renderer; // Add the renderer property

  Connection({
    required this.userId,
    this.connectionType,
    required this.name,
    this.audioEnabled = true,
    this.videoEnabled = true,
    MediaStream? stream,
  }) : super(localStream: stream) {
    // Initialize the renderer if video is enabled
    if (videoEnabled) {
      _initializeRenderer(stream);
    }
  }

  // Method to initialize the renderer
  Future<void> _initializeRenderer(MediaStream? stream) async {
    renderer = RTCVideoRenderer();
    await renderer!.initialize();
    
    if (stream != null) {
      // Attach the stream to the renderer if it's not null
      renderer!.srcObject = stream;
      print('Renderer initialized for user: $name');
    } else {
      print('Stream is null, cannot attach to renderer for user: $name');
    }
  }

  void toggleVideo(bool val) {
    videoEnabled = val;
    // Optionally handle video toggle logic here
  }

  void toggleAudio(bool val) {
    audioEnabled = val;
    // Optionally handle audio toggle logic here
  }
}
