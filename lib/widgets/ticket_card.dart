import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ticket_package.dart';
import '../controllers/currency_controller.dart';
import '../controllers/ticket_controller.dart';
import '../theme.dart';
import 'motion.dart';

class TicketCard extends StatelessWidget {
  final TicketPackage ticket;
  final VoidCallback onTap;
  final VoidCallback? onMorePressed;
  final bool isHorizontalCard;

  /// Isi lebar penuh yang diberikan parent (dipakai carousel PageView).
  final bool fillWidth;

  /// Jika diisi, gambar kartu terbang mulus ke halaman detail (Hero).
  final String? heroTag;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
    this.onMorePressed,
    this.isHorizontalCard = true,
    this.fillWidth = false,
    this.heroTag,
  });

  IconData get _icon {
    switch (ticket.category) {
      case 'hospitality':
        return Icons.workspace_premium_rounded;
      case 'walkabout':
        return Icons.directions_walk_rounded;
      default:
        return Icons.event_seat_rounded;
    }
  }

  List<Color> get _tint {
    if (!ticket.isAvailable) {
      return const [Color(0xFF2A2A33), Color(0xFF1B1B22)];
    }
    switch (ticket.category) {
      case 'hospitality':
        return const [Color(0xFF4F4012), Color(0xFF1F2133)];
      case 'walkabout':
        return const [Color(0xFF4F2A1D), Color(0xFF1F2133)];
      default:
        return const [Color(0xFF3B2A55), Color(0xFF1F2133)];
    }
  }

  Color _urgencyColor(int r) =>
      r <= 5 ? AppTheme.f1Red : (r <= 20 ? AppTheme.gold : AppTheme.success);

  // Indikator urgensi (bukan kapasitas asli): makin sedikit sisa, makin penuh.
  double _urgencyFill(int r) =>
      r <= 5 ? 0.95 : (r <= 20 ? 0.8 : (r <= 50 ? 0.55 : 0.3));

  @override
  Widget build(BuildContext context) {
    final remaining = ticket.isAvailable ? ticket.remaining : null;

    return Pressable(
      child: Container(
        width: (isHorizontalCard && !fillWidth) ? 264.0 : double.infinity,
        margin: EdgeInsets.only(
          right: (isHorizontalCard && !fillWidth) ? 12 : 0,
          bottom: isHorizontalCard ? 0 : 14,
        ),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(22),
          border: ticket.featured
              ? Border.all(color: AppTheme.f1Red.withOpacity(0.35))
              : null,
          boxShadow: [
            BoxShadow(
              color: ticket.featured
                  ? AppTheme.f1Red.withOpacity(0.16)
                  : Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              splashColor: AppTheme.f1Red.withOpacity(0.12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildImage(remaining),
                  _buildBody(remaining),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(int? remaining) {
    final ticketCtrl = Get.find<TicketController>();

    Widget picture = Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          ticket.effectiveImageAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _tint,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Align(
              alignment: const Alignment(0.75, -0.2),
              child: Icon(
                _icon,
                size: 46,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.25),
                Colors.transparent,
                Colors.black.withOpacity(0.65),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );

    if (heroTag != null) {
      picture = Hero(tag: heroTag!, child: picture);
    }

    return SizedBox(
      height: isHorizontalCard ? 184 : 190,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          picture,
          Positioned(top: 9, left: 9, child: _buildBadge(remaining)),
          Positioned(
            top: 7,
            right: 8,
            child: Obx(() {
              final isWish = ticketCtrl.isWishlisted(ticket.id);
              return GestureDetector(
                onTap: () => ticketCtrl.toggleWishlist(ticket.id),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isWish
                        ? AppTheme.f1Red
                        : AppTheme.darkBg.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutBack,
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isWish ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isWish),
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              );
            }),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ticket.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  ticket.location,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(int? remaining) {
    String label;
    Color bg;
    Color fg;

    if (!ticket.isAvailable) {
      label = 'Sold Out';
      bg = AppTheme.soldOut.withOpacity(0.3);
      fg = Colors.white70;
    } else if (remaining != null && remaining <= 5) {
      label = 'Almost Gone';
      bg = AppTheme.f1Red.withOpacity(0.25);
      fg = const Color(0xFFFF6B66);
    } else if (ticket.featured) {
      label = 'Best Seller';
      bg = AppTheme.gold.withOpacity(0.2);
      fg = AppTheme.gold;
    } else {
      label = 'Available';
      bg = AppTheme.success.withOpacity(0.18);
      fg = AppTheme.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBody(int? remaining) {
    final currencyCtrl = Get.find<CurrencyController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (remaining != null) ...[
            Text(
              '$remaining left',
              style: TextStyle(
                color: _urgencyColor(remaining),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Container(
                height: 4,
                color: AppTheme.cardBorder,
                alignment: Alignment.centerLeft,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: _urgencyFill(remaining)),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => FractionallySizedBox(
                    widthFactor: v,
                    child: Container(color: _urgencyColor(remaining)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (!isHorizontalCard) ...[
            const SizedBox(height: 8),
            Text(
              ticket.description,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.startingPrice == null
                          ? 'Price Unavailable'
                          : 'From',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 1),
                    if (ticket.startingPrice == null)
                      const Text(
                        'Not Available',
                        style: TextStyle(
                          color: AppTheme.soldOut,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else ...[
                      Obx(
                        () => Text(
                          currencyCtrl.formatPrice(ticket.startingPrice!),
                          style: TextStyle(
                            color: ticket.isAvailable
                                ? AppTheme.textWhite
                                : AppTheme.soldOut,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Obx(() {
                        final equiv = currencyCtrl
                            .formatSgdEquivalent(ticket.startingPrice!);
                        if (equiv.isEmpty) return const SizedBox.shrink();
                        return Text(
                          equiv,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        );
                      }),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onMorePressed ?? onTap,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: ticket.isAvailable
                        ? AppTheme.f1Red
                        : AppTheme.surfaceBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
