import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/ticket_package.dart';
import 'local_service.dart';

class TicketService {
  Future<void> seedIfEmpty() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/tickets.json');
      final List dynamicList = json.decode(jsonStr);
      for (final item in dynamicList) {
        final ticket = TicketPackage.fromMap(Map<String, dynamic>.from(item));
        await LocalService.ticketsBox.put(ticket.id, ticket);
      }
    } catch (e) {
      if (LocalService.ticketsBox.isEmpty) {
        final defaultTicket = TicketPackage(
          id: 'super-pit',
          category: 'grandstand',
          name: 'Super Pit Grandstand',
          zoneAccess: '1, 2, 3, 4',
          gates: '1, 2',
          location: 'Pit Straight',
          price3Day: 2608,
          priceFri: 988,
          priceSat: 1288,
          priceSun: 1888,
          overview: [
            'Access Zones: 1, 2, 3, 4',
            'Preferred Gates: 1, 2',
            'Located along Pit Straight',
            'Access to all performance stages',
            'Commemorative ticket with lanyard',
            'S\$100 food vouchers for use across the 3 days',
            '6 drink vouchers per day',
          ],
          description: 'Upper deck with direct views of pit lane, starting grid, and podium ceremony.',
          imageAsset: 'assets/images/super-pit.jpg',
          status: 'available',
          featured: true,
        );
        await LocalService.ticketsBox.put(defaultTicket.id, defaultTicket);
      }
    }
  }

  List<TicketPackage> getAllTickets() {
    return LocalService.ticketsBox.values.toList();
  }

  List<TicketPackage> getFeaturedTickets() {
    final list = LocalService.ticketsBox.values.where((t) => t.featured).toList();
    if (list.isEmpty) {
      return LocalService.ticketsBox.values.take(5).toList();
    }
    return list;
  }

  TicketPackage? getTicketById(String id) {
    return LocalService.ticketsBox.get(id);
  }

  bool isWishlisted(String userId, String packageId) {
    final key = '$userId:$packageId';
    return LocalService.wishlistBox.containsKey(key);
  }

  Future<bool> toggleWishlist(String userId, String packageId) async {
    final key = '$userId:$packageId';
    if (LocalService.wishlistBox.containsKey(key)) {
      await LocalService.wishlistBox.delete(key);
      return false;
    } else {
      await LocalService.wishlistBox.put(key, packageId);
      return true;
    }
  }

  List<TicketPackage> getWishlistedTickets(String userId) {
    final userPrefix = '$userId:';
    final ticketIds = LocalService.wishlistBox.keys
        .where((k) => k.toString().startsWith(userPrefix))
        .map((k) => LocalService.wishlistBox.get(k))
        .whereType<String>()
        .toList();

    return ticketIds
        .map((id) => LocalService.ticketsBox.get(id))
        .whereType<TicketPackage>()
        .toList();
  }
}
