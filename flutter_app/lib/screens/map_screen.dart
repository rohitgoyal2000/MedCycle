import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../models/pharmacy.dart';
import '../providers/citizen_provider.dart';
import '../widgets/pharmacy_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  int? _selectedPharmacyId;
  String _searchQuery = '';

  // Default center: Mumbai
  static const LatLng _defaultCenter = LatLng(19.0760, 72.8777);

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Pharmacy> _filteredPharmacies(List<Pharmacy> all) {
    if (_searchQuery.trim().isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    return all.where((p) => p.name.toLowerCase().contains(q) || p.address.toLowerCase().contains(q)).toList();
  }

  void _flyToPharmacy(Pharmacy pharmacy) {
    _mapController.move(LatLng(pharmacy.lat, pharmacy.lng), 15);
    setState(() => _selectedPharmacyId = pharmacy.id);
  }

  void _locateMe() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Location',
          style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'For location services, please add the geolocator package and request permissions. Showing default Mumbai location.',
          style: TextStyle(fontFamily: 'PlusJakartaSans'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _mapController.move(_defaultCenter, 13);
            },
            child: const Text('OK', style: TextStyle(color: AppTheme.primary, fontFamily: 'PlusJakartaSans')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<CitizenProvider>(
      builder: (context, provider, _) {
        final pharmacies = _filteredPharmacies(provider.pharmacies);

        return Container(
          color: AppTheme.bgLight,
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search pharmacies...',
                          prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: AppTheme.textMuted),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _locateMe,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: AppTheme.gradientMain,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.my_location, color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),

              // Map
              SizedBox(
                height: 280,
                child: Stack(
                  children: [
                    ClipRRect(
                      child: FlutterMap(
                        mapController: _mapController,
                        options: const MapOptions(
                          initialCenter: _defaultCenter,
                          initialZoom: 12,
                          minZoom: 8,
                          maxZoom: 18,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.medcycle.app',
                          ),
                          MarkerLayer(
                            markers: pharmacies
                                .map(
                                  (p) => Marker(
                                    point: LatLng(p.lat, p.lng),
                                    width: 46,
                                    height: 46,
                                    child: GestureDetector(
                                      onTap: () => _flyToPharmacy(p),
                                      child: _buildMapMarker(p),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    // Stats overlay
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_pharmacy, color: AppTheme.primary, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              '${pharmacies.length} pharmacies',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Pharmacy list
              Expanded(
                child: provider.isLoading && provider.pharmacies.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                    : pharmacies.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.search_off, size: 48, color: AppTheme.textMuted),
                                const SizedBox(height: 12),
                                Text(
                                  'No pharmacies found',
                                  style: AppTheme.bodyMD.copyWith(fontSize: 15),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            itemCount: pharmacies.length,
                            itemBuilder: (ctx, i) {
                              final p = pharmacies[i];
                              return PharmacyCard(
                                pharmacy: p,
                                isSelected: _selectedPharmacyId == p.id,
                                onTap: () => _flyToPharmacy(p),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapMarker(Pharmacy pharmacy) {
    final isSelected = _selectedPharmacyId == pharmacy.id;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: pharmacy.isActive ? AppTheme.gradientMain : null,
        color: pharmacy.isActive ? null : AppTheme.textMuted,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (pharmacy.isActive ? AppTheme.primary : AppTheme.textMuted).withValues(alpha: isSelected ? 0.5 : 0.3),
            blurRadius: isSelected ? 14 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.local_pharmacy,
        color: Colors.white,
        size: isSelected ? 24 : 20,
      ),
    );
  }
}
