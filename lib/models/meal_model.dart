class Ingredient {
  final String name;
  final String amount;
  Ingredient({required this.name, required this.amount});
  Map<String, dynamic> toMap() => {'name': name, 'amount': amount};
  factory Ingredient.fromMap(Map<String, dynamic> m) =>
      Ingredient(name: m['name'], amount: m['amount']);
}

class MealModel {
  final String id;
  final String name;
  final String mealTime;   // breakfast / lunch / snack / dinner
  final String timeLabel;  // "7:30 AM"
  final String emoji;
  final List<Ingredient> ingredients;
  final List<String> boostTags;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;

  MealModel({
    required this.id,
    required this.name,
    required this.mealTime,
    required this.timeLabel,
    required this.emoji,
    required this.ingredients,
    required this.boostTags,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'mealTime': mealTime,
    'timeLabel': timeLabel, 'emoji': emoji,
    'ingredients': ingredients.map((i) => i.toMap()).toList(),
    'boostTags': boostTags,
    'calories': calories, 'protein': protein,
    'carbs': carbs, 'fats': fats,
  };

  factory MealModel.fromMap(Map<String, dynamic> m) => MealModel(
    id: m['id'] ?? '',
    name: m['name'] ?? '',
    mealTime: m['mealTime'] ?? '',
    timeLabel: m['timeLabel'] ?? '',
    emoji: m['emoji'] ?? '🍽️',
    ingredients: (m['ingredients'] as List? ?? [])
        .map((i) => Ingredient.fromMap(i)).toList(),
    boostTags: List<String>.from(m['boostTags'] ?? []),
    calories: m['calories'] ?? 0,
    protein: (m['protein'] ?? 0).toDouble(),
    carbs: (m['carbs'] ?? 0).toDouble(),
    fats: (m['fats'] ?? 0).toDouble(),
  );
}

class DayMealPlan {
  final String day;
  final List<MealModel> meals;
  DayMealPlan({required this.day, required this.meals});

  int get totalCalories => meals.fold(0, (s, m) => s + m.calories);
  double get totalProtein => meals.fold(0.0, (s, m) => s + m.protein);
  double get totalCarbs   => meals.fold(0.0, (s, m) => s + m.carbs);
  double get totalFats    => meals.fold(0.0, (s, m) => s + m.fats);
}

// ── Default weekly plan ────────────────────────────────────────────────────
final List<MealModel> defaultMeals = [
  MealModel(
    id: 'breakfast_1',
    name: 'Spinach & Berry Smoothie Bowl',
    mealTime: 'breakfast',
    timeLabel: '7:30 AM',
    emoji: '🥗',
    ingredients: [
      Ingredient(name: 'Baby spinach', amount: '60g'),
      Ingredient(name: 'Mixed berries (frozen)', amount: '100g'),
      Ingredient(name: 'Banana', amount: '1 medium'),
      Ingredient(name: 'Chia seeds', amount: '1 tbsp'),
      Ingredient(name: 'Coconut yogurt', amount: '80g'),
    ],
    boostTags: ['Vit C +45mg', 'Antioxidants', 'Gut Health'],
    calories: 320, protein: 12, carbs: 58, fats: 7,
  ),
  MealModel(
    id: 'lunch_1',
    name: 'Golden Turmeric & Lentil Soup',
    mealTime: 'lunch',
    timeLabel: '12:30 PM',
    emoji: '🍲',
    ingredients: [
      Ingredient(name: 'Red lentils', amount: '80g'),
      Ingredient(name: 'Turmeric (fresh)', amount: '1 tsp'),
      Ingredient(name: 'Ginger root', amount: '2cm piece'),
      Ingredient(name: 'Tomatoes (chopped)', amount: '150g'),
      Ingredient(name: 'Garlic cloves', amount: '3 cloves'),
    ],
    boostTags: ['Anti-inflammatory', 'Zinc +2mg'],
    calories: 410, protein: 22, carbs: 68, fats: 5,
  ),
  MealModel(
    id: 'snack_1',
    name: 'Walnut & Citrus Mix',
    mealTime: 'snack',
    timeLabel: '4:00 PM',
    emoji: '🥜',
    ingredients: [
      Ingredient(name: 'Walnuts', amount: '30g'),
      Ingredient(name: 'Orange segments', amount: '1 medium'),
      Ingredient(name: 'Pumpkin seeds', amount: '15g'),
    ],
    boostTags: ['Omega-3', 'Vit C +35mg'],
    calories: 220, protein: 7, carbs: 14, fats: 16,
  ),
  MealModel(
    id: 'dinner_1',
    name: 'Salmon with Broccoli & Quinoa',
    mealTime: 'dinner',
    timeLabel: '7:30 PM',
    emoji: '🐟',
    ingredients: [
      Ingredient(name: 'Salmon fillet', amount: '150g'),
      Ingredient(name: 'Broccoli florets', amount: '120g'),
      Ingredient(name: 'Quinoa (cooked)', amount: '80g'),
      Ingredient(name: 'Lemon juice', amount: '1 tbsp'),
      Ingredient(name: 'Olive oil', amount: '1 tsp'),
    ],
    boostTags: ['Vit D +6µg', 'Omega-3 +1.2g', 'Zinc +3mg'],
    calories: 520, protein: 42, carbs: 38, fats: 18,
  ),
];
