class Post {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final String authorId;
  final String authorDisplayName;
  final double rating;
  final Map<String, double> ratings;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.authorId,
    required this.authorDisplayName,
    this.rating = 0.0,
    required this.ratings,
  });
}
