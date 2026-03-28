import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
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
  String? _locationError;

  RecyclingPoint? _selectedPoint;
  RecyclingCategory? _activeFilter;

  late final AnimationController _sheetController;
  late final Animation<Offset> _sheetSlide;
  late final AnimationController _fabController;
  late final Animation<double> _fabScale;

  // ── Mock data ─────────────────────────────────────────────────────────────
  // Replace with a real API / gRPC call once your backend is ready.
  static const List<RecyclingPoint> _mockPoints = [
    RecyclingPoint(
      id: '1',
      name: 'Highbury Recycling Hub',
      location: LatLng(51.5525, -0.1027),
      categories: [
        RecyclingCategory.plastic,
        RecyclingCategory.glass,
        RecyclingCategory.paper,
      ],
      address: '14 Highbury Grove, London N5 2EA',
      openingHours: 'Mon–Sat  8 am – 6 pm',
    ),
    RecyclingPoint(
      id: '2',
      name: 'Islington Bottle Bank',
      location: LatLng(51.5465, -0.1058),
      categories: [RecyclingCategory.glass, RecyclingCategory.metal],
      address: 'Islington Green Car Park, N1 8DU',
      openingHours: 'Open 24 hours',
    ),
    RecyclingPoint(
      id: '3',
      name: 'Holloway Reuse Centre',
      location: LatLng(51.5601, -0.1145),
      categories: [
        RecyclingCategory.electronics,
        RecyclingCategory.clothing,
        RecyclingCategory.plastic,
      ],
      address: '254 Holloway Road, London N7 6NE',
      openingHours: 'Tue–Sun  9 am – 5 pm',
    ),
    RecyclingPoint(
      id: '4',
      name: 'Finsbury Park Drop-off',
      location: LatLng(51.5642, -0.1050),
      categories: [
        RecyclingCategory.paper,
        RecyclingCategory.plastic,
        RecyclingCategory.metal,
      ],
      address: 'Finsbury Park Station, N4 2NQ',
      openingHours: 'Mon–Fri  7 am – 8 pm',
    ),
    RecyclingPoint(
      id: '5',
      name: 'Canonbury E-Waste Point',
      location: LatLng(51.5490, -0.0945),
      categories: [RecyclingCategory.electronics],
      address: 'Canonbury Square, N1 2AN',
      openingHours: 'Mon–Sat  10 am – 4 pm',
    ),
    RecyclingPoint(
      id: '6',
      name: 'Upper Street Textiles',
      location: LatLng(51.5442, -0.1026),
      categories: [RecyclingCategory.clothing],
      address: '112 Upper Street, London N1 1QN',
      openingHours: 'Open 24 hours',
    ),
  ];

  List<RecyclingPoint> get _filteredPoints => _activeFilter == null
      ? _mockPoints
      : _mockPoints.where((p) => p.categories.contains(_activeFilter)).toList();

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
    setState(() {
      _locationLoading = true;
      _locationError = null;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _locationLoading = false;
          _locationError = 'Location permission denied.';
          // Fall back to central London
          _userLocation = const LatLng(51.5074, -0.1278);
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      final userLatLng = LatLng(pos.latitude, pos.longitude);

      // Annotate mock points with real distances
      final annotated =
          _mockPoints.map((p) {
            final dist =
                const Distance().as(
                  LengthUnit.Kilometer,
                  userLatLng,
                  p.location,
                ) /
                1000;
            return p.copyWith(distanceKm: dist);
          }).toList()..sort(
            (a, b) => (a.distanceKm ?? 9999).compareTo(b.distanceKm ?? 9999),
          );

      setState(() {
        _userLocation = userLatLng;
        _locationLoading = false;
      });

      _mapController.move(userLatLng, 14.5);
      _fabController.forward();
      print('Permission: $permission');
      print('Position: ${pos.latitude}, ${pos.longitude}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationLoading = false;
        _locationError = 'Could not get location.';
        _userLocation = const LatLng(51.5525, -0.1027);
      });
    }
  }

  void _centreOnUser() {
    if (_userLocation == null) return;
    HapticFeedback.lightImpact();
    _mapController.move(_userLocation!, 15);
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

  // ── Directions ────────────────────────────────────────────────────────────

  Future<void> _openDirections(RecyclingPoint point) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${point.location.latitude},${point.location.longitude}',
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
              child: Stack(
                children: [
                  _buildMap(),
                  _buildFAB(),
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
    // Default centre: north London (near mock data)
    final centre = _userLocation ?? const LatLng(51.5525, -0.1027);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: centre,
          initialZoom: 14.5,
          onTap: (_, __) => _dismissSheet(),
        ),
        children: [
          // Tile layer – OSM (swap for a styled tiles URL if desired)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.ecoscan',
          ),
          // Recycling point markers
          MarkerLayer(markers: _buildMarkers()),
          // User location dot
          if (_userLocation != null)
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
              // Drag handle
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
                    // Name + distance row
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
                    // Address
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
                    // Opening hours
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
                          Text(
                            point.openingHours!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFA1A19A),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Category chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: point.categories
                          .map((c) => _categoryChip(c))
                          .toList(),
                    ),
                    const SizedBox(height: 14),
                    // Directions button
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
