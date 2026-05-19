from django.contrib import admin
from .models import Badge


@admin.register(Badge)
class BadgeAdmin(admin.ModelAdmin):
    list_display = ['citizen', 'badge_type', 'earned_at']
    list_filter = ['badge_type']
