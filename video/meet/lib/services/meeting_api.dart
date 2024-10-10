import 'package:http/http.dart' as http;
import 'package:meet/util/user.util.dart';
// import 'package:video_conferening_mobile/util/user.util.dart';

// final String MEETING_API_URL = '<api_url>/meeting';
final String MEETING_API_URL = 'http://192.168.10.74:8081/meeting';

Future<http.Response> startMeeting() async {
  var userId = await loadUserId();
  var response =
      // await http.post('$MEETING_API_URL/start', body: {'userId': userId});
      await http.post(Uri.parse('$MEETING_API_URL/start'),
          body: {'userId': '$userId'});
  return response;
}

// $MEETING_API_URL/join?meetingId=$meetingId
Future<http.Response> joinMeeting(String meetingId) async {
  // var response = await http.get('$MEETING_API_URL/join?meetingId=$meetingId');

  var response =
      await http.get(Uri.parse('$MEETING_API_URL/join?meetingId=$meetingId'));

  if (response.statusCode >= 200 && response.statusCode < 400) {
    return response;
  }
  throw UnsupportedError('Not a valid meeting');
}
