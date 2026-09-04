class CaptchaCategory {
  final int id;
  final String categoryName;
  final String image;
  
  CaptchaCategory({
    required this.id,
    required this.categoryName,
    required this.image,
  });

  factory CaptchaCategory.fromJson(Map<String, dynamic> json) {
    return CaptchaCategory(
      id: json['id'],
      categoryName: json['category_name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
