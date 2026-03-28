import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/scan_result.dart';
import '../widgets/result_card.dart';
import '../theme/app_theme.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with TickerProviderStateMixin {
  ScanResult? _lastResult;
  String? _lastBarcode;
  int _repeatCount = 0;
  int _totalScans = 0;

  late final AnimationController _ringController;
  late final AnimationController _cardController;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _cardSlide;

  @override
  void initState() {
    super.initState();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _ringOpacity = Tween(
      begin: 0.9,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ringController, curve: Curves.easeOut));
    _cardSlide = Tween(
      begin: 8.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ringController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(String barcode) {
    if (barcode == _lastBarcode) {
      return;
    } else {
      _repeatCount = 1;
      _lastBarcode = barcode;
    }
    _totalScans++;

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Trigger animations
    _ringController.forward(from: 0);
    _cardController.forward(from: 0);

    final result = _mockLookup(barcode);
    setState(() {
      _lastResult = result;
    });
  }

  //TODO: Replace with real API call
  ScanResult _mockLookup(String barcode) {
    return ScanResult(
      barcode: barcode,
      itemName: 'Plastic Bottle',
      isRecyclable: true,
      binColour: 'Yellow bin',
      tip: 'Rinse and remove the cap before placing in the yellow bin.',
      repeatCount: _repeatCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildScanLabel(),
                    const SizedBox(height: 10),
                    _buildViewfinder(),
                    const SizedBox(height: 12),
                    _buildResultArea(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              fontSize: 32,
              fontWeight: FontWeight.w600,
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
              '$_totalScans ${_totalScans == 1 ? "scan" : "scans"}',
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

  Widget _buildScanLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'SCANNER',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFFA1A19A),
            letterSpacing: 1.0,
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _totalScans > 0
                ? AppTheme.green100
                : const Color(0x0A000000),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'session active',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _totalScans > 0
                  ? AppTheme.green700
                  : const Color(0xFFA1A19A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewfinder() {
    return AnimatedBuilder(
      animation: _ringController,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.green400.withValues(alpha: _ringOpacity.value),
            width: 2,
          ),
        ),
        child: child,
      ),
      child: AspectRatio(
        aspectRatio: 1, // always square
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              MobileScanner(
                onDetect: (capture) {
                  final barcode = capture.barcodes.firstOrNull?.rawValue;
                  if (barcode != null) _onBarcodeDetected(barcode);
                },
              ),
              _buildCorners(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorners() {
    return Stack(
      children: [
        Positioned(top: 14, left: 14, child: _corner(0)),
        Positioned(top: 14, right: 14, child: _corner(1)),
        Positioned(bottom: 14, left: 14, child: _corner(2)),
        Positioned(bottom: 14, right: 14, child: _corner(3)),
      ],
    );
  }

  Widget _corner(int index) {
    final borderSide = const BorderSide(color: Colors.white, width: 2.2);
    final borders = [
      Border(top: borderSide, left: borderSide),
      Border(top: borderSide, right: borderSide),
      Border(bottom: borderSide, left: borderSide),
      Border(bottom: borderSide, right: borderSide),
    ];
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(border: borders[index]),
    );
  }

  Widget _buildResultArea() {
    if (_lastResult == null) {
      return Padding(
        padding: EdgeInsets.only(top: 16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.green100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.green400, width: 1.5),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 36,
                  color: AppTheme.green400,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Scan an item',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF1A1A18),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'to see if it\'s recyclable',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFA1A19A),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _cardSlide.value),
        child: Opacity(
          opacity: _cardController.value.clamp(0.0, 1.0),
          child: child,
        ),
      ),
      child: ResultCard(result: _lastResult!, repeatCount: _repeatCount),
    );
  }
}
