import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../providers/citizen_provider.dart';
import '../widgets/lang_switcher.dart';
import 'home_screen.dart';
import 'dispose_screen.dart';
import 'map_screen.dart';
import 'rewards_screen.dart';
import 'chatbot_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    DisposeScreen(),
    MapScreen(),
    RewardsScreen(),
    ChatbotScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final navItems = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_outlined),
        activeIcon: const Icon(Icons.home),
        label: l10n.navHome,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.recycling_outlined),
        activeIcon: const Icon(Icons.recycling),
        label: l10n.navDispose,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.map_outlined),
        activeIcon: const Icon(Icons.map),
        label: l10n.navMap,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.emoji_events_outlined),
        activeIcon: const Icon(Icons.emoji_events),
        label: l10n.navRewards,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.smart_toy_outlined),
        activeIcon: const Icon(Icons.smart_toy),
        label: l10n.navChat,
      ),
    ];

    final titles = [
      l10n.appName,
      l10n.disposeTitle,
      l10n.mapTitle,
      l10n.rewardsTitle,
      l10n.chatTitle,
    ];

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.gradientMain,
            boxShadow: [
              BoxShadow(
                color: Color(0x332563EB),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Logo + title
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: const Icon(Icons.recycling, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      titles[_currentIndex],
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const LangSwitcher(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Consumer<CitizenProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.citizen == null) {
            return Container(
              decoration: const BoxDecoration(gradient: AppTheme.meshBackground),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primary),
                    SizedBox(height: 16),
                    Text(
                      'Initializing MedCycle...',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return IndexedStack(
            index: _currentIndex,
            children: _screens,
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: navItems,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textMuted,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
