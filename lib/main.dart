import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'services/local_service.dart';
import 'services/device_service.dart';
import 'services/ticket_service.dart';
import 'bindings.dart';
import 'routes.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Local storage (Hive + SharedPreferences)
  await LocalService.init();

  // 2. Notifikasi lokal & timezone
  await DeviceService.init();

  // 3. Seed paket tiket dari assets/data/tickets.json
  await TicketService().seedIfEmpty();

  runApp(const SgGpTicketsApp());
}

class SgGpTicketsApp extends StatelessWidget {
  const SgGpTicketsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Belum login -> onboarding setiap kali app dibuka (tanpa flag permanen).
    // Sudah login -> langsung ke beranda.
    final String startRoute =
        LocalService.isLoggedIn ? AppRoutes.root : AppRoutes.welcome;

    return GetMaterialApp(
      title: 'SG GP Tickets 2027',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialBinding: InitialBindings(),
      initialRoute: startRoute,
      getPages: AppRoutes.pages,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
