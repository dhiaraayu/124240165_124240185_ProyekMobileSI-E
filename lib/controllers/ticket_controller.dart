import 'package:get/get.dart';
import '../models/ticket_package.dart';
import '../services/ticket_service.dart';
import 'auth_controller.dart';

class TicketController extends GetxController {
  final TicketService _ticketService = TicketService();

  final tickets = <TicketPackage>[].obs;
  final featuredTickets = <TicketPackage>[].obs;
  final selectedCategory = 'all'.obs;
  final selectedTicket = Rxn<TicketPackage>();
  final selectedDay = '3-Day'.obs;
  final wishlistedIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadTickets();
  }

  void loadTickets() {
    tickets.value = _ticketService.getAllTickets();
    featuredTickets.value = _ticketService.getFeaturedTickets();
    refreshWishlist();
  }

  void refreshWishlist() {
    final authCtrl = Get.find<AuthController>();
    if (authCtrl.isLoggedIn.value) {
      final list = _ticketService.getWishlistedTickets(authCtrl.currentUserId.value);
      wishlistedIds.assignAll(list.map((t) => t.id).toSet());
    } else {
      wishlistedIds.clear();
    }
  }

  bool isWishlisted(String packageId) {
    return wishlistedIds.contains(packageId);
  }

  Future<void> toggleWishlist(String packageId) async {
    final authCtrl = Get.find<AuthController>();
    authCtrl.requireLogin(
      message: 'Sign in to save tickets to your wishlist.',
      onSuccess: () async {
        final added = await _ticketService.toggleWishlist(
          authCtrl.currentUserId.value,
          packageId,
        );
        if (added) {
          wishlistedIds.add(packageId);
          Get.snackbar(
            'Wishlist Updated',
            'Added ticket to your wishlist ❤️',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          wishlistedIds.remove(packageId);
          Get.snackbar(
            'Wishlist Updated',
            'Removed ticket from your wishlist',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      },
    );
  }

  List<TicketPackage> get filteredTickets {
    if (selectedCategory.value == 'all') return tickets;
    return tickets.where((t) => t.category == selectedCategory.value).toList();
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void selectTicket(TicketPackage ticket) {
    selectedTicket.value = ticket;
    // Default to first available day
    if (ticket.availableDays.isNotEmpty) {
      selectedDay.value = ticket.availableDays.first;
    } else {
      selectedDay.value = '3-Day';
    }
  }
}
