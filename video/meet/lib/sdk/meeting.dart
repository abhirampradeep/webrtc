import 'dart:convert';

import 'package:eventify/eventify.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:meet/sdk/connection.dart';
import 'package:meet/sdk/message_format.dart';
import 'package:meet/sdk/message_payload.dart';
import 'package:meet/sdk/payload_data.dart';
import 'package:meet/sdk/transport.dart';
// import 'package:flutter_webrtc/media_stream.dart';
// import 'package:flutter_webrtc/rtc_ice_candidate.dart';
// import 'package:flutter_webrtc/rtc_session_description.dart';
// import 'package:video_conferening_mobile/sdk/connection.dart';
// import 'package:video_conferening_mobile/sdk/message_format.dart';
// import 'package:video_conferening_mobile/sdk/message_payload.dart';
// import 'package:video_conferening_mobile/sdk/payload_data.dart';
// import 'package:video_conferening_mobile/sdk/transport.dart';

class Meeting extends EventEmitter {
  // final String url = 'wss://api.meetx.madankumar.me/websocket/meeting';
  final String url = 'ws://192.168.10.74:8081/websocket/meeting';
  Transport? transport;
  String meetingId;
  // List<Connection> connections = new List();
  List<Connection>? connections;

  bool joined;
  bool connected;
  MediaStream? stream;
  String? userId;
  String? name;
  // List<MessageFormat> messages = new List();
  List<MessageFormat>? messages;

  bool videoEnabled;
  bool audioEnabled;

  Meeting({
    required this.meetingId,
    this.userId,
    this.name,
    this.stream,
    this.joined = false,
    this.connected = false,
    this.audioEnabled = true,
    this.videoEnabled = true,
    List<Connection>? connections,
    List<MessageFormat>? messages,
    this.transport,
  })  : this.connections = connections ?? [],
        this.messages = messages ?? [] {
    this.transport = new Transport(
      url: formatUrl(this.meetingId),
      maxRetryCount: 3,
      canReconnect: true,
    );
    this.listenMessage();
  }

  String formatUrl(String id) {
    return '$url?id=$id';
  }

  MessagePayload parseMessage(dynamic data) {
    try {
      return MessagePayload.fromJson(json.decode(data));
    } catch (error) {
      return MessagePayload(type: 'unknown');
    }
  }

  void sendMessage(String type, dynamic data) {
    try {
      final String payload = json.encode({'type': type, 'data': data});
      if (transport != null) {
        transport!.send(payload);
      }
    } catch (error) {
      print(error);
    }
  }

  void listenMessage() {
    if (transport != null) {
      transport!.on('open', null, (ev, context) {
        connected = true;
        print(ev.eventName);
        join();
      });
      transport!.on('message', null, (ev, context) {
        print(ev.eventData);
        final payload = parseMessage(ev.eventData);
        handleMessage(payload);
      });
      transport!.on('closed', null, (ev, context) {
        connected = false;
      });
      transport!.on('failed', null, (ev, context) {
        this.reset();
        this.emit('failed');
      });
      transport!.connect();
    }
  }

  // Connection getConnection(String userId) {
  //   return connections!.firstWhere((connection) => connection.userId == userId,
  //       orElse: () => null);
  // }
  Connection? getConnection(String userId) {
    return connections!.firstWhere(
      (connection) => connection.userId == userId,
      orElse: () => Connection(
          userId: '',
          name: 'name'), // This is fine now since the return type is nullable
    );
  }

  Future<Connection?> createConnection(UserJoinedData data) async {
    if (stream != null) {
      print('Creating connection for user: ${data.name}');
      final connection = new Connection(
        connectionType: 'incoming',
        userId: data.userId!,
        name: data.name!,
        stream: stream,
        audioEnabled: data.config!.audioEnabled,
        videoEnabled: data.config!.videoEnabled,
      );
      connection.on('connected', null, (ev, context) {
        print('rtp connected');
      });
      // connection.on('candidate', null, (ev, context) {
      //   sendIceCandidate(connection.userId, ev.eventData);
      // });
      connection.on('candidate', null, (ev, context) {
        // Check if ev.eventData is of type RTCIceCandidate
        if (ev.eventData is RTCIceCandidate) {
          sendIceCandidate(connection.userId, ev.eventData as RTCIceCandidate);
        } else {
          // Handle the case where the data is not of the expected type
          print(
              'Received data is not of type RTCIceCandidate: ${ev.eventData}');
        }
      });

      connection.on('stream-changed', null, (ev, context) {
        this.emit('stream-changed');
      });
      connections!.add(connection);
      await connection.start();
      this.emit('connection', null, connection);

      // Log the stream tracks
      var videoTracks = stream!.getVideoTracks();
      if (videoTracks.isEmpty) {
        print('No video tracks available for user: ${data.name}');
      }
      return connection;
    } else {
      print('Stream is null, cannot create connection for user: ${data.name}');
    }
    return null;
  }

  void join() {
    this.sendMessage('join-meeting', {
      'name': name,
      'userId': userId,
      'config': {
        'audioEnabled': audioEnabled,
        'videoEnabled': videoEnabled,
      },
    });
  }

  void joinedMeeting(JoinedMeetingData data) {
    joined = true;
    userId = data.userId;
  }

  void userJoined(UserJoinedData data) async {
    final connection = await createConnection(data);
    if (connection != null) {
      sendConnectionRequest(connection.userId);
    }
  }

  void sendIceCandidate(String otherUserId, RTCIceCandidate candidate) {
    sendMessage('icecandidate', {
      'userId': userId,
      'otherUserId': otherUserId,
      'candidate': candidate.toMap(),
    });
  }

  void sendConnectionRequest(String otherUserId) {
    sendMessage('connection-request', {
      'name': name,
      'userId': userId,
      'otherUserId': otherUserId,
      'config': {
        'audioEnabled': audioEnabled,
        'videoEnabled': videoEnabled,
      },
    });
  }

  void receivedConnectionRequest(UserJoinedData data) async {
    final connection = await createConnection(data);
    if (connection != null) {
      sendOfferSdp(data.userId!);
    }
  }

  void sendOfferSdp(String otherUserId) async {
    final connection = getConnection(otherUserId);
    if (connection != null) {
      final sdp = await connection.createOffer();
      sendMessage('offer-sdp', {
        'userId': userId,
        'otherUserId': otherUserId,
        'sdp': sdp?.toMap(),
      });
    }
  }

  void receivedOfferSdp(OfferSdpData data) {
    this.sendAnswerSdp(data.userId!, data.sdp!);
  }

  void sendAnswerSdp(String otherUserId, RTCSessionDescription sdp) async {
    final connection = getConnection(otherUserId);
    if (connection != null) {
      await connection.setOfferSdp(sdp);
      final answerSdp = await connection.createAnswer();
      sendMessage('answer-sdp', {
        'userId': this.userId,
        'otherUserId': otherUserId,
        'sdp': answerSdp!.toMap(),
      });
    }
  }

  void receivedAnswerSdp(AnswerSdpData data) async {
    final connection = getConnection(data.userId!);
    if (connection != null) {
      await connection.setAnswerSdp(data.sdp!);
    }
  }

  void setIceCandidate(IceCandidateData data) async {
    final connection = getConnection(data.userId!);
    if (connection != null) {
      await connection.setCandidate(data.candidate!);
    }
  }

  void userLeft(UserLeftData data) {
    final connection = getConnection(data.userId!);
    if (connection != null) {
      this.emit('user-left', null, connection);
      connection.close();
      connections!
          .removeWhere((element) => element.userId == connection.userId);
    }
  }

  void meetingEnded(MeetingEndedData data) {
    this.emit('ended');
    destroy();
  }

  void end() {
    sendMessage('end-meeting', {
      'userId': this.userId,
    });
    destroy();
  }

  void leave() {
    sendMessage('leave-meeting', {
      'userId': this.userId,
    });
    destroy();
  }

  bool toggleVideo() {
    if (stream != null) {
      final videoTrack = stream!.getVideoTracks()[0];
      if (videoTrack != null) {
        final bool videoEnabled = videoTrack.enabled = !videoTrack.enabled;
        this.videoEnabled = videoEnabled;
        sendMessage('video-toggle', {
          'userId': this.userId,
          'videoEnabled': videoEnabled,
        });
        return videoEnabled;
      }
    }
    return false;
  }

  bool toggleAudio() {
    if (stream != null) {
      final audioTrack = stream!.getAudioTracks()[0];
      if (audioTrack != null) {
        final bool audioEnabled = audioTrack.enabled = !audioTrack.enabled;
        this.audioEnabled = audioEnabled;
        sendMessage('audio-toggle', {
          'userId': this.userId,
          'audioEnabled': audioEnabled,
        });
        return audioEnabled;
      }
    }
    return false;
  }

  void listenVideoToggle(VideoToggleData data) {
    final connection = this.getConnection(data.userId!);
    if (connection != null) {
      connection?.toggleVideo(data.videoEnabled);
      this.emit('connection-setting-changed');
    }
  }

  void listenAudioToggle(AudioToggleData data) {
    final connection = this.getConnection(data.userId!);
    if (connection != null) {
      connection.toggleAudio(data.audioEnabled);
      this.emit('connection-setting-changed');
    }
  }

  void handleUserMessage(MessageData data) {
    this.messages!.add(data.message!);
    this.emit('message', null, data.message);
  }

  void sendUserMessage(String text) {
    sendMessage('message', {
      'userId': this.userId,
      'message': {
        'userId': this.userId,
        'text': text,
      },
    });
  }

  void handleNotFound() {
    this.emit('not-found');
  }

  stopStream() {
    if (stream != null) {
      stream!.dispose();
    }
  }

  void handleMessage(MessagePayload payload) {
    switch (payload.type) {
      case 'joined-meeting':
        joinedMeeting(JoinedMeetingData.fromJson(payload.data));
        break;
      case 'user-joined':
        userJoined(UserJoinedData.fromJson(payload.data));
        break;
      case 'connection-request':
        receivedConnectionRequest(UserJoinedData.fromJson(payload.data));
        break;
      case 'offer-sdp':
        receivedOfferSdp(OfferSdpData.fromJson(payload.data));
        break;
      case 'answer-sdp':
        receivedAnswerSdp(AnswerSdpData.fromJson(payload.data));
        break;
      case 'user-left':
        userLeft(UserLeftData.fromJson(payload.data));
        break;
      case 'meeting-ended':
        meetingEnded(MeetingEndedData.fromJson(payload.data));
        break;
      case 'icecandidate':
        setIceCandidate(IceCandidateData.fromJson(payload.data));
        break;
      case 'video-toggle':
        listenVideoToggle(VideoToggleData.fromJson(payload.data));
        break;
      case 'audio-toggle':
        listenAudioToggle(AudioToggleData.fromJson(payload.data));
        break;
      case 'message':
        handleUserMessage(MessageData.fromJson(payload.data));
        break;
      case 'not-found':
        handleNotFound();
        break;
      default:
        break;
    }
  }

  void destroy() {
    if (transport != null) {
      transport!.destroy();
      transport = null;
    }
    connections!.forEach((connection) {
      connection.close();
    });
    stopStream();
    connections = [];
    connected = false;
    stream = null;
    joined = false;
  }

  void reset() {
    this.connections = [];
    this.joined = false;
    this.connected = false;
  }

  void reconnect() {
    if (transport != null) {
      transport!.reconnect();
    }
  }
}
