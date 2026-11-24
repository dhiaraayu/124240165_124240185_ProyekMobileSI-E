import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ticket_package.dart';
import '../controllers/ticket_controller.dart';
import '../controllers/currency_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/currency_selector.dart';
import '../theme.dart';

class TicketDetailPage extends StatefulWidget {
  const TicketDetailPage({super.key});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TicketPackage _ticket;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final ticketCtrl = Get.find<TicketController>();
    final arg = Get.arguments;
    if (arg is TicketPackage) {
      _ticket = arg;
    } else if (ticketCtrl.selectedTicket.value != null) {
      _ticket = ticketCtrl.selectedTicket.value!;
    } else {
      _ticket = ticketCtrl.tickets.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onBuyPressed() {
    final authCtrl = Get.find<AuthController>();

    if (!_ticket.isAvailable) {
      Get.snackbar(
        'Ticket Sold Out',
        'This ticket package is currently sold out.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.cardBg,
        colorText: Colors.white,
      );
      return;
    }

    // Guest Flow: BUY -> "04 Masuk / Daftar" -> "05 Checkout"
    authCtrl.requireLogin(
      message: 'Please sign in or register to complete your booking.',
      onSuccess: () {
        Get.toNamed('/checkout', arguments: _ticket);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticketCtrl = Get.find<TicketController>();
    final currencyCtrl = Get.find<CurrencyController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _ticket.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Obx(() {
            final isWish = ticketCtrl.isWishlisted(_ticket.id);
            return IconButton(
              icon: Icon(
                isWish ? Icons.favorite : Icons.favorite_border,
                color: isWish ? AppTheme.f1Red : Colors.white,
              ),
              onPressed: () => ticketCtrl.toggleWishlist(_ticket.id),
            );
          }),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CurrencySelector(isCompact: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Hero Ticket Photo Banner
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  _ticket.effectiveImageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.cardBg,
                    child: const Center(
                      child: Icon(Icons.confirmation_number_outlined, size: 48, color: AppTheme.f1Red),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.2),
                        AppTheme.cardBg.withOpacity(0.95),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Header Details & Badge Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppTheme.cardBg,
              border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceBg,
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Image.asset(
                      _ticket.effectiveImageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        _ticket.category == 'hospitality'
                            ? Icons.hotel_class_rounded
                            : (_ticket.category == 'walkabout'
                                ? Icons.directions_walk_rounded
                                : Icons.stadium_rounded),
                        color: AppTheme.f1Red,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _ticket.isAvailable
                                  ? AppTheme.success.withOpacity(0.2)
                                  : AppTheme.soldOut.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _ticket.isAvailable
                                    ? AppTheme.success
                                    : AppTheme.soldOut,
                              ),
                            ),
                            child: Text(
                              _ticket.isAvailable ? 'AVAILABLE' : 'SOLD OUT',
                              style: TextStyle(
                                color: _ticket.isAvailable
                                    ? AppTheme.success
                                    : AppTheme.soldOut,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _ticket.category.toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.gold,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Obx(() => Text(
                            currencyCtrl.formatPrice(_ticket.price3Day),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          )),
                      Obx(() {
                        final equiv = currencyCtrl.formatSgdEquivalent(_ticket.price3Day);
                        if (equiv.isEmpty) return const SizedBox.shrink();
                        return Text(
                          equiv,
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Two Tabs: 02 Overview & 03 Pricing Details
          Container(
            color: AppTheme.cardBg,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '02 Overview'),
                Tab(text: '03 Pricing Details'),
              ],
            ),
          ),

          // TabBarView Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 02: Overview
                _buildOverviewTab(),

                // TAB 03: Pricing Details
                _buildPricingDetailsTab(currencyCtrl),
              ],
            ),
          ),

          // Bottom Bar with BUY Button
          _buildBottomBar(currencyCtrl),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Specs Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Column(
              children: [
                _buildSpecItem(Icons.grid_view_rounded, 'Access Zones', 'Zone ${_ticket.zoneAccess}'),
                const Divider(color: AppTheme.cardBorder, height: 16),
                _buildSpecItem(Icons.door_front_door_outlined, 'Preferred Gates', 'Gate ${_ticket.gates}'),
                const Divider(color: AppTheme.cardBorder, height: 16),
                _buildSpecItem(Icons.place_outlined, 'Track Location', _ticket.location),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Description
          const Text(
            'About This Package',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _ticket.description,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 14, height: 1.5),
          ),

          const SizedBox(height: 20),

          // Benefits / Overview List
          const Text(
            'Package Benefits & Inclusions',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._ticket.overview.map((benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        benefit,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.f1Red),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPricingDetailsTab(CurrencyController currencyCtrl) {
    final days = [
      {'name': '3-Day (Fri - Sun)', 'price': _ticket.price3Day},
      {'name': 'Friday Pass', 'price': _ticket.priceFri},
      {'name': 'Saturday Pass', 'price': _ticket.priceSat},
      {'name': 'Sunday Pass', 'price': _ticket.priceSun},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session Breakdown & Pricing',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Prices shown in your active currency. Subject to availability.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ...days.map((item) {
            final dayName = item['name'] as String;
            final price = item['price'] as double?;
            final isAvailable = price != null && price > 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isAvailable ? AppTheme.cardBorder : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAvailable ? 'Grandstand reserved seat' : 'Not offered for single day',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  Obx(() {
                    if (!isAvailable) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Not Available',
                          style: TextStyle(
                            color: AppTheme.soldOut,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyCtrl.formatPrice(price),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currencyCtrl.formatSgdEquivalent(price),
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar(CurrencyController currencyCtrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppTheme.cardBg,
        border: Border(top: BorderSide(color: AppTheme.cardBorder)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('From', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  Obx(() => Text(
                        currencyCtrl.formatPrice(_ticket.price3Day),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      )),
                ],
              ),
            ),
            SizedBox(
              width: 170,
              height: 48,
              child: ElevatedButton(
                onPressed: _ticket.isAvailable ? _onBuyPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.f1Red,
                  disabledBackgroundColor: AppTheme.soldOut.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _ticket.isAvailable ? 'BUY NOW' : 'SOLD OUT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
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
