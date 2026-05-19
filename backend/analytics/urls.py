from django.urls import path
from . import views

urlpatterns = [
    path('stats/', views.overall_stats, name='analytics-stats'),
    path('heatmap/', views.heatmap_data, name='analytics-heatmap'),
    path('amr-zones/', views.amr_zones, name='analytics-amr-zones'),
    path('antibiotic-breakdown/', views.antibiotic_breakdown, name='analytics-breakdown'),
    path('state-summary/', views.state_summary, name='analytics-state-summary'),
    path('pharmacy-performance/', views.pharmacy_performance, name='analytics-pharmacy-performance'),
]
