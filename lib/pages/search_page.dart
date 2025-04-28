import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'recipe_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> allRecipes = [];
  List<Map<String, dynamic>> filteredRecipes = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), _filterRecipes);
    });
  }

  void _loadRecipes() {
    final recipesRef = FirebaseDatabase.instance.ref('categories');
    recipesRef.once().then((DatabaseEvent event) {
      final snapshot = event.snapshot;
      List<Map<String, dynamic>> loadedRecipes = [];
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((categoryKey, categoryValue) {
          debugPrint('Processing category: $categoryKey');
          if (categoryValue is Map<dynamic, dynamic>) {
            debugPrint('Category $categoryKey is a map');
            categoryValue.forEach((recipeKey, recipeValue) {
              if (recipeValue is Map<dynamic, dynamic>) {
                debugPrint('Adding recipe $recipeKey from category $categoryKey');
                loadedRecipes.add({
                  'categoryName': categoryKey.toString(),
                  'recipeId': recipeKey.toString(),
                  'title': recipeValue['title']?.toString() ?? 'Untitled Recipe',
                  'image': recipeValue['image']?.toString() ?? '',
                  'desc': recipeValue['desc']?.toString() ?? '',
                  'time': recipeValue['time']?.toString() ?? '',
                  'likes': recipeValue['likes']?.toString() ?? '0',
                });
              } else {
                debugPrint('Recipe $recipeKey in category $categoryKey is not a map: $recipeValue');
              }
            });
          } else if (categoryValue is List<dynamic>) {
            debugPrint('Category $categoryKey is a list');
            for (int i = 0; i < categoryValue.length; i++) {
              final recipeValue = categoryValue[i];
              if (recipeValue is Map<dynamic, dynamic>) {
                debugPrint('Adding recipe at index $i from category $categoryKey');
                loadedRecipes.add({
                  'categoryName': categoryKey.toString(),
                  'recipeId': '$i',
                  'title': recipeValue['title']?.toString() ?? 'Untitled Recipe',
                  'image': recipeValue['image']?.toString() ?? '',
                  'desc': recipeValue['desc']?.toString() ?? '',
                  'time': recipeValue['time']?.toString() ?? '',
                  'likes': recipeValue['likes']?.toString() ?? '0',
                });
              } else {
                debugPrint('Item at index $i in category $categoryKey is not a map: $recipeValue');
              }
            }
          } else {
            debugPrint('Category $categoryKey is neither a map nor a list: $categoryValue');
          }
        });
        debugPrint('Total loaded recipes: ${loadedRecipes.length}');
      } else {
        debugPrint('Snapshot does not exist. No recipes found in Firebase.');
      }
      setState(() {
        allRecipes = loadedRecipes;
        filteredRecipes = loadedRecipes;
        isLoading = false;
      });
    }).catchError((error) {
      debugPrint('Error fetching recipes: $error');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading recipes: $error')),
      );
    });
  }

  void _filterRecipes() {
    final query = searchController.text.toLowerCase();
    debugPrint('Filtering with query: "$query"');
    setState(() {
      filteredRecipes = allRecipes.where((recipe) {
        final title = recipe['title']?.toLowerCase() ?? '';
        final desc = recipe['desc']?.toLowerCase() ?? '';
        final category = recipe['categoryName']?.toLowerCase() ?? '';
        debugPrint('Checking recipe: title="$title", desc="$desc", category="$category"');
        final matches = title.contains(query) || desc.contains(query) || category.contains(query);
        if (matches) {
          debugPrint('Recipe matches query: ${recipe['title']}');
        }
        return matches;
      }).toList();
      debugPrint('Filtered recipes count: ${filteredRecipes.length}');
      if (filteredRecipes.isEmpty && allRecipes.isNotEmpty) {
        debugPrint('No matches found. All recipes: ${allRecipes.map((r) => r['title']).toList()}');
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 108, 67)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            final query = textEditingValue.text.toLowerCase();
            return allRecipes
                .map((recipe) => recipe['title'] as String)
                .where((title) => title.isNotEmpty && title.toLowerCase().contains(query))
                .toSet();
          },
          onSelected: (String selection) {
            searchController.text = selection;
            _filterRecipes();
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            searchController = controller;
            return TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                border: InputBorder.none,
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    controller.clear();
                    _filterRecipes();
                  },
                )
                    : null,
              ),
              onSubmitted: (value) => _filterRecipes(),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 200,
                    maxWidth: MediaQuery.of(context).size.width - 32,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 255, 108, 67)))
            : allRecipes.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Color.fromARGB(255, 255, 108, 67),
              ),
              SizedBox(height: 16),
              Text(
                'No recipes available in the database',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
            : filteredRecipes.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 60,
                color: Color.fromARGB(255, 255, 108, 67),
              ),
              SizedBox(height: 16),
              Text(
                'No recipes found for your search',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredRecipes.length,
          itemBuilder: (context, index) {
            final recipe = filteredRecipes[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: recipe['image'].isNotEmpty
                      ? recipe['image'].startsWith('assets/')
                      ? Image.asset(
                    recipe['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                  )
                      : Image.network(
                    recipe['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                  )
                      : const Icon(Icons.image, size: 50),
                ),
                title: Text(
                  recipe['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  recipe['desc'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailPage(
                        categoryName: recipe['categoryName'].toLowerCase(),
                        recipeId: recipe['recipeId'],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}