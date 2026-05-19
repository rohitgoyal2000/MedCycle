import io
import base64
import math
from datetime import date

import qrcode
from django.conf import settings
from django.db.models import Count, Q
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import Citizen, Medicine, Pharmacy, DisposalRequest
from .serializers import (
    CitizenSerializer, CitizenCreateSerializer,
    MedicineSerializer, PharmacySerializer,
    DisposalRequestSerializer,
    DisposalInitiateSerializer, DisposalVerifySerializer,
)
from rewards.utils import award_points_and_badges


# ─── Citizen ────────────────────────────────────────────────────────────────

@api_view(['POST'])
def citizen_register(request):
    """Create an anonymous citizen profile."""
    ser = CitizenCreateSerializer(data=request.data)
    if ser.is_valid():
        citizen = ser.save()
        return Response(CitizenSerializer(citizen).data, status=status.HTTP_201_CREATED)
    return Response(ser.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
def citizen_profile(request, anonymous_id):
    """Retrieve citizen profile by anonymous UUID."""
    try:
        citizen = Citizen.objects.get(anonymous_id=anonymous_id)
    except Citizen.DoesNotExist:
        return Response({'error': 'Not found'}, status=status.HTTP_404_NOT_FOUND)
    return Response(CitizenSerializer(citizen).data)


@api_view(['GET'])
def citizen_history(request, anonymous_id):
    """Disposal history for a citizen."""
    try:
        citizen = Citizen.objects.get(anonymous_id=anonymous_id)
    except Citizen.DoesNotExist:
        return Response({'error': 'Not found'}, status=status.HTTP_404_NOT_FOUND)
    disposals = citizen.disposals.all().order_by('-created_at')
    return Response(DisposalRequestSerializer(disposals, many=True).data)


# ─── Medicine ────────────────────────────────────────────────────────────────

@api_view(['GET'])
def medicine_lookup(request):
    """Look up medicine by barcode."""
    barcode = request.query_params.get('barcode', '').strip()
    if not barcode:
        return Response({'error': 'barcode param required'}, status=status.HTTP_400_BAD_REQUEST)
    try:
        medicine = Medicine.objects.get(barcode=barcode)
        return Response(MedicineSerializer(medicine).data)
    except Medicine.DoesNotExist:
        return Response({'found': False, 'barcode': barcode}, status=status.HTTP_404_NOT_FOUND)


# ─── Pharmacies ──────────────────────────────────────────────────────────────

def _haversine(lat1, lon1, lat2, lon2):
    """Distance in km between two (lat, lon) points."""
    R = 6371
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat / 2) ** 2
         + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2))
         * math.sin(dlon / 2) ** 2)
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


@api_view(['GET'])
def pharmacies_nearby(request):
    """Return active pharmacies sorted by distance from user location."""
    try:
        lat = float(request.query_params.get('lat', 0))
        lon = float(request.query_params.get('lon', 0))
    except ValueError:
        return Response({'error': 'Invalid lat/lon'}, status=status.HTTP_400_BAD_REQUEST)

    radius_km = float(request.query_params.get('radius', 15))
    pharmacies = Pharmacy.objects.filter(is_active=True)

    results = []
    for p in pharmacies:
        dist = _haversine(lat, lon, p.latitude, p.longitude)
        if dist <= radius_km:
            p.distance_km = round(dist, 2)
            results.append(p)

    results.sort(key=lambda p: p.distance_km)
    return Response(PharmacySerializer(results, many=True).data)


@api_view(['GET'])
def pharmacy_list(request):
    """List all active pharmacies (no location filter)."""
    pharmacies = Pharmacy.objects.filter(is_active=True)
    return Response(PharmacySerializer(pharmacies, many=True).data)


# ─── Disposal ────────────────────────────────────────────────────────────────

def _generate_qr_base64(data: str) -> str:
    """Return a QR code as a base64-encoded PNG string."""
    qr = qrcode.QRCode(version=1, box_size=8, border=4)
    qr.add_data(data)
    qr.make(fit=True)
    img = qr.make_image(fill_color="#1a56db", back_color="white")
    buf = io.BytesIO()
    img.save(buf, format='PNG')
    return base64.b64encode(buf.getvalue()).decode('utf-8')


@api_view(['POST'])
def disposal_initiate(request):
    """
    Step 1: Citizen submits medicine details.
    Returns a unique QR code (base64 PNG + UUID) for drop-off.
    """
    ser = DisposalInitiateSerializer(data=request.data)
    if not ser.is_valid():
        return Response(ser.errors, status=status.HTTP_400_BAD_REQUEST)

    d = ser.validated_data
    citizen = Citizen.objects.get(anonymous_id=d['citizen_id'])

    expiry = d.get('expiry_date')
    is_expired = (expiry < date.today()) if expiry else False

    disposal = DisposalRequest.objects.create(
        citizen=citizen,
        medicine_name=d['medicine_name'],
        medicine_barcode=d.get('medicine_barcode', ''),
        antibiotic_class=d.get('antibiotic_class', ''),
        quantity=d.get('quantity', 1),
        unit=d.get('unit', 'tablets'),
        expiry_date=expiry,
        is_expired=is_expired,
        is_home_disposal=d.get('is_home_disposal', False),
        latitude=d.get('latitude'),
        longitude=d.get('longitude'),
        district=d.get('district', ''),
        state=d.get('state', ''),
        disposal_method='home_disposal' if d.get('is_home_disposal') else 'pharmacy_drop_off',
    )

    qr_b64 = _generate_qr_base64(str(disposal.disposal_id))

    if disposal.is_home_disposal:
        # Award points immediately for home disposal (no pharmacy scan needed)
        award_points_and_badges(citizen, disposal)

    return Response({
        'disposal_id': str(disposal.disposal_id),
        'qr_code_base64': qr_b64,
        'medicine_name': disposal.medicine_name,
        'status': disposal.status,
        'is_home_disposal': disposal.is_home_disposal,
        'points_preview': settings.POINTS_PER_DISPOSAL,
    }, status=status.HTTP_201_CREATED)


@api_view(['POST'])
def disposal_verify(request):
    """
    Step 2: Pharmacy scans QR code and confirms receipt.
    Awards full points to citizen.
    """
    ser = DisposalVerifySerializer(data=request.data)
    if not ser.is_valid():
        return Response(ser.errors, status=status.HTTP_400_BAD_REQUEST)

    disposal = ser.validated_data['disposal']
    pharmacy = ser.validated_data['pharmacy']

    disposal.mark_verified(pharmacy)
    pharmacy.total_verified += 1
    pharmacy.save(update_fields=['total_verified'])

    points_earned = award_points_and_badges(disposal.citizen, disposal)

    return Response({
        'disposal_id': str(disposal.disposal_id),
        'status': 'verified',
        'pharmacy': pharmacy.name,
        'citizen_id': str(disposal.citizen.anonymous_id),
        'points_earned': points_earned,
        'total_points': disposal.citizen.total_points,
    })


@api_view(['GET'])
def disposal_status(request, disposal_id):
    """Get status of a disposal by UUID."""
    try:
        disposal = DisposalRequest.objects.get(disposal_id=disposal_id)
    except DisposalRequest.DoesNotExist:
        return Response({'error': 'Not found'}, status=status.HTTP_404_NOT_FOUND)
    return Response(DisposalRequestSerializer(disposal).data)


@api_view(['GET'])
def home_disposal_guide(request):
    """Return step-by-step home disposal instructions."""
    antibiotic_class = request.query_params.get('antibiotic_class', 'general')
    guides = {
        'general': [
            "Remove medicines from original packaging.",
            "Mix with an undesirable substance (coffee grounds, dirt, or cat litter).",
            "Place in a sealed, non-transparent bag or container.",
            "Dispose in your household waste bin — NOT in recycling or flush down the toilet.",
            "Remove or black out personal info from the packaging before discarding.",
            "Log this disposal in the MedCycle app to earn your points!",
        ],
        'penicillin': [
            "Do NOT crush penicillin tablets — seal in original packaging.",
            "Wrap tightly in newspaper or brown paper.",
            "Mix with coffee grounds or soil in a ziplock bag.",
            "Dispose in general household waste.",
            "Wash hands thoroughly after handling.",
        ],
        'fluoroquinolone': [
            "Fluoroquinolones have high AMR risk — prioritize pharmacy drop-off.",
            "If unavailable: seal tablets in original blister pack.",
            "Place in a sturdy, sealed bag with cat litter or soil.",
            "Dispose in general waste — never flush.",
            "Inform your local health authority about the disposal.",
        ],
    }
    instructions = guides.get(antibiotic_class, guides['general'])
    return Response({
        'antibiotic_class': antibiotic_class,
        'instructions': instructions,
        'warning': 'Never flush antibiotics down the toilet or pour down the drain.',
        'preferred_method': 'Please use a nearby MedCycle drop-off pharmacy whenever possible.',
    })
