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

  static List<Post> mockPosts = [
    Post(
      id: 'p1',
      userId: 'u1',
      userName: 'Alex Rivera',
      content:
          'NEW PR TODAY 🔥 Hit 150KG on the squat. Consistent training pays off. #CSEE #PRAlert',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 42,
      isLiked: true,
      comments: [
        Comment(
          id: 'cm1',
          userId: 'u2',
          userName: 'Jordan Smith',
          content: 'BEAST MODE 🏆',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
    ),
    Post(
      id: 'p2',
      userId: 'u2',
      userName: 'Jordan Smith',
      content:
          'Morning HIIT class was absolutely brutal today. If you weren\'t sweating, you weren\'t trying. See you tomorrow at 6AM 💪',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      likes: 28,
    ),
    Post(
      id: 'p3',
      userId: 'u3',
      userName: 'Sam Chen',
      content:
          '📢 New boxing classes starting next Monday. Limited spots available — book now in the Classes tab!',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      likes: 67,
      isPinned: true,
    ),
    Post(
      id: 'p4',
      userId: 'u1',
      userName: 'Alex Rivera',
      content:
          'Week 8 of my strength program done. Volume is up 40% from where I started. The grind is real. 📈',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likes: 19,
    ),
  ];
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
}
