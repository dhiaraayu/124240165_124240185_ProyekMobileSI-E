import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'services/local_service.dart';
import 'views/root_page.dart';
import 'views/ticket_detail_page.dart';
import 'views/login_page.dart';
import 'views/checkout_page.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!LocalService.isLoggedIn) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}

class AppRoutes {
  static const String root = '/root';
  static const String welcome = '/welcome';
  static const String ticketDetail = '/ticket-detail';
  static const String login = '/login';
  static const String checkout = '/checkout';

  static final List<GetPage> pages = [
    GetPage(
      name: root,
      page: () => const RootPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    ),
    // Layar login pertama kali (bisa dilewati)
    GetPage(
      name: welcome,
      page: () => const LoginPage(isWelcome: true),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: ticketDetail,
      page: () => const TicketDetailPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    ),
    // Login dari tombol BUY (bisa ditutup)
    GetPage(
      name: login,
      page: () => const LoginPage(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: checkout,
      page: () => const CheckoutPage(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    ),
  ];
}
