import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/pages/ingredient_input_page.dart';
import '../widget/custom_bottom_nav.dart';
import 'profile_page.dart';
import 'category_page.dart';
import 'recipe_detail_page.dart';
import '../widget/notification_widget.dart';
import '../widget/search_widget.dart';
import 'category_food_page.dart';
import 'dart:math';


Future<List<Map<String, dynamic>>> fetchAllRecipes() async {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('categories');

  try {
    final DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      final value = snapshot.value;
      // debugPrint('All categories data: $value');

      if (value is Map) {
        List<Map<String, dynamic>> allRecipes = [];
        final categories = Map<String, dynamic>.from(value);

        for (var categoryEntry in categories.entries) {
          final categoryName = categoryEntry.key;
          final categoryData = categoryEntry.value;

          if (categoryData is List) {
            final recipes = categoryData
                .asMap()
                .entries
                .where((entry) => entry.value != null)
                .map((entry) {
              final recipe = Map<String, dynamic>.from(entry.value as Map);
              recipe['categoryName'] = categoryName; // Add categoryName to the recipe
              return recipe;
            })
                .toList();
            allRecipes.addAll(recipes);
          } else if (categoryData is Map) {
            final recipes = Map<String, dynamic>.from(categoryData).values.map((item) {
              final recipe = Map<String, dynamic>.from(item as Map);
              recipe['categoryName'] = categoryName;
              return recipe;
            }).toList();
            allRecipes.addAll(recipes);
          }
        }

        // debugPrint('All recipes: $allRecipes');
        return allRecipes;
      } else {
        debugPrint('Categories data is not a Map');
        return [];
      }
    } else {
      debugPrint('No categories found in the database');
      return [];
    }
  } catch (e) {
    debugPrint('Error fetching all recipes: $e');
    return [];
  }
}
Future<List<Map<String, dynamic>>> fetchFoodItems(String category) async {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('categories/$category');

  try {
    final DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      final value = snapshot.value;
      // debugPrint('Data for $category: $value');

      if (value is List) {
        // Convert the list to a list of maps, filtering out null values
        final items = value
            .asMap()
            .entries
            .where((entry) => entry.value != null) // Filter out null values
            .map((entry) => Map<String, dynamic>.from(entry.value as Map))
            .toList();
        // debugPrint('Processed items for $category: $items');
        return items;
      } else if (value is Map) {
        // Fallback in case the data is a Map (unlikely based on logs)
        final items = Map<String, dynamic>.from(value).values.map((item) {
          return Map<String, dynamic>.from(item as Map);
        }).toList();
        // debugPrint('Processed items for $category: $items');
        return items;
      } else {
        // debugPrint('Data for $category is neither a List nor a Map');
        return [];
      }
    } else {
      debugPrint('No data found for $category');
      return [];
    }
  } catch (e) {
    debugPrint('Error fetching food items for $category: $e');
    return [];
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> featuredRecipes = [];
  List<Map<String, dynamic>> favoriteRecipes = [];
  List<Map<String, dynamic>> popularCategories = [];
  bool isLoading = true;
  String? userName;
  StreamSubscription<DatabaseEvent>? _userNameSubscription;
  StreamSubscription<DatabaseEvent>? _favoritesSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadData();
    _listenToFavorites();
  }

  void _loadUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      _userNameSubscription = userRef.onValue.listen((DatabaseEvent event) {
        final snapshot = event.snapshot;
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            userName = data['name']?.toString() ?? 'Guest';
          });
        } else {
          setState(() {
            userName = 'Guest';
          });
        }
      });
    } else {
      setState(() {
        userName = 'Guest';
      });
    }
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    // Fetch the list of categories dynamically
    final categoriesSnapshot = await FirebaseDatabase.instance.ref('categories').get();
    if (!categoriesSnapshot.exists) {
      // debugPrint('No categories found in the database');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final categoryNames = (categoriesSnapshot.value as Map).keys.cast<String>().toList();
    // debugPrint('Available categories: $categoryNames');

    // Fetch all recipes and select random ones for trending
    final allRecipes = await fetchAllRecipes();
    final random = Random();
    // Select up to 5 random recipes (or fewer if there aren't enough recipes)
    final trendingItems = (allRecipes..shuffle(random)).take(5).toList();
    final featured = trendingItems.map((item) {
      return {
        'recipeId': item['id']?.toString() ?? '',
        'categoryName': item['categoryName']?.toString() ?? 'Trending',
        'title': item['title']?.toString() ?? 'Unknown',
        'image': item['image']?.toString() ?? '',
        'time': item['time']?.toString() ?? 'N/A',
        'likes': item['likes']?.toString() ?? '0',
        'desc': item['desc']?.toString() ?? 'No description',
      };
    }).toList();

    // Define popular categories dynamically
    final categories = categoryNames.map((id) {
      return {
        'id': id,
        'name': id.substring(0, 1).toUpperCase() + id.substring(1),
        'image': 'assets/images/$id.jpg',
        'recipeCount': 0,
      };
    }).toList();

    // Fetch recipe counts for each category
    for (var category in categories) {
      final items = await fetchFoodItems(category['id'] as String);
      category['recipeCount'] = items.length;
    }

    setState(() {
      featuredRecipes = featured;
      popularCategories = categories;
      isLoading = false;
    });
  }

  void _listenToFavorites() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favoritesRef = FirebaseDatabase.instance.ref('users/${user.uid}/favorites');
      _favoritesSubscription = favoritesRef.onValue.listen((DatabaseEvent event) {
        final snapshot = event.snapshot;
        List<Map<String, dynamic>> favorites = [];
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          data.forEach((key, value) {
            favorites.add({
              'recipeId': key.toString(),
              'categoryName': value['categoryName']?.toString() ?? '',
              'title': value['title']?.toString() ?? '',
              'image': value['image']?.toString() ?? '',
              'time': value['time']?.toString() ?? '',
              'likes': value['likes']?.toString() ?? '0',
              'desc': value['desc']?.toString() ?? '',
            });
          });
        }
        final seenIds = <String>{};
        favorites = favorites.where((recipe) {
          final id = recipe['recipeId'] as String?;
          if (id == null || seenIds.contains(id)) {
            return false;
          }
          seenIds.add(id);
          return true;
        }).toList();

        setState(() {
          favoriteRecipes = favorites;
        });
      });
    } else {
      setState(() {
        favoriteRecipes = [];
      });
    }
  }

  @override
  void dispose() {
    _userNameSubscription?.cancel();
    _favoritesSubscription?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => IngredientInputPage()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CategoryPage()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        break;
    }
  }

  void _navigateToRecipe(String categoryName, String recipeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailPage(
          categoryName: categoryName.toLowerCase(),
          recipeId: recipeId,
        ),
      ),
    );
  }

  void _navigateToCategory(String categoryId, String categoryName) async {
    final BuildContext currentContext = context;
    setState(() {
      isLoading = true;
    });
    final rawFoodItems = await fetchFoodItems(categoryId);
    // Normalize the data to ensure all fields are Strings
    final foodItems = rawFoodItems.map((item) {
      return {
        'recipeId': item['id']?.toString() ?? '',
        'categoryName': categoryId,
        'title': item['title']?.toString() ?? 'Unknown',
        'image': item['image']?.toString() ?? '',
        'time': item['time']?.toString() ?? 'N/A',
        'likes': item['likes']?.toString() ?? '0',
        'desc': item['desc']?.toString() ?? 'No description',
        'ingredients': item['ingredients'] ?? [],
        'steps': item['steps'] ?? [],
      };
    }).toList();
    setState(() {
      isLoading = false;
    });
    // debugPrint('Navigating to CategoryFoodPage for $categoryName with ${foodItems.length} items');
    Navigator.push(
      currentContext,
      MaterialPageRoute(
        builder: (_) => CategoryFoodPage(
          categoryTitle: categoryName,
          foodItems: foodItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = FirebaseAuth.instance.currentUser == null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              'RecipeBuddy',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 108, 67),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: const [
          NotificationWidget(),
          SearchWidget(),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color.fromARGB(255, 255, 108, 67)),
      )
          : RefreshIndicator(
        color: const Color.fromARGB(255, 255, 108, 67),
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello${userName != null ? ", $userName" : ""}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'What would you like to cook today?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 108, 67),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Trending Recipes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 300,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredRecipes.length,
                  itemBuilder: (context, index) => _buildFeaturedRecipeCard(featuredRecipes[index]),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 108, 67),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Popular Categories',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: popularCategories.length,
                  itemBuilder: (context, index) => _buildCategoryCard(popularCategories[index]),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 108, 67),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Your Favorite Recipe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isGuest
                ? SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Please log in or sign up to view your favorite recipes',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
                : favoriteRecipes.isEmpty
                ? SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Your favorite recipes will appear here. Explore more!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildFavoriteRecipeCard(favoriteRecipes[index]),
                childCount: favoriteRecipes.length,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildFeaturedRecipeCard(Map<String, dynamic> recipe) {
    final imageUrl = recipe['image'] as String?;
    return GestureDetector(
      onTap: () => _navigateToRecipe(recipe['categoryName']?.toString() ?? 'Unknown', recipe['recipeId']?.toString() ?? ''),
      child: Container(
        width: 220,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  imageUrl != null && imageUrl.isNotEmpty
                      ? imageUrl.startsWith('http')
                      ? Image.network(
                    imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                  )
                      : Image.asset(
                    imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                  )
                      : const SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: Icon(Icons.image, size: 50),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        recipe['categoryName']?.toString() ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['title']?.toString() ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe['desc']?.toString() ?? 'No description',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite, size: 16, color: Colors.pinkAccent),
                          const SizedBox(width: 4),
                          Text(
                            recipe['likes']?.toString() ?? '0',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Color.fromARGB(255, 255, 108, 67)),
                          const SizedBox(width: 4),
                          Text(
                            recipe['time']?.toString() ?? 'N/A',
                            style: const TextStyle(fontSize: 13),
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
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final imageUrl = category['image'] as String?;
    return GestureDetector(
      onTap: () => _navigateToCategory(category['id']?.toString() ?? '', category['name']?.toString() ?? ''),
      child: Container(
        width: 100,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? imageUrl.startsWith('http')
                  ? Image.network(
                imageUrl,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 30),
              )
                  : Image.asset(
                imageUrl,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 30),
              )
                  : const SizedBox(
                height: 60,
                width: 60,
                child: Icon(Icons.category, size: 30, color: Color.fromARGB(255, 255, 108, 67)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category['name']?.toString() ?? 'Unknown',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '${category['recipeCount']?.toString() ?? '0'} recipes',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteRecipeCard(Map<String, dynamic> recipe) {
    final imageUrl = recipe['image'] as String?;
    return GestureDetector(
      onTap: () => _navigateToRecipe(recipe['categoryName']?.toString() ?? 'Unknown', recipe['recipeId']?.toString() ?? ''),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? imageUrl.startsWith('http')
                  ? Image.network(
                imageUrl,
                height: 90,
                width: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 30),
              )
                  : Image.asset(
                imageUrl,
                height: 90,
                width: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 30),
              )
                  : const SizedBox(
                height: 90,
                width: 90,
                child: Icon(Icons.image, size: 30),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 108, 67).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            recipe['categoryName']?.toString() ?? 'Unknown',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 255, 108, 67),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe['title']?.toString() ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recipe['desc']?.toString() ?? 'No description',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.favorite, size: 14, color: Colors.pinkAccent),
                            const SizedBox(width: 4),
                            Text(
                              recipe['likes']?.toString() ?? '0',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Color.fromARGB(255, 255, 108, 67)),
                            const SizedBox(width: 4),
                            Text(
                              recipe['time']?.toString() ?? 'N/A',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}