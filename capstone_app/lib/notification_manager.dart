import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationManager
{
  // all these functions need to be here for awesome notifications to work,
  // but they are empty since there is currently no logic for these events

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


  // create a scheduled notification
  createNotification(int id, String itemName, DateTime scheduleTime) async
  {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'my_channel',
          title: 'Expiration Reminder for $itemName!',
          body: 'You have an item expiring soon! Consider using it!',
          category: NotificationCategory.Reminder,
        ),
        schedule: NotificationCalendar.fromDate(date: scheduleTime)
    );

  }

  // cancel a scheduled notification
  cancelNotification(int id) async => await AwesomeNotifications().cancel(id);
}