class ScanResult {
  final String barcode;
  final String itemName;
  final bool isRecyclable;
  final String binColour;
  final String tip;
  final int repeatCount;

  const ScanResult({
    required this.barcode,
    required this.itemName,
    required this.isRecyclable,
    required this.binColour,
    required this.tip,
    this.repeatCount = 1,
  });
}
