class Citizen {
  final String anonymousId;
  final int totalPoints;
  final int totalDisposals;
  final String region;

  const Citizen({
    required this.anonymousId,
    required this.totalPoints,
    required this.totalDisposals,
    required this.region,
  });

  factory Citizen.fromJson(Map<String, dynamic> json) {
    return Citizen(
      anonymousId: json['anonymous_id']?.toString() ?? json['id']?.toString() ?? '',
      totalPoints: (json['total_points'] ?? json['points'] ?? 0) as int,
      totalDisposals: (json['total_disposals'] ?? json['disposals'] ?? 0) as int,
      region: json['region']?.toString() ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anonymous_id': anonymousId,
      'total_points': totalPoints,
      'total_disposals': totalDisposals,
      'region': region,
    };
  }

  Citizen copyWith({
    String? anonymousId,
    int? totalPoints,
    int? totalDisposals,
    String? region,
  }) {
    return Citizen(
      anonymousId: anonymousId ?? this.anonymousId,
      totalPoints: totalPoints ?? this.totalPoints,
      totalDisposals: totalDisposals ?? this.totalDisposals,
      region: region ?? this.region,
    );
  }
}
