import 'package:flutter/material.dart';
import '../generated/recycling.pb.dart';
import '../theme/app_theme.dart';

class ResultCard extends StatelessWidget {
  final RecyclingItem item;
  final String barcode;
  final int repeatCount;

  const ResultCard({
    super.key,
    required this.item,
    required this.barcode,
    this.repeatCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isRecyclable = item.recyclable;
    final colour = isRecyclable ? AppTheme.green100 : AppTheme.orange100;
    final textColour = isRecyclable ? AppTheme.green600 : AppTheme.orange600;
    final label = isRecyclable ? 'Recyclable' : 'Not recyclable';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColour.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scanned item',
            style: TextStyle(
              fontSize: 11,
              color: textColour.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            barcode,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColour,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: textColour.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textColour,
                  ),
                ),
              ),
              if (item.hasBinColour()) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: textColour.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.binColour.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: textColour,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (item.hasBinType()) ...[
            const SizedBox(height: 6),
            Text(
              'Bin type: ${item.binType.name}',
              style: TextStyle(
                fontSize: 11,
                color: textColour.withValues(alpha: 0.8),
              ),
            ),
          ],
          if (item.hasAdvice()) ...[
            const SizedBox(height: 10),
            Divider(color: textColour.withValues(alpha: 0.15), height: 1),
            const SizedBox(height: 10),
            Text(
              item.advice,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
          if (repeatCount > 1) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Scanned ${repeatCount}x this session — result updated',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFA1A19A),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
