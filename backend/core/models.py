import uuid
from django.db import models
from django.utils import timezone


class Citizen(models.Model):
    """Anonymous citizen profile — no mandatory PII stored."""
    anonymous_id = models.UUIDField(default=uuid.uuid4, unique=True, editable=False)
    phone_hash = models.CharField(max_length=64, blank=True, help_text="SHA-256 of phone (optional)")
    total_points = models.IntegerField(default=0)
    region = models.CharField(max_length=100, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-total_points']

    def __str__(self):
        return f"Citizen {str(self.anonymous_id)[:8]}"


class Medicine(models.Model):
    """Antibiotic medicine catalog."""
    ANTIBIOTIC_CLASSES = [
        ('penicillin', 'Penicillins'),
        ('cephalosporin', 'Cephalosporins'),
        ('macrolide', 'Macrolides'),
        ('fluoroquinolone', 'Fluoroquinolones'),
        ('tetracycline', 'Tetracyclines'),
        ('aminoglycoside', 'Aminoglycosides'),
        ('sulfonamide', 'Sulfonamides'),
        ('carbapenem', 'Carbapenems'),
        ('other', 'Other'),
    ]

    barcode = models.CharField(max_length=100, unique=True)
    name = models.CharField(max_length=200)
    generic_name = models.CharField(max_length=200, blank=True)
    manufacturer = models.CharField(max_length=200, blank=True)
    antibiotic_class = models.CharField(max_length=50, choices=ANTIBIOTIC_CLASSES, default='other')
    amr_risk_level = models.CharField(
        max_length=10,
        choices=[('low', 'Low'), ('medium', 'Medium'), ('high', 'High'), ('critical', 'Critical')],
        default='medium'
    )
    disposal_instructions = models.TextField(blank=True)

    def __str__(self):
        return f"{self.name} ({self.barcode})"


class Pharmacy(models.Model):
    """Verified disposal collection point."""
    name = models.CharField(max_length=200)
    address = models.TextField()
    area = models.CharField(max_length=100, blank=True)
    city = models.CharField(max_length=100, default='')
    state = models.CharField(max_length=100, blank=True)
    latitude = models.FloatField()
    longitude = models.FloatField()
    phone = models.CharField(max_length=20, blank=True)
    is_active = models.BooleanField(default=True)
    accepts_expired = models.BooleanField(default=True)
    operating_hours = models.CharField(max_length=200, default='9AM - 9PM')
    total_verified = models.IntegerField(default=0)
    joined_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name_plural = 'Pharmacies'

    def __str__(self):
        return f"{self.name} — {self.city}"


class DisposalRequest(models.Model):
    """Core entity: one antibiotic disposal event."""
    STATUS_PENDING = 'pending'
    STATUS_SUBMITTED = 'submitted'
    STATUS_VERIFIED = 'verified'

    STATUS_CHOICES = [
        (STATUS_PENDING, 'Pending — QR generated, awaiting drop-off'),
        (STATUS_SUBMITTED, 'Submitted — at pharmacy, awaiting scan'),
        (STATUS_VERIFIED, 'Verified — pharmacy confirmed'),
    ]

    disposal_id = models.UUIDField(default=uuid.uuid4, unique=True, editable=False)
    citizen = models.ForeignKey(Citizen, on_delete=models.CASCADE, related_name='disposals')

    # Medicine details (inline for offline support)
    medicine_name = models.CharField(max_length=200)
    medicine_barcode = models.CharField(max_length=100, blank=True)
    antibiotic_class = models.CharField(max_length=50, blank=True)
    amr_risk_level = models.CharField(max_length=10, default='medium')
    quantity = models.PositiveIntegerField(default=1)
    unit = models.CharField(max_length=20, default='tablets')
    expiry_date = models.DateField(null=True, blank=True)
    is_expired = models.BooleanField(default=False)

    # Disposal logistics
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=STATUS_PENDING)
    is_home_disposal = models.BooleanField(default=False)
    disposal_method = models.CharField(max_length=100, blank=True)  # e.g., "pharmacy_drop_off"
    pharmacy = models.ForeignKey(
        Pharmacy, null=True, blank=True,
        on_delete=models.SET_NULL, related_name='disposals'
    )

    # Location (coarse — district level for privacy)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    district = models.CharField(max_length=100, blank=True)
    state = models.CharField(max_length=100, blank=True)

    # Rewards
    points_awarded = models.IntegerField(default=0)

    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    submitted_at = models.DateTimeField(null=True, blank=True)
    verified_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Disposal {str(self.disposal_id)[:8]} — {self.medicine_name} [{self.status}]"

    def mark_submitted(self):
        self.status = self.STATUS_SUBMITTED
        self.submitted_at = timezone.now()
        self.save(update_fields=['status', 'submitted_at'])

    def mark_verified(self, pharmacy):
        self.status = self.STATUS_VERIFIED
        self.pharmacy = pharmacy
        self.verified_at = timezone.now()
        self.save(update_fields=['status', 'pharmacy', 'verified_at'])
