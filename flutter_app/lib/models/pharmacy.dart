class Pharmacy {
  final int id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final bool isActive;
  final int totalVerified;
  double? distance;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.isActive,
    required this.totalVerified,
    this.distance,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      id: (json['id'] ?? 0) as int,
      name: json['name']?.toString() ?? 'Unknown Pharmacy',
      address: json['address']?.toString() ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? json['latitude']?.toString() ?? '0') ?? 0.0,
      lng: double.tryParse(json['lng']?.toString() ?? json['longitude']?.toString() ?? '0') ?? 0.0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      totalVerified: (json['total_verified'] ?? 0) as int,
      distance: json['distance'] != null ? double.tryParse(json['distance'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'is_active': isActive,
      'total_verified': totalVerified,
      if (distance != null) 'distance': distance,
    };
  }
}
