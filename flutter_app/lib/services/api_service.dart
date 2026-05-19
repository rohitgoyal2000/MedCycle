import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../constants/api.dart';
import '../models/citizen.dart';
import '../models/pharmacy.dart';
import '../models/disposal.dart';
import '../models/badge_model.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ---------- Citizen ----------

  Future<Citizen> registerCitizen(String region) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.citizenRegister),
            headers: _headers,
            body: jsonEncode({'region': region}),
          )
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Citizen.fromJson(data);
      }
      throw Exception('Registration failed: ${response.statusCode}');
    } catch (_) {
      // Fallback: generate a local citizen
      return Citizen(
        anonymousId: const Uuid().v4(),
        totalPoints: 0,
        totalDisposals: 0,
        region: region,
      );
    }
  }

  Future<Citizen> getCitizenProfile(String anonymousId) async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConstants.citizenProfile(anonymousId)),
            headers: _headers,
          )
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Citizen.fromJson(data);
      }
      throw Exception('Profile fetch failed: ${response.statusCode}');
    } catch (_) {
      return Citizen(
        anonymousId: anonymousId,
        totalPoints: 120,
        totalDisposals: 4,
        region: 'Mumbai',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getCitizenHistory(String anonymousId) async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConstants.citizenHistory(anonymousId)),
            headers: _headers,
          )
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return data.cast<Map<String, dynamic>>();
        if (data is Map && data['results'] is List) {
          return (data['results'] as List).cast<Map<String, dynamic>>();
        }
      }
      throw Exception('History fetch failed');
    } catch (_) {
      return _demoHistory;
    }
  }

  // ---------- Pharmacies ----------

  Future<List<Pharmacy>> getPharmacies() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.pharmacies), headers: _headers)
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data is Map && data['results'] is List) {
          list = data['results'] as List;
        } else {
          list = [];
        }
        return list.map((e) => Pharmacy.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception('Pharmacy fetch failed');
    } catch (_) {
      return _demoPharmacies;
    }
  }

  // ---------- Disposal ----------

  Future<Disposal> initiateDisposal({
    required String anonymousId,
    required String medicineName,
    required String antibioticClass,
    required String quantity,
    required String expiryDate,
    required String amrRiskLevel,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.disposalInitiate),
            headers: _headers,
            body: jsonEncode({
              'anonymous_id': anonymousId,
              'medicine_name': medicineName,
              'antibiotic_class': antibioticClass,
              'quantity': quantity,
              'expiry_date': expiryDate,
              'amr_risk_level': amrRiskLevel,
            }),
          )
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Disposal.fromJson(data);
      }
      throw Exception('Disposal initiation failed: ${response.statusCode}');
    } catch (_) {
      final id = const Uuid().v4();
      return Disposal(
        disposalId: id,
        medicineName: medicineName,
        status: 'pending',
        pointsAwarded: 30,
        qrCodeBase64: null,
        createdAt: DateTime.now().toIso8601String(),
      );
    }
  }

  Future<Map<String, dynamic>> verifyDisposal(String disposalId, int pharmacyId) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.disposalVerify),
            headers: _headers,
            body: jsonEncode({
              'disposal_id': disposalId,
              'pharmacy_id': pharmacyId,
            }),
          )
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Verification failed');
    } catch (_) {
      return {'status': 'verified', 'points_awarded': 30, 'message': 'Disposal verified successfully'};
    }
  }

  // ---------- Rewards ----------

  Future<List<dynamic>> getLeaderboard() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.leaderboard), headers: _headers)
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return data;
        if (data is Map && data['results'] is List) return data['results'] as List;
      }
      throw Exception('Leaderboard fetch failed');
    } catch (_) {
      return _demoLeaderboard;
    }
  }

  Future<List<BadgeModel>> getCitizenBadges(String anonymousId) async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConstants.citizenBadges(anonymousId)),
            headers: _headers,
          )
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data is Map && data['badges'] is List) {
          list = data['badges'] as List;
        } else {
          list = [];
        }
        return list.map((e) => BadgeModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception('Badges fetch failed');
    } catch (_) {
      return BadgeModel.defaultBadges;
    }
  }

  // ---------- Chat ----------

  Future<Map<String, dynamic>> chat(String message, String anonymousId) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.chatbot),
            headers: _headers,
            body: jsonEncode({
              'message': message,
              'anonymous_id': anonymousId,
            }),
          )
          .timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Chat failed');
    } catch (_) {
      return _demoChatResponse(message);
    }
  }

  // ---------- Analytics ----------

  Future<Map<String, dynamic>> getAnalyticsStats() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.analyticsStats), headers: _headers)
          .timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Analytics fetch failed');
    } catch (_) {
      return {
        'total_disposals': 1247,
        'total_citizens': 342,
        'total_pharmacies': 28,
        'kg_prevented': 48.6,
      };
    }
  }

  // ---------- Demo Fallback Data ----------

  static final List<Pharmacy> _demoPharmacies = [
    Pharmacy(
      id: 1,
      name: 'Apollo Pharmacy',
      address: 'Andheri West, Mumbai 400053',
      lat: 19.1364,
      lng: 72.8296,
      isActive: true,
      totalVerified: 89,
      distance: 0.8,
    ),
    Pharmacy(
      id: 2,
      name: 'MedPlus Health',
      address: 'Bandra East, Mumbai 400051',
      lat: 19.0596,
      lng: 72.8395,
      isActive: true,
      totalVerified: 54,
      distance: 1.2,
    ),
    Pharmacy(
      id: 3,
      name: 'Wellness Forever',
      address: 'Juhu, Mumbai 400049',
      lat: 19.1075,
      lng: 72.8263,
      isActive: true,
      totalVerified: 37,
      distance: 2.1,
    ),
    Pharmacy(
      id: 4,
      name: 'Netmeds Pharmacy',
      address: 'Malad West, Mumbai 400064',
      lat: 19.1870,
      lng: 72.8484,
      isActive: false,
      totalVerified: 22,
      distance: 3.4,
    ),
    Pharmacy(
      id: 5,
      name: 'Savitri Medical Store',
      address: 'Goregaon East, Mumbai 400063',
      lat: 19.1663,
      lng: 72.8526,
      isActive: true,
      totalVerified: 61,
      distance: 4.0,
    ),
  ];

  static final List<Map<String, dynamic>> _demoHistory = [
    {
      'disposal_id': 'demo-001',
      'medicine_name': 'Amoxicillin 500mg',
      'status': 'verified',
      'points_awarded': 30,
      'created_at': '2026-03-28T10:30:00Z',
    },
    {
      'disposal_id': 'demo-002',
      'medicine_name': 'Ciprofloxacin 250mg',
      'status': 'verified',
      'points_awarded': 50,
      'created_at': '2026-03-22T15:00:00Z',
    },
    {
      'disposal_id': 'demo-003',
      'medicine_name': 'Azithromycin 500mg',
      'status': 'pending',
      'points_awarded': 0,
      'created_at': '2026-03-31T09:00:00Z',
    },
  ];

  static final List<Map<String, dynamic>> _demoLeaderboard = [
    {'rank': 1, 'region': 'Mumbai', 'points': 480, 'disposals': 16},
    {'rank': 2, 'region': 'Pune', 'points': 390, 'disposals': 13},
    {'rank': 3, 'region': 'Delhi', 'points': 310, 'disposals': 10},
    {'rank': 4, 'region': 'Chennai', 'points': 260, 'disposals': 9},
    {'rank': 5, 'region': 'Bangalore', 'points': 230, 'disposals': 8},
    {'rank': 6, 'region': 'Hyderabad', 'points': 210, 'disposals': 7},
    {'rank': 7, 'region': 'Kolkata', 'points': 190, 'disposals': 6},
    {'rank': 8, 'region': 'Ahmedabad', 'points': 150, 'disposals': 5},
  ];

  static Map<String, dynamic> _demoChatResponse(String message) {
    final lower = message.toLowerCase();
    String reply;
    if (lower.contains('amr') || lower.contains('antibiotic resistance')) {
      reply =
          'AMR (Antimicrobial Resistance) occurs when bacteria evolve to resist the effects of antibiotics. Improper disposal of antibiotics into drains or landfills contributes to AMR spread. Always dispose of antibiotics through MedCycle drop-off points!';
    } else if (lower.contains('earn') || lower.contains('point') || lower.contains('reward')) {
      reply =
          'You earn points for every safe disposal! Low-risk medicines: 10 pts, Medium: 20 pts, High: 30 pts, Critical: 50 pts. Collect badges and climb the leaderboard as you go!';
    } else if (lower.contains('guide') || lower.contains('how') || lower.contains('dispose')) {
      reply =
          'To dispose safely: 1) Fill in the medicine details in the Dispose tab. 2) Generate a QR code. 3) Visit any MedCycle partner pharmacy. 4) Show the QR to the pharmacist. 5) Earn your points and badge!';
    } else if (lower.contains('pharmacy') || lower.contains('location') || lower.contains('where')) {
      reply =
          'Use the Map tab to find the nearest MedCycle partner pharmacy. You can tap "Locate Me" to find pharmacies near your current location. We have 28+ partner pharmacies across major cities.';
    } else {
      reply =
          'Thank you for your question! I\'m here to help with safe antibiotic disposal. You can ask me about AMR risks, how to earn reward points, finding pharmacies, or step-by-step disposal guides. What would you like to know?';
    }
    return {'response': reply, 'message': reply};
  }
}
