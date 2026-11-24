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

  // 1. Initialize Local Storage (Hive Flutter + SharedPreferences)
  await LocalService.init();

  // 2. Initialize Local Notifications & Timezones
  await DeviceService.init();

  // 3. Seed Ticket Packages from assets/data/tickets.json if empty
  await TicketService().seedIfEmpty();

  runApp(const SgGpTicketsApp());
}

class SgGpTicketsApp extends StatelessWidget {
  const SgGpTicketsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SG GP Tickets 2027',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialBinding: InitialBindings(),
      initialRoute: AppRoutes.root,
      getPages: AppRoutes.pages,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
