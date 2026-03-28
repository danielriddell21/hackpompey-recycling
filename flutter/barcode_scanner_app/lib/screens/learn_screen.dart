import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum LearnCategory { plastic, glass, paper, metal, electronics, clothing }

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  static const _categoryMeta = <LearnCategory, (String, Color, IconData, String)>{
    LearnCategory.plastic: (
      'Plastic',
      Colors.green,
      Icons.water_drop_outlined,
      'Include bottles, tubs, and containers. Rinse clean before recycling. Avoid plastic bags and film.',
    ),
    LearnCategory.glass: (
      'Glass',
      Colors.blue,
      Icons.wine_bar_outlined,
      'Include jars and bottles. Remove lids and rinse. Do not include light bulbs or Pyrex.',
    ),
    LearnCategory.paper: (
      'Paper & Card',
      Colors.teal,
      Icons.article_outlined,
      'Recycle newspapers, magazines, cardboard, and office paper. Remove food residue.',
    ),
    LearnCategory.metal: (
      'Metal',
      Colors.grey,
      Icons.hardware_outlined,
      'Recycle cans, tins, and foil. Rinse before recycling. Aerosol cans are accepted if empty.',
    ),
    LearnCategory.electronics: (
      'Electronics',
      Colors.purple,
      Icons.devices_outlined,
      'Recycle small electrical items and gadgets at household recycling centres. Do not place in general bins.',
    ),
    LearnCategory.clothing: (
      'Clothing & Textiles',
      Colors.pink,
      Icons.checkroom_outlined,
      'Recycle clothes, shoes, and textiles via charity banks or local recycling points. Avoid wet or dirty items.',
    ),
  };

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filter categories based on search query
    final filteredCategories = LearnCategory.values.where((cat) {
      final label = _categoryMeta[cat]!.$1.toLowerCase();
      return label.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: filteredCategories.map((cat) {
                  final (label, color, icon, advice) = _categoryMeta[cat]!;
                  return _categoryCard(label, color, icon, advice);
                }).toList(),
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
            'Learn To Recycle',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: Color(0xFFA1A19A),
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search at item to learn...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _categoryCard(
    String title,
    Color color,
    IconData icon,
    String advice,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  advice,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555550),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
