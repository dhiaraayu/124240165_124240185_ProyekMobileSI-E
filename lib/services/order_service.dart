import '../models/order.dart';
import 'local_service.dart';
import 'device_service.dart';

class OrderService {
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

    // Trigger immediate confirmation notification
    await DeviceService.showNow(
      id: notifId,
      title: 'Order Confirmed! 🏎️',
      body: '$quantity x $packageName ($attendance) has been booked successfully.',
    );

    // Schedule race weekend reminders:
    // Marina Bay 2027: Oct 8-10, 2027
    final raceDay = DateTime(2027, 10, 8, 9, 0);
    final reminderEve = raceDay.subtract(const Duration(days: 1));
    if (reminderEve.isAfter(DateTime.now())) {
      await DeviceService.schedule(
        id: notifId + 1,
        title: 'F1 Singapore GP Tomorrow! 🏁',
        body: 'Prepare your tickets for $packageName. Gates open tomorrow!',
        scheduledDate: reminderEve,
      );
    }

    return order;
  }

  // READ (Filtered strictly by active userId for security & privacy)
  List<Order> getOrdersForUser(String userId) {
    return LocalService.ordersBox.values
        .where((order) => order.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // UPDATE (Update attendee name and quantity, recalculate total)
  Future<Order> updateOrder({
    required String orderId,
    required String newAttendeeName,
    required int newQuantity,
  }) async {
    final order = LocalService.ordersBox.get(orderId);
    if (order == null) throw Exception('Order not found');

    // Calculate unit price from existing order
    final unitPrice = order.quantity > 0 ? (order.totalPriceSGD / order.quantity) : 0.0;
    final newTotal = unitPrice * newQuantity;

    final updated = order.copyWith(
      attendeeName: newAttendeeName.trim(),
      quantity: newQuantity,
      totalPriceSGD: newTotal,
    );

    await LocalService.ordersBox.put(orderId, updated);
    return updated;
  }

  // DELETE / CANCEL
  Future<void> cancelOrder(String orderId) async {
    final order = LocalService.ordersBox.get(orderId);
    if (order != null) {
      // Cancel scheduled notifications for this order
      await DeviceService.cancel(order.notifId);
      await DeviceService.cancel(order.notifId + 1);

      // Remove from Hive
      await LocalService.ordersBox.delete(orderId);
    }
  }
}
