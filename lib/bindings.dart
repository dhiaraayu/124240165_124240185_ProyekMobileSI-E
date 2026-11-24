import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'controllers/currency_controller.dart';
import 'controllers/ticket_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/venue_controller.dart';

import 'services/venue_notification_service.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CurrencyController>(
      () => CurrencyController(),
      fenix: true,
    );

    Get.lazyPut<AuthController>(
      () => AuthController(),
      fenix: true,
    );

    Get.lazyPut<TicketController>(
      () => TicketController(),
      fenix: true,
    );

    Get.lazyPut<OrderController>(
      () => OrderController(),
      fenix: true,
    );

    Get.lazyPut<HomeController>(
      () => HomeController(),
      fenix: true,
    );

    Get.lazyPut<VenueNotificationService>(
      () => VenueNotificationService(),
      fenix: true,
    );

    Get.lazyPut<VenueController>(
      () => VenueController(
        notifications: Get.find<VenueNotificationService>(),
      ),
      fenix: true,
    );
  }
}