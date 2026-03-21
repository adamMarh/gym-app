class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  int likes;
  bool isLiked;
  bool isPinned;
  bool isFlagged;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    this.likes = 0,
    this.isLiked = false,
    this.isPinned = false,
    this.isFlagged = false,
    List<Comment>? comments,
  }) : comments = comments ?? [];

  factory Post.fromJson(Map<String, dynamic> json) {
    final rawComments = json['comments'] as List<dynamic>? ?? [];
    return Post(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatarUrl: (json['userAvatarUrl'] as String?)?.isEmpty == true
          ? null
          : json['userAvatarUrl'] as String?,
      content: json['content'] as String,
      imageUrl: (json['imageUrl'] as String?)?.isEmpty == true
          ? null
          : json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      isFlagged: json['isFlagged'] as bool? ?? false,
      comments: rawComments
          .map((c) => Comment.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
