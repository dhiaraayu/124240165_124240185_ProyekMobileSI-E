import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../controllers/order_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/currency_controller.dart';
import '../theme.dart';
import '../widgets/app_button.dart';

class MyTicketsPage extends StatelessWidget {
  const MyTicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final orderCtrl = Get.find<OrderController>();
    final currencyCtrl = Get.find<CurrencyController>();

    return Scaffold(
      body: Obx(() {
        if (!authCtrl.isLoggedIn.value) {
          return _buildGuestPrompt();
        }

        orderCtrl.loadOrders();
        final orders = orderCtrl.orders;

        if (orders.isEmpty) {
          return _buildEmptyTickets(context);
        }

        return RefreshIndicator(
          onRefresh: () async => orderCtrl.loadOrders(),
          color: AppTheme.f1Red,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildTicketOrderCard(context, order, orderCtrl, currencyCtrl);
            },
          ),
        );
      }),
    );
  }

  Widget _buildGuestPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: const Icon(Icons.confirmation_number_outlined, size: 48, color: AppTheme.f1Red),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign In to View Your Tickets',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your booked passes, grandstand reservations, and reminders are tied to your personal account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Sign In / Register',
              width: 220,
              onPressed: () => Get.toNamed('/login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTickets(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.airplane_ticket_outlined, size: 54, color: AppTheme.textMuted.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'No Tickets Booked Yet',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Browse the official Grandstand, Walkabout, and Hospitality packages on the Home tab.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketOrderCard(
    BuildContext context,
    Order order,
    OrderController orderCtrl,
    CurrencyController currencyCtrl,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status Badge & Booking Date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'CONFIRMED & ACTIVE',
                      style: TextStyle(
                        color: AppTheme.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  dateFormat.format(order.createdAt),
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Package Name & Attendance Session
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.packageName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.f1Red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppTheme.f1Red.withOpacity(0.3)),
                            ),
                            child: Text(
                              order.attendance,
                              style: const TextStyle(
                                color: AppTheme.f1Red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyCtrl.formatPrice(order.totalPriceSGD),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '${order.quantity} x Tickets',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(color: AppTheme.cardBorder, height: 1),
                const SizedBox(height: 12),

                // Attendee Info
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: AppTheme.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Holder: ${order.attendeeName}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // KELOLA Button -> Opens "08 Kelola Tiket" Bottom Sheet
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.settings_outlined, size: 16, color: AppTheme.textWhite),
                    label: const Text(
                      'KELOLA TIKET',
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.cardBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: AppTheme.surfaceBg,
                    ),
                    onPressed: () => _openManageTicketBottomSheet(context, order, orderCtrl),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 08 Kelola Tiket Bottom Sheet (CRUD Update and Delete)
  void _openManageTicketBottomSheet(
    BuildContext context,
    Order order,
    OrderController orderCtrl,
  ) {
    final nameCtrl = TextEditingController(text: order.attendeeName);
    var currentQty = order.quantity;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '08 Kelola Tiket',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${order.packageName} (${order.attendance})',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Update Attendee Name
              const Text(
                'Ticket Holder Name',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.edit_outlined, color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 16),

              // Update Quantity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ticket Quantity',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          onPressed: currentQty > 1
                              ? () => setModalState(() => currentQty--)
                              : null,
                        ),
                        Text('$currentQty', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add, size: 16),
                          onPressed: currentQty < 10
                              ? () => setModalState(() => currentQty++)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Save Changes Button (CRUD Update)
              AppButton(
                text: 'Save Changes',
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  final navigator = Navigator.of(ctx);
                  await orderCtrl.updateTicket(
                    orderId: order.id,
                    newAttendeeName: nameCtrl.text.trim(),
                    newQuantity: currentQty,
                  );
                  navigator.pop();
                },
              ),

              const SizedBox(height: 12),

              // Cancel Ticket Button (CRUD Delete)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                  label: const Text(
                    'Cancel & Refund Ticket',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _showCancelConfirmDialog(context, order, orderCtrl);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelConfirmDialog(
    BuildContext context,
    Order order,
    OrderController orderCtrl,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Cancel Ticket Booking?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to cancel your ${order.packageName} booking? Your scheduled race reminders will also be cancelled.',
          style: const TextStyle(color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            child: const Text('Keep Ticket', style: TextStyle(color: AppTheme.textMuted)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Yes, Cancel Booking', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await orderCtrl.cancelTicket(order.id);
            },
          ),
        ],
      ),
    );
  }
}
