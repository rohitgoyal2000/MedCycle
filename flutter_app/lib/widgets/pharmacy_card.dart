import 'package:flutter/material.dart';
import '../models/pharmacy.dart';
import '../constants/theme.dart';

class PharmacyCard extends StatelessWidget {
  final Pharmacy pharmacy;
  final VoidCallback? onTap;
  final bool isSelected;

  const PharmacyCard({
    super.key,
    required this.pharmacy,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primary.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: pharmacy.isActive ? AppTheme.gradientMain : null,
                color: pharmacy.isActive ? null : AppTheme.textMuted.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_pharmacy, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pharmacy.name,
                    style: AppTheme.headingSM.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pharmacy.address,
                    style: AppTheme.bodyMD.copyWith(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (pharmacy.distance != null) ...[
                        const Icon(Icons.near_me, size: 12, color: AppTheme.accent),
                        const SizedBox(width: 3),
                        Text(
                          '${pharmacy.distance!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      const Icon(Icons.check_circle_outline, size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        '${pharmacy.totalVerified} verified',
                        style: AppTheme.bodySM,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: pharmacy.isActive
                        ? AppTheme.success.withValues(alpha: 0.12)
                        : AppTheme.danger.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pharmacy.isActive ? 'Active' : 'Closed',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: pharmacy.isActive ? AppTheme.success : AppTheme.danger,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 6),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.primary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
