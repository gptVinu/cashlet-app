// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;

// class NotificationService {
//   static final NotificationService _instance = NotificationService._();
//   factory NotificationService() => _instance;
//   NotificationService._();

//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> init() async {
//     // Using simpler initialization settings to avoid any styling issues
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );

//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         // Handle notification tapped logic here
//       },
//     );
//   }

//   Future<void> showNotification({
//     required int id,
//     required String title,
//     required String body,
//   }) async {
//     // Using simple notification details without BigPictureStyle to avoid the conflict
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'cashlet_channel',
//       'Cashlet Notifications',
//       channelDescription: 'Notification channel for Cashlet app',
//       importance: Importance.max,
//       priority: Priority.high,
//       // Avoid using styling that might cause conflicts
//     );

//     const NotificationDetails platformDetails =
//         NotificationDetails(android: androidDetails);

//     await _flutterLocalNotificationsPlugin.show(
//       id,
//       title,
//       body,
//       platformDetails,
//     );
//   }

//   Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledDate,
//   }) async {
//     try {
//       // Using simple notification details
//       const AndroidNotificationDetails androidDetails =
//           AndroidNotificationDetails(
//         'cashlet_reminder_channel',
//         'Cashlet Reminders',
//         channelDescription: 'Reminder notifications for Cashlet app',
//         importance: Importance.max,
//         priority: Priority.high,
//       );

//       const NotificationDetails platformDetails =
//           NotificationDetails(android: androidDetails);

//       // Use try-catch to handle API differences between plugin versions
//       try {
//         // Attempt with older API first (pre v10.0.0)
//         await _flutterLocalNotificationsPlugin.zonedSchedule(
//           id,
//           title,
//           body,
//           tz.TZDateTime.from(scheduledDate, tz.local),
//           platformDetails,
//           androidAllowWhileIdle: true, // Only use this parameter for older versions
//           uiLocalNotificationDateInterpretation:
//               UILocalNotificationDateInterpretation.absoluteTime,
//           matchDateTimeComponents: DateTimeComponents.time,
//         );
//       } catch (e) {
//         print('Fallback to newer notification API: $e');
//         // Fallback to newer API style (v10.0.0+)
//         await _flutterLocalNotificationsPlugin.zonedSchedule(
//           id,
//           title,
//           body,
//           tz.TZDateTime.from(scheduledDate, tz.local),
//           platformDetails,
//           // Only use these parameters for newer versions
//           androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//           dateInterpretation: DateTimeInterpretation.absoluteTime,
//           matchDateTimeComponents: DateTimeComponents.time,
//         );
//       }
//     } catch (e) {
//       print('Failed to schedule notification: $e');
//       // If all attempts fail, use a basic show notification as a last resort
//       try {
//         await showNotification(
//           id: id,
//           title: title,
//           body: body,
//         );
//       } catch (finalError) {
//         print('Could not show notification: $finalError');
//       }
//     }
//   }

//   Future<void> cancelNotification(int id) async {
//     await _flutterLocalNotificationsPlugin.cancel(id);
//   }

//   Future<void> cancelAllNotifications() async {
//     await _flutterLocalNotificationsPlugin.cancelAll();
//   }
// }
// }
