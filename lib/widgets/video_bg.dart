import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controllers/home_controller.dart';
import '../theme.dart';
import 'motion.dart';

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
      height: 350,
      width: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFF0D0E16)),
      child: Stack(
        children: [
          // 1. Video latar (jika hero.mp4 tersedia)
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

          // 2. Overlay gradien
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.f1Red
                        .withOpacity(_isVideoInitialized ? 0.30 : 0.40),
                    const Color(0xFF0B0C14)
                        .withOpacity(_isVideoInitialized ? 0.75 : 0.95),
                    AppTheme.darkBg,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 3. Ikon latar samar
          Positioned(
            top: 30,
            right: -30,
            child: Transform.rotate(
              angle: -0.2,
              child: const Opacity(
                opacity: 0.08,
                child: Icon(
                  Icons.sports_motorsports_rounded,
                  size: 240,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // 4. Lengkungan menyambung ke konten di bawah
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 22,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.darkBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(22)),
              ),
            ),
          ),

          // 5. Isi hero
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 38),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.f1Red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Singapore GP · 8–10 Oct 2027',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                const Text(
                  '2027 Tickets\nNow On Sale',
                  style: AppText.display,
                ),
                const SizedBox(height: 18),

                // Hitung mundur
                Obx(() => Row(
                      children: [
                        _buildCountdownBox('days', homeCtrl.days.value),
                        const SizedBox(width: 8),
                        _buildCountdownBox('hrs', homeCtrl.hours.value),
                        const SizedBox(width: 8),
                        _buildCountdownBox('min', homeCtrl.minutes.value),
                        const SizedBox(width: 8),
                        _buildCountdownBox('sec', homeCtrl.seconds.value,
                            highlight: true),
                      ],
                    )),
                const SizedBox(height: 16),

                // Tombol (scroll ke carousel)
                Pressable(
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: homeCtrl.scrollToCarousel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.f1Red,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Tickets',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_downward_rounded, size: 18),
                        ],
                      ),
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

  Widget _buildCountdownBox(String label, int value, {bool highlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.09),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value.toString().padLeft(2, '0'),
              style: TextStyle(
                color: highlight ? AppTheme.gold : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
