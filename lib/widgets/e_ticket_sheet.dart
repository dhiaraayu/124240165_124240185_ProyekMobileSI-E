import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/order.dart';
import '../theme.dart';

/// Tanggal event berdasarkan jenis attendance pada order.
String eventDatesFor(String attendance) {
  switch (attendance) {
    case 'Friday':
      return '8 Oct 2027';
    case 'Saturday':
      return '9 Oct 2027';
    case 'Sunday':
      return '10 Oct 2027';
    default:
      return '8–10 Oct 2027';
  }
}

/// Isi QR: kode booking + nama pemegang tiket (untuk dipindai di gate).
String ticketQrData(Order order) =>
    'SGGP2027|${order.id}|${order.attendeeName}';

/// Menampilkan e-ticket (seperti tiket akses di aplikasi kereta):
/// QR code besar di layar.
void showETicket(BuildContext context, Order order) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppTheme.darkBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _ETicketSheet(order: order),
  );
}

class _ETicketSheet extends StatefulWidget {
  final Order order;

  const _ETicketSheet({required this.order});

  @override
  State<_ETicketSheet> createState() => _ETicketSheetState();
}

class _ETicketSheetState extends State<_ETicketSheet> {
  Widget _field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.textWhite,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final code = order.id.isEmpty
        ? '-'
        : (order.id.length > 8 ? order.id.substring(0, 8) : order.id)
            .toUpperCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              color: AppTheme.cardBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header merah
                  Container(
                    color: AppTheme.f1Red,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SINGAPORE GRAND PRIX 2027',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          order.packageName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.attendance} Pass',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // QR code
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 8),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: QrImageView(
                            data: ticketQrData(order),
                            version: QrVersions.auto,
                            size: 210,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '#$code',
                          style: const TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Show this QR code at the gate',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Perforasi
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final n = (c.maxWidth / 10).floor().clamp(1, 200);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              n,
                              (_) => Container(
                                width: 4,
                                height: 1.5,
                                color: AppTheme.cardBorder,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Detail
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: _field('Ticket holder', order.attendeeName),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 4,
                              child: _field('Tickets', '${order.quantity}'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: _field('Event dates',
                                  eventDatesFor(order.attendance)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 4,
                              child: _field(
                                'Status',
                                order.status == 'cancelled'
                                    ? 'Cancelled'
                                    : 'Confirmed',
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
        ],
      ),
    );
  }
}
