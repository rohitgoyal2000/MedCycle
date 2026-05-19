from django.db import models
from core.models import Citizen


class Badge(models.Model):
    BADGE_CHOICES = [
        ('first_disposal',   'First Disposal',),
        ('amr_hero',         'AMR Hero'),
        ('safe_champion',    'Safe Medicine Champion'),
        ('community_leader', 'Community Leader'),
        ('eco_warrior',      'Eco Warrior'),
        ('health_guardian',  'Health Guardian'),
    ]

    BADGE_META = {
        'first_disposal':   {'icon': '🌱', 'color': '#34d399', 'desc': 'Completed your first safe disposal!'},
        'amr_hero':         {'icon': '🦸', 'color': '#60a5fa', 'desc': '10 verified disposals — you are an AMR Hero!'},
        'safe_champion':    {'icon': '🏅', 'color': '#fbbf24', 'desc': '25 disposals — Safe Medicine Champion!'},
        'community_leader': {'icon': '🌟', 'color': '#f472b6', 'desc': '50 disposals — inspiring your community!'},
        'eco_warrior':      {'icon': '🌍', 'color': '#4ade80', 'desc': '100 disposals — true Eco Warrior!'},
        'health_guardian':  {'icon': '🛡️', 'color': '#a78bfa', 'desc': '200 disposals — Health Guardian status!'},
    }

    citizen = models.ForeignKey(Citizen, on_delete=models.CASCADE, related_name='badges')
    badge_type = models.CharField(max_length=30, choices=BADGE_CHOICES)
    earned_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = [('citizen', 'badge_type')]
        ordering = ['earned_at']

    def __str__(self):
        return f"{self.citizen} — {self.badge_type}"

    @property
    def meta(self):
        return self.BADGE_META.get(self.badge_type, {})
