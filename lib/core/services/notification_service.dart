
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level FCM background handler (required by Firebase)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Message handled in background — notification shown by system
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static const _channelId = 'astra_corridor';
  static const _channelName = 'ASTRA Green Corridor';

  // ── Initialise ────────────────────────────────────

  Future<void> initialize() async {
    // Local notifications setup
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotif.initialize(initSettings);

    // Create high-importance channel for heads-up
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Green corridor proximity alerts',
      importance: Importance.max,
      playSound: true,
    );
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // FCM permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground FCM handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showHeadsUpNotification(
        title: message.notification?.title ?? '🚨 ASTRA',
        body: message.notification?.body ?? 'Green Corridor update',
      );
    });

    // Background FCM handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // ── FCM Token ─────────────────────────────────────

  Future<String?> getFcmToken() async {
    try {
      return await _fcm.getToken();
    } catch (_) {
      return null;
    }
  }

  // ── Show Notification ─────────────────────────────

  Future<void> showHeadsUpNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Green corridor proximity alerts',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
      ticker: 'ASTRA Alert',
    );
    const details = NotificationDetails(android: androidDetails);

    await _localNotif.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}
