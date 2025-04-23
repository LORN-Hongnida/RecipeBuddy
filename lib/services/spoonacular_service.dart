import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart'; // Assuming your Recipe model is in this path

class SpoonacularService {
  final String _apiKey = 'f1e35b57ee5041a3b97676267f77eaaf'; // Replace with your actual API key
  final String _baseUrl = 'https://api.spoonacular.com/recipes';

  // Example: Get popular recipes
  Future<List<Recipe>> getPopularRecipes({int number = 10}) async {
    final Uri uri = Uri.parse('$_baseUrl/complexSearch?apiKey=$_apiKey&sort=popularity&number=$number');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('results')) {
          final List<dynamic> results = data['results'];
          return results.map((json) => _recipeFromSpoonacularJson(json)).toList();
        } else {
          throw Exception('Failed to parse popular recipes: Missing "results"');
        }
      } else {
        throw Exception('Failed to load popular recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching popular recipes: $e');
      return [];
    }
  }

  // Example: Search recipes by query
  Future<List<Recipe>> searchRecipes(String query, {int number = 10}) async {
    final Uri uri = Uri.parse('$_baseUrl/complexSearch?apiKey=$_apiKey&query=$query&number=$number');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('results')) {
          final List<dynamic> results = data['results'];
          return results.map((json) => _recipeFromSpoonacularJson(json)).toList();
        } else {
          throw Exception('Failed to parse search results: Missing "results"');
        }
      } else {
        throw Exception('Failed to search recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching recipes: $e');
      return [];
    }
  }

  // Example: Get recipe information (details)
  Future<Recipe?> getRecipeDetails(String id) async {
    final Uri uri = Uri.parse('$_baseUrl/$id/information?apiKey=$_apiKey');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return _recipeFromSpoonacularDetailsJson(data);
      } else if (response.statusCode == 404) {
        return null; // Recipe not found
      } else {
        throw Exception('Failed to load recipe details for $id: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipe details for $id: $e');
      return null;
    }
  }

  // Helper function to convert Spoonacular JSON to your Recipe model (adjust as needed)
  Recipe _recipeFromSpoonacularJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'].toString(),
      name: json['title'] ?? 'No Title',
      imageUrl: json['image'] ?? '',
      description: json['summary'] ?? 'No Summary', // You might need to fetch details for full description
      cookingTime: json['readyInMinutes'] ?? 0,
      rating: json['spoonacularScore'] != null ? (json['spoonacularScore'] as num) / 10 : 0.0, // Adjust as needed
      tags: (json['dishTypes'] as List<dynamic>?)?.cast<String>() ?? [], // Example tag mapping
      ingredients: [], // You'll likely fetch these from the details endpoint
      allergens: [],   // You might need to infer these from ingredients or use another API endpoint
    );
  }

  // Helper function to convert Spoonacular details JSON to your Recipe model (adjust as needed)
  Recipe _recipeFromSpoonacularDetailsJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'].toString(),
      name: json['title'] ?? 'No Title',
      imageUrl: json['image'] ?? '',
      description: json['summary'] ?? 'No Summary',
      cookingTime: json['readyInMinutes'] ?? 0,
      rating: json['spoonacularScore'] != null ? (json['spoonacularScore'] as num) / 10 : 0.0,
      tags: (json['dishTypes'] as List<dynamic>?)?.cast<String>() ?? [],
      ingredients: (json['extendedIngredients'] as List<dynamic>?)?.map((ing) => ing['name'] as String).toList() ?? [],
      allergens: (json['diets'] as List<dynamic>?)?.cast<String>() ?? [], // This might not be a direct mapping
      // ... map other details as needed
    );
  }

// Add more API methods as needed (e.g., filter by ingredients, diets, etc.)
}