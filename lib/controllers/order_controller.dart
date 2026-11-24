import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/order.dart';
import '../models/ticket_package.dart';
import '../services/order_service.dart';
import 'auth_controller.dart';

class OrderController extends GetxController {
  final OrderService _orderService = OrderService();

  final orders = <Order>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  void loadOrders() {
    final authCtrl = Get.find<AuthController>();
    if (authCtrl.isLoggedIn.value && authCtrl.currentUserId.value.isNotEmpty) {
      orders.value =
          _orderService.getOrdersForUser(authCtrl.currentUserId.value);
    } else {
      orders.clear();
    }
  }

  // Create Order (Checkout)
  Future<Order?> checkout({
    required TicketPackage ticket,
    required String attendance,
    required int quantity,
    required String attendeeName,
    required double totalPriceSGD,
  }) async {
    final authCtrl = Get.find<AuthController>();
    if (!authCtrl.isLoggedIn.value) {
      Get.toNamed('/login');
      return null;
    }

    try {
      isLoading.value = true;
      final order = await _orderService.createOrder(
        userId: authCtrl.currentUserId.value,
        packageId: ticket.id,
        packageName: ticket.name,
        attendance: attendance,
        quantity: quantity,
        attendeeName: attendeeName.trim(),
        totalPriceSGD: totalPriceSGD,
      );

      loadOrders();
      final reminderError = _orderService.lastReminderError;
      if (reminderError != null) {
        Get.snackbar(
          'Booking Confirmed',
          'Your order was saved, but the reminder was not scheduled: $reminderError',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
      return order;
    } catch (e) {
      Get.snackbar(
        'Checkout Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Update Order (Manage Ticket: Name & Quantity)
  Future<bool> updateTicket({
    required String orderId,
    required String newAttendeeName,
    required int newQuantity,
  }) async {
    try {
      isLoading.value = true;
      await _orderService.updateOrder(
        orderId: orderId,
        newAttendeeName: newAttendeeName,
        newQuantity: newQuantity,
      );
      loadOrders();
      Get.snackbar(
        'Ticket Updated',
        'Ticket details updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00D26A),
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Update Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Cancel Order (Delete Ticket & Cancel Notifications)
  Future<bool> cancelTicket(String orderId) async {
    try {
      isLoading.value = true;
      await _orderService.cancelOrder(orderId);
      loadOrders();
      Get.snackbar(
        'Ticket Cancelled',
        'Your ticket has been cancelled and scheduled reminders removed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1A1B26),
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Cancellation Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
