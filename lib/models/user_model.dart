class UserModel {
  final String uid;
  final String name;
  final String email;
  final String goal;
  final String diet;
  final int age;
  final double height;
  final double weight;
  final String activity;
  final int immunityScore;
  final int streak;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.goal = 'Boost Immunity',
    this.diet = 'Omnivore',
    this.age = 25,
    this.height = 165,
    this.weight = 65,
    this.activity = 'Lightly Active',
    this.immunityScore = 78,
    this.streak = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get bmi => weight / ((height / 100) * (height / 100));
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25)   return 'Normal';
    if (bmi < 30)   return 'Overweight';
    return 'Obese';
  }

  Map<String, dynamic> toMap() => {
    'uid':            uid,
    'name':           name,
    'email':          email,
    'goal':           goal,
    'diet':           diet,
    'age':            age,
    'height':         height,
    'weight':         weight,
    'activity':       activity,
    'immunityScore':  immunityScore,
    'streak':         streak,
    'createdAt':      createdAt.toIso8601String(),
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    uid:           map['uid'] ?? '',
    name:          map['name'] ?? '',
    email:         map['email'] ?? '',
    goal:          map['goal'] ?? 'Boost Immunity',
    diet:          map['diet'] ?? 'Omnivore',
    age:           map['age'] ?? 25,
    height:        (map['height'] ?? 165).toDouble(),
    weight:        (map['weight'] ?? 65).toDouble(),
    activity:      map['activity'] ?? 'Lightly Active',
    immunityScore: map['immunityScore'] ?? 78,
    streak:        map['streak'] ?? 1,
    createdAt:     map['createdAt'] != null
        ? DateTime.parse(map['createdAt']) : DateTime.now(),
  );

  UserModel copyWith({
    String? name, String? goal, String? diet,
    int? age, double? height, double? weight,
    String? activity, int? immunityScore, int? streak,
  }) => UserModel(
    uid:           uid,
    name:          name ?? this.name,
    email:         email,
    goal:          goal ?? this.goal,
    diet:          diet ?? this.diet,
    age:           age ?? this.age,
    height:        height ?? this.height,
    weight:        weight ?? this.weight,
    activity:      activity ?? this.activity,
    immunityScore: immunityScore ?? this.immunityScore,
    streak:        streak ?? this.streak,
    createdAt:     createdAt,
  );
}
