from datetime import timedelta
from django.utils import timezone
from django.db.models import Count, Q, Sum
from rest_framework.decorators import api_view
from rest_framework.response import Response

from core.models import DisposalRequest, Pharmacy, Citizen


@api_view(['GET'])
def overall_stats(request):
    """High-level platform statistics for admin dashboard."""
    total = DisposalRequest.objects.count()
    verified = DisposalRequest.objects.filter(status='verified').count()
    home = DisposalRequest.objects.filter(is_home_disposal=True).count()
    citizens = Citizen.objects.count()
    pharmacies = Pharmacy.objects.filter(is_active=True).count()

    # Last 7 days trend
    seven_days_ago = timezone.now() - timedelta(days=7)
    daily = (
        DisposalRequest.objects
        .filter(created_at__gte=seven_days_ago)
        .extra({'day': "date(created_at)"})
        .values('day')
        .annotate(count=Count('id'))
        .order_by('day')
    )

    return Response({
        'total_disposals': total,
        'verified_disposals': verified,
        'home_disposals': home,
        'pharmacy_disposals': total - home,
        'total_citizens': citizens,
        'active_pharmacies': pharmacies,
        'verification_rate': round((verified / total * 100), 1) if total else 0,
        'daily_trend': list(daily),
    })


@api_view(['GET'])
def heatmap_data(request):
    """
    Disposal geo-data for heatmap rendering.
    Returns district-level aggregated counts to preserve privacy.
    """
    days = int(request.query_params.get('days', 30))
    since = timezone.now() - timedelta(days=days)

    state_filter = request.query_params.get('state', '')

    qs = DisposalRequest.objects.filter(
        created_at__gte=since,
        latitude__isnull=False,
        longitude__isnull=False,
    )
    if state_filter:
        qs = qs.filter(state__iexact=state_filter)

    # District-level aggregation
    districts = (
        qs.values('district', 'state', 'latitude', 'longitude')
        .annotate(count=Count('id'))
    )

    points = []
    for d in districts:
        if d['latitude'] and d['longitude']:
            # Risk scoring: high-count districts are high risk
            count = d['count']
            risk = 'low' if count < 5 else ('medium' if count < 20 else 'high')
            points.append({
                'district': d['district'] or 'Unknown',
                'state': d['state'] or '',
                'lat': d['latitude'],
                'lng': d['longitude'],
                'count': count,
                'risk_level': risk,
            })

    return Response({
        'period_days': days,
        'total_points': len(points),
        'heatmap': points,
    })


@api_view(['GET'])
def amr_zones(request):
    """Identify high-risk AMR zones based on antibiotic class and volume."""
    qs = (
        DisposalRequest.objects
        .filter(status='verified')
        .values('district', 'state', 'antibiotic_class', 'amr_risk_level')
        .annotate(count=Count('id'))
        .order_by('-count')
    )

    zones = []
    for row in qs[:100]:
        zones.append({
            'district': row['district'] or 'Unknown',
            'state': row['state'] or '',
            'antibiotic_class': row['antibiotic_class'],
            'amr_risk_level': row['amr_risk_level'],
            'disposal_count': row['count'],
        })
    return Response({'zones': zones})


@api_view(['GET'])
def antibiotic_breakdown(request):
    """Breakdown of disposals by antibiotic class."""
    data = (
        DisposalRequest.objects
        .values('antibiotic_class')
        .annotate(count=Count('id'))
        .order_by('-count')
    )
    return Response({'breakdown': list(data)})


@api_view(['GET'])
def state_summary(request):
    """Per-state disposal summary for government dashboard."""
    data = (
        DisposalRequest.objects
        .values('state')
        .annotate(
            total=Count('id'),
            verified=Count('id', filter=Q(status='verified')),
            home=Count('id', filter=Q(is_home_disposal=True)),
        )
        .order_by('-total')
    )
    return Response({'states': list(data)})


@api_view(['GET'])
def pharmacy_performance(request):
    """Top performing pharmacies by verified disposals."""
    pharmacies = (
        Pharmacy.objects
        .filter(is_active=True)
        .order_by('-total_verified')[:20]
    )
    data = [
        {
            'id': p.id,
            'name': p.name,
            'city': p.city,
            'state': p.state,
            'total_verified': p.total_verified,
        }
        for p in pharmacies
    ]
    return Response({'pharmacies': data})
