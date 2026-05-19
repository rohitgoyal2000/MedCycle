class BadgeModel {
  final String type;
  final String name;
  final String icon;
  final String color;
  final String description;
  final bool earned;

  const BadgeModel({
    required this.type,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.earned,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      type: json['type']?.toString() ?? json['badge_type']?.toString() ?? '',
      name: json['name']?.toString() ?? json['badge_name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '🏅',
      color: json['color']?.toString() ?? '#2563EB',
      description: json['description']?.toString() ?? '',
      earned: json['earned'] == true || json['earned'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'icon': icon,
      'color': color,
      'description': description,
      'earned': earned,
    };
  }

  static List<BadgeModel> get defaultBadges => [
        const BadgeModel(
          type: 'first_disposal',
          name: 'First Disposal',
          icon: '🌱',
          color: '#10B981',
          description: 'Completed your first safe medicine disposal',
          earned: false,
        ),
        const BadgeModel(
          type: 'amr_hero',
          name: 'AMR Hero',
          icon: '🦸',
          color: '#2563EB',
          description: 'Disposed 5 antibiotic medicines safely',
          earned: false,
        ),
        const BadgeModel(
          type: 'safe_champion',
          name: 'Safe Champion',
          icon: '🛡️',
          color: '#7C3AED',
          description: 'Completed 10 safe disposals',
          earned: false,
        ),
        const BadgeModel(
          type: 'community_leader',
          name: 'Community Leader',
          icon: '👑',
          color: '#F59E0B',
          description: 'Top 10 in your region leaderboard',
          earned: false,
        ),
        const BadgeModel(
          type: 'eco_warrior',
          name: 'Eco Warrior',
          icon: '🌍',
          color: '#059669',
          description: 'Prevented 1kg of antibiotics from entering environment',
          earned: false,
        ),
        const BadgeModel(
          type: 'health_guardian',
          name: 'Health Guardian',
          icon: '❤️',
          color: '#EF4444',
          description: 'Completed 25 safe disposals',
          earned: false,
        ),
      ];
}
