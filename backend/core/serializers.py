import hashlib
from rest_framework import serializers
from .models import Citizen, Medicine, Pharmacy, DisposalRequest


class CitizenSerializer(serializers.ModelSerializer):
    disposal_count = serializers.SerializerMethodField()
    badges = serializers.SerializerMethodField()
    rank = serializers.SerializerMethodField()

    class Meta:
        model = Citizen
        fields = [
            'anonymous_id', 'total_points', 'region',
            'created_at', 'disposal_count', 'badges', 'rank'
        ]
        read_only_fields = ['anonymous_id', 'total_points', 'created_at']

    def get_disposal_count(self, obj):
        return obj.disposals.filter(status=DisposalRequest.STATUS_VERIFIED).count()

    def get_badges(self, obj):
        from rewards.models import Badge
        return list(obj.badges.values_list('badge_type', flat=True))

    def get_rank(self, obj):
        return Citizen.objects.filter(total_points__gt=obj.total_points).count() + 1


class CitizenCreateSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=15, required=False, allow_blank=True)
    region = serializers.CharField(max_length=100, required=False, allow_blank=True)

    def create(self, validated_data):
        phone = validated_data.get('phone_number', '')
        phone_hash = hashlib.sha256(phone.encode()).hexdigest() if phone else ''
        citizen = Citizen.objects.create(
            phone_hash=phone_hash,
            region=validated_data.get('region', '')
        )
        return citizen


class MedicineSerializer(serializers.ModelSerializer):
    class Meta:
        model = Medicine
        fields = '__all__'


class PharmacySerializer(serializers.ModelSerializer):
    distance_km = serializers.FloatField(read_only=True, required=False)

    class Meta:
        model = Pharmacy
        fields = [
            'id', 'name', 'address', 'area', 'city', 'state',
            'latitude', 'longitude', 'phone', 'is_active',
            'accepts_expired', 'operating_hours', 'total_verified',
            'distance_km'
        ]


class DisposalRequestSerializer(serializers.ModelSerializer):
    qr_data = serializers.SerializerMethodField()
    citizen_id = serializers.UUIDField(source='citizen.anonymous_id', read_only=True)

    class Meta:
        model = DisposalRequest
        fields = [
            'disposal_id', 'citizen_id', 'medicine_name', 'medicine_barcode',
            'antibiotic_class', 'amr_risk_level', 'quantity', 'unit',
            'expiry_date', 'is_expired', 'status', 'is_home_disposal',
            'disposal_method', 'pharmacy', 'latitude', 'longitude',
            'district', 'state', 'points_awarded', 'created_at',
            'submitted_at', 'verified_at', 'qr_data'
        ]
        read_only_fields = [
            'disposal_id', 'status', 'points_awarded',
            'created_at', 'submitted_at', 'verified_at', 'qr_data'
        ]

    def get_qr_data(self, obj):
        return str(obj.disposal_id)


class DisposalInitiateSerializer(serializers.Serializer):
    citizen_id = serializers.UUIDField()
    medicine_name = serializers.CharField(max_length=200)
    medicine_barcode = serializers.CharField(max_length=100, required=False, allow_blank=True)
    antibiotic_class = serializers.CharField(max_length=50, required=False, allow_blank=True)
    quantity = serializers.IntegerField(min_value=1, default=1)
    unit = serializers.CharField(max_length=20, default='tablets')
    expiry_date = serializers.DateField(required=False, allow_null=True)
    is_home_disposal = serializers.BooleanField(default=False)
    latitude = serializers.FloatField(required=False, allow_null=True)
    longitude = serializers.FloatField(required=False, allow_null=True)
    district = serializers.CharField(max_length=100, required=False, allow_blank=True)
    state = serializers.CharField(max_length=100, required=False, allow_blank=True)

    def validate_citizen_id(self, value):
        try:
            Citizen.objects.get(anonymous_id=value)
        except Citizen.DoesNotExist:
            raise serializers.ValidationError("Citizen not found.")
        return value


class DisposalVerifySerializer(serializers.Serializer):
    disposal_id = serializers.UUIDField()
    pharmacy_id = serializers.IntegerField()

    def validate(self, data):
        try:
            disposal = DisposalRequest.objects.get(disposal_id=data['disposal_id'])
        except DisposalRequest.DoesNotExist:
            raise serializers.ValidationError("Disposal QR code not found.")
        if disposal.status == DisposalRequest.STATUS_VERIFIED:
            raise serializers.ValidationError("This disposal has already been verified.")
        try:
            pharmacy = Pharmacy.objects.get(id=data['pharmacy_id'], is_active=True)
        except Pharmacy.DoesNotExist:
            raise serializers.ValidationError("Pharmacy not found or inactive.")
        data['disposal'] = disposal
        data['pharmacy'] = pharmacy
        return data
