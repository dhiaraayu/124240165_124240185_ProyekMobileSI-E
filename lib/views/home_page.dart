import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/ticket_controller.dart';
import '../widgets/video_bg.dart';
import '../widgets/ticket_card.dart';
import '../theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();
    final ticketCtrl = Get.find<TicketController>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await homeCtrl.fetchWeatherAndAirQuality();
          ticketCtrl.loadTickets();
        },
        color: AppTheme.f1Red,
        child: SingleChildScrollView(
          controller: homeCtrl.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Banner / Video Background
              const VideoBgHero(),

              const SizedBox(height: 16),

              // 2. Weather & Air Quality Card (Open-Meteo API)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildWeatherAndHazeCard(homeCtrl),
              ),

              const SizedBox(height: 24),

              // 3. Ticket Carousel Section
              Padding(
                key: homeCtrl.carouselKey,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OFFICIAL TICKETS',
                          style: TextStyle(
                            color: AppTheme.f1Red,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Grandstand & Packages',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Obx(() => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.cardBorder),
                          ),
                          child: Text(
                            '${ticketCtrl.filteredTickets.length} Options',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Category Filter Pills
              _buildCategoryFilters(ticketCtrl),

              const SizedBox(height: 12),

              // Horizontal Ticket Carousel ("Entertainment Highlights" style)
              SizedBox(
                height: 330,
                child: Obx(() {
                  final list = ticketCtrl.filteredTickets;
                  if (list.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tickets found in this category.',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return TicketCard(
                        ticket: item,
                        isHorizontalCard: true,
                        onTap: () {
                          // Tap card -> navigates to "02 Detail - Overview"
                          ticketCtrl.selectTicket(item);
                          Get.toNamed('/ticket-detail', arguments: item);
                        },
                        onMorePressed: () {
                          // MORE button -> navigates to "02 Detail - Overview"
                          ticketCtrl.selectTicket(item);
                          Get.toNamed('/ticket-detail', arguments: item);
                        },
                      );
                    },
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Circuit Highlights & Race Schedule Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCircuitInfoSection(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherAndHazeCard(HomeController homeCtrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Obx(() {
        if (homeCtrl.isLoadingWeather.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.f1Red),
                  ),
                  SizedBox(width: 10),
                  Text('Loading Marina Bay live weather...',
                      style:
                          TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
          );
        }

        final w = homeCtrl.weather.value;
        final aq = homeCtrl.airQuality.value;

        return Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(w?.icon ?? '☀️',
                      style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Marina Bay Track Weather',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${w?.temperature.toStringAsFixed(1) ?? '29.0'}°C • ${w?.description ?? 'Clear Sky'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: AppTheme.success.withOpacity(0.4)),
                  ),
                  child: const Text(
                    'LIVE SGT',
                    style: TextStyle(
                      color: AppTheme.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppTheme.cardBorder, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.air, size: 16, color: AppTheme.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Air Quality: PM2.5 ${aq?.pm25.toStringAsFixed(1) ?? '12.0'} µg/m³ • ${aq?.qualityStatus ?? 'Good'}',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCategoryFilters(TicketController ticketCtrl) {
    const categories = [
      {'key': 'all', 'label': 'All Tickets'},
      {'key': 'grandstand', 'label': 'Grandstand'},
      {'key': 'walkabout', 'label': 'Walkabout'},
      {'key': 'hospitality', 'label': 'VIP Hospitality'},
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Obx(() {
            final isSelected = ticketCtrl.selectedCategory.value == cat['key'];
            return ChoiceChip(
              label: Text(cat['label']!),
              selected: isSelected,
              onSelected: (_) => ticketCtrl.setCategory(cat['key']!),
              selectedColor: AppTheme.f1Red,
              backgroundColor: AppTheme.cardBg,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textMuted,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.f1Red : AppTheme.cardBorder,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              showCheckmark: false,
            );
          });
        },
      ),
    );
  }

  Widget _buildCircuitInfoSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag_rounded, color: AppTheme.f1Red, size: 20),
              SizedBox(width: 8),
              Text(
                'Race Weekend Schedule',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildScheduleRow(
              'Friday, 8 Oct', 'Practice 1 & 2', '17:30 & 21:00 SGT'),
          const Divider(color: AppTheme.cardBorder, height: 16),
          _buildScheduleRow('Saturday, 9 Oct', 'Practice 3 & Qualifying',
              '17:30 & 21:00 SGT'),
          const Divider(color: AppTheme.cardBorder, height: 16),
          _buildScheduleRow(
              'Sunday, 10 Oct', 'Singapore Grand Prix (62 Laps)', '20:00 SGT'),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(String day, String event, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              event,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
        Text(
          time,
          style: const TextStyle(
              color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
