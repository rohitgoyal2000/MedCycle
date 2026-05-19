from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from core.models import Citizen
from .models import Badge


@api_view(['GET'])
def leaderboard(request):
    """Top 50 citizens by total points (community leaderboard)."""
    scope = request.query_params.get('scope', 'global')  # global | region
    region = request.query_params.get('region', '')

    qs = Citizen.objects.order_by('-total_points')
    if scope == 'region' and region:
        qs = qs.filter(region__iexact=region)

    top = qs[:50]
    data = []
    for rank, c in enumerate(top, start=1):
        data.append({
            'rank': rank,
            'anonymous_id': str(c.anonymous_id)[:8] + '****',
            'total_points': c.total_points,
            'region': c.region,
            'disposal_count': c.disposals.filter(status='verified').count(),
            'badges': list(c.badges.values_list('badge_type', flat=True)),
        })
    return Response({'scope': scope, 'leaderboard': data})


@api_view(['GET'])
def citizen_badges(request, anonymous_id):
    """Return all badges earned by a citizen."""
    try:
        citizen = Citizen.objects.get(anonymous_id=anonymous_id)
    except Citizen.DoesNotExist:
        return Response({'error': 'Not found'}, status=status.HTTP_404_NOT_FOUND)

    badges = citizen.badges.all()
    data = []
    for b in badges:
        data.append({
            'badge_type': b.badge_type,
            'icon': b.meta.get('icon', '🏅'),
            'color': b.meta.get('color', '#fff'),
            'description': b.meta.get('desc', ''),
            'earned_at': b.earned_at,
        })
    return Response({'citizen_id': str(citizen.anonymous_id), 'badges': data})


@api_view(['GET'])
def badge_catalog(request):
    """Return full badge catalog with unlock criteria."""
    from django.conf import settings
    catalog = []
    for badge_type, meta in Badge.BADGE_META.items():
        catalog.append({
            'badge_type': badge_type,
            'icon': meta['icon'],
            'color': meta['color'],
            'description': meta['desc'],
            'required_disposals': settings.BADGE_THRESHOLDS.get(badge_type, 0),
        })
    return Response(catalog)
