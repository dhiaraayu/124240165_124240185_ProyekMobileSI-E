import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controllers/home_controller.dart';
import '../theme.dart';

class VideoBgHero extends StatefulWidget {
  const VideoBgHero({super.key});

  @override
  State<VideoBgHero> createState() => _VideoBgHeroState();
}

class _VideoBgHeroState extends State<VideoBgHero> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/videos/hero.mp4');
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.setVolume(0.0);
      _videoController!.play();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (_) {
      // Fallback gracefully to animated gradient background if video is not available or corrupted
      _isVideoInitialized = false;
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();

    return Container(
      height: 380,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0D0E16),
      ),
      child: Stack(
        children: [
          // 1. Video Player background (if hero.mp4 is available)
          if (_isVideoInitialized && _videoController != null)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),

          // 2. Dynamic Gradient Overlay & Speed line pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.f1Red.withOpacity(_isVideoInitialized ? 0.35 : 0.45),
                    const Color(0xFF0B0C14).withOpacity(_isVideoInitialized ? 0.75 : 0.95),
                    AppTheme.darkBg,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Speed lines & background graphic
          Positioned(
            top: 40,
            right: -30,
            child: Transform.rotate(
              angle: -0.2,
              child: Opacity(
                opacity: 0.12,
                child: const Icon(
                  Icons.sports_motorsports_rounded,
                  size: 260,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Hero Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.f1Red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'FORMULA 1 SINGAPORE GP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'MARINA BAY • 8-10 OCT 2027',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                const Text(
                  '2027 TICKETS\nNOW ON SALE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Countdown Timer (DAYS / HRS / MINS / SECS)
                Obx(() => Row(
                      children: [
                        _buildCountdownBox('DAYS', homeCtrl.days.value),
                        const SizedBox(width: 8),
                        _buildCountdownBox('HRS', homeCtrl.hours.value),
                        const SizedBox(width: 8),
                        _buildCountdownBox('MINS', homeCtrl.minutes.value),
                        const SizedBox(width: 8),
                        _buildCountdownBox('SECS', homeCtrl.seconds.value),
                      ],
                    )),
                const SizedBox(height: 20),

                // BUY NOW Button (Scrolls to Carousel)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: homeCtrl.scrollToCarousel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.f1Red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'BUY NOW',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.keyboard_double_arrow_down_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownBox(String label, int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBg.withOpacity(0.85),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          children: [
            Text(
              value.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
