import 'package:flutter_test/flutter_test.dart';
import 'package:projectakhir/models/app_user.dart';
import 'package:projectakhir/models/ticket_package.dart';
import 'package:projectakhir/models/order.dart';

void main() {
  group('F1 Ticket Package Model Tests', () {
    test('Ticket package calculates prices and availability correctly', () {
      final ticket = TicketPackage(
        id: 'super-pit',
        category: 'grandstand',
        name: 'Super Pit Grandstand',
        zoneAccess: '1, 2, 3, 4',
        gates: '1, 2',
        location: 'Pit Straight',
        price3Day: 2608.0,
        priceFri: 988.0,
        priceSat: 1288.0,
        priceSun: 1888.0,
        overview: ['Access Zones: 1, 2, 3, 4'],
        description: 'Overlooking pit lane',
        imageAsset: 'assets/images/super-pit.jpg',
        status: 'available',
        featured: true,
      );

      expect(ticket.isAvailable, true);
      expect(ticket.getPriceForDay('3-Day'), 2608.0);
      expect(ticket.getPriceForDay('Friday'), 988.0);
      expect(ticket.availableDays.length, 4);
    });

    test('Order calculation and copyWith works properly', () {
      final order = Order(
        id: 'ord_123',
        userId: 'usr_1',
        packageId: 'super-pit',
        packageName: 'Super Pit Grandstand',
        attendance: '3-Day',
        quantity: 2,
        attendeeName: 'Alex Verstappen',
        totalPriceSGD: 5216.0,
        status: 'paid',
        createdAt: DateTime.now(),
        notifId: 1001,
      );

      expect(order.quantity, 2);
      expect(order.totalPriceSGD, 5216.0);

      final updated = order.copyWith(quantity: 3, totalPriceSGD: 7824.0);
      expect(updated.quantity, 3);
      expect(updated.totalPriceSGD, 7824.0);
    });

    test('AppUser model serializes properly', () {
      final user = AppUser(
        id: 'usr_1',
        name: 'Alex Verstappen',
        email: 'alex@f1.com',
        passwordHash: 'hash123',
        salt: 'salt123',
      );

      final map = user.toMap();
      final fromMap = AppUser.fromMap(map);
      expect(fromMap.id, 'usr_1');
      expect(fromMap.name, 'Alex Verstappen');
      expect(fromMap.email, 'alex@f1.com');
    });
  });
}
