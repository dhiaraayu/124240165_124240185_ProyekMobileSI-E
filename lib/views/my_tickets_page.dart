import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../controllers/order_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/currency_controller.dart';
import '../theme.dart';
import '../widgets/app_button.dart';
import '../widgets/e_ticket_sheet.dart';
import '../widgets/motion.dart';
import '../widgets/segmented_filter.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  int _filter = 0; // 0 = Active, 1 = Cancelled

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final orderCtrl = Get.find<OrderController>();
    final currencyCtrl = Get.find<CurrencyController>();

    return Scaffold(
      body: FadeSlideIn(
        offsetY: 12,
        duration: const Duration(milliseconds: 380),
        child: Obx(() {
          if (!authCtrl.isLoggedIn.value) {
            return _buildGuestPrompt();
          }

          final all = orderCtrl.orders.toList();

          if (all.isEmpty) {
            return _buildEmptyTickets(context);
          }

          final active = all.where((o) => o.status != 'cancelled').toList();
          final cancelled = all.where((o) => o.status == 'cancelled').toList();
          final shown = _filter == 0 ? active : cancelled;

          return RefreshIndicator(
            onRefresh: () async => orderCtrl.loadOrders(),
            color: AppTheme.f1Red,
            backgroundColor: AppTheme.surfaceBg,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                const Text('My Tickets', style: AppText.h1),
                const SizedBox(height: 2),
                Text(
                  '${all.length} ${all.length == 1 ? 'booking' : 'bookings'}',
                  style: AppText.caption,
                ),
                const SizedBox(height: 14),
                SegmentedFilter(
                  labels: const ['Active', 'Cancelled'],
                  selectedIndex: _filter,
                  onChanged: (i) => setState(() => _filter = i),
                ),
                const SizedBox(height: 16),
                if (shown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        _filter == 0
                            ? 'No active bookings right now.'
                            : 'No cancelled bookings.',
                        style: AppText.caption,
                      ),
                    ),
                  )
                else
                  for (int i = 0; i < shown.length; i++)
                    FadeSlideIn(
                      key: ValueKey('${shown[i].id}-$_filter'),
                      delay: Duration(milliseconds: 70 * (i < 4 ? i : 4)),
                      offsetY: 18,
                      child: _buildTicketOrderCard(
                          context, shown[i], orderCtrl, currencyCtrl),
                    ),
              ],
            ),
          );
        }),
      ),
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
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: AppTheme.cardBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.confirmation_number_outlined,
                  size: 46, color: AppTheme.f1Red),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign In to View Your Tickets',
              style: AppText.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your booked passes, grandstand reservations, and reminders are tied to your personal account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppTheme.textMuted, fontSize: 13, height: 1.45),
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
            Icon(Icons.airplane_ticket_outlined,
                size: 54, color: AppTheme.textMuted.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('No Tickets Booked Yet', style: AppText.h2),
            const SizedBox(height: 8),
            const Text(
              'Browse the official Grandstand, Walkabout, and Hospitality packages on the Home tab.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppTheme.textMuted, fontSize: 13, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashedDivider() {
    return SizedBox(
      height: 18,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final n = (constraints.maxWidth / 9).floor();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    n,
                    (_) => Container(
                        width: 4, height: 1, color: AppTheme.cardBorder),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: -9,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: AppTheme.darkBg,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -9,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: AppTheme.darkBg,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.caption),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTicketOrderCard(
    BuildContext context,
    Order order,
    OrderController orderCtrl,
    CurrencyController currencyCtrl,
  ) {
    final isCancelled = order.status == 'cancelled';
    final dateFormat = DateFormat('dd MMM yyyy');
    final statusColor = isCancelled ? AppTheme.soldOut : AppTheme.success;

    return Opacity(
      opacity: isCancelled ? 0.7 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.packageName, style: AppText.title),
                        const SizedBox(height: 3),
                        Text(order.attendance, style: AppText.caption),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isCancelled ? 'Cancelled' : 'Confirmed',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _dashedDivider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _infoColumn('Booked', dateFormat.format(order.createdAt)),
                      _infoColumn('Quantity',
                          '${order.quantity} ${order.quantity == 1 ? 'Ticket' : 'Tickets'}'),
                      _infoColumn('Holder', order.attendeeName),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Text('Total', style: AppText.caption),
                      const Spacer(),
                      Obx(() => Text(
                            currencyCtrl.formatPrice(order.totalPriceSGD),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          )),
                    ],
                  ),
                  // Cancelled orders remain visible as history and cannot be edited.
                  if (!isCancelled) ...[
                    const SizedBox(height: 14),
                    Pressable(
                      child: SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: TextButton.icon(
                          icon: const Icon(Icons.tune_rounded,
                              size: 17, color: AppTheme.textWhite),
                          label: const Text(
                            'Manage Ticket',
                            style: TextStyle(
                              color: AppTheme.textWhite,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: AppTheme.surfaceBg,
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () => _openManageTicketBottomSheet(
                              context, order, orderCtrl),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
    final pageContext = context; // context halaman (bukan context sheet)

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                'Manage Ticket',
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
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  prefixIcon:
                      Icon(Icons.edit_outlined, color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 16),

              // Quantity is fixed after purchase; changing it requires a payment/refund flow.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ticket Quantity',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${order.quantity}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Save Changes Button (CRUD Update)
              AppButton(
                text: 'Save Changes',
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) {
                    Get.snackbar(
                      'Name Required',
                      'Please enter the ticket holder name.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppTheme.f1Red,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  final success = await orderCtrl.updateTicket(
                    orderId: order.id,
                    newAttendeeName: nameCtrl.text.trim(),
                    newQuantity: order.quantity,
                  );
                  if (success && Navigator.of(ctx).canPop()) {
                    Navigator.of(ctx).pop();
                  }
                },
              ),

              const SizedBox(height: 10),

              // E-ticket: tampilkan QR code
              AppButton(
                text: 'Lihat E-Ticket',
                icon: Icons.qr_code_2_rounded,
                isOutlined: true,
                color: AppTheme.textWhite,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  showETicket(pageContext, order);
                },
              ),

              const SizedBox(height: 6),

              // Cancel Ticket Button (CRUD Delete)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 18),
                  label: const Text(
                    'Cancel Ticket',
                    style: TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold),
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
        title: const Text('Cancel Ticket Booking?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to cancel your ${order.packageName} booking? The order will remain in your history, but no automatic refund will be processed.',
          style: const TextStyle(color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            child: const Text('Keep Ticket',
                style: TextStyle(color: AppTheme.textMuted)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Yes, Cancel Booking',
                style: TextStyle(color: Colors.white)),
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
