import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import 'firebase_options.dart';
import 'notification.dart' as notifications;

@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("BACKGROUND Outer //////////////////");
  if (message.messageId != "") {
    print("BACKGROUND NOTIFICATION RECEIVER //////////////////");
    print(message.data["title"]);
    print(message.notification);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(provisional: true);

  print('User granted permission: ${settings.authorizationStatus}');

  await notifications.Notification.init();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((message) async {
    print(message);
    print("////////////////////// LISTEN //////////////////////////");
    // Notification.Data data = Notification.Data.fromJson(message.data);
    notifications.Notification.show(
        title: '${message.notification?.title}',
        message: '${message.notification?.body}');
  });

  String? fcmToken = await FirebaseMessaging.instance.getToken();

  print("///////////// FCM ///////////////");
  print(fcmToken);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
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
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handleMessage(message.message);
        },
      )
      ..loadHtmlString('''
<!DOCTYPE html>
<html>
  <head>
    <title>WebView Test</title>
    <script type="text/javascript">
      function sendMessageToFlutter() {
        FlutterChannel.postMessage('Hello from WebView!');
      }
    </script>
  </head>
  <body>
    <h1>Welcome to WebView</h1>
    <button onclick="sendMessageToFlutter()">Send Message</button>
  </body>
</html>
''');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Center(child: Text("WEBVIEW")),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: WebViewWidget(controller: controller)),
          ],
        ),
      ),
    );
  }

  void _handleMessage(String message) async {
    print('Message from WebView: $message');

    // FCM Token Retrieval
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken == null) {
      print("Error: FCM token is null");
      return;
    }

    // Prepare the API URL and headers
    const String apiUrl = "https://www.google.com"; // Target API endpoint
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, String> body = {'fcmToken': fcmToken}; // Include only the token

    try {
      // Make the API call
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      // Check the status code
      if (response.statusCode == 200) {
        print("FCM token sent successfully.");
      } else {
        print("Failed to send FCM token: ${response.statusCode}");
      }
    } catch (e) {
      print("Error during API call: $e");
    }

    // Show the message in a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message from WebView'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
