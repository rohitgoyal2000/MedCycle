import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../models/badge_model.dart';
import '../providers/citizen_provider.dart';
import '../widgets/glass_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ringController;
  late Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _ringAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.meshBackground),
      child: RefreshIndicator(
        onRefresh: () async {
          await context.read<CitizenProvider>().loadBadges();
          await context.read<CitizenProvider>().loadLeaderboard();
        },
        color: AppTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Consumer<CitizenProvider>(
            builder: (context, provider, _) {
              final citizen = provider.citizen;
              final points = citizen?.totalPoints ?? 0;
              final disposals = citizen?.totalDisposals ?? 0;
              final levelPoints = _getLevelPoints(points);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level progress card
                  GlassCard(
                    child: Row(
                      children: [
                        // Progress ring
                        AnimatedBuilder(
                          animation: _ringAnimation,
                          builder: (context, child) => SizedBox(
                            width: 110,
                            height: 110,
                            child: CustomPaint(
                              painter: _RingPainter(
                                progress: _ringAnimation.value * (points / levelPoints['max']!).clamp(0, 1),
                                startColor: AppTheme.primary,
                                endColor: AppTheme.secondary,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      points.toString(),
                                      style: const TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const Text(
                                      'pts',
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.gradientMain,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  levelPoints['name']!.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(l10n.totalPoints, style: AppTheme.labelMD),
                              Text(
                                '$points / ${levelPoints['max']} pts',
                                style: AppTheme.headingSM,
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: AnimatedBuilder(
                                  animation: _ringAnimation,
                                  builder: (context, child) => LinearProgressIndicator(
                                    value: _ringAnimation.value *
                                        (points / (levelPoints['max'] as int)).clamp(0, 1),
                                    backgroundColor: AppTheme.borderLight,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(levelPoints['max'] as int) - points} pts to next level',
                                style: AppTheme.bodySM,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _miniStat(
                          icon: Icons.recycling,
                          value: disposals.toString(),
                          label: l10n.totalDisposals,
                          gradient: AppTheme.gradientMain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _miniStat(
                          icon: Icons.military_tech,
                          value: provider.earnedBadgeCount.toString(),
                          label: l10n.badges,
                          gradient: AppTheme.gradientPurple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _miniStat(
                          icon: Icons.star,
                          value: '#${_getUserRank(provider.leaderboard, citizen?.region ?? "")}',
                          label: 'Rank',
                          gradient: AppTheme.gradientGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Badges section
                  Text(l10n.badges, style: AppTheme.headingMD),
                  const SizedBox(height: 12),
                  _buildBadgesGrid(provider.badges),
                  const SizedBox(height: 20),

                  // Leaderboard
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.leaderboard, style: AppTheme.headingMD),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Top ${math.min(provider.leaderboard.length, 10)}',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildLeaderboard(provider.leaderboard),
                  const SizedBox(height: 30),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String value,
    required String label,
    required LinearGradient gradient,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(label, style: AppTheme.bodySM, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid(List<BadgeModel> badges) {
    final displayBadges = badges.isEmpty ? BadgeModel.defaultBadges : badges;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: displayBadges.length,
      itemBuilder: (context, index) {
        final badge = displayBadges[index];
        return _badgeTile(badge);
      },
    );
  }

  Widget _badgeTile(BadgeModel badge) {
    final color = _hexToColor(badge.color);
    return GestureDetector(
      onTap: () => _showBadgeDetail(badge),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: badge.earned ? color.withValues(alpha: 0.3) : AppTheme.borderLight,
            width: badge.earned ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: badge.earned
                  ? color.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: badge.earned ? 14 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge icon
            ColorFiltered(
              colorFilter: badge.earned
                  ? const ColorFilter.mode(Colors.transparent, BlendMode.color)
                  : const ColorFilter.matrix([
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0,      0,      0,      1, 0,
                    ]),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    badge.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.name,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: badge.earned ? AppTheme.textPrimary : AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            if (!badge.earned) ...[
              const SizedBox(height: 4),
              const Icon(Icons.lock_outline, size: 12, color: AppTheme.textMuted),
            ],
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(BadgeModel badge) {
    final color = _hexToColor(badge.color);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Text(badge.icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(badge.name, style: AppTheme.headingMD),
            const SizedBox(height: 6),
            Text(badge.description, style: AppTheme.bodyMD, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: badge.earned
                    ? color.withValues(alpha: 0.1)
                    : AppTheme.textMuted.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge.earned ? 'Earned!' : 'Not yet earned',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w700,
                  color: badge.earned ? color : AppTheme.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard(List<dynamic> leaderboard) {
    if (leaderboard.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Leaderboard loading...', style: TextStyle(color: AppTheme.textMuted)),
        ),
      );
    }
    return Column(
      children: leaderboard.take(10).toList().asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value as Map<String, dynamic>;
        final rank = (item['rank'] ?? index + 1) as int;
        final region = item['region']?.toString() ?? 'Unknown';
        final points = (item['points'] ?? 0) as int;
        final disposals = (item['disposals'] ?? 0) as int;

        final isTopThree = rank <= 3;
        final medalColors = [
          const Color(0xFFFFD700),
          const Color(0xFFC0C0C0),
          const Color(0xFFCD7F32),
        ];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isTopThree ? medalColors[rank - 1].withValues(alpha: 0.3) : AppTheme.borderLight,
              width: isTopThree ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isTopThree
                    ? medalColors[rank - 1].withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 36,
                child: isTopThree
                    ? Text(
                        ['🥇', '🥈', '🥉'][rank - 1],
                        style: const TextStyle(fontSize: 22),
                        textAlign: TextAlign.center,
                      )
                    : Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppTheme.borderLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '$rank',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      region,
                      style: AppTheme.headingSM.copyWith(fontSize: 14),
                    ),
                    Text(
                      '$disposals disposals',
                      style: AppTheme.bodySM,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: isTopThree ? AppTheme.gradientMain : null,
                  color: isTopThree ? null : AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$points pts',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isTopThree ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _getLevelPoints(int points) {
    if (points < 100) return {'name': 'Newcomer', 'max': 100};
    if (points < 300) return {'name': 'Green Starter', 'max': 300};
    if (points < 600) return {'name': 'Eco Advocate', 'max': 600};
    if (points < 1000) return {'name': 'AMR Fighter', 'max': 1000};
    return {'name': 'AMR Champion', 'max': 2000};
  }

  int _getUserRank(List<dynamic> leaderboard, String region) {
    for (var i = 0; i < leaderboard.length; i++) {
      final item = leaderboard[i] as Map<String, dynamic>;
      if (item['region']?.toString() == region) return i + 1;
    }
    return leaderboard.length + 1;
  }

  Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) {
      return Color(int.parse('FF$cleaned', radix: 16));
    }
    return AppTheme.primary;
  }
}

// Custom painter for the progress ring
class _RingPainter extends CustomPainter {
  final double progress;
  final Color startColor;
  final Color endColor;

  _RingPainter({
    required this.progress,
    required this.startColor,
    required this.endColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;

    // Background track
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = AppTheme.borderLight;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi * progress,
        colors: [startColor, endColor],
        tileMode: TileMode.clamp,
      );

      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..shader = gradient.createShader(rect);

      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
