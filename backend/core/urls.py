from django.urls import path
from . import views

urlpatterns = [
    # Citizen
    path('citizen/register/', views.citizen_register, name='citizen-register'),
    path('citizen/<uuid:anonymous_id>/profile/', views.citizen_profile, name='citizen-profile'),
    path('citizen/<uuid:anonymous_id>/history/', views.citizen_history, name='citizen-history'),

    # Medicine
    path('medicine/lookup/', views.medicine_lookup, name='medicine-lookup'),

    # Pharmacies
    path('pharmacies/', views.pharmacy_list, name='pharmacy-list'),
    path('pharmacies/nearby/', views.pharmacies_nearby, name='pharmacies-nearby'),

    # Disposals
    path('disposal/initiate/', views.disposal_initiate, name='disposal-initiate'),
    path('disposal/verify/', views.disposal_verify, name='disposal-verify'),
    path('disposal/<uuid:disposal_id>/status/', views.disposal_status, name='disposal-status'),
    path('disposal/home-guide/', views.home_disposal_guide, name='home-disposal-guide'),
]
