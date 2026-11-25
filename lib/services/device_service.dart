import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MarinaGate {
  final String id;
  final String name;
  final String location;
  final String description;
  final double latitude;
  final double longitude;
  final double? distanceMeters;
  final bool isNear; // < 150m is marked green!

  const MarinaGate({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.distanceMeters,
    this.isNear = false,
  });

  MarinaGate copyWithDistance(double meters) {
    return MarinaGate(
      id: id,
      name: name,
      location: location,
      description: description,
      latitude: latitude,
      longitude: longitude,
      distanceMeters: meters,
      isNear: meters <= 150.0,
    );
  }

  String get formattedDistance {
    if (distanceMeters == null) return '--';
    if (distanceMeters! < 1000) {
      return '${distanceMeters!.round()} m';
    } else {
      return '${(distanceMeters! / 1000).toStringAsFixed(1)} km';
    }
  }
}

class DeviceService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const List<MarinaGate> defaultGates = [
    MarinaGate(
      id: 'gate-1',
      name: 'Gate 1 (Republic Blvd)',
      location: 'Republic Blvd / Turn 1',
      description:
          'Main access for Super Pit, Pit, Turn 1 & Turn 2 Grandstands.',
      latitude: 1.2917,
      longitude: 103.8619,
    ),
    MarinaGate(
      id: 'gate-2',
      name: 'Gate 2 (Promenade)',
      location: 'Beside Singapore Flyer',
      description:
          'Convenient entrance from Promenade MRT Station (Circle & Downtown lines).',
      latitude: 1.2894,
      longitude: 103.8631,
    ),
    MarinaGate(
      id: 'gate-3',
      name: 'Gate 3 (Marina Centre)',
      location: 'Raffles Blvd / Millenia Walk',
      description:
          'Short walk from Esplanade MRT. Direct access to Zone 1 and Zone 2.',
      latitude: 1.2935,
      longitude: 103.8580,
    ),
    MarinaGate(
      id: 'gate-4',
      name: 'Gate 4 (Padang / St. Andrew)',
      location: 'St. Andrew\'s Road / Padang',
      description:
          'Prime access for Padang Grandstand and headline concerts at Padang Stage.',
      latitude: 1.2905,
      longitude: 103.8530,
    ),
    MarinaGate(
      id: 'gate-5',
      name: 'Gate 5 (National Gallery)',
      location: 'Fullerton Rd / Supreme Court',
      description:
          'Close to City Hall MRT Station. Access to Zone 4 walkabout and Empress.',
      latitude: 1.2890,
      longitude: 103.8518,
    ),
    MarinaGate(
      id: 'gate-6',
      name: 'Gate 6 (Anderson Bridge)',
      location: 'Anderson Bridge / Fullerton',
      description: 'Access to Turn 11-13 viewing platforms and Padang Stage.',
      latitude: 1.2865,
      longitude: 103.8540,
    ),
    MarinaGate(
      id: 'gate-7',
      name: 'Gate 7 (Empress Lawn)',
      location: 'Victoria Theatre & Concert Hall',
      description:
          'Direct gate for Empress Grandstand and historic civic district.',
      latitude: 1.2878,
      longitude: 103.8525,
    ),
    MarinaGate(
      id: 'gate-8',
      name: 'Gate 8 (Marina Bay Waterfront)',
      location: 'Helix Bridge / Marina Bay',
      description:
          'Direct entrance from Bayfront MRT (Marina Bay Sands & Bayfront Grandstand).',
      latitude: 1.2845,
      longitude: 103.8600,
    ),
  ];

  static Future<void> init() async {
    try {
      tz.initializeTimeZones();
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          
        },
      );

      
    } catch (_) {}
  }

  
  static Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'f1_orders_channel',
        'F1 Order Notifications',
        channelDescription: 'Order confirmation and ticketing alerts',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );
      const notificationDetails = NotificationDetails(android: androidDetails);
      await _notificationsPlugin.show(id, title, body, notificationDetails);
    } catch (_) {}
  }

  
  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final notificationPermission =
        await androidImplementation?.requestNotificationsPermission() ?? true;
    if (!notificationPermission) {
      throw Exception('Notification permission was not granted.');
    }

    final permissionGranted =
        await androidImplementation?.requestExactAlarmsPermission() ?? true;
    if (!permissionGranted) {
      throw Exception(
          'Exact alarm permission was not granted. Please enable Alarms & reminders in Settings.');
    }

    final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);
    const androidDetails = AndroidNotificationDetails(
      'f1_race_reminders',
      'F1 Race Reminders',
      channelDescription: 'Scheduled reminders for race weekend & gates',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduled,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  
  static Future<void> scheduleTest10Seconds({
    required int id,
    required String title,
    required String body,
  }) async {
    final triggerTime = DateTime.now().add(const Duration(seconds: 10));
    await schedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: triggerTime,
    );
  }

  
  static Future<void> cancel(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
    } catch (_) {}
  }

 
  static Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
  }

  // 3. Geolocator LBS Support
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 6),
      );
    } catch (_) {
      return null;
    }
  }

  static List<MarinaGate> calculateGateDistances(Position userPos) {
    return defaultGates.map((gate) {
      final distance = Geolocator.distanceBetween(
        userPos.latitude,
        userPos.longitude,
        gate.latitude,
        gate.longitude,
      );
      return gate.copyWithDistance(distance);
    }).toList()
      ..sort(
          (a, b) => (a.distanceMeters ?? 0).compareTo(b.distanceMeters ?? 0));
  }
}
