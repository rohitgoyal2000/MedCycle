import 'package:flutter/foundation.dart';
import '../models/citizen.dart';
import '../models/pharmacy.dart';
import '../models/disposal.dart';
import '../models/badge_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class CitizenProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Citizen? _citizen;
  List<Pharmacy> _pharmacies = [];
  List<BadgeModel> _badges = [];
  List<Map<String, dynamic>> _history = [];
  List<dynamic> _leaderboard = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Citizen? get citizen => _citizen;
  List<Pharmacy> get pharmacies => _pharmacies;
  List<BadgeModel> get badges => _badges;
  List<Map<String, dynamic>> get history => _history;
  List<dynamic> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get earnedBadgeCount => _badges.where((b) => b.earned).length;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  /// Called on app start — loads saved citizen or registers a new one
  Future<void> init() async {
    _setLoading(true);
    try {
      final savedId = await StorageService.loadAnonymousId();
      if (savedId != null && savedId.isNotEmpty) {
        _citizen = await _apiService.getCitizenProfile(savedId);
      } else {
        final region = await StorageService.loadRegion() ?? 'Mumbai';
        _citizen = await _apiService.registerCitizen(region);
        await StorageService.saveAnonymousId(_citizen!.anonymousId);
        await StorageService.saveRegion(_citizen!.region);
      }
      // Load supporting data in parallel
      await Future.wait([
        loadPharmacies(),
        loadBadges(),
        loadHistory(),
        loadLeaderboard(),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProfile() async {
    if (_citizen == null) return;
    try {
      _citizen = await _apiService.getCitizenProfile(_citizen!.anonymousId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> loadPharmacies() async {
    try {
      _pharmacies = await _apiService.getPharmacies();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> loadBadges() async {
    if (_citizen == null) return;
    try {
      _badges = await _apiService.getCitizenBadges(_citizen!.anonymousId);
      notifyListeners();
    } catch (e) {
      _badges = BadgeModel.defaultBadges;
      notifyListeners();
    }
  }

  Future<void> loadHistory() async {
    if (_citizen == null) return;
    try {
      _history = await _apiService.getCitizenHistory(_citizen!.anonymousId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> loadLeaderboard() async {
    try {
      _leaderboard = await _apiService.getLeaderboard();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  /// Initiates a disposal and returns the Disposal object (with QR code)
  Future<Disposal?> initiateDisposal({
    required String medicineName,
    required String antibioticClass,
    required String quantity,
    required String expiryDate,
    required String amrRiskLevel,
  }) async {
    if (_citizen == null) return null;
    _setLoading(true);
    try {
      final disposal = await _apiService.initiateDisposal(
        anonymousId: _citizen!.anonymousId,
        medicineName: medicineName,
        antibioticClass: antibioticClass,
        quantity: quantity,
        expiryDate: expiryDate,
        amrRiskLevel: amrRiskLevel,
      );
      return disposal;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> verifyDisposal(String disposalId, int pharmacyId) async {
    _setLoading(true);
    try {
      final result = await _apiService.verifyDisposal(disposalId, pharmacyId);
      // Update local citizen points
      if (_citizen != null && result['points_awarded'] != null) {
        final pts = (result['points_awarded'] as num).toInt();
        _citizen = _citizen!.copyWith(
          totalPoints: _citizen!.totalPoints + pts,
          totalDisposals: _citizen!.totalDisposals + 1,
        );
      }
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> sendChatMessage(String message) async {
    return _apiService.chat(message, _citizen?.anonymousId ?? 'anonymous');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
