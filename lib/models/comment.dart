class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String authorDisplayName; // Add the display name field
  final String content;
  final DateTime dateTime;

  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorDisplayName,
    required this.content,
    required this.dateTime,
  });
}
