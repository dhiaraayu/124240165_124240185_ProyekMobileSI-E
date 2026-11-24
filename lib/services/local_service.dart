import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import '../models/ticket_package.dart';
import '../models/order.dart';

class LocalService {
  static late Box<AppUser> usersBox;
  static late Box<TicketPackage> ticketsBox;
  static late Box<Order> ordersBox;
  static late Box<String> wishlistBox;
  static late Box<Order> draftBox;
  static late SharedPreferences prefs;

  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserId = 'userId';
  static const String keyUserName = 'userName';
  static const String keyUserEmail = 'userEmail';
  static const String keyCurrency = 'selectedCurrency';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Hive Adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(AppUserAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TicketPackageAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(OrderAdapter());

    // Open Hive Boxes
    usersBox = await Hive.openBox<AppUser>('usersBox');
    ticketsBox = await Hive.openBox<TicketPackage>('ticketsBox');
    ordersBox = await Hive.openBox<Order>('ordersBox');
    wishlistBox = await Hive.openBox<String>('wishlistBox');
    draftBox = await Hive.openBox<Order>('draftBox');

    // Init SharedPreferences
    prefs = await SharedPreferences.getInstance();
  }

  // Session Management
  static bool get isLoggedIn => prefs.getBool(keyIsLoggedIn) ?? false;
  static String? get currentUserId => prefs.getString(keyUserId);
  static String? get currentUserName => prefs.getString(keyUserName);
  static String? get currentUserEmail => prefs.getString(keyUserEmail);
  static String get selectedCurrency => prefs.getString(keyCurrency) ?? 'SGD';

  static Future<void> setSession({
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setString(keyUserId, userId);
    await prefs.setString(keyUserName, userName);
    await prefs.setString(keyUserEmail, userEmail);
  }

  static Future<void> clearSession() async {
    await prefs.setBool(keyIsLoggedIn, false);
    await prefs.remove(keyUserId);
    await prefs.remove(keyUserName);
    await prefs.remove(keyUserEmail);
  }

  static Future<void> setCurrency(String currency) async {
    await prefs.setString(keyCurrency, currency);
  }
}
