import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/ticket_controller.dart';
import '../controllers/currency_controller.dart';
import '../models/ticket_package.dart';
import '../theme.dart';
import '../widgets/motion.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ticketCtrl = Get.find<TicketController>();
    final authCtrl = Get.find<AuthController>();
    final currencyCtrl = Get.find<CurrencyController>();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Favorite Tickets',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FadeSlideIn(
        offsetY: 12,
        duration: const Duration(milliseconds: 380),
        child: Obx(() {
        if (!authCtrl.isLoggedIn.value) {
          return _buildEmptyState(
            icon: Icons.lock_outline_rounded,
            title: 'Sign In Required',
            subtitle: 'Sign in to access your saved tickets.',
            buttonText: 'Sign In / Sign Up',
            onPressed: () => Get.toNamed('/login'),
          );
        }

        final favorites = ticketCtrl.tickets
            .where(
              (ticket) => ticketCtrl.wishlistedIds.contains(ticket.id),
            )
            .toList();

        if (favorites.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'No Favorites Yet',
            subtitle:
                'Save your favorite grandstands and packages to find them here.',
            buttonText: 'Browse Tickets',
            onPressed: () => Get.back(),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Text(
                '${favorites.length} Saved Tickets',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final ticket = favorites[index];

                  return _buildFavoriteCard(
                    ticket,
                    ticketCtrl,
                    currencyCtrl,
                  );
                },
              ),
            ),
          ],
        );
      }),
      ),
    );
  }

  Widget _buildFavoriteCard(
    TicketPackage ticket,
    TicketController ticketCtrl,
    CurrencyController currencyCtrl,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Stack(
              children: [
                SizedBox(
                  height: 155,
                  width: double.infinity,
                  child: Image.asset(
                    ticket.effectiveImageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.surfaceBg,
                        child: const Center(
                          child: Icon(
                            Icons.confirmation_number_outlined,
                            color: AppTheme.f1Red,
                            size: 42,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ticket.isAvailable
                          ? AppTheme.success
                          : AppTheme.soldOut,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ticket.isAvailable ? 'Available' : 'Sold Out',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black.withOpacity(0.65),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'Remove From Favorites',
                      onPressed: () {
                        ticketCtrl.toggleWishlist(ticket.id);
                      },
                      icon: const Icon(
                        Icons.favorite,
                        color: AppTheme.f1Red,
                        size: 21,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${ticket.location} • Zone ${ticket.zoneAccess}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Starting From',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              currencyCtrl.formatPrice(
                                ticket.price3Day,
                              ),
                              style: const TextStyle(
                                color: AppTheme.f1Red,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        ticketCtrl.toggleWishlist(ticket.id);
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      label: const Text(
                        'Remove',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Icon(
                icon,
                size: 42,
                color: AppTheme.f1Red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.f1Red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
