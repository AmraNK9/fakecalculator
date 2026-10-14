import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FloatChat extends StatefulWidget {
  const FloatChat({super.key});

  @override
  State<FloatChat> createState() => _FloatChatState();
}

class _FloatChatState extends State<FloatChat> {
  int prograss = 0;
  late WebViewController controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int v) {
            // Update loading bar.
            setState(() {
              prograss = v;
            });
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://la-won-chat.000webhostapp.com/?room=lawonkabyar&password=1234'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Messaging'),
        ),
        body: prograss == 100
            ? WebViewWidget(controller: controller)
            : Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * .8,
                  child: StepProgressIndicator(
                    totalSteps: 100,
                    currentStep: prograss,
                    size: 8,
                    padding: 0,
                    selectedColor: Colors.yellow,
                    unselectedColor: Colors.cyan,
                    roundedEdges: const Radius.circular(10),
                    // selectedGradientColor: const LinearGradient(
                    //   begin: Alignment.topLeft,
                    //   end: Alignment.bottomRight,
                    //   colors: [Colors.yellowAccent, Colors.deepOrange],
                    // ),
                    // unselectedGradientColor: const LinearGradient(
                    //   begin: Alignment.topLeft,
                    //   end: Alignment.bottomRight,
                    //   colors: [Colors.black, Colors.blue],
                    // ),
                  ),
                ),
              ));
  }
}
