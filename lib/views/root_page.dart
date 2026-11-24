
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/currency_selector.dart';
import 'home_page.dart';
import 'my_tickets_page.dart';
import 'venue_page.dart';
import 'profile_page.dart';

class RootPage extends StatefulWidget {
  final int initialIndex;

  const RootPage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  late int _currentIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex.clamp(0, 3);

    _pageController = PageController(
      initialPage: _currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppTheme.f1Red,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                'SG',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'SINGAPORE GP 2027',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CurrencySelector(isCompact: true),
          ),
        ],
      ),

      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          HomePage(),
          MyTicketsPage(),
          VenuePage(),
          ProfilePage(),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardBg,
          border: Border(
            top: BorderSide(
              color: AppTheme.cardBorder,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              activeIcon: Icon(Icons.confirmation_number),
              label: 'My Tickets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Venue',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
