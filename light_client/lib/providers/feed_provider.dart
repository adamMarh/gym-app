import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class FeedProvider extends ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<Post> get posts => List.unmodifiable(_posts);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.instance.get('/feed') as List<dynamic>;
      _posts = data
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Failed to load feed.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId) async {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;

    // Optimistic update
    final post = _posts[idx];
    final wasLiked = post.isLiked;
    post.isLiked = !wasLiked;
    post.likes += wasLiked ? -1 : 1;
    notifyListeners();

    try {
      final json = await ApiService.instance
          .post('/feed/$postId/like') as Map<String, dynamic>;
      // Sync confirmed state from server
      _posts[idx]
        ..isLiked = json['isLiked'] as bool? ?? post.isLiked
        ..likes = (json['likes'] as num?)?.toInt() ?? post.likes;
      notifyListeners();
    } catch (_) {
      // Rollback
      post.isLiked = wasLiked;
      post.likes += wasLiked ? 1 : -1;
      notifyListeners();
    }
  }

  Future<void> addPost(Post post) async {
    try {
      final json = await ApiService.instance.post('/feed', {
        'content': post.content,
        if (post.imageUrl != null) 'imageUrl': post.imageUrl,
      }) as Map<String, dynamic>;
      _posts.insert(0, Post.fromJson(json));
      notifyListeners();
    } catch (_) {
      // Silently ignore
    }
  }

  Future<void> deletePost(String postId) async {
    final removed = _posts.where((p) => p.id == postId).toList();
    _posts.removeWhere((p) => p.id == postId);
    notifyListeners();

    try {
      await ApiService.instance.delete('/feed/$postId');
    } catch (_) {
      _posts.addAll(removed);
      notifyListeners();
    }
  }

  Future<void> flagPost(String postId) async {
    try {
      final json = await ApiService.instance
          .post('/feed/$postId/flag') as Map<String, dynamic>;
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        _posts[idx].isFlagged = json['isFlagged'] as bool? ?? false;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> pinPost(String postId) async {
    try {
      await ApiService.instance.post('/feed/$postId/pin');
      // Unpin all then pin selected, to match server behaviour
      for (final p in _posts) {
        p.isPinned = false;
      }
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        _posts[idx].isPinned = true;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addComment(String postId, Comment comment) async {
    try {
      final json = await ApiService.instance.post('/feed/$postId/comments', {
        'content': comment.content,
      }) as Map<String, dynamic>;
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        _posts[idx].comments.add(Comment.fromJson(json));
        notifyListeners();
      }
    } catch (_) {}
  }

  void clear() {
    _posts = [];
    notifyListeners();
  }
}
