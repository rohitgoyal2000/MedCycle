from django.conf import settings
from .models import Badge


# AMR risk multipliers — high-risk antibiotics earn bonus points
RISK_MULTIPLIERS = {
    'critical': 3,
    'high': 2,
    'medium': 1,
    'low': 1,
}


def award_points_and_badges(citizen, disposal):
    """
    Award points for a disposal event and check badge thresholds.
    Returns points awarded in this transaction.
    """
    if disposal.points_awarded > 0:
        # Already awarded (idempotent guard)
        return disposal.points_awarded

    base = settings.POINTS_PER_DISPOSAL
    multiplier = RISK_MULTIPLIERS.get(disposal.amr_risk_level, 1)
    bonus = settings.BONUS_POINTS_VERIFIED if disposal.status == 'verified' else 0

    points = base * multiplier + bonus
    citizen.total_points += points
    citizen.save(update_fields=['total_points'])

    disposal.points_awarded = points
    disposal.save(update_fields=['points_awarded'])

    _check_and_award_badges(citizen)
    return points


def _check_and_award_badges(citizen):
    thresholds = settings.BADGE_THRESHOLDS
    verified_count = citizen.disposals.filter(status='verified').count()
    existing = set(citizen.badges.values_list('badge_type', flat=True))

    for badge_type, threshold in thresholds.items():
        if verified_count >= threshold and badge_type not in existing:
            Badge.objects.create(citizen=citizen, badge_type=badge_type)
