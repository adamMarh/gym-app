import 'package:flutter/foundation.dart';
import '../models/post.dart';

class FeedProvider extends ChangeNotifier {
  final List<Post> _posts = List.from(Post.mockPosts);

  List<Post> get posts {
    final sorted = List<Post>.from(_posts);
    sorted.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }

  void toggleLike(String postId) {
    final post = _posts.firstWhere((p) => p.id == postId);
    if (post.isLiked) {
      post.likes--;
      post.isLiked = false;
    } else {
      post.likes++;
      post.isLiked = true;
    }
    notifyListeners();
  }

  void addPost(Post post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void deletePost(String postId) {
    _posts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }

  void flagPost(String postId) {
    final post = _posts.firstWhere((p) => p.id == postId);
    post.isFlagged = !post.isFlagged;
    notifyListeners();
  }

  void pinPost(String postId) {
    for (final p in _posts) {
      p.isPinned = false;
    }
    final post = _posts.firstWhere((p) => p.id == postId);
    post.isPinned = true;
    notifyListeners();
  }

  void addComment(String postId, Comment comment) {
    final post = _posts.firstWhere((p) => p.id == postId);
    post.comments.add(comment);
    notifyListeners();
  }
}
