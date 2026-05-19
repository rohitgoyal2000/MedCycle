class Disposal {
  final String disposalId;
  final String medicineName;
  final String status;
  final int pointsAwarded;
  final String? qrCodeBase64;
  final String createdAt;

  const Disposal({
    required this.disposalId,
    required this.medicineName,
    required this.status,
    required this.pointsAwarded,
    this.qrCodeBase64,
    required this.createdAt,
  });

  factory Disposal.fromJson(Map<String, dynamic> json) {
    return Disposal(
      disposalId: json['disposal_id']?.toString() ?? json['id']?.toString() ?? '',
      medicineName: json['medicine_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      pointsAwarded: (json['points_awarded'] ?? json['points'] ?? 0) as int,
      qrCodeBase64: json['qr_code']?.toString() ?? json['qr_code_base64']?.toString(),
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disposal_id': disposalId,
      'medicine_name': medicineName,
      'status': status,
      'points_awarded': pointsAwarded,
      if (qrCodeBase64 != null) 'qr_code_base64': qrCodeBase64,
      'created_at': createdAt,
    };
  }
}
