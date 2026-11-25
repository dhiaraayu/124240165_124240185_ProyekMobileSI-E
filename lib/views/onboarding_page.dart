import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme.dart';
import '../widgets/onboarding_visual.dart';

class _OnboardData {
  final String overline;
  final String title;
  final String description;
  final String? extra;
  final int variant;
  final List<String> assets;
  final bool showTicket;

  const _OnboardData({
    required this.overline,
    required this.title,
    required this.description,
    required this.variant,
    this.extra,
    this.assets = const [],
    this.showTicket = false,
  });
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _page = 0;

  static const List<_OnboardData> _pages = [
    _OnboardData(
      overline: 'SG GP Tickets 2027',
      title: 'Welcome to\nSingapore GP',
      description: 'Get ready for the ultimate night race experience.',
      extra: 'Your official app for Singapore Grand Prix 2027 tickets.',
      variant: 0,
      assets: ['assets/images/onboarding_1.jpg'],
    ),
    _OnboardData(
      overline: 'Experience the race',
      title: 'Feel the\nNight Race',
      description:
          'Experience the excitement of Formula 1 at the heart of Singapore.',
      variant: 1,
      assets: ['assets/images/onboarding_2.jpg'],
    ),
    _OnboardData(
      overline: 'Your ticket, your experience',
      title: 'Your Race Pass,\nOne Tap Away',
      description: 'Discover, manage, and access your race tickets in one place.',
      variant: 2,
      assets: ['assets/images/onboarding_3.jpg'],
      showTicket: true,
    ),
  ];

  bool get _isLast => _page == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToAuth() => Get.toNamed('/auth-choice');

  void _next() {
    if (_isLast) {
      _goToAuth();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => _OnboardPageView(data: _pages[i]),
          ),

          // Bar atas: brand + Skip
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 12, 0),
              child: Row(
                children: [
                  Container(width: 4, height: 18, color: AppTheme.f1Red),
                  const SizedBox(width: 10),
                  const Text(
                    'SG GP TICKETS 2027',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isLast ? 0 : 1,
                    child: IgnorePointer(
                      ignoring: _isLast,
                      child: TextButton(
                        onPressed: _goToAuth,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Kontrol bawah: indikator + Next / Get Started
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
                child: Row(
                  children: [
                    Row(
                      children: List.generate(_pages.length, (i) {
                        final active = i == _page;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.only(right: 6),
                          width: active ? 26 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                active ? AppTheme.f1Red : AppTheme.cardBorder,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.f1Red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _isLast ? 'GET STARTED' : 'NEXT',
                                key: ValueKey(_isLast),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPageView extends StatelessWidget {
  final _OnboardData data;

  const _OnboardPageView({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        OnboardingBackdrop(assets: data.assets, variant: data.variant),

        // Overlay gelap agar teks selalu terbaca di atas foto
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.35),
                Colors.transparent,
                AppTheme.darkBg.withOpacity(0.92),
                AppTheme.darkBg,
              ],
              stops: const [0.0, 0.3, 0.68, 1.0],
            ),
          ),
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: data.showTicket
                      ? const Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: _TicketMock(),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Text(
                  data.overline.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.f1Red,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    height: 1.02,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  data.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    height: 1.45,
                  ),
                ),
                if (data.extra != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    data.extra!,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketMock extends StatelessWidget {
  const _TicketMock();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.f1Red.withOpacity(0.25),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppTheme.f1Red,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SINGAPORE GRAND PRIX 2027',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Race Pass',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  size: 120,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '8–10 OCT 2027',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'MARINA BAY',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
