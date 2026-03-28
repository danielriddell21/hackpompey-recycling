import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:grpc/grpc.dart';

import '../generated/recycling.pbgrpc.dart'; // generated service client
import '../widgets/result_card.dart';
import '../theme/app_theme.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with TickerProviderStateMixin {
  RecyclingItem? _lastResult;
  String? _lastBarcode;
  int _repeatCount = 0;
  int _totalScans = 0;
  bool _isLoading = false;
  String? _errorMessage;

  late final RecyclingServiceClient _recyclingClient;
  late final ClientChannel _channel;

  late final AnimationController _ringController;
  late final AnimationController _cardController;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _cardSlide;

  @override
  void initState() {
    super.initState();

    // TODO: Replace with actual endpoint
    _channel = ClientChannel(
      'your-api-host.example.com',
      port: 443,
      options: const ChannelOptions(credentials: ChannelCredentials.secure()),
    );
    _recyclingClient = RecyclingServiceClient(_channel);

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
    _channel.shutdown();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(String barcode) async {
    if (barcode == _lastBarcode) return;

    _lastBarcode = barcode;
    _repeatCount = 1;
    _totalScans++;

    HapticFeedback.mediumImpact();
    _ringController.forward(from: 0);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with real gRPC call
      await Future.delayed(
        const Duration(milliseconds: 600),
      ); // simulate latency

      final mockItem = RecyclingItem(
        recyclable: true,
        advice: 'Rinse and remove the cap before placing in the correct bin.',
        binColour: RecyclingItem_BinColour.GREEN,
        binType: RecyclingItem_BinType.PLASTIC,
      );

      setState(() {
        _lastResult = mockItem;
        _isLoading = false;
      });

      _cardController.forward(from: 0);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  // Future<void> _onBarcodeDetected(String barcode) async {
  //   if (barcode == _lastBarcode) return;

  //   _lastBarcode = barcode;
  //   _repeatCount = 1;
  //   _totalScans++;

  //   HapticFeedback.mediumImpact();
  //   _ringController.forward(from: 0);

  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = null;
  //   });

  //   try {
  //     final request = CanItBeRecycledRequest(barcode: barcode);
  //     final response = await _recyclingClient.canItBeRecycled(request);

  //     setState(() {
  //       _lastResult = response.data;
  //       _isLoading = false;
  //     });

  //     _cardController.forward(from: 0);
  //   } on GrpcError catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //       _errorMessage = e.message ?? 'Could not reach recycling service';
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //       _errorMessage = 'Something went wrong. Please try again.';
  //     });
  //   }
  // }

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
        aspectRatio: 1,
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
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 32),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.green600,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3F3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFCDD2)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFE57373),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFC62828),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_lastResult == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
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
      child: ResultCard(
        item: _lastResult!,
        barcode: _lastBarcode!,
        repeatCount: _repeatCount,
      ),
    );
  }
}
