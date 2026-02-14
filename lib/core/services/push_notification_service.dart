import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/app_logger.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    AppLogger.d('Background message received: ${message.messageId}');
  }
}

/// Push notification service for handling Firebase Cloud Messaging
class PushNotificationService {
  PushNotificationService._();
  
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  static String? _fcmToken;
  static bool _initialized = false;
  
  /// Get the current FCM token
  static String? get fcmToken => _fcmToken;
  
  /// Check if the service is initialized
  static bool get isInitialized => _initialized;
  
  /// Android notification channel for high importance notifications
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'spendex_notifications',
    'Spendex Notifications',
    description: 'Notifications for budget alerts, transactions, and updates',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );
  
  /// Initialize push notification service
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: true,
        criticalAlert: false,
      );
      
      if (kDebugMode) {
        AppLogger.d('PushNotificationService: Permission status: ${settings.authorizationStatus}');
      }
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        
        // Initialize local notifications
        await _initializeLocalNotifications();
        
        // Get FCM token
        _fcmToken = await _messaging.getToken();
        if (kDebugMode) {
          AppLogger.d('PushNotificationService: FCM Token: $_fcmToken');
        }
        
        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          _onTokenRefresh(newToken);
        });
        
        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        
        // Handle notification tap when app is in background
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
        
        // Check for initial message (app opened from terminated state)
        final initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }
        
        _initialized = true;
        if (kDebugMode) {
          AppLogger.d('PushNotificationService: Initialized successfully');
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        AppLogger.e('PushNotificationService: Initialization failed', e, stack);
      }
    }
  }
  
  /// Initialize local notifications for foreground display
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
    
    // Create Android notification channel
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }
  }
  
  /// Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      AppLogger.d('PushNotificationService: Foreground message: ${message.messageId}');
    }
    
    final notification = message.notification;
    final android = message.notification?.android;
    
    // Show local notification if there's a notification payload
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }
  
  /// Handle notification tap (background/terminated state)
  static void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      AppLogger.d('PushNotificationService: Notification tapped: ${message.data}');
    }
    // Handle navigation based on message data
    _processNotificationAction(message.data);
  }
  
  /// Handle local notification tap
  static void _onLocalNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      AppLogger.d('PushNotificationService: Local notification tapped: ${response.payload}');
    }
    
    if (response.payload != null) {
      try {
        _processNotificationAction(data);
      } catch (e) {
        if (kDebugMode) {
          AppLogger.e('PushNotificationService: Failed to parse payload', e);
        }
      }
    }
  }
  
  /// Process notification action and navigate
  static void _processNotificationAction(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;
    
    // Navigation will be handled by the app's router
    // This is a placeholder for the actual navigation logic
    if (kDebugMode) {
      AppLogger.d('PushNotificationService: Action type=$type, id=$id');
    }
  }
  
  /// Handle token refresh
  static void _onTokenRefresh(String newToken) {
    if (kDebugMode) {
      AppLogger.d('PushNotificationService: Token refreshed: $newToken');
    }
    // Send new token to backend
    // TODO: Implement token registration API call
  }
  
  /// Subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        AppLogger.d('PushNotificationService: Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.e('PushNotificationService: Failed to subscribe to topic', e);
      }
    }
  }
  
  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        AppLogger.d('PushNotificationService: Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.e('PushNotificationService: Failed to unsubscribe from topic', e);
      }
    }
  }
}
