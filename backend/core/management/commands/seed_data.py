"""
Management command to seed demo data for MedCycle.
Usage: python manage.py seed_data
"""
import random
import uuid
from datetime import date, timedelta
from django.core.management.base import BaseCommand
from django.utils import timezone
from core.models import Citizen, Medicine, Pharmacy, DisposalRequest
from rewards.models import Badge


PHARMACIES = [
    {"name": "Apollo Pharmacy", "area": "Connaught Place", "city": "New Delhi", "state": "Delhi", "lat": 28.6315, "lon": 77.2167},
    {"name": "MedPlus Health", "area": "Bandra West", "city": "Mumbai", "state": "Maharashtra", "lat": 19.0607, "lon": 72.8362},
    {"name": "Wellness Forever", "area": "Koregaon Park", "city": "Pune", "state": "Maharashtra", "lat": 18.5362, "lon": 73.8937},
    {"name": "Frank Ross Pharmacy", "area": "Park Street", "city": "Kolkata", "state": "West Bengal", "lat": 22.5514, "lon": 88.3520},
    {"name": "Hetero Pharmacy", "area": "Banjara Hills", "city": "Hyderabad", "state": "Telangana", "lat": 17.4126, "lon": 78.4483},
    {"name": "Suraksha Medical", "area": "T Nagar", "city": "Chennai", "state": "Tamil Nadu", "lat": 13.0418, "lon": 80.2341},
    {"name": "City Care Pharmacy", "area": "MG Road", "city": "Bengaluru", "state": "Karnataka", "lat": 12.9757, "lon": 77.6011},
    {"name": "Jan Aushadhi Kendra", "area": "Civil Lines", "city": "Jaipur", "state": "Rajasthan", "lat": 26.9124, "lon": 75.7873},
    {"name": "Life Care Medical", "area": "Gomti Nagar", "city": "Lucknow", "state": "Uttar Pradesh", "lat": 26.8600, "lon": 81.0200},
    {"name": "HealthMart Plus", "area": "Navrangpura", "city": "Ahmedabad", "state": "Gujarat", "lat": 23.0395, "lon": 72.5680},
]

MEDICINES = [
    {"barcode": "8901234567890", "name": "Amoxicillin 500mg", "generic": "Amoxicillin", "cls": "penicillin", "risk": "high"},
    {"barcode": "8901234567891", "name": "Azithromycin 250mg", "generic": "Azithromycin", "cls": "macrolide", "risk": "medium"},
    {"barcode": "8901234567892", "name": "Ciprofloxacin 500mg", "generic": "Ciprofloxacin", "cls": "fluoroquinolone", "risk": "critical"},
    {"barcode": "8901234567893", "name": "Doxycycline 100mg", "generic": "Doxycycline", "cls": "tetracycline", "risk": "medium"},
    {"barcode": "8901234567894", "name": "Metronidazole 400mg", "generic": "Metronidazole", "cls": "other", "risk": "low"},
    {"barcode": "8901234567895", "name": "Cefixime 200mg", "generic": "Cefixime", "cls": "cephalosporin", "risk": "high"},
    {"barcode": "8901234567896", "name": "Levofloxacin 500mg", "generic": "Levofloxacin", "cls": "fluoroquinolone", "risk": "critical"},
    {"barcode": "8901234567897", "name": "Augmentin 625mg", "generic": "Amoxicillin+Clavulanate", "cls": "penicillin", "risk": "high"},
]


class Command(BaseCommand):
    help = 'Seed MedCycle database with demo data'

    def handle(self, *args, **options):
        self.stdout.write('Seeding pharmacies...')
        pharmacies = []
        for p in PHARMACIES:
            ph, _ = Pharmacy.objects.get_or_create(
                name=p['name'],
                defaults={
                    'address': f"{p['area']}, {p['city']}",
                    'area': p['area'],
                    'city': p['city'],
                    'state': p['state'],
                    'latitude': p['lat'],
                    'longitude': p['lon'],
                    'phone': f"+91 {random.randint(7000000000, 9999999999)}",
                    'is_active': True,
                    'total_verified': random.randint(10, 200),
                }
            )
            pharmacies.append(ph)

        self.stdout.write('Seeding medicines...')
        for m in MEDICINES:
            Medicine.objects.get_or_create(
                barcode=m['barcode'],
                defaults={
                    'name': m['name'],
                    'generic_name': m['generic'],
                    'manufacturer': 'Demo Pharma Ltd.',
                    'antibiotic_class': m['cls'],
                    'amr_risk_level': m['risk'],
                    'disposal_instructions': 'Mix with soil, seal in bag, dispose in general waste.',
                }
            )

        self.stdout.write('Seeding citizens and disposals...')
        regions = ['Delhi', 'Mumbai', 'Pune', 'Kolkata', 'Hyderabad', 'Chennai', 'Bengaluru']
        medicines_list = MEDICINES

        for i in range(30):
            citizen = Citizen.objects.create(
                region=random.choice(regions),
                total_points=0,
            )
            num_disposals = random.randint(1, 15)
            for _ in range(num_disposals):
                med = random.choice(medicines_list)
                pharmacy = random.choice(pharmacies)
                days_ago = random.randint(0, 60)
                created = timezone.now() - timedelta(days=days_ago)
                d = DisposalRequest(
                    citizen=citizen,
                    medicine_name=med['name'],
                    medicine_barcode=med['barcode'],
                    antibiotic_class=med['cls'],
                    amr_risk_level=med['risk'],
                    quantity=random.randint(1, 10),
                    expiry_date=date.today() - timedelta(days=random.randint(0, 365)),
                    is_expired=True,
                    status='verified',
                    pharmacy=pharmacy,
                    latitude=pharmacy.latitude + random.uniform(-0.05, 0.05),
                    longitude=pharmacy.longitude + random.uniform(-0.05, 0.05),
                    district=pharmacy.area,
                    state=pharmacy.state,
                    points_awarded=10,
                    verified_at=created + timedelta(hours=2),
                )
                d.save()
                d.created_at = created
                d.save(update_fields=['created_at'])
                citizen.total_points += 10
            citizen.save(update_fields=['total_points'])

        self.stdout.write(self.style.SUCCESS('Demo data seeded successfully!'))
