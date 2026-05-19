from django.urls import path
from . import views

urlpatterns = [
    path('leaderboard/', views.leaderboard, name='leaderboard'),
    path('badges/catalog/', views.badge_catalog, name='badge-catalog'),
    path('badges/<uuid:anonymous_id>/', views.citizen_badges, name='citizen-badges'),
]
