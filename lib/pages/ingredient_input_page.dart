import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widget/custom_bottom_nav.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'category_page.dart';
import '../widget/notification_widget.dart';
import '../widget/search_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'dart:async';

class IngredientInputPage extends StatefulWidget {
  const IngredientInputPage({Key? key}) : super(key: key);

  @override
  _IngredientInputPageState createState() => _IngredientInputPageState();
}

class _IngredientInputPageState extends State<IngredientInputPage> with SingleTickerProviderStateMixin {
  final TextEditingController _ingredientController = TextEditingController();
  String? _ingredient;
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = false;
  int _selectedIndex = 1;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ingredientController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CategoryPage()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        break;
    }
  }

  Future<void> _getRecipeRecommendations(String ingredient) async {
    print('Fetching recipes for: $ingredient');
    setState(() {
      _isLoading = true;
    });
    _animationController.reset();
    _animationController.forward();

    final prompt = '''
  Generate 5 recipes using $ingredient as a key ingredient.
  Format each recipe as:
  RECIPE:
  TITLE: [Recipe Name]
  CATEGORY: [Category]
  TIME: [Time]
  DESCRIPTION: [Description]
  INGREDIENTS:
  1. [Ingredient]
  INSTRUCTIONS:
  1. [Step]
  ---
  ''';

    final apiKey = 'AIzaSyCMs2VwqnaiGORJwhDGf5U8p2HcgnlecqI'; // Replace with your key
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}],
          'generationConfig': {
            'maxOutputTokens': 1000,
            'temperature': 0.7,
          }
        }),
      ).timeout(const Duration(seconds: 10));

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] == null || data['candidates'].isEmpty) {
          print('No candidates found');
          setState(() {
            _recipes = [{'title': 'Error', 'category': 'N/A', 'time': '0', 'description': 'No recipes found', 'ingredients': [], 'instructions': []}];
            _isLoading = false;
          });
          return;
        }

        List<Map<String, dynamic>> fetchedRecipes = [];
        String recipeText = data['candidates'][0]['content']['parts'][0]['text'];
        print('Recipe Text: $recipeText');
        List<String> recipes = recipeText.split('---');

        for (var recipeString in recipes) {
          if (recipeString.trim().isEmpty) continue;

          Map<String, dynamic> recipeMap = {
            'difficulty': _getRandomDifficulty(),
            'tags': _generateRandomTags(),
            'rating': (3 + (2 * Random().nextDouble())).toStringAsFixed(1),
          };

          RegExp titleRegex = RegExp(r'TITLE:\s*(.+)', caseSensitive: false);
          RegExp categoryRegex = RegExp(r'CATEGORY:\s*(.+)', caseSensitive: false);
          RegExp timeRegex = RegExp(r'TIME:\s*(.+)', caseSensitive: false);
          RegExp descRegex = RegExp(r'DESCRIPTION:\s*(.+?)(?=INGREDIENTS:|$)', caseSensitive: false, dotAll: true);
          RegExp ingredientsRegex = RegExp(r'INGREDIENTS:\s*(.+?)(?=INSTRUCTIONS:|$)', caseSensitive: false, dotAll: true);
          RegExp instructionsRegex = RegExp(r'INSTRUCTIONS:\s*(.+)', caseSensitive: false, dotAll: true);

          recipeMap['title'] = titleRegex.firstMatch(recipeString)?.group(1)?.trim() ?? 'Untitled';
          recipeMap['category'] = categoryRegex.firstMatch(recipeString)?.group(1)?.trim() ?? 'Other';
          recipeMap['time'] = timeRegex.firstMatch(recipeString)?.group(1)?.trim() ?? 'N/A';
          recipeMap['description'] = descRegex.firstMatch(recipeString)?.group(1)?.trim() ?? 'No description';
          recipeMap['ingredients'] = ingredientsRegex.firstMatch(recipeString)?.group(1)?.trim().split('\n').where((line) => line.trim().isNotEmpty).map((line) => line.trim().replaceAll(RegExp(r'^\d+\.\s*'), '')).toList() ?? [];
          recipeMap['instructions'] = instructionsRegex.firstMatch(recipeString)?.group(1)?.trim().split('\n').where((line) => line.trim().isNotEmpty).map((line) => line.trim().replaceAll(RegExp(r'^\d+\.\s*'), '')).toList() ?? [];

          fetchedRecipes.add(recipeMap);
        }

        print('Parsed Recipes: $fetchedRecipes');
        setState(() {
          _recipes = fetchedRecipes;
          _isLoading = false;
        });
      } else {
        print('API Error: ${response.statusCode}');
        setState(() {
          _recipes = [{'title': 'Error', 'category': 'N/A', 'time': '0', 'description': 'API error: ${response.statusCode}', 'ingredients': [], 'instructions': []}];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching recipes: $e');
      setState(() {
        _recipes = [{'title': 'Error', 'category': 'N/A', 'time': '0', 'description': 'Error: $e', 'ingredients': [], 'instructions': []}];
        _isLoading = false;
      });
    }
  }

  String _getRandomDifficulty() {
    final difficulties = ['Easy', 'Medium', 'Hard'];
    return difficulties[Random().nextInt(difficulties.length)];
  }

  List<String> _generateRandomTags() {
    final allTags = ['Gluten-Free', 'Vegetarian', 'Vegan', 'Low-Carb', 'High-Protein', 'Dairy-Free', 'Quick', 'Family-Friendly'];
    final numTags = 1 + Random().nextInt(3);
    final shuffled = List<String>.from(allTags)..shuffle();
    return shuffled.take(numTags).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            pinned: true,
            title: const Text(
              'Recipe Finder',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 108, 67),
                fontWeight: FontWeight.bold,
                fontSize: 21,
              ),
            ),
            leading: const SizedBox(),
            actions: [
              const NotificationWidget(),
              const SearchWidget(),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _ingredientController,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'What ingredient do you have?',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Icon(Icons.food_bank_outlined, color: Color.fromARGB(255, 255, 108, 67)),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_ingredientController.text.isNotEmpty) {
                                _ingredient = _ingredientController.text.trim();
                                _getRecipeRecommendations(_ingredient!);
                                FocusScope.of(context).unfocus();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(60, 40),
                            ),
                            child: const Text('Find'),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _recipes.isEmpty && !_isLoading
              ? SliverFillRemaining(child: _buildHeroSection())
              : SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return FadeTransition(
                    opacity: _animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(_animation),
                      child: _buildRecipeCard(_recipes[index]),
                    ),
                  );
                },
                childCount: _recipes.length,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      bottomSheet: _isLoading
          ? Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.deepOrange),
              const SizedBox(height: 20),
              Text(
                'Finding delicious recipes\nwith $_ingredient...',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          const Text(
            'What would you like to cook today?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Enter an ingredient you have, and we\'ll suggest delicious recipes you can make.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSuggestionChip('Chicken'),
              _buildSuggestionChip('Garlic'),
              _buildSuggestionChip('Tomato'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSuggestionChip('Potato'),
              _buildSuggestionChip('Chocolate'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String ingredient) {
    return GestureDetector(
      onTap: () {
        _ingredientController.text = ingredient;
        _ingredient = ingredient;
        _getRecipeRecommendations(ingredient);
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.deepOrange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.deepOrange.withOpacity(0.3)),
        ),
        child: Text(
          ingredient,
          style: TextStyle(
            color: Colors.deepOrange.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    const Color cardColor = Colors.deepOrangeAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 5),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              color: cardColor,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: 0.2,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              recipe['category'] ?? 'Other',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe['title'] ?? 'Recipe',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                recipe['time'] ?? 'N/A',
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.star, color: Colors.yellow, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                recipe['rating'] ?? '4.5',
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  recipe['difficulty'] ?? 'Easy',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recipe['tags'] != null && (recipe['tags'] as List).isNotEmpty)
                  SizedBox(
                    height: 30,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: (recipe['tags'] as List).length,
                      itemBuilder: (context, i) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            recipe['tags'][i],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 15),
                Text(
                  recipe['description'] ?? 'No description available.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                if (recipe['ingredients'] != null)
                  ...List.generate(
                    min((recipe['ingredients'] as List).length, 5),
                        (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            height: 8,
                            width: 8,
                            decoration: const BoxDecoration(
                              color: cardColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              recipe['ingredients'][i],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if ((recipe['ingredients'] as List).length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      '+ ${(recipe['ingredients'] as List).length - 5} more ingredients',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: cardColor,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showRecipeDetails(context, recipe);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cardColor,
                          side: const BorderSide(color: cardColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book, size: 16),
                            SizedBox(width: 5),
                            Text('Full Recipe'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRecipeDetails(BuildContext context, Map<String, dynamic> recipe) {
    const Color cardColor = Colors.deepOrangeAccent;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      height: 5,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Expanded(
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Stack(
                              children: [
                                Container(
                                  height: 200,
                                  decoration: const BoxDecoration(
                                    color: cardColor,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(30)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  right: 20,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                              20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.deepOrangeAccent.withOpacity(
                                                  0.1),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          recipe['category'] ?? 'Other',
                                          style: const TextStyle(
                                            color: cardColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        recipe['title'] ?? 'Recipe',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 2),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          _buildInfoChip(Icons.access_time,
                                              recipe['time'] ?? 'N/A'),
                                          const SizedBox(width: 10),
                                          _buildInfoChip(Icons.restaurant,
                                              recipe['difficulty'] ?? 'Easy'),
                                          const SizedBox(width: 10),
                                          _buildInfoChip(Icons.star,
                                              '${recipe['rating'] ??
                                                  '4.5'} Rating'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Material(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(30),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      borderRadius: BorderRadius.circular(30),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        child: const Icon(
                                            Icons.close, size: 24),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.all(20),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                Text(
                                  recipe['description'] ??
                                      'No description available.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                _buildSectionHeader(
                                    'Ingredients', Icons.shopping_basket,
                                    cardColor),
                                const SizedBox(height: 15),
                                if (recipe['ingredients'] != null)
                                  ...List.generate(
                                    (recipe['ingredients'] as List).length,
                                        (i) =>
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 12),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 6),
                                                height: 10,
                                                width: 10,
                                                decoration: const BoxDecoration(
                                                  color: cardColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 15),
                                              Expanded(
                                                child: Text(
                                                  recipe['ingredients'][i],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey.shade900,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  )
                                else
                                  Text(
                                    'No ingredients listed.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                const SizedBox(height: 30),
                                _buildSectionHeader(
                                    'Instructions', Icons.restaurant_menu,
                                    cardColor),
                                const SizedBox(height: 15),
                                if (recipe['instructions'] != null)
                                  ...List.generate(
                                    (recipe['instructions'] as List).length,
                                        (i) =>
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 20),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  color: cardColor.withOpacity(
                                                      0.2),
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '${i + 1}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: cardColor,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 15),
                                              Expanded(
                                                child: Text(
                                                  recipe['instructions'][i],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey.shade900,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  )
                                else
                                  Text(
                                    'No instructions available.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                const SizedBox(height: 30),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
        }

        Widget _buildInfoChip(IconData icon, String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 5),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      );
    }

    Widget _buildSectionHeader(String title, IconData icon, Color color) {
      return Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      );
    }
  }