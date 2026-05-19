from django.contrib import admin
from .models import Citizen, Medicine, Pharmacy, DisposalRequest


@admin.register(Citizen)
class CitizenAdmin(admin.ModelAdmin):
    list_display = ['anonymous_id', 'total_points', 'region', 'created_at']
    search_fields = ['anonymous_id', 'region']
    ordering = ['-total_points']


@admin.register(Medicine)
class MedicineAdmin(admin.ModelAdmin):
    list_display = ['name', 'barcode', 'antibiotic_class', 'amr_risk_level']
    list_filter = ['antibiotic_class', 'amr_risk_level']
    search_fields = ['name', 'barcode', 'generic_name']


@admin.register(Pharmacy)
class PharmacyAdmin(admin.ModelAdmin):
    list_display = ['name', 'city', 'state', 'is_active', 'total_verified']
    list_filter = ['is_active', 'state', 'city']
    search_fields = ['name', 'address', 'city']


@admin.register(DisposalRequest)
class DisposalRequestAdmin(admin.ModelAdmin):
    list_display = [
        'disposal_id', 'medicine_name', 'citizen', 'status',
        'district', 'state', 'created_at'
    ]
    list_filter = ['status', 'is_home_disposal', 'antibiotic_class', 'amr_risk_level', 'state']
    search_fields = ['disposal_id', 'medicine_name', 'district']
    readonly_fields = ['disposal_id', 'created_at', 'submitted_at', 'verified_at']
    date_hierarchy = 'created_at'
