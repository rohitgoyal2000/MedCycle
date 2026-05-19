import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/theme.dart';
import '../providers/citizen_provider.dart';
import '../widgets/glass_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _heroController;
  late Animation<double> _heroAnimation;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _heroAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.meshBackground),
      child: RefreshIndicator(
        onRefresh: () => context.read<CitizenProvider>().init(),
        color: AppTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(context, l10n),
              const SizedBox(height: 20),
              _buildStatsRow(context, l10n),
              const SizedBox(height: 20),
              _buildAmrAwarenessCard(context, l10n),
              const SizedBox(height: 20),
              _buildQuickActions(context, l10n),
              const SizedBox(height: 20),
              _buildRecentActivity(context, l10n),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF2563EB), const Color(0xFF7C3AED), _heroAnimation.value)!,
                Color.lerp(const Color(0xFF7C3AED), const Color(0xFF0EA5E9), _heroAnimation.value)!,
                const Color(0xFF0EA5E9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Stack(
        children: [
          // Background pattern circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            left: -10,
            bottom: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_outlined, color: Colors.white, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        l10n.tagline,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Consumer<CitizenProvider>(
                  builder: (context, provider, _) => Text(
                    '${l10n.homeGreeting}! 👋',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dispose Safely. Fight AMR.\nEarn Rewards.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    _heroStatPill(Icons.medical_services_outlined, '1.2k+ disposed'),
                    const SizedBox(width: 8),
                    _heroStatPill(Icons.location_on_outlined, '28 drop-offs'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStatPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, AppLocalizations l10n) {
    return Consumer<CitizenProvider>(
      builder: (context, provider, _) {
        final citizen = provider.citizen;
        if (provider.isLoading && citizen == null) {
          return _buildShimmerStats();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _statCard(
                  gradient: AppTheme.gradientMain,
                  icon: Icons.recycling,
                  value: citizen?.totalDisposals.toString() ?? '0',
                  label: l10n.totalDisposals,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  gradient: AppTheme.gradientGreen,
                  icon: Icons.star,
                  value: citizen?.totalPoints.toString() ?? '0',
                  label: l10n.totalPoints,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  gradient: AppTheme.gradientPurple,
                  icon: Icons.military_tech,
                  value: provider.earnedBadgeCount.toString(),
                  label: l10n.badges,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard({
    required LinearGradient gradient,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTheme.bodySM,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: List.generate(
            3,
            (i) => Expanded(
              child: Container(
                margin: EdgeInsets.only(left: i == 0 ? 0 : 10),
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmrAwarenessCard(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: const Border(
            left: BorderSide(color: AppTheme.danger, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.danger.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.whyThisMatters,
                    style: AppTheme.headingSM.copyWith(color: AppTheme.danger),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Improper antibiotic disposal contributes to Antimicrobial Resistance (AMR) — a global health crisis causing 700,000+ deaths annually. Dispose safely through MedCycle.',
                    style: AppTheme.bodyMD.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTheme.headingMD),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _quickAction(
                gradient: AppTheme.gradientMain,
                icon: Icons.qr_code_scanner,
                title: l10n.disposeTitle,
                subtitle: 'Generate QR code',
                onTap: () => _navigateTo(context, 1),
              ),
              _quickAction(
                gradient: AppTheme.gradientGreen,
                icon: Icons.location_on,
                title: 'Find Drop-off',
                subtitle: 'Nearest pharmacy',
                onTap: () => _navigateTo(context, 2),
              ),
              _quickAction(
                gradient: AppTheme.gradientPurple,
                icon: Icons.home_outlined,
                title: l10n.homeDisposalGuide,
                subtitle: 'Safe home tips',
                onTap: () => _showHomeGuideDialog(context),
              ),
              _quickAction(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.smart_toy,
                title: 'Ask MedBot',
                subtitle: 'AI assistant',
                onTap: () => _navigateTo(context, 4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, int index) {
    // Quick action taps show a bottom sheet prompt since tab switching
    // requires access to the parent MainScreen's setState.
    // For a production app, use a global navigation controller or
    // pass a callback down from MainScreen.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          index == 1
              ? 'Tap the "Dispose" tab to get started!'
              : index == 2
                  ? 'Tap the "Map" tab to find pharmacies!'
                  : 'Tap the "MedBot" tab to chat!',
          style: const TextStyle(fontFamily: 'PlusJakartaSans'),
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _quickAction({
    required LinearGradient gradient,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.headingSM.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTheme.bodySM,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, AppLocalizations l10n) {
    return Consumer<CitizenProvider>(
      builder: (context, provider, _) {
        final history = provider.history;
        if (history.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent Activity', style: AppTheme.headingMD),
              const SizedBox(height: 12),
              ...history.take(3).map((item) => _activityItem(item)),
            ],
          ),
        );
      },
    );
  }

  Widget _activityItem(Map<String, dynamic> item) {
    final status = item['status']?.toString() ?? 'pending';
    final isVerified = status == 'verified';
    final points = (item['points_awarded'] ?? 0) as int;
    final medicine = item['medicine_name']?.toString() ?? 'Medicine';
    final date = item['created_at']?.toString() ?? '';

    String dateStr = '';
    if (date.isNotEmpty) {
      try {
        final dt = DateTime.parse(date);
        dateStr = '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {
        dateStr = date.substring(0, date.length > 10 ? 10 : date.length);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isVerified
                  ? AppTheme.success.withValues(alpha: 0.12)
                  : AppTheme.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isVerified ? Icons.check_circle : Icons.hourglass_empty,
              color: isVerified ? AppTheme.success : AppTheme.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine,
                  style: AppTheme.headingSM.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (dateStr.isNotEmpty)
                  Text(dateStr, style: AppTheme.bodySM),
              ],
            ),
          ),
          if (isVerified && points > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '+$points pts',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.success,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showHomeGuideDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Home Disposal Guide', style: AppTheme.headingLG),
            const SizedBox(height: 8),
            Text(
              'Follow these steps for safe antibiotic disposal at home:',
              style: AppTheme.bodyMD,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: const [
                  _GuideStep(
                    step: '1',
                    title: 'Do NOT flush antibiotics',
                    description: 'Never flush medicines down the toilet or drain — this pollutes water sources.',
                    icon: Icons.block,
                    color: AppTheme.danger,
                  ),
                  _GuideStep(
                    step: '2',
                    title: 'Remove personal information',
                    description: 'Scratch off your name/address from medicine labels before disposal.',
                    icon: Icons.person_off,
                    color: AppTheme.warning,
                  ),
                  _GuideStep(
                    step: '3',
                    title: 'Use MedCycle drop-off points',
                    description: 'Take medicines to the nearest partner pharmacy for proper disposal.',
                    icon: Icons.location_on,
                    color: AppTheme.primary,
                  ),
                  _GuideStep(
                    step: '4',
                    title: 'Mix with undesirable substances',
                    description: 'If unable to use drop-off, mix with coffee grounds or cat litter before sealing in a bag.',
                    icon: Icons.blender,
                    color: AppTheme.success,
                  ),
                  _GuideStep(
                    step: '5',
                    title: 'Seal and bag properly',
                    description: 'Place in a sealed, opaque bag before placing in household trash as a last resort.',
                    icon: Icons.delete_outline,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  final String step;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _GuideStep({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.headingSM),
                const SizedBox(height: 3),
                Text(description, style: AppTheme.bodyMD),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
