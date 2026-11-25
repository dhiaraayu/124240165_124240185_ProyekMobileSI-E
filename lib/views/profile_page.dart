import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/ticket_controller.dart';
import '../theme.dart';
import '../widgets/app_button.dart';
import 'favorites_page.dart';
import '../widgets/motion.dart';

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
              'Cancel',
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
              'Log Out',
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
      body: FadeSlideIn(
        offsetY: 12,
        duration: const Duration(milliseconds: 380),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Obx(() {
            final isLoggedIn = authCtrl.isLoggedIn.value;
            final userName = authCtrl.currentUserName.value;
            final userEmail = authCtrl.currentUserEmail.value;

            final activeOrders =
                orderCtrl.orders.where((o) => o.status != 'cancelled').toList();
            final ticketCount =
                activeOrders.fold<int>(0, (sum, o) => sum + o.quantity);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(isLoggedIn, userName, userEmail),
                const SizedBox(height: 12),
                if (!isLoggedIn)
                  AppButton(
                    text: 'Sign In / Sign Up',
                    onPressed: () => Get.toNamed('/login'),
                  ),
                if (isLoggedIn) ...[
                  Row(
                    children: [
                      Expanded(
                          child: _buildStatItem(
                              'Orders', '${activeOrders.length}')),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _buildStatItem('Tickets', '$ticketCount')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStatItem('Season', '2027')),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const Text('Account Overview', style: AppText.h2),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _buildAccountInfo(
                          icon: Icons.person_outline_rounded,
                          label: 'Account Name',
                          value: userName,
                        ),
                        const Divider(color: AppTheme.cardBorder, height: 1),
                        _buildAccountInfo(
                          icon: Icons.email_outlined,
                          label: 'Email Address',
                          value: userEmail,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                const Text('My Collection', style: AppText.h2),
                const SizedBox(height: 10),
                _buildMenuItem(
                  icon: Icons.favorite_rounded,
                  title: 'Favorite Tickets',
                  subtitle: 'View your saved tickets',
                  iconColor: AppTheme.f1Red,
                  onTap: _openFavorites,
                ),
                if (isLoggedIn) ...[
                  const SizedBox(height: 28),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _showLogoutDialog(context, authCtrl),
                      icon: const Icon(Icons.logout_rounded,
                          color: Color(0xFFFF6B66), size: 18),
                      label: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Color(0xFFFF6B66),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isLoggedIn, String userName, String userEmail) {
    final initial = isLoggedIn && userName.isNotEmpty
        ? userName[0].toUpperCase()
        : 'G';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A1220), AppTheme.cardBg],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.f1Red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.f1Red.withOpacity(0.3),
                  spreadRadius: 3,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
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
                  style: AppText.h2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  isLoggedIn ? userEmail : 'Sign in to manage your tickets',
                  style: AppText.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isLoggedIn) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded,
                            size: 13, color: AppTheme.success),
                        SizedBox(width: 4),
                        Text(
                          'Registered Member',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.gold,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: AppText.caption),
        ],
      ),
    );
  }

  Widget _buildAccountInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textMuted, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.caption),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Pressable(
      child: Material(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppText.title),
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppText.caption),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
