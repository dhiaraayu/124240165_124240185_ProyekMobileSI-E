import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ticket_package.dart';
import '../controllers/ticket_controller.dart';
import '../controllers/currency_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/currency_selector.dart';
import '../widgets/segmented_filter.dart';
import '../theme.dart';
import '../widgets/motion.dart';

class TicketDetailPage extends StatefulWidget {
  const TicketDetailPage({super.key});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  late TicketPackage _ticket;
  bool _invalidTicket = false;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    final ticketCtrl = Get.find<TicketController>();
    final arg = Get.arguments;
    if (arg is TicketPackage) {
      _ticket = arg;
    } else if (ticketCtrl.selectedTicket.value != null) {
      _ticket = ticketCtrl.selectedTicket.value!;
    } else if (ticketCtrl.tickets.isNotEmpty) {
      _ticket = ticketCtrl.tickets.first;
    } else {
      _invalidTicket = true;
    }
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

    // Guest flow: Buy -> Sign In / Register -> Checkout
    authCtrl.requireLogin(
      message: 'Please sign in or register to complete your booking.',
      onSuccess: () {
        Get.toNamed('/checkout', arguments: _ticket);
      },
    );
  }

  IconData get _categoryIcon {
    switch (_ticket.category) {
      case 'hospitality':
        return Icons.workspace_premium_rounded;
      case 'walkabout':
        return Icons.directions_walk_rounded;
      default:
        return Icons.event_seat_rounded;
    }
  }

  String get _categoryLabel => _ticket.category.isEmpty
      ? ''
      : _ticket.category[0].toUpperCase() + _ticket.category.substring(1);

  Color _urgencyColor(int r) =>
      r <= 5 ? AppTheme.f1Red : (r <= 20 ? AppTheme.gold : AppTheme.success);

  @override
  Widget build(BuildContext context) {
    final ticketCtrl = Get.find<TicketController>();
    final currencyCtrl = Get.find<CurrencyController>();

    if (_invalidTicket) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ticket Details')),
        body: const Center(
          child: Text(
            'Ticket details are unavailable. Please return and select a ticket.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leadingWidth: 58,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14, top: 8, bottom: 8),
          child: _CircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Get.back(),
          ),
        ),
        actions: [
          Obx(() {
            final isWish = ticketCtrl.isWishlisted(_ticket.id);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _CircleButton(
                icon: isWish ? Icons.favorite : Icons.favorite_border,
                color: isWish ? AppTheme.f1Red : Colors.white,
                onTap: () => ticketCtrl.toggleWishlist(_ticket.id),
              ),
            );
          }),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: CurrencySelector(isCompact: true),
          ),
        ],
      ),
      body: FadeSlideIn(
        offsetY: 0,
        duration: const Duration(milliseconds: 380),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_ticket.name, style: AppText.h1),
                          const SizedBox(height: 4),
                          Text(_ticket.location, style: AppText.caption),
                          const SizedBox(height: 14),
                          _buildPriceRow(currencyCtrl),
                          const SizedBox(height: 18),
                          SegmentedFilter(
                            labels: const ['Overview', 'Pricing Details'],
                            selectedIndex: _tab,
                            onChanged: (i) => setState(() => _tab = i),
                          ),
                          const SizedBox(height: 18),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: KeyedSubtree(
                              key: ValueKey(_tab),
                              child: _tab == 0
                                  ? _buildOverviewTab()
                                  : _buildPricingDetailsTab(currencyCtrl),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(currencyCtrl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'ticket-img-${_ticket.id}',
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  _ticket.effectiveImageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3B2A55), Color(0xFF1F2133)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Align(
                      alignment: const Alignment(0.7, -0.1),
                      child: Icon(
                        _categoryIcon,
                        size: 110,
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                        AppTheme.darkBg,
                      ],
                      stops: const [0.0, 0.45, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            bottom: 38,
            child: Row(
              children: [
                _pill(
                  _ticket.isAvailable ? 'Available' : 'Sold Out',
                  _ticket.isAvailable
                      ? AppTheme.success.withOpacity(0.2)
                      : AppTheme.soldOut.withOpacity(0.25),
                  _ticket.isAvailable ? AppTheme.success : Colors.white70,
                ),
                const SizedBox(width: 6),
                _pill(
                  _categoryLabel,
                  Colors.white.withOpacity(0.14),
                  Colors.white,
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 22,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppTheme.darkBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPriceRow(CurrencyController currencyCtrl) {
    final remaining = _ticket.isAvailable ? _ticket.remaining : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _ticket.startingPrice == null
              ? const Text(
                  'Not Available',
                  style: TextStyle(
                    color: AppTheme.soldOut,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('From', style: AppText.caption),
                    Obx(() => Text(
                          currencyCtrl.formatPrice(_ticket.startingPrice!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        )),
                    Obx(() {
                      final equiv = currencyCtrl
                          .formatSgdEquivalent(_ticket.startingPrice!);
                      if (equiv.isEmpty) return const SizedBox.shrink();
                      return Text(equiv, style: AppText.caption);
                    }),
                  ],
                ),
        ),
        if (remaining != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _urgencyColor(remaining).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$remaining left',
              style: TextStyle(
                color: _urgencyColor(remaining),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _infoTile(Icons.grid_view_rounded, 'Access Zones',
                  'Zone ${_ticket.zoneAccess}'),
              const SizedBox(width: 8),
              _infoTile(Icons.door_front_door_outlined, 'Preferred Gates',
                  'Gate ${_ticket.gates}'),
              const SizedBox(width: 8),
              _infoTile(
                  Icons.place_outlined, 'Track Location', _ticket.location),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('About This Package', style: AppText.h2),
        const SizedBox(height: 8),
        Text(
          _ticket.description,
          style: const TextStyle(
              color: AppTheme.textMuted, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 24),
        const Text("What's Included", style: AppText.h2),
        const SizedBox(height: 12),
        ..._ticket.overview.map((benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppTheme.success, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      benefit,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppTheme.f1Red),
            const SizedBox(height: 8),
            Text(label, style: AppText.caption),
            const SizedBox(height: 2),
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
    );
  }

  Widget _buildPricingDetailsTab(CurrencyController currencyCtrl) {
    final days = [
      {'name': '3-Day (Fri - Sun)', 'price': _ticket.price3Day},
      {'name': 'Friday Pass', 'price': _ticket.priceFri},
      {'name': 'Saturday Pass', 'price': _ticket.priceSat},
      {'name': 'Sunday Pass', 'price': _ticket.priceSun},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Session Breakdown & Pricing', style: AppText.h2),
        const SizedBox(height: 6),
        const Text(
          'Prices shown in your active currency. Subject to availability.',
          style: AppText.caption,
        ),
        const SizedBox(height: 16),
        ...days.map((item) {
          final dayName = item['name'] as String;
          final price = item['price'] as double?;
          final isAvailable = price != null && price > 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          color: isAvailable ? Colors.white : AppTheme.soldOut,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAvailable
                            ? 'Grandstand reserved seat'
                            : 'Not offered for single day',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  if (!isAvailable) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBg,
                        borderRadius: BorderRadius.circular(20),
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
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        currencyCtrl.formatSgdEquivalent(price),
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
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
    );
  }

  Widget _buildBottomBar(CurrencyController currencyCtrl) {
    final canBuy = _ticket.isAvailable && _ticket.availableDays.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('From', style: AppText.caption),
                  _ticket.startingPrice == null
                      ? const Text(
                          'Not Available',
                          style: TextStyle(
                            color: AppTheme.soldOut,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : Obx(() => Text(
                            currencyCtrl.formatPrice(_ticket.startingPrice!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          )),
                ],
              ),
            ),
            Pressable(
              child: SizedBox(
                width: 170,
                height: 50,
                child: ElevatedButton(
                  onPressed: canBuy ? _onBuyPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.f1Red,
                    disabledBackgroundColor: AppTheme.soldOut.withOpacity(0.4),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    !_ticket.isAvailable
                        ? 'Sold Out'
                        : (_ticket.availableDays.isEmpty
                            ? 'Not Available'
                            : 'Buy Now'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
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

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.darkBg.withOpacity(0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 19, color: color),
        ),
      ),
    );
  }
}
