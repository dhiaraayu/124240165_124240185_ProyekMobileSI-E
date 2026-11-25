import '../models/order.dart';
import 'local_service.dart';
import 'device_service.dart';

class OrderService {
  String? lastReminderError;

  // CREATE
  Future<Order> createOrder({
    required String userId,
    required String packageId,
    required String packageName,
    required String attendance,
    required int quantity,
    required String attendeeName,
    required double totalPriceSGD,
  }) async {
    lastReminderError = null;
    final int notifId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final String id = 'ord_${DateTime.now().millisecondsSinceEpoch}';

    final order = Order(
      id: id,
      userId: userId,
      packageId: packageId,
      packageName: packageName,
      attendance: attendance,
      quantity: quantity,
      attendeeName: attendeeName,
      totalPriceSGD: totalPriceSGD,
      status: 'paid',
      createdAt: DateTime.now(),
      notifId: notifId,
    );

    await LocalService.ordersBox.put(id, order);

    await DeviceService.showNow(
      id: notifId,
      title: 'Order Confirmed!',
      body:
          '$quantity x $packageName ($attendance) has been booked successfully.',
    );

    final raceDay = DateTime(2027, 10, 8, 9, 0);
    final reminderEve = raceDay.subtract(const Duration(days: 1));
    if (reminderEve.isAfter(DateTime.now())) {
      try {
        await DeviceService.schedule(
          id: notifId + 1,
          title: 'F1 Singapore GP Tomorrow!',
          body: 'Prepare your tickets for $packageName. Gates open tomorrow!',
          scheduledDate: reminderEve,
        );
      } catch (e) {
        lastReminderError = e.toString().replaceFirst('Exception: ', '');
      }
    }

    return order;
  }

  List<Order> getOrdersForUser(String userId) {
    return LocalService.ordersBox.values
        .where((order) => order.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }


  Future<Order> updateOrder({
    required String orderId,
    required String newAttendeeName,
    required int newQuantity,
  }) async {
    final order = LocalService.ordersBox.get(orderId);
    if (order == null) throw Exception('Order not found');

    if (newAttendeeName.trim().isEmpty) {
      throw Exception('Ticket holder name cannot be empty.');
    }
    if (newQuantity != order.quantity) {
      throw Exception('Ticket quantity cannot be changed after payment.');
    }
    if (order.status == 'cancelled') {
      throw Exception('Cancelled orders cannot be edited.');
    }

    final updated = order.copyWith(
      attendeeName: newAttendeeName.trim(),
    );

    await LocalService.ordersBox.put(orderId, updated);
    return updated;
  }

  // DELETE / CANCEL
  Future<void> cancelOrder(String orderId) async {
    final order = LocalService.ordersBox.get(orderId);
    if (order != null) {
      
      await DeviceService.cancel(order.notifId);
      await DeviceService.cancel(order.notifId + 1);

     
      await LocalService.ordersBox.put(
        orderId,
        order.copyWith(status: 'cancelled'),
      );
    }
  }
}
