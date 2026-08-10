import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // 알림 권한 요청
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // FCM 토큰 저장 (Firestore users/{uid}/fcmTokens)
    await _saveToken();

    // 토큰 갱신 시 재저장
    _messaging.onTokenRefresh.listen(_storeToken);

    // 포어그라운드 메시지 수신 설정
    FirebaseMessaging.onMessage.listen(_handleForeground);
  }

  static Future<void> _saveToken() async {
    final token = await _messaging.getToken();
    if (token != null) await _storeToken(token);
  }

  static Future<void> _storeToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token)
        .set({'token': token, 'updatedAt': FieldValue.serverTimestamp()});
  }

  static void _handleForeground(RemoteMessage message) {
    debugPrint('[FCM] 포어그라운드 메시지: ${message.notification?.title}');
  }
}
