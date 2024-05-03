

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationManager
{
  // called when a notification is created by the app
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async
  {

  }

  // called when a notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async
  {

  }

  // called when the user dismisses a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(ReceivedNotification receivedNotification) async
  {

  }

  // called when the user clicks on a notification
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedNotification receivedNotification) async
  {

  }

  createNotification(int id, String itemName, DateTime scheduleTime) async
  {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'my_channel',
          title: 'Expiration Reminder!',
          body: 'Your $itemName is expiring soon! Consider using it!',
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
          autoDismissible: false,
        ),
        schedule: NotificationCalendar.fromDate(
          date: scheduleTime,
          preciseAlarm: true,
          allowWhileIdle: true
        ));
  }

  cancelNotification(int id) async => await AwesomeNotifications().cancel(id);
}