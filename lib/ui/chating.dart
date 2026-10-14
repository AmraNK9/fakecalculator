import 'package:calculator/ui/audio_room.dart';
import 'package:calculator/utlis/float_chat_variable.dart';
import 'package:calculator/utlis/utlis.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class ChattingScreen extends StatefulWidget {
  const ChattingScreen({super.key, required this.roomId});
  final String? roomId;

  @override
  _ChattingScreenState createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  final ScrollController _controller = ScrollController(); // Scroll controller
  Future<void> _createAudioRoom() async {
    // Set up our call object
    final call = StreamVideo.instance.makeCall(
      callType: StreamCallType.audioRoom(),
      id: "102",
    );
    showDialog(
        context: context,
        builder: (_) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          );
        });
    final result = await call.getOrCreate(); // Call object is created
    if (result.isSuccess) {
      await call.join(); // Our local app user can join and receive events
      await call
          .goLive(); // Allow others to see and join the call (exit backstage mode)
      Navigator.of(context).pop();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AudioRoomScreen(
            audioRoomCall: call,
          ),
        ),
      );
    } else {
      debugPrint('Not able to create a call.${result.getErrorOrNull()}');
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firestore
        .collection('messages')
        .where("roomId", isEqualTo: widget.roomId)
        .orderBy("timestamp")
        .snapshots()
        .listen((event) {
      var doc = event.docs.last.data();
      if (doc['type'] == MessageType.command.name &&
          doc['sender'] != FloatChatGlobal.userId) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: const Text("Voice room request"),
                  content: const Text("Are u join voice room?"),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.grey.shade400)),
                      child: const Text("Cancle"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _createAudioRoom();
                      },
                      child: const Text("Join"),
                    )
                  ],
                ));
      }
      print("type >>>> ${doc['type']}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            children: [
              const ListTile(
                title: Text(
                  "I love you so much La Won Ka Byar",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(
                  Icons.heart_broken,
                  color: Colors.pink,
                ),
              ),
              ListTile(
                title: const Text("User Name --> 00000"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                ),
              ),
              ListTile(
                title:
                    Text("Password --> ${FloatChatGlobal.calculatorPassword}"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_) {
                          final TextEditingController textEditingController =
                              TextEditingController();
                          return Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    decoration: const InputDecoration(
                                        hintText: "xxxxxx",
                                        border: OutlineInputBorder()),
                                    controller: textEditingController,
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                            onPressed: () async {
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              if (textEditingController
                                                  .text.isNotEmpty) {
                                                prefs.setString(
                                                    PrefsKey.calPassKey,
                                                    textEditingController.text);
                                                FloatChatGlobal
                                                        .calculatorPassword =
                                                    textEditingController.text;
                                                setState(() {
                                                  FloatChatGlobal
                                                          .calculatorPassword =
                                                      textEditingController
                                                          .text;
                                                });
                                              }
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Save")),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  },
                ),
              ),
              ListTile(
                title: const Text("Delete Command --> 1234"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  _createAudioRoom();

                  sendMessage(
                      messageType: MessageType.command, text: "#callRequest");
                },
                icon: const Icon(Icons.call))
          ],
          title: Text(
            widget.roomId ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('messages')
                    .where("roomId", isEqualTo: widget.roomId)
                    .orderBy("timestamp")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var messages = snapshot.data!.docs;

                  List<MessageBubble> messageWidgets = [];
                  for (var message in messages) {
                    var messageText = '';
                    var messageSender = '';
                    var date;
                    try {
                      messageText = message['text'];
                      messageSender = message['sender'];
                      date = message['timestamp'];
                    } catch (e) {}

                    var messageWidget = MessageBubble(
                      date: timeAgo(timeStampToDate(date?.seconds)),
                      sender: messageSender,
                      text: messageText,
                    );
                    messageWidgets.add(messageWidget);
                  }

                  // Scroll to end whenever messages update
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _controller.animateTo(
                      _controller.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  });

                  return ListView(
                    controller: _controller, // Attach controller here
                    children: messageWidgets,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your message...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage({MessageType? messageType, String? text}) async {
    if (_messageController.text.isNotEmpty || (text?.isNotEmpty ?? false)) {
      await _firestore.collection('messages').add({
        'roomId': widget.roomId,
        'text': text ?? _messageController.text,
        'sender': FloatChatGlobal.userId,
        'timestamp': Timestamp.now(),
        "type": messageType?.name ?? "message"
      });
      _messageController.clear();
    }
  }
}

class MessageBubble extends StatelessWidget {
  final String? sender;
  final String text;
  final String? date;
  const MessageBubble(
      {super.key,
      required this.text,
      required this.sender,
      required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: sender == FloatChatGlobal.userId
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            borderRadius: BorderRadius.only(
              topLeft:
                  Radius.circular(FloatChatGlobal.userId != sender ? 0 : 20),
              bottomLeft: const Radius.circular(20),
              bottomRight: const Radius.circular(20),
              topRight:
                  Radius.circular(FloatChatGlobal.userId == sender ? 0 : 20),
            ),
            elevation: 5.0,
            color: sender == FloatChatGlobal.userId
                ? Colors.lightBlueAccent
                : Colors.grey.shade500,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: sender == FloatChatGlobal.userId
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    sender ?? '',
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            date ?? '',
            style: const TextStyle(
              fontSize: 12.0,
              color: Color.fromARGB(99, 0, 0, 0),
            ),
          ),
        ],
      ),
    );
  }
}
