// import 'package:eventify/eventify.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// // import 'package:flutter_webrtc/rtc_peerconnection.dart';
// // import 'package:flutter_webrtc/rtc_peerconnection_factory.dart';
// // import 'package:flutter_webrtc/webrtc.dart';

// class PeerConnection extends EventEmitter {
//   MediaStream? localStream;
//   MediaStream? remoteStream;
//   RTCVideoRenderer? renderer = new RTCVideoRenderer();

//   RTCPeerConnection? rtcPeerConnection;

//   PeerConnection(
//       {this.localStream,
//       this.remoteStream,
//       this.renderer,
//       this.rtcPeerConnection});

//   final Map<String, dynamic> configuration = {
//     'iceServers': [
//       {
//         "urls": [
//           'stun:stun.l.google.com:19302',
//           'stun:stun1.l.google.com:19302'
//         ],
//       }
//     ]
//   };
//   final Map<String, dynamic> loopbackConstraints = {
//     "mandatory": {},
//     "optional": [
//       {"DtlsSrtpKeyAgreement": true},
//     ],
//   };

//   final Map<String, dynamic> offerSdpConstraints = {
//     "mandatory": {
//       "OfferToReceiveAudio": true,
//       "OfferToReceiveVideo": true,
//     },
//     "optional": [],
//   };

//   Future<void> start() async {
//     rtcPeerConnection =
//         await createPeerConnection(configuration, loopbackConstraints);
//     // rtcPeerConnection?.addStream(localStream!);
//     localStream?.getTracks().forEach((track) {
//       rtcPeerConnection?.addTrack(track, localStream!);
//     });
//     rtcPeerConnection?.onAddStream = _onAddStream;
//     rtcPeerConnection?.onRemoveStream = _onRemoveStream;
//     rtcPeerConnection?.onRenegotiationNeeded = _onRenegotiationNeeded;
//     rtcPeerConnection?.onIceCandidate = _onIceCandidate;
//     await renderer?.initialize();
//     this.emit('connected');
//   }

//   void _onAddStream(MediaStream stream) {
//     remoteStream = stream;
//     renderer!.srcObject = stream;
//     // renderer?.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain;
//     this.emit('stream-changed');
//   }

//   void _onRemoveStream(MediaStream stream) {
//     remoteStream = null;
//   }

//   void _onRenegotiationNeeded() {
//     print('negotiationneeded');
//     this.emit('negotiationneeded');
//   }

//   void _onIceCandidate(RTCIceCandidate candidate) {
//     if (candidate != null) {
//       this.emit('candidate', null, candidate);
//     }
//   }

//   Future<RTCSessionDescription?> createOffer() async {
//     if (rtcPeerConnection != null) {
//       try {
//         final RTCSessionDescription sdp =
//             await rtcPeerConnection!.createOffer(offerSdpConstraints);
//         await rtcPeerConnection!.setLocalDescription(sdp);
//         return sdp;
//       } catch (error) {
//         print(error);
//       }
//     }
//     return null;
//   }

//   Future<void> setOfferSdp(RTCSessionDescription sdp) async {
//     if (rtcPeerConnection != null) {
//       await rtcPeerConnection?.setRemoteDescription(sdp);
//     }
//   }

//   Future<RTCSessionDescription?> createAnswer() async {
//     if (rtcPeerConnection != null) {
//       final RTCSessionDescription sdp =
//           await rtcPeerConnection!.createAnswer(offerSdpConstraints);
//       await rtcPeerConnection!.setLocalDescription(sdp);
//       return sdp;
//     }
//     return null;
//   }

//   Future<void> setAnswerSdp(RTCSessionDescription sdp) async {
//     if (rtcPeerConnection != null) {
//       await rtcPeerConnection!.setRemoteDescription(sdp);
//     }
//   }

//   Future<void> setCandidate(RTCIceCandidate candidate) async {
//     if (rtcPeerConnection != null) {
//       await rtcPeerConnection!.addCandidate(candidate);
//     }
//   }

//   void close() {
//     if (rtcPeerConnection != null) {
//       rtcPeerConnection!.close();
//       rtcPeerConnection = null;
//     }
//     renderer!.dispose();
//     localStream = null;
//     remoteStream = null;
//   }
// }

import 'package:eventify/eventify.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class PeerConnection extends EventEmitter {
  MediaStream? localStream;
  MediaStream? remoteStream;
  RTCVideoRenderer? renderer = new RTCVideoRenderer();

  RTCPeerConnection? rtcPeerConnection;

  PeerConnection(
      {this.localStream,
      this.remoteStream,
      this.renderer,
      this.rtcPeerConnection});

  final Map<String, dynamic> configuration = {
    'iceServers': [
      {
        "urls": [
          'stun:stun.l.google.com:19302',
          'stun:stun1.l.google.com:19302'
        ],
      }
    ]
  };
  final Map<String, dynamic> loopbackConstraints = {
    "mandatory": {},
    "optional": [
      {"DtlsSrtpKeyAgreement": true},
    ],
  };

  final Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true,
    },
    "optional": [],
  };

  Future<void> start() async {
    rtcPeerConnection =
        await createPeerConnection(configuration, loopbackConstraints);

    // Use addTrack instead of addStream
    localStream?.getTracks().forEach((track) {
      rtcPeerConnection?.addTrack(track, localStream!);
    });

    // Replace onAddStream with onTrack for handling remote stream
    rtcPeerConnection?.onTrack = _onTrack;
    rtcPeerConnection?.onRemoveTrack =
        (MediaStream stream, MediaStreamTrack track) {
      _onRemoveTrack(stream, track);
    };
    rtcPeerConnection?.onRenegotiationNeeded = _onRenegotiationNeeded;
    rtcPeerConnection?.onIceCandidate = _onIceCandidate;
    await renderer?.initialize();
    this.emit('connected');
  }

  // Handle track added (remote track event)
  void _onTrack(RTCTrackEvent event) {
    if (event.streams.isNotEmpty) {
      remoteStream = event.streams[0];
      renderer!.srcObject = remoteStream;
      this.emit('stream-changed');
    }
  }

  // void _onRemoveTrack(RTCTrackEvent event) {
  //   if (remoteStream != null) {
  //     // Cleanup remote stream
  //     remoteStream = null;
  //   }
  // }
  void _onRemoveTrack(MediaStream stream, MediaStreamTrack track) {
    if (remoteStream != null && remoteStream == stream) {
      remoteStream?.removeTrack(track);
      if (remoteStream!.getTracks().isEmpty) {
        remoteStream = null; // If there are no tracks left, clear the stream
      }
      this.emit('stream-removed');
    }
  }

  void _onRenegotiationNeeded() {
    print('negotiationneeded');
    this.emit('negotiationneeded');
  }

  void _onIceCandidate(RTCIceCandidate candidate) {
    if (candidate != null) {
      this.emit('candidate', null, candidate);
    }
  }

  Future<RTCSessionDescription?> createOffer() async {
    if (rtcPeerConnection != null) {
      try {
        final RTCSessionDescription sdp =
            await rtcPeerConnection!.createOffer(offerSdpConstraints);
        await rtcPeerConnection!.setLocalDescription(sdp);
        return sdp;
      } catch (error) {
        print(error);
      }
    }
    return null;
  }

  Future<void> setOfferSdp(RTCSessionDescription sdp) async {
    if (rtcPeerConnection != null) {
      await rtcPeerConnection?.setRemoteDescription(sdp);
    }
  }

  Future<RTCSessionDescription?> createAnswer() async {
    if (rtcPeerConnection != null) {
      final RTCSessionDescription sdp =
          await rtcPeerConnection!.createAnswer(offerSdpConstraints);
      await rtcPeerConnection!.setLocalDescription(sdp);
      return sdp;
    }
    return null;
  }

  Future<void> setAnswerSdp(RTCSessionDescription sdp) async {
    if (rtcPeerConnection != null) {
      await rtcPeerConnection!.setRemoteDescription(sdp);
    }
  }

  Future<void> setCandidate(RTCIceCandidate candidate) async {
    if (rtcPeerConnection != null) {
      await rtcPeerConnection!.addCandidate(candidate);
    }
  }

  void close() {
    if (rtcPeerConnection != null) {
      rtcPeerConnection!.close();
      rtcPeerConnection = null;
    }
    renderer!.dispose();
    localStream = null;
    remoteStream = null;
  }
}
