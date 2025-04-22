import 'package:flutter/material.dart';
import '../services/spoonacular_service.dart';
import '../models/recipe.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpoonacularService _spoonacularService = SpoonacularService();
  List<Recipe> _popularRecipes = [];
  List<Recipe> _yourRecipes = [];
  List<Recipe> _recentlyAdded = [];
  bool _isLoading = true;
  String _error = '';
  int _selectedIndex = 0; // To track the currently selected item

  @override
  void initState() {
    super.initState();
    _loadHomePageData();
  }

  Future<void> _loadHomePageData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final popular = await _spoonacularService.getPopularRecipes(number: 5);
      setState(() {
        _popularRecipes = popular;
        _yourRecipes = popular;
        _recentlyAdded = popular;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load recipes: $e';
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
        // Home action
          print('Home Tapped');
          break;
        case 1:
        // Filter/Explore action (based on the image)
          print('Filter Tapped');
          break;
        case 2:
        // Layers/Collections action (based on the image)
          print('Collections Tapped');
          break;
        case 3:
        // Profile action
          print('Profile Tapped');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Make body extend under the floating navigation bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: IconButton(
            icon: const Icon(Icons.menu, color: Colors.grey),
            onPressed: () {
              print('Menu Tapped');
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
              onPressed: () {
                print('Notifications Tapped');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.grey),
              onPressed: () {
                print('Search Tapped');
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 80), // Adjust bottom padding for the floating bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hi! Dianne',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'What are you cooking today',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: [
                  'Breakfast',
                  'Lunch',
                  'Dinner',
                  'Vegan',
                  'Dessert',
                  'Snacks'
                ].length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = [
                    'Breakfast',
                    'Lunch',
                    'Dinner',
                    'Vegan',
                    'Dessert',
                    'Snacks'
                  ][index];
                  return ElevatedButton(
                    onPressed: () {
                      print('$category Tapped');
                      // Handle category selection (API filtering)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5F5),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(category),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Trending Recipe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _popularRecipes.isNotEmpty
                ? _buildTrendingRecipeCard(_popularRecipes.first)
                : const Text('No trending recipes available.'),
            const SizedBox(height: 30),
            const Text(
              'Your Recipes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: _yourRecipes.isNotEmpty
                  ? ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _yourRecipes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 15),
                itemBuilder: (context, index) {
                  return _buildSmallRecipeCard(_yourRecipes[index]);
                },
              )
                  : const Text('No recipes in your collection.'),
            ),
            const SizedBox(height: 30),
            const Text(
              'Recently Added',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: _recentlyAdded.isNotEmpty
                  ? ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _recentlyAdded.length,
                separatorBuilder: (context, index) => const SizedBox(width: 15),
                itemBuilder: (context, index) {
                  return _buildSmallRecipeCard(_recentlyAdded[index]);
                },
              )
                  : const Text('No recently added recipes.'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.orange, // Match the color from your image
            borderRadius: BorderRadius.circular(30.0), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0), // Adjust padding for icon spacing
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.home_outlined, color: Colors.white), // Replace with your home icon
                  onPressed: () => _onItemTapped(0),
                  color: _selectedIndex == 0 ? Colors.white : Colors.white70,
                ),
                IconButton(
                  icon: const Icon(Icons.document_scanner_outlined, color: Colors.white), // Replace with your filter icon
                  onPressed: () => _onItemTapped(1),
                  color: _selectedIndex == 1 ? Colors.white : Colors.white70,
                ),
                IconButton(
                  icon: const Icon(Icons.layers_outlined, color: Colors.white), // Replace with your collections icon
                  onPressed: () => _onItemTapped(2),
                  color: _selectedIndex == 2 ? Colors.white : Colors.white70,
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.white), // Replace with your profile icon
                  onPressed: () => _onItemTapped(3),
                  color: _selectedIndex == 3 ? Colors.white : Colors.white70,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingRecipeCard(Recipe recipe) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[200],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              recipe.imageUrl ?? 'https://via.placeholder.com/300/E8EAF6/000000?Text=No+Image',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 120,
                width: double.infinity,
                child: Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  recipe.description ?? 'No description available.',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: Colors.orange),
                        const SizedBox(width: 3),
                        Text('${recipe.cookingTime ?? "?"} min', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rate_outlined, size: 14, color: Colors.orange),
                        const SizedBox(width: 3),
                        Text('${recipe.rating?.toStringAsFixed(1) ?? "?"}', style: const TextStyle(fontSize: 12)),
                      ],
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

  Widget _buildSmallRecipeCard(Recipe recipe) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[200],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              recipe.imageUrl ?? 'https://via.placeholder.com/120/E8EAF6/000000?Text=No+Image',
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 80,
                width: double.infinity,
                child: Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star_rate_outlined, size: 10, color: Colors.orange),
                    const SizedBox(width: 2),
                    Text('${recipe.rating?.toStringAsFixed(1) ?? "?"}', style: const TextStyle(fontSize: 10)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 10, color: Colors.orange),
                    const SizedBox(width: 2),
                    Text('${recipe.cookingTime ?? "?"} min', style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}