import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

enum RecyclingCategory { plastic, glass, paper, metal, electronics, clothing }

class RecyclingPoint {
  final String id;
  final String name;
  final LatLng location;
  final List<RecyclingCategory> categories;
  final String address;
  final String? openingHours;
  final double? distanceKm;

  const RecyclingPoint({
    required this.id,
    required this.name,
    required this.location,
    required this.categories,
    required this.address,
    this.openingHours,
    this.distanceKm,
  });

  RecyclingPoint copyWith({double? distanceKm}) => RecyclingPoint(
    id: id,
    name: name,
    location: location,
    categories: categories,
    address: address,
    openingHours: openingHours,
    distanceKm: distanceKm ?? this.distanceKm,
  );
}

// ---------------------------------------------------------------------------
// Overpass API service
// ---------------------------------------------------------------------------

class _OverpassService {
  static const _endpoint = 'https://overpass-api.de/api/interpreter';

  // Maps OSM recycling:* tag values → our category enum
  static const _tagMap = <String, RecyclingCategory>{
    'plastic': RecyclingCategory.plastic,
    'plastic_bottles': RecyclingCategory.plastic,
    'glass': RecyclingCategory.glass,
    'glass_bottles': RecyclingCategory.glass,
    'paper': RecyclingCategory.paper,
    'cardboard': RecyclingCategory.paper,
    'metal': RecyclingCategory.metal,
    'scrap_metal': RecyclingCategory.metal,
    'electrical_items': RecyclingCategory.electronics,
    'electronics': RecyclingCategory.electronics,
    'small_appliances': RecyclingCategory.electronics,
    'clothes': RecyclingCategory.clothing,
    'shoes': RecyclingCategory.clothing,
    'textiles': RecyclingCategory.clothing,
  };

  static Future<List<RecyclingPoint>> fetchNearby(
    double lat,
    double lon, {
    int radiusMetres = 3000,
  }) async {
    final query =
        '''
[out:json][timeout:25];
(
  node["amenity"="recycling"](around:$radiusMetres,$lat,$lon);
  node["recycling_type"="centre"](around:$radiusMetres,$lat,$lon);
);
out body;
''';

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'data=${Uri.encodeComponent(query)}',
    );

    if (response.statusCode != 200) {
      throw Exception('Overpass API error ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = (json['elements'] as List<dynamic>?) ?? [];

    final points = <RecyclingPoint>[];
    for (final el in elements) {
      final tags = (el['tags'] as Map<String, dynamic>?) ?? {};
      final id = el['id'].toString();
      final nodeLat = (el['lat'] as num?)?.toDouble();
      final nodeLon = (el['lon'] as num?)?.toDouble();
      if (nodeLat == null || nodeLon == null) continue;

      // Derive categories from recycling:* = yes tags
      final categories = <RecyclingCategory>{};
      for (final entry in tags.entries) {
        if (entry.key.startsWith('recycling:') && entry.value == 'yes') {
          final material = entry.key.replaceFirst('recycling:', '');
          final cat = _tagMap[material];
          if (cat != null) categories.add(cat);
        }
      }
      // Recycling centres accept everything
      if (categories.isEmpty && tags['recycling_type'] == 'centre') {
        categories.addAll(RecyclingCategory.values);
      }

      final name =
          tags['name'] ??
          tags['operator'] ??
          (tags['recycling_type'] == 'centre'
              ? 'Recycling Centre'
              : 'Recycling Point');

      final addrParts = <String>[
        if (tags['addr:housenumber'] != null && tags['addr:street'] != null)
          '${tags['addr:housenumber']} ${tags['addr:street']}',
        if (tags['addr:street'] != null && tags['addr:housenumber'] == null)
          tags['addr:street']!,
        if (tags['addr:city'] != null) tags['addr:city']!,
        if (tags['addr:postcode'] != null) tags['addr:postcode']!,
      ];
      final address = addrParts.isNotEmpty
          ? addrParts.join(', ')
          : '${nodeLat.toStringAsFixed(4)}, ${nodeLon.toStringAsFixed(4)}';

      points.add(
        RecyclingPoint(
          id: id,
          name: name,
          location: LatLng(nodeLat, nodeLon),
          categories: categories.toList(),
          address: address,
          openingHours: tags['opening_hours'] as String?,
        ),
      );
    }

    return points;
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class RecyclingMapScreen extends StatefulWidget {
  const RecyclingMapScreen({super.key});

  @override
  State<RecyclingMapScreen> createState() => _RecyclingMapScreenState();
}

class _RecyclingMapScreenState extends State<RecyclingMapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  LatLng? _userLocation;
  bool _locationLoading = true;

  List<RecyclingPoint> _points = [];
  bool _pointsLoading = false;
  String? _pointsError;

  RecyclingPoint? _selectedPoint;
  RecyclingCategory? _activeFilter;

  late final AnimationController _sheetController;
  late final Animation<Offset> _sheetSlide;
  late final AnimationController _fabController;
  late final Animation<double> _fabScale;

  List<RecyclingPoint> get _filteredPoints => _activeFilter == null
      ? _points
      : _points.where((p) => p.categories.contains(_activeFilter)).toList();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _sheetSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _sheetController, curve: Curves.easeOutCubic),
        );

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _fabScale = CurvedAnimation(parent: _fabController, curve: Curves.easeOut);

    _requestLocation();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Future<void> _requestLocation() async {
    setState(() => _locationLoading = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _locationLoading = false;
          _pointsError = 'Location permission denied.';
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;

      final userLatLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _userLocation = userLatLng;
        _locationLoading = false;
      });

      _mapController.move(userLatLng, 14.5);
      _fabController.forward();

      await _fetchRecyclingPoints(userLatLng);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationLoading = false;
        _pointsError = 'Could not get location.';
      });
    }
  }

  Future<void> _fetchRecyclingPoints(LatLng centre) async {
    setState(() {
      _pointsLoading = true;
      _pointsError = null;
    });

    try {
      final raw = await _OverpassService.fetchNearby(
        centre.latitude,
        centre.longitude,
        radiusMetres: 3000,
      );
      if (!mounted) return;

      final dist = const Distance();
      final annotated =
          raw
              .map(
                (p) => p.copyWith(
                  distanceKm: dist.as(LengthUnit.Kilometer, centre, p.location),
                ),
              )
              .toList()
            ..sort(
              (a, b) => (a.distanceKm ?? 9999).compareTo(b.distanceKm ?? 9999),
            );

      setState(() {
        _points = annotated;
        _pointsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pointsLoading = false;
        _pointsError = 'Could not load recycling points.';
      });
    }
  }

  void _centreOnUser() {
    if (_userLocation == null) return;
    HapticFeedback.lightImpact();
    _mapController.move(_userLocation!, 15);
  }

  Future<void> _refresh() async {
    if (_userLocation == null) return;
    HapticFeedback.mediumImpact();
    _dismissSheet();
    await _fetchRecyclingPoints(_userLocation!);
  }

  // ── Marker selection ──────────────────────────────────────────────────────

  void _selectPoint(RecyclingPoint point) {
    HapticFeedback.selectionClick();
    setState(() => _selectedPoint = point);
    _sheetController.forward(from: 0);
    _mapController.move(point.location, 15.5);
  }

  void _dismissSheet() {
    _sheetController.reverse().then((_) {
      if (mounted) setState(() => _selectedPoint = null);
    });
  }

  Future<void> _openDirections(RecyclingPoint point) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${point.location.latitude},${point.location.longitude}',
    );
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterRow(),
            Expanded(
              child: _locationLoading
                  ? _buildCentredLoader('Getting your location…')
                  : Stack(
                      children: [
                        _buildMap(),
                        _buildFAB(),
                        if (_pointsLoading) _buildMapLoader(),
                        if (_pointsError != null && !_pointsLoading)
                          _buildErrorBanner(),
                        if (_selectedPoint != null) _buildBottomSheet(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.green100,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.eco, size: 20, color: AppTheme.green600),
          ),
          const SizedBox(width: 10),
          const Text(
            'EcoScan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '·',
            style: TextStyle(fontSize: 22, color: Color(0xFFA1A19A)),
          ),
          const SizedBox(width: 8),
          const Text(
            'Nearby Points',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: Color(0xFFA1A19A),
              letterSpacing: -0.4,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _refresh,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppTheme.green100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                size: 18,
                color: AppTheme.green700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.green100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_filteredPoints.length} sites',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.green700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────────────

  static const _filterMeta = <RecyclingCategory, (String, IconData)>{
    RecyclingCategory.plastic: ('Plastic', Icons.water_drop_outlined),
    RecyclingCategory.glass: ('Glass', Icons.wine_bar_outlined),
    RecyclingCategory.paper: ('Paper', Icons.article_outlined),
    RecyclingCategory.metal: ('Metal', Icons.hardware_outlined),
    RecyclingCategory.electronics: ('Electronics', Icons.devices_outlined),
    RecyclingCategory.clothing: ('Clothing', Icons.checkroom_outlined),
  };

  Widget _buildFilterRow() {
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip(null, 'All', Icons.layers_outlined),
          ...RecyclingCategory.values.map((cat) {
            final (label, icon) = _filterMeta[cat]!;
            return _filterChip(cat, label, icon);
          }),
        ],
      ),
    );
  }

  Widget _filterChip(RecyclingCategory? category, String label, IconData icon) {
    final active = _activeFilter == category;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeFilter = category);
        if (_selectedPoint != null &&
            category != null &&
            !_selectedPoint!.categories.contains(category)) {
          _dismissSheet();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppTheme.green600 : AppTheme.green100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppTheme.green600 : AppTheme.green400,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? Colors.white : AppTheme.green700,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : AppTheme.green700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Map ───────────────────────────────────────────────────────────────────

  Widget _buildMap() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _userLocation!,
          initialZoom: 14.5,
          onTap: (_, __) => _dismissSheet(),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.ecoscan',
          ),
          MarkerLayer(markers: _buildMarkers()),
          MarkerLayer(
            markers: [
              Marker(
                point: _userLocation!,
                width: 20,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.green600,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.green600.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    return _filteredPoints.map((point) {
      final isSelected = _selectedPoint?.id == point.id;
      return Marker(
        point: point.location,
        width: isSelected ? 44 : 36,
        height: isSelected ? 44 : 36,
        child: GestureDetector(
          onTap: () => _selectPoint(point),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppTheme.green600 : Colors.white,
              border: Border.all(
                color: isSelected ? AppTheme.green600 : AppTheme.green400,
                width: isSelected ? 0 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: isSelected ? 12 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.recycling_rounded,
              size: isSelected ? 22 : 18,
              color: isSelected ? Colors.white : AppTheme.green600,
            ),
          ),
        ),
      );
    }).toList();
  }

  // ── Overlays ──────────────────────────────────────────────────────────────

  Widget _buildCentredLoader(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.green600,
            strokeWidth: 2,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: Color(0xFFA1A19A)),
          ),
        ],
      ),
    );
  }

  Widget _buildMapLoader() {
    return Positioned(
      top: 12,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 12,
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  color: AppTheme.green600,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Finding recycling points…',
                style: TextStyle(fontSize: 12, color: Color(0xFF555550)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3F3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFE57373), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _pointsError!,
                style: const TextStyle(fontSize: 12, color: Color(0xFFC62828)),
              ),
            ),
            GestureDetector(
              onTap: _refresh,
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.green600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FAB ───────────────────────────────────────────────────────────────────

  Widget _buildFAB() {
    return Positioned(
      right: 16,
      top: 16,
      child: ScaleTransition(
        scale: _fabScale,
        child: GestureDetector(
          onTap: _centreOnUser,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.my_location_rounded,
              size: 20,
              color: AppTheme.green600,
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom detail sheet ───────────────────────────────────────────────────

  Widget _buildBottomSheet() {
    final point = _selectedPoint!;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _sheetSlide,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0D8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            point.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (point.distanceKm != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.green100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${point.distanceKm!.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.green700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: Color(0xFFA1A19A),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            point.address,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFA1A19A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (point.openingHours != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Color(0xFFA1A19A),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              point.openingHours!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFA1A19A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (point.categories.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: point.categories
                            .map((c) => _categoryChip(c))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _openDirections(point),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.green600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(
                          Icons.directions_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Get Directions',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(RecyclingCategory cat) {
    final (label, icon) = _filterMeta[cat]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.green100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.green400),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.green700),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.green700,
            ),
          ),
        ],
      ),
    );
  }
}
