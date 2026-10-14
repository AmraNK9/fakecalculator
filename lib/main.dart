import 'package:auto_size_text/auto_size_text.dart';
import 'package:calculator/api/api.dart';
import 'package:calculator/firebase_options.dart';
import 'package:calculator/ui/chating.dart';
import 'package:calculator/utlis/float_chat_variable.dart';
import 'package:calculator/utlis/utlis.dart';
import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // prefs.clear();

  FloatChatGlobal.userId = prefs.getString("user_id");
  FloatChatGlobal.userNickName = prefs.getString("nick_name");
  FloatChatGlobal.calculatorPassword = prefs.getString(PrefsKey.calPassKey) ??
      FloatChatGlobal.calculatorPassword;
  CallingGlobal.userToken = prefs.getString("call_token");

  if (FloatChatGlobal.userNickName?.isEmpty ?? true) {
    FloatChatGlobal.userNickName = getRandomNickname();
    prefs.setString("nick_name", FloatChatGlobal.userNickName ?? '');
  }

  if ((FloatChatGlobal.userId?.isEmpty ?? true)) {
    FloatChatGlobal.userId = getCurrentUnixTimestampInSeconds().toString();
    prefs.setString("user_id", FloatChatGlobal.userId ?? '');
  }

  // Initialize Stream video and set the API key for our app.
  final user = User.regular(
    role: 'user',
    userId: FloatChatGlobal.userId ?? "Jsins_Solo12",
    name: FloatChatGlobal.userNickName,
    // image:
  );

  // try {
  //   if (CallingGlobal.userToken == null || CallingGlobal.userToken!.isEmpty) {
  //     final res = await Api().dio.post('/api/user', data: {
  //       "name": FloatChatGlobal.userNickName,
  //       "id": FloatChatGlobal.userId
  //     });
  //     CallingGlobal.userToken = res.data['token'];
  //     prefs.setString("call_token", CallingGlobal.userToken ?? '');
  //   }

  //   // debugPrint("Token --> $res");
  // } catch (e) {
  //   print("fetching token error ---\n $e");
  // }

  // debugPrint("token ----> $token");

  StreamVideo('94d5w8fr6mtd', user: user,

      // userToken: CallingGlobal.userToken,
      // userToken: CallingGlobal.userToken
      tokenLoader: (v) async {
    print("run Token Loader");
    final res = await Api().dio.post('/api/user', data: {
      "name": FloatChatGlobal.userNickName,
      "id": FloatChatGlobal.userId
    });
    print("Token ---> ${res.data['token']}");
    return res.data['token'];
  }

      // userToken: "John_doe"
      // userToken: token,
      );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = '';
  String result = '0';
  final String secretPassword = FloatChatGlobal.calculatorPassword;

  double memory = 0.0; // Memory storage
  double lastAnswer = 0.0; // Last answer

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        display = '';
        result = '0';
      } else if (buttonText == '⌫') {
        if (display.isNotEmpty) {
          display = display.substring(0, display.length - 1);
        }
      } else if (buttonText == '=') {
        String password = '';

        // Find password in display
        RegExp regExp = RegExp(r'\×\×\×(.*?)%');

        Iterable<Match> matches = regExp.allMatches(display);
        if (matches.isNotEmpty) {
          password = matches.first.group(1) ?? '';
          print("password == $password");
        }
        if (password == FloatChatGlobal.calculatorPassword) {
          // Find the index of '%'
          int index = display.indexOf('%');
          String? roomId;
          if (index != -1) {
            // Extract substring starting right after '%'
            String result = display.substring(index + 1).trim();
            roomId = result;
            print('room_id $result'); // Output: in string
          } else {
            print("'%'' not found in the string.");
          }
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, ani, secAni) {
                return ChattingScreen(
                  roomId: roomId,
                );
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final offsetAnimable = Tween(
                  begin: const Offset(1, 0),
                  end: const Offset(0, 0),
                ).chain(CurveTween(curve: Curves.easeInOut));
                final offsetAnimation = animation.drive(
                  offsetAnimable,
                );

                // final alignAnimatable = AlignmentTween(
                //     begin: Alignment.centerLeft, end: Alignment.topRight);
                // // final alignAnimation = animation.drive(alignAnimatable);
                // // final RelativeRectTween rectTween = RelativeRectTween(
                // //   begin:
                // //       const RelativeRect.fromLTRB(50.0, 50.0, 50.0, 50.0),
                // //   end: const RelativeRect.fromLTRB(150.0, 150.0, 0.0, 0.0),
                // // );
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              // transitionDuration: const Duration(seconds: 1),
            ),
          );
        }
        // try {
        const eval = ExpressionEvaluator();
        final parsedExpression =
            Expression.parse(display.replaceAll('×', '*').replaceAll('÷', '/'));
        lastAnswer = eval.eval(parsedExpression, {}).toDouble();
        result = lastAnswer.toString();

        // } catch (e) {
        //   print("e-->$e");
        //   result = 'Error';
        // }
      } else if (buttonText == 'mc') {
        memory = 0.0;
      } else if (buttonText == 'm+') {
        try {
          const eval = ExpressionEvaluator();
          final parsedExpression = Expression.parse(
              display.replaceAll('×', '*').replaceAll('÷', '/'));
          memory += eval.eval(parsedExpression, {});
        } catch (e) {
          result = 'Error';
        }
      } else if (buttonText == 'm-') {
        try {
          const eval = ExpressionEvaluator();
          final parsedExpression = Expression.parse(
              display.replaceAll('×', '*').replaceAll('÷', '/'));
          memory -= eval.eval(parsedExpression, {});
        } catch (e) {
          result = 'Error';
        }
      } else if (buttonText == 'mr') {
        display = memory.toString();
      } else if (buttonText == 'ans') {
        display = lastAnswer.toString();
      } else {
        display += buttonText;
      }
    });
  }

  Widget buildButton(String buttonText,
      {Color? textColor, Color? bgColor, int flex = 1, double? fontSize}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(2),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(24),
            shape: const RoundedRectangleBorder(
                // borderRadius: BorderRadius.circular(8),
                ),
            backgroundColor: bgColor ?? Colors.white,
            foregroundColor: textColor ?? Colors.black,
            textStyle: TextStyle(fontSize: fontSize ?? 24),
          ),
          onPressed: () => buttonPressed(buttonText),
          child: AutoSizeText(
            maxLines: 1,
            buttonText,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text('Calculator'),

          ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.bottomRight,
              child: AutoSizeText(
                maxLines: 2,
                display,
                style:
                    const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(16),
              child: AutoSizeText(
                maxLines: 1,
                result,
                style: const TextStyle(fontSize: 32, color: Colors.grey),
              ),
            ),
          ),
          const Divider(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  buildButton('mc', textColor: Colors.black54),
                  buildButton('m+', textColor: Colors.black54),
                  buildButton('m-', textColor: Colors.black54),
                  buildButton('mr', textColor: Colors.black54),
                ],
              ),
              Row(
                children: [
                  buildButton('C', textColor: Colors.blue),
                  buildButton('÷', textColor: Colors.blue),
                  buildButton('×', textColor: Colors.blue),
                  buildButton(
                    '⌫',
                    fontSize: 20,
                    textColor: Colors.blue,
                  ),
                ],
              ),
              Row(
                children: [
                  buildButton('7'),
                  buildButton('8'),
                  buildButton('9'),
                  buildButton('-', textColor: Colors.blue),
                ],
              ),
              Row(
                children: [
                  buildButton('4'),
                  buildButton('5'),
                  buildButton('6'),
                  buildButton('+', textColor: Colors.blue),
                ],
              ),
              Row(
                children: [
                  buildButton('1'),
                  buildButton('2'),
                  buildButton('3'),
                  buildButton("ans", textColor: Colors.blue)
                ],
              ),
              Row(
                children: [
                  buildButton('%'),
                  buildButton('0'),
                  buildButton('.'),
                  buildButton('=',
                      bgColor: Colors.blue, textColor: Colors.white),
                ],
              ),
              //  SizedBox(
              //     height: MediaQuery.of(context).viewInsets.bottom,
              //     )
            ],
          ),
        ],
      ),
    );
  }
}
