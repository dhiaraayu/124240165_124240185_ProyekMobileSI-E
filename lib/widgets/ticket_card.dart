import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ticket_package.dart';
import '../controllers/currency_controller.dart';
import '../controllers/ticket_controller.dart';
import '../theme.dart';

class TicketCard extends StatelessWidget {
  final TicketPackage ticket;
  final VoidCallback onTap;
  final VoidCallback? onMorePressed;
  final bool isHorizontalCard;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
    this.onMorePressed,
    this.isHorizontalCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final currencyCtrl = Get.find<CurrencyController>();
    final ticketCtrl = Get.find<TicketController>();

    return Container(
      width: isHorizontalCard ? 270.0 : double.infinity,
      margin: EdgeInsets.only(
        right: isHorizontalCard ? 16 : 0,
        bottom: isHorizontalCard ? 0 : 16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ticket.featured
              ? AppTheme.f1Red.withOpacity(0.6)
              : AppTheme.cardBorder,
          width: ticket.featured ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          splashColor: AppTheme.f1Red.withOpacity(0.15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ticket Image
              Stack(
                children: [
                  SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          ticket.effectiveImageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: ticket.isAvailable
                                    ? [
                                        const Color(0xFF1F2133),
                                        const Color(0xFF2C2F48),
                                      ]
                                    : [
                                        const Color(0xFF1B1B22),
                                        const Color(0xFF24242E),
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                ticket.category == 'hospitality'
                                    ? Icons.hotel_class_rounded
                                    : ticket.category == 'walkabout'
                                        ? Icons.directions_walk_rounded
                                        : Icons.stadium_rounded,
                                color: ticket.isAvailable
                                    ? AppTheme.f1Red
                                    : AppTheme.soldOut,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.35),
                                Colors.transparent,
                                AppTheme.cardBg.withOpacity(0.85),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Tags
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ticket.isAvailable
                                ? AppTheme.success.withOpacity(0.9)
                                : AppTheme.soldOut.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ticket.isAvailable ? 'AVAILABLE' : 'SOLD OUT',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.darkBg.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.cardBorder),
                          ),
                          child: const Text(
                            '3-DAY PASS',
                            style: TextStyle(
                              color: AppTheme.textWhite,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Wishlist
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Obx(() {
                      final isWish = ticketCtrl.isWishlisted(ticket.id);

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => ticketCtrl.toggleWishlist(ticket.id),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.darkBg.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isWish ? Icons.favorite : Icons.favorite_border,
                              color: isWish ? AppTheme.f1Red : Colors.white70,
                              size: 18,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),

              // Ticket Details
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${ticket.location} • Zone ${ticket.zoneAccess}',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Text(
                      ticket.name,
                      style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

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
                    const SizedBox(height: 12),

                    const Divider(
                      color: AppTheme.cardBorder,
                      height: 1,
                    ),
                    const SizedBox(height: 10),

                    // Price and More Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.startingPrice == null
                                    ? 'Price unavailable'
                                    : 'Starting from',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Obx(
                                () => Text(
                                  ticket.startingPrice == null
                                      ? 'Not Available'
                                      : currencyCtrl.formatPrice(
                                          ticket.startingPrice!,
                                        ),
                                  style: TextStyle(
                                    color: ticket.isAvailable
                                        ? AppTheme.textWhite
                                        : AppTheme.soldOut,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Obx(() {
                                if (ticket.startingPrice == null) {
                                  return const SizedBox.shrink();
                                }
                                final equiv = currencyCtrl.formatSgdEquivalent(
                                  ticket.startingPrice!,
                                );

                                if (equiv.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                return Text(
                                  equiv,
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 9,
                                  ),
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: onMorePressed ?? onTap,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.cardBorder,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'MORE',
                                  style: TextStyle(
                                    color: AppTheme.textWhite,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 10,
                                  color: AppTheme.textWhite,
                                ),
                              ],
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
        ),
      ),
    );
  }
}
