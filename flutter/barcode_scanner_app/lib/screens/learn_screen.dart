import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum LearnCategory {
  plastic,
  glass,
  clothing,
  electronics,
  metal,
  paper,
  foodWaste,
}

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
    LearnCategory.foodWaste: (
      'Food Waste',
      Colors.orange,
      Icons.restaurant_outlined,
      'Compost fruit, vegetable scraps, coffee grounds, and eggshells. Avoid meat and dairy in home compost if not suitable.',
    ),
  };

  // Map keywords to relevant categories
  static const Map<String, List<LearnCategory>> _keywordMap = {
    // Plastic
    'bottle': [LearnCategory.plastic, LearnCategory.glass],
    'container': [LearnCategory.plastic],
    'tub': [LearnCategory.plastic],
    'yogurt cup': [LearnCategory.plastic],
    'milk jug': [LearnCategory.plastic],
    'shampoo bottle': [LearnCategory.plastic],
    'detergent bottle': [LearnCategory.plastic],
    'food wrapper': [LearnCategory.plastic],
    'sandwich bag': [LearnCategory.plastic],
    'plastic bag': [LearnCategory.plastic],
    'juice bottle': [LearnCategory.plastic],
    'water bottle': [LearnCategory.plastic],
    'takeout container': [LearnCategory.plastic],
    'snack bag': [LearnCategory.plastic],
    'candy wrapper': [LearnCategory.plastic],
    'plastic lid': [LearnCategory.plastic],
    'margarine tub': [LearnCategory.plastic],
    'butter tub': [LearnCategory.plastic],
    'medicine bottle': [LearnCategory.plastic],
    'ketchup bottle': [LearnCategory.plastic],
    'shampoo cap': [LearnCategory.plastic],
    'lotion bottle': [LearnCategory.plastic],
    'soap container': [LearnCategory.plastic],
    'ice cream tub': [LearnCategory.plastic],
    'peanut butter jar': [LearnCategory.plastic],
    'protein powder container': [LearnCategory.plastic],
    'salad container': [LearnCategory.plastic],
    'condiment bottle': [LearnCategory.plastic],
    'soda bottle': [LearnCategory.plastic],
    'iced tea bottle': [LearnCategory.plastic],
    'sports drink bottle': [LearnCategory.plastic],
    'detergent tub': [LearnCategory.plastic],
    'cleaning spray': [LearnCategory.plastic],
    'dishwasher pod container': [LearnCategory.plastic],
    'snack cup': [LearnCategory.plastic],
    'frozen food tray': [LearnCategory.plastic],
    'frozen meal tray': [LearnCategory.plastic],
    'dessert cup': [LearnCategory.plastic],
    'cookie wrapper': [LearnCategory.plastic],
    'bread bag': [LearnCategory.plastic],
    'bag of chips': [LearnCategory.plastic],
    'plastic straw': [LearnCategory.plastic],
    'yogurt lid': [LearnCategory.plastic],
    'protein shake bottle': [LearnCategory.plastic],
    'milk carton (plastic lined)': [LearnCategory.plastic],
    'ketchup packet': [LearnCategory.plastic],
    'mayonnaise bottle': [LearnCategory.plastic],
    'sauce bottle': [LearnCategory.plastic],
    'syrup bottle': [LearnCategory.plastic],
    'energy drink bottle': [LearnCategory.plastic],
    'baby bottle': [LearnCategory.plastic],
    'protein bar wrapper': [LearnCategory.plastic],
    'plastic utensil': [LearnCategory.plastic],
    'coffee cup lid': [LearnCategory.plastic],
    'candy bar wrapper': [LearnCategory.plastic],
    'snack container': [LearnCategory.plastic],
    'fruit cup': [LearnCategory.plastic],
    'vegetable bag': [LearnCategory.plastic],
    'prepackaged salad bag': [LearnCategory.plastic],
    'plastic wrap': [LearnCategory.plastic],
    'cling film': [LearnCategory.plastic],
    'frozen vegetable bag': [LearnCategory.plastic],
    'frozen fruit bag': [LearnCategory.plastic],
    'bakery tray': [LearnCategory.plastic],
    'deli container': [LearnCategory.plastic],
    'sushi tray': [LearnCategory.plastic],
    'meal prep container': [LearnCategory.plastic],
    'plastic jar': [LearnCategory.plastic],
    'cleaning wipe container': [LearnCategory.plastic],
    'soap bottle': [LearnCategory.plastic],
    'lotion cap': [LearnCategory.plastic],
    'hand sanitizer bottle': [LearnCategory.plastic],
    'mouthwash bottle': [LearnCategory.plastic],
    'detergent cap': [LearnCategory.plastic],
    'pasta container': [LearnCategory.plastic],
    'rice bag (plastic)': [LearnCategory.plastic],
    'cereal bag': [LearnCategory.plastic],
    'snack pouch': [LearnCategory.plastic],
    'snack tub': [LearnCategory.plastic],
    'pudding cup': [LearnCategory.plastic],
    'juice pouch': [LearnCategory.plastic],
    'cosmetic container': [LearnCategory.plastic],
    'makeup bottle': [LearnCategory.plastic],
    'nail polish bottle': [LearnCategory.plastic],
    'water jug': [LearnCategory.plastic],
    'ice cube tray': [LearnCategory.plastic],
    'frozen dessert tub': [LearnCategory.plastic],
    'frozen pizza bag': [LearnCategory.plastic],
    'frozen snack bag': [LearnCategory.plastic],
    'plastic cup': [LearnCategory.plastic],
    'party cup': [LearnCategory.plastic],
    'condiment tub': [LearnCategory.plastic],
    'chip bag': [LearnCategory.plastic],
    'cookie container': [LearnCategory.plastic],
    'reusable water bottle': [LearnCategory.plastic],
    'shaker bottle': [LearnCategory.plastic],
    'condiment squeeze bottle': [LearnCategory.plastic],
    'yogurt squeeze pack': [LearnCategory.plastic],
    'condiment pack': [LearnCategory.plastic],
    'takeout cup': [LearnCategory.plastic],
    'ice cream cone wrapper': [LearnCategory.plastic],
    'protein drink container': [LearnCategory.plastic],

    // Glass
    'wine bottle': [LearnCategory.glass],
    'beer bottle': [LearnCategory.glass],
    'juice bottle (glass)': [LearnCategory.glass],
    'soda bottle (glass)': [LearnCategory.glass],
    'sauce jar': [LearnCategory.glass],
    'pickle jar': [LearnCategory.glass],
    'jam jar': [LearnCategory.glass],
    'honey jar': [LearnCategory.glass],
    'condiment jar': [LearnCategory.glass],
    'pasta sauce jar': [LearnCategory.glass],
    'baby food jar': [LearnCategory.glass],
    'vinegar bottle': [LearnCategory.glass],
    'oil bottle': [LearnCategory.glass],
    'milk bottle (glass)': [LearnCategory.glass],
    'ketchup bottle (glass)': [LearnCategory.glass],
    'mayonnaise jar (glass)': [LearnCategory.glass],
    'olive jar': [LearnCategory.glass],
    'peanut butter jar (glass)': [LearnCategory.glass],
    'liquor bottle': [LearnCategory.glass],
    'spirit bottle': [LearnCategory.glass],
    'perfume bottle': [LearnCategory.glass],
    'candle jar': [LearnCategory.glass],
    'tealight jar': [LearnCategory.glass],
    'decorative jar': [LearnCategory.glass],
    'beverage bottle': [LearnCategory.glass],
    'craft beer bottle': [LearnCategory.glass],
    'soda jar': [LearnCategory.glass],
    'cocktail mixer bottle': [LearnCategory.glass],
    'syrup bottle (glass)': [LearnCategory.glass],
    'tonic water bottle': [LearnCategory.glass],
    'water bottle (glass)': [LearnCategory.glass],
    'sparkling water bottle': [LearnCategory.glass],
    'milkshake bottle': [LearnCategory.glass],
    'dessert jar': [LearnCategory.glass],
    'pudding jar': [LearnCategory.glass],
    'jelly jar': [LearnCategory.glass],
    'coffee jar': [LearnCategory.glass],
    'tea jar': [LearnCategory.glass],
    'herbal jar': [LearnCategory.glass],
    'flower vase': [LearnCategory.glass],
    'spice jar': [LearnCategory.glass],
    'salt jar': [LearnCategory.glass],
    'sugar jar': [LearnCategory.glass],
    'mustard jar': [LearnCategory.glass],
    'chutney jar': [LearnCategory.glass],
    'pickled vegetables jar': [LearnCategory.glass],
    'tomato paste jar': [LearnCategory.glass],
    'tomato sauce jar': [LearnCategory.glass],
    'fruit jar': [LearnCategory.glass],
    'vegetable jar': [LearnCategory.glass],
    'cocktail bottle': [LearnCategory.glass],
    'martini bottle': [LearnCategory.glass],
    'wine carafe': [LearnCategory.glass],
    'beer growler': [LearnCategory.glass],
    'glass bottle cap': [LearnCategory.glass],
    'whiskey bottle': [LearnCategory.glass],
    'brandy bottle': [LearnCategory.glass],
    'cognac bottle': [LearnCategory.glass],
    'liqueur bottle': [LearnCategory.glass],
    'aperitif bottle': [LearnCategory.glass],
    'cordial bottle': [LearnCategory.glass],
    'decorative glass': [LearnCategory.glass],
    'perfume jar': [LearnCategory.glass],
    'cosmetic jar (glass)': [LearnCategory.glass],
    'lotion bottle (glass)': [LearnCategory.glass],
    'essential oil bottle': [LearnCategory.glass],
    'fragrance bottle': [LearnCategory.glass],
    'candle holder': [LearnCategory.glass],
    'tealight holder': [LearnCategory.glass],
    'jam pot': [LearnCategory.glass],
    'jelly pot': [LearnCategory.glass],
    'syrup jar': [LearnCategory.glass],
    'honey pot': [LearnCategory.glass],
    'dessert pot': [LearnCategory.glass],
    'pudding pot': [LearnCategory.glass],
    'smoothie bottle': [LearnCategory.glass],
    'water carafe': [LearnCategory.glass],
    'milk jug (glass)': [LearnCategory.glass],
    'sauce pot': [LearnCategory.glass],
    'dessert cup (glass)': [LearnCategory.glass],

    // Paper & Card
    'newspaper': [LearnCategory.paper],
    'magazine': [LearnCategory.paper],
    'cardboard box': [LearnCategory.paper],
    'cereal box': [LearnCategory.paper],
    'shoe box': [LearnCategory.paper],
    'tissue box': [LearnCategory.paper],
    'paper bag': [LearnCategory.paper],
    'wrapping paper': [LearnCategory.paper],
    'envelope': [LearnCategory.paper],
    'letter': [LearnCategory.paper],
    'notebook': [LearnCategory.paper],
    'copy paper': [LearnCategory.paper],
    'printer paper': [LearnCategory.paper],
    'flyer': [LearnCategory.paper],
    'brochure': [LearnCategory.paper],
    'pamphlet': [LearnCategory.paper],
    'book': [LearnCategory.paper],
    'journal': [LearnCategory.paper],
    'diary': [LearnCategory.paper],
    'office paper': [LearnCategory.paper],
    // … continue adding 100 items here
  };

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // If search query is empty, show all categories
    List<LearnCategory> filteredCategories;
    if (_searchQuery.isEmpty) {
      filteredCategories = LearnCategory.values;
    } else {
      // Collect categories matching any keyword in the query
      final query = _searchQuery.toLowerCase();
      filteredCategories = _keywordMap.entries
          .where((entry) => query.contains(entry.key))
          .expand((entry) => entry.value)
          .toSet() // remove duplicates
          .toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            Expanded(
              child: filteredCategories.isEmpty
                  ? const Center(
                      child: Text(
                        'No results found.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: filteredCategories.map((cat) {
                        final (label, color, icon, advice) =
                            _categoryMeta[cat]!;
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
          hintText: 'Search item to recycle...',
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
