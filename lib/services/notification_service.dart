import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// -----------------------------------------------------------------------------
// BACKGROUND HANDLER (Top-level)
// -----------------------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Note: We don't need to show a notification here manually. 
  // Firebase handles the background display automatically using the Manifest settings.
  print("Background message ID: ${message.messageId}");
}

class NotificationService {
  // Singleton Pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Defines the "High Importance" Channel for Android
  final AndroidNotificationChannel _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel_v2', // Must match the value in AndroidManifest.xml
    'High Importance Notifications', 
    description: 'This channel is used for important notifications.',
    importance: Importance.max, // <--- MAKES IT POP UP (Heads-up)
    playSound: true,
  );

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // 1. Request Permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      // ✅ ADD THIS BLOCK TO PRINT THE TOKEN
      String? token = await _firebaseMessaging.getToken();
      print("========================================");
      print("FCM TOKEN: $token");
      print("========================================");
      
      // 2. Setup Local Notifications (Creates the channel on the phone)
      await _setupLocalNotifications();

      // 3. Register Background Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 4. Handle Foreground Messages (The "Pop-up" when app is open)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showForegroundNotification(message);
      });

      // 5. Handle Taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      
      // 6. Check if app was opened from terminated state
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _isInitialized = true;
    }
  }

  Future<void> _setupLocalNotifications() async {
    // Create the high importance channel on Android
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }

    // Initialization Settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle tap on the local foreground notification
        print("Foreground Local Notification Tapped: ${response.payload}");
      },
    );
  }

  void _showForegroundNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // If notification data is present, show a local notification
    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.max, // Priority High
            priority: Priority.high,    // Priority High
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data.toString(),
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    print("Notification Tapped. Payload: ${message.data}");
    // Add your navigation logic here
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}