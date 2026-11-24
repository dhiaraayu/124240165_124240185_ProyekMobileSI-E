
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/ticket_controller.dart';
import '../theme.dart';
import '../widgets/app_button.dart';
import 'favorites_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showLogoutDialog(
    BuildContext context,
    AuthController authCtrl,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text(
          'Log Out?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.f1Red,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              authCtrl.logout();
            },
            child: const Text(
              'LOG OUT',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _openFavorites() {
    final ticketCtrl = Get.find<TicketController>();
    ticketCtrl.refreshWishlist();

    Get.to(() => const FavoritesPage());
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final orderCtrl = Get.find<OrderController>();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          final isLoggedIn = authCtrl.isLoggedIn.value;
          final userName = authCtrl.currentUserName.value;
          final userEmail = authCtrl.currentUserEmail.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PROFILE HEADER
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppTheme.f1Red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          isLoggedIn && userName.isNotEmpty
                              ? userName[0].toUpperCase()
                              : 'G',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLoggedIn ? userName : 'Guest User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isLoggedIn
                                ? userEmail
                                : 'Sign in to manage your tickets',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (!isLoggedIn)
                AppButton(
                  text: 'SIGN IN / SIGN UP',
                  onPressed: () => Get.toNamed('/login'),
                ),

              if (isLoggedIn) ...[
                // ACCOUNT STATISTICS
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'ORDERS',
                        '${orderCtrl.orders.length}',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.cardBorder,
                      ),
                      _buildStatItem(
                        'TICKETS',
                        '${orderCtrl.orders.fold<int>(
                          0,
                          (sum, item) => sum + item.quantity,
                        )}',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.cardBorder,
                      ),
                      _buildStatItem('SEASON', '2027'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ACCOUNT OVERVIEW
                const Text(
                  'ACCOUNT OVERVIEW',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAccountInfo(
                        icon: Icons.person_outline_rounded,
                        label: 'Account Name',
                        value: userName,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          color: AppTheme.cardBorder,
                          height: 1,
                        ),
                      ),
                      _buildAccountInfo(
                        icon: Icons.email_outlined,
                        label: 'Email Address',
                        value: userEmail,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          color: AppTheme.cardBorder,
                          height: 1,
                        ),
                      ),
                      _buildAccountInfo(
                        icon: Icons.verified_user_outlined,
                        label: 'Account Status',
                        value: 'Registered Member',
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // FAVORITES
              const Text(
                'MY COLLECTION',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 10),

              _buildMenuItem(
                icon: Icons.favorite_rounded,
                title: 'Favorite Tickets',
                subtitle: 'View your saved tickets',
                iconColor: AppTheme.f1Red,
                onTap: _openFavorites,
              ),

              const SizedBox(height: 24),

              // LOG OUT
              if (isLoggedIn)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.redAccent,
                    ),
                    label: const Text(
                      'LOG OUT',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.redAccent,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () =>
                        _showLogoutDialog(context, authCtrl),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.gold,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.f1Red,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppTheme.cardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: AppTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
