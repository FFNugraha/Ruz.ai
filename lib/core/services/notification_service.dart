import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final token = await _fcm.getToken();
    await FirebaseService.saveDeviceToken(token!);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] ?? '';

    switch (type) {
      case 'pest_alert':
        // Tampilkan in-app notification card dengan tingkat urgensi
        break;
      case 'fertilizer_reminder':
        // Tampilkan reminder pupuk
        break;
      case 'irrigation_alert':
        // Alert kelembaban tanah
        break;
      case 'growth_phase':
        // Informasi fase tumbuh baru
        break;
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navigate ke screen yang relevan berdasarkan notification type
  }
}
