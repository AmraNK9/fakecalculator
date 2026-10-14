// import 'package:calculator/utlis/float_chat_variable.dart';
import 'package:english_words/english_words.dart';
// import 'package:jaguar_jwt/jaguar_jwt.dart';

int getCurrentUnixTimestampInSeconds() {
  // DateTime.now() gives the current date and time in local time zone
  // To get the current time in UTC (which is what Unix timestamp uses), use .toUtc()
  DateTime now = DateTime.now().toUtc();

  // DateTime.millisecondsSinceEpoch gives the number of milliseconds since Jan 1, 1970, UTC
  // Convert milliseconds to seconds by dividing by 1000
  int timestamp = now.millisecondsSinceEpoch ~/ 1000;

  return timestamp;
}

String timeAgo(String? dateString) {
  if (dateString == null) return '';
  String dateFormatedString = dateString;
  DateTime? d;
  DateTime? b = DateTime.tryParse(dateFormatedString);
  if (b == null) {
    return dateString;
  } else {
    d = b.toLocal();
  }

  Duration diff = DateTime.now().difference(d);
  if (diff.inDays > 365) {
    return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
  }
  if (diff.inDays > 30) {
    return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
  }
  if (diff.inDays > 7) {
    return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
  }
  if (diff.inDays > 0) {
    return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
  }
  if (diff.inHours > 0) {
    return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
  }
  if (diff.inMinutes > 0) {
    return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
  }
  return "a few minutes ago";
}

String? timeStampToDate(int? timestamp) {
  if (timestamp == null) {
    return null;
  }
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  // Format the DateTime as a string
  String formattedDate =
      "${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} "
      "${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}";

  return formattedDate;
}

String _twoDigits(int n) {
  if (n >= 10) {
    return "$n";
  }
  return "0$n";
}

String getRandomNickname() {
  final WordPair wordPair = WordPair.random();
  return '${wordPair.first} ${wordPair.second}';
}

enum MessageType { message, command }

// String generateToken({String? userId}) {
//   print("user_id --> ${FloatChatGlobal.userId}");
//   const key = 's3cr3t';
//   final claimSet = JwtClaim(
//     subject: FloatChatGlobal.userId,
//     issuer: 'teja',
//     audience: <String>['audience1.example.com', 'audience2.example.com'],
//     otherClaims: <String, dynamic>{
//       'typ': 'authnresponse',
//       'pld': {'k': 'v'},
//       'user_id': FloatChatGlobal.userId
//     },
//     maxAge: const Duration(
//       minutes: 5,
//     ),
//   );

//   // Assuming issueJwtHS256 is asynchronous:
//   String token = issueJwtHS256(claimSet, key);
//   return token;
// }
