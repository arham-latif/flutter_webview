import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Notification {
  static const String CHANNEL_KEY = "intelli_inbox";
  static const String CHANNEL_NAME = "Intelli Inbox";

  static Future<void> init() async {
    final mc = const MethodChannel('create_channel');

    mc.invokeMethod('createNotificationChannel', {
      "id": CHANNEL_KEY,
      "name": CHANNEL_NAME,
      "description": "Intelli Inbox Application chat notifications",
    }).then((value) async {
      NotificationChannel channel = NotificationChannel(
          channelKey: CHANNEL_KEY,
          channelName: CHANNEL_NAME,
          channelDescription:
              'This channel is used for important notifications.',
          importance: NotificationImportance.High,
          channelGroupKey: CHANNEL_KEY,
          channelShowBadge: true,
          enableVibration: true,
          defaultRingtoneType: DefaultRingtoneType.Notification,
          playSound: true,
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white);

      AwesomeNotifications().setChannel(channel);

      await AwesomeNotifications().initialize(null, [
        channel,
      ]);
    }).catchError((e) {
      print(e);
    });
  }

  static initListener() {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: selectNotification);
  }

  @pragma("vm:entry-point")
  static Future selectNotification(ReceivedAction notificationResponse) async {
    print(notificationResponse.payload);
    if (notificationResponse.payload!.isNotEmpty) {
      // Data temp =
      //     Data.fromJson(jsonDecode(notificationResponse.payload!["data"]!));
      //
      // print(notificationResponse.buttonKeyPressed);
      // print(temp.feedbackRequired);
      // if (temp.feedbackRequired == "1") {
      //   String feedback = "";
      //   String feedbackText = "";
      //   if (notificationResponse.buttonKeyPressed == "option1") {
      //     feedback = temp.option1!.value;
      //     feedbackText = temp.option1!.text;
      //   } else if (notificationResponse.buttonKeyPressed == "option2") {
      //     feedback = temp.option2!.value;
      //     feedbackText = temp.option2!.text;
      //   } else if (notificationResponse.buttonKeyPressed == "option3") {
      //     feedback = temp.option3!.value;
      //     feedbackText = temp.option3!.text;
      //   } else {
      //     Utils.navigate(page: const NotificationView());
      //   }
      //   ApiService.instance.submitNotificationFeedback(
      //       id: temp.id, feedback: feedback, feedbackText: feedbackText);
      // } else {
      //   switch (temp.screen) {
      //     case "eventHandler":
      //     case "event":
      //       Utils.navigate(
      //         page: ChatView(
      //           userModel: temp.user,
      //         ),
      //       );
      //       break;
      //     case "checkIn":
      //     case "checkOut":
      //     case "backgroundStatus":
      //     case "appUsageStatus":
      //     case "userGroupShift":
      //     case "locationMissingOut":
      //     case "locationMissingIn":
      //       Utils.navigate(
      //         page: ProfileView(
      //           user: temp.user!,
      //         ),
      //       );
      //       break;
      //     case "groupInfo":
      //       Utils.navigate(page: HomeView());
      //       break;
      //     case "locationSameStop":
      //       homeViewModel.bottomBarIndex.value = 3;
      //       break;
      //     default:
      //       Utils.navigate(page: const NotificationView());
      //       break;
      //   }
      // }
    }
  }

  static Future<void> show({
    required String title,
    required String message,
    dynamic payload,
  }) async {
    // await channel.invokeMethod('showNotification', {
    //   'title': title,
    //   'body': message,
    //   "actions": ['Action 1', 'Action 2']
    // });

    List<NotificationActionButton> actions = [];
    // if (payload.feedbackRequired == "1") {
    //   if (payload.option1 != null) {
    //     actions.add(NotificationActionButton(
    //       key: "option1",
    //       label: payload.option1!.text,
    //     ));
    //   }
    //   if (payload.option2 != null) {
    //     actions.add(
    //       NotificationActionButton(
    //         key: "option2",
    //         label: payload.option2!.text,
    //       ),
    //     );
    //   }
    //   if (payload.option3 != null) {
    //     actions.add(NotificationActionButton(
    //       key: "option3",
    //       label: payload.option3!.text,
    //     ));
    //   }
    // }

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 0,
            channelKey: CHANNEL_KEY,
            title: title,
            body: message,
            // payload: {'data': jsonEncode(payload.toJson())},
            actionType: ActionType.KeepOnTop),
        actionButtons: actions);
  }

  Future<void> backgroundNotification(
    String title,
    String message,
    Map<String, String> payload,
  ) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: CHANNEL_KEY,
        title: title,
        body: message,
        payload: payload, // Directly use the payload map
      ),
    );
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print("/////////////// ON REACT //////////////////");
    AlertDialog(
      title: Text(title!),
      content: Text(body!),
      actions: <Widget>[
        GestureDetector(
            onTap: () {
              print("TESTING");
            },
            child: const Text("Okay")),
      ],
    );
  }
}
