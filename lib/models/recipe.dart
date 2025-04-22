class Recipe {
  final String id;
  final String name;
  final String? imageUrl; // Make nullable as it might be missing
  final String? description; // Make nullable
  final int? cookingTime; // Make nullable
  final double? rating; // Make nullable
  final List<String>? tags; // Make nullable
  final List<String>? ingredients; // Make nullable
  final List<String>? allergens; // Make nullable

  Recipe({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    this.cookingTime,
    this.rating,
    this.tags,
    this.ingredients,
    this.allergens,
  });

  // Optional: Factory method to create a Recipe from JSON data
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'].toString(),
      name: json['title'] ?? 'No Title',
      imageUrl: json['image'],
      description: json['summary'],
      cookingTime: json['readyInMinutes'],
      rating: (json['spoonacularScore'] as num?)?.toDouble(),
      tags: (json['dishTypes'] as List<dynamic>?)?.cast<String>(),
      ingredients: (json['extendedIngredients'] as List<dynamic>?)?.map((ing) => ing['name'] as String).toList(),
      allergens: (json['diets'] as List<dynamic>?)?.cast<String>(),
      // ... adjust based on the actual JSON structure
    );
  }
}