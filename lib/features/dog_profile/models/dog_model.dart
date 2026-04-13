class Dog {
  final int? id;
  final String name;
  final String breed;
  final DateTime birthDate;
  final String gender; // 'male' or 'female'
  final double weight; // kg
  final String? chipNumber; // 동물등록번호 (15자리)
  final String? profileImageUrl;
  final String userId; // Supabase Auth UUID (String)
  final DateTime createdAt;

  Dog({
    this.id,
    required this.name,
    required this.breed,
    required this.birthDate,
    required this.gender,
    required this.weight,
    this.chipNumber,
    this.profileImageUrl,
    required this.userId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // 나이 계산
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // JSON → Dog 객체 변환 (Supabase snake_case 컬럼명 기준)
  factory Dog.fromJson(Map<String, dynamic> json) {
    return Dog(
      id: json['id'] as int?,
      name: json['name'] as String,
      breed: json['breed'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      gender: json['gender'] as String,
      weight: (json['weight'] as num).toDouble(),
      chipNumber: json['chip_number'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      userId: json['user_id'] as String,
      createdAt: json['i_date'] != null
          ? DateTime.parse(json['i_date'] as String)
          : DateTime.now(),
    );
  }

  // Dog 객체 → JSON 변환 (Supabase insert/update용)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'breed': breed,
      'birth_date': birthDate.toIso8601String(),
      'gender': gender,
      'weight': weight,
      'chip_number': chipNumber,
      'profile_image_url': profileImageUrl,
      'user_id': userId,
    };
  }

  // 복사본 생성
  Dog copyWith({
    int? id,
    String? name,
    String? breed,
    DateTime? birthDate,
    String? gender,
    double? weight,
    String? chipNumber,
    String? profileImageUrl,
    String? userId,
    DateTime? createdAt,
  }) {
    return Dog(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      chipNumber: chipNumber ?? this.chipNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
